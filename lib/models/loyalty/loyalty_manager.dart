import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'loyalty.dart';

/// Gerenciador do programa de fidelidade
class LoyaltyManager extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LoyaltyProgram? _loyaltyProgram;
  List<PointsTransaction> _transactions = [];
  List<Reward> _availableRewards = [];
  List<RewardRedemption> _redemptions = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<DocumentSnapshot>? _programSubscription;
  StreamSubscription<QuerySnapshot>? _transactionsSubscription;

  @override
  void dispose() {
    _programSubscription?.cancel();
    _transactionsSubscription?.cancel();
    super.dispose();
  }

  // Getters
  LoyaltyProgram? get loyaltyProgram => _loyaltyProgram;
  List<PointsTransaction> get transactions => _transactions;
  List<Reward> get availableRewards => _availableRewards;
  List<RewardRedemption> get redemptions => _redemptions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Calcula os ganhos líquidos (pontos ganhos menos estornos)
  int get netEarnedPoints {
    if (_loyaltyProgram == null) return 0;

    // Soma apenas as transações do tipo 'earned' com valores positivos
    final earnedPoints = _transactions
        .where((t) => t.type == PointsTransactionType.earned && t.points > 0)
        .fold<int>(0, (sum, t) => sum + t.points);

    // Soma os estornos (transações 'expired' com pontos negativos relacionados a pedidos)
    final refundedPoints = _transactions
        .where((t) =>
            t.type == PointsTransactionType.expired &&
            t.points < 0 &&
            t.orderId != null)
        .fold<int>(0, (sum, t) => sum + t.points.abs());

    return earnedPoints - refundedPoints;
  }

  /// Carrega programa de fidelidade do usuário
  Future<void> loadLoyaltyProgram() async {
    try {
      _setLoading(true);
      _clearError();

      final user = _auth.currentUser;
      if (user == null) {
        _setError('Usuário não autenticado');
        return;
      }

      final doc =
          await _firestore.collection('loyalty_programs').doc(user.uid).get();

      if (doc.exists) {
        _loyaltyProgram = LoyaltyProgram.fromMap(doc.data()!);
      } else {
        // Criar programa de fidelidade inicial
        await _createLoyaltyProgram(user.uid);
      }

      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar programa de fidelidade: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Cria programa de fidelidade inicial
  Future<void> _createLoyaltyProgram(String userId) async {
    final program = LoyaltyProgram(
      id: _firestore.collection('loyalty_programs').doc().id,
      userId: userId,
      joinedAt: DateTime.now(),
      lastUpdated: DateTime.now(),
    );

    await _firestore
        .collection('loyalty_programs')
        .doc(userId)
        .set(program.toMap());

    _loyaltyProgram = program;
  }

  /// Inicia listener em tempo real para o programa de fidelidade
  void startRealtimeListener() {
    final user = _auth.currentUser;
    if (user == null) return;

    // Listener para programa de fidelidade
    _programSubscription?.cancel();
    _programSubscription = _firestore
        .collection('loyalty_programs')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        _loyaltyProgram = LoyaltyProgram.fromMap(data);
        debugPrint('🔄 Programa de fidelidade atualizado em tempo real');
        debugPrint('   - currentPoints: ${_loyaltyProgram?.currentPoints}');
        debugPrint(
            '   - totalPointsEarned: ${_loyaltyProgram?.totalPointsEarned}');
        debugPrint(
            '   - totalPointsRedeemed: ${_loyaltyProgram?.totalPointsRedeemed}');
        debugPrint('   - Dados brutos do Firestore: $data');
        notifyListeners();
      }
    }, onError: (error) {
      debugPrint('❌ Erro no listener de fidelidade: $error');
    });

    // Listener para transações
    _transactionsSubscription?.cancel();
    _transactionsSubscription = _firestore
        .collection('points_transactions')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      _transactions = snapshot.docs
          .map((doc) => PointsTransaction.fromMap(doc.data()))
          .toList();
      debugPrint(
          '🔄 Transações atualizadas em tempo real: ${_transactions.length}');
      // Log das transações de estorno
      final refunds = _transactions
          .where((t) =>
              t.type == PointsTransactionType.expired &&
              t.points < 0 &&
              t.orderId != null)
          .toList();
      debugPrint('   - Estornos encontrados: ${refunds.length}');
      for (var r in refunds) {
        debugPrint(
            '     * ${r.description}: ${r.points} pontos (Order: ${r.orderId})');
      }
      notifyListeners();
    }, onError: (error) {
      debugPrint('❌ Erro no listener de transações: $error');
    });
  }

  /// Método de debug para recalcular e corrigir pontos baseado nas transações
  Future<void> recalculatePoints() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      debugPrint('🔧 Iniciando recálculo de pontos...');

      // Buscar todas as transações
      final transactionsSnapshot = await _firestore
          .collection('points_transactions')
          .where('userId', isEqualTo: user.uid)
          .get();

      int calculatedPoints = 0;
      int totalEarned = 0;
      int totalRedeemed = 0;

      for (var doc in transactionsSnapshot.docs) {
        final t = PointsTransaction.fromMap(doc.data());

        if (t.type == PointsTransactionType.earned && t.points > 0) {
          calculatedPoints += t.points;
          totalEarned += t.points;
          debugPrint('  ✅ Ganho: +${t.points} (${t.description})');
        } else if (t.type == PointsTransactionType.expired && t.points < 0) {
          calculatedPoints += t.points; // pontos já é negativo
          debugPrint('  ⚠️ Estorno: ${t.points} (${t.description})');
        } else if (t.type == PointsTransactionType.redeemed) {
          calculatedPoints += t.points; // pontos já é negativo
          totalRedeemed += t.points.abs();
          debugPrint('  🎁 Resgatado: ${t.points} (${t.description})');
        }
      }

      // Garantir que não fique negativo
      calculatedPoints = calculatedPoints.clamp(0, double.infinity).toInt();

      debugPrint('📊 Resultado do recálculo:');
      debugPrint('   - Pontos calculados: $calculatedPoints');
      debugPrint('   - Total ganho: $totalEarned');
      debugPrint('   - Total resgatado: $totalRedeemed');

      // Buscar programa atual
      final programDoc =
          await _firestore.collection('loyalty_programs').doc(user.uid).get();

      if (programDoc.exists) {
        final currentProgram = LoyaltyProgram.fromMap(programDoc.data()!);

        debugPrint('📊 Programa atual no Firestore:');
        debugPrint('   - currentPoints: ${currentProgram.currentPoints}');
        debugPrint(
            '   - totalPointsEarned: ${currentProgram.totalPointsEarned}');

        // Atualizar apenas se houver diferença
        if (currentProgram.currentPoints != calculatedPoints ||
            currentProgram.totalPointsEarned != totalEarned) {
          debugPrint('⚠️ DIVERGÊNCIA DETECTADA! Corrigindo...');

          final updatedProgram = currentProgram.copyWith(
            currentPoints: calculatedPoints,
            totalPointsEarned: totalEarned,
            totalPointsRedeemed: totalRedeemed,
            lastUpdated: DateTime.now(),
          );

          final newTier = updatedProgram.calculateTier();
          final programWithTier = (newTier != updatedProgram.currentTier)
              ? updatedProgram.copyWith(currentTier: newTier)
              : updatedProgram;

          await _firestore
              .collection('loyalty_programs')
              .doc(user.uid)
              .set(programWithTier.toMap());

          debugPrint('✅ Pontos corrigidos no Firestore!');
          debugPrint(
              '   - Novos currentPoints: ${programWithTier.currentPoints}');
          debugPrint(
              '   - Novo totalPointsEarned: ${programWithTier.totalPointsEarned}');
        } else {
          debugPrint('✅ Pontos já estão corretos!');
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao recalcular pontos: $e');
    }
  }

  /// Carrega transações de pontos
  Future<void> loadTransactions({int limit = 50}) async {
    try {
      _setLoading(true);
      _clearError();

      final user = _auth.currentUser;
      if (user == null) {
        _setError('Usuário não autenticado');
        return;
      }

      final query = await _firestore
          .collection('points_transactions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      _transactions = query.docs
          .map((doc) => PointsTransaction.fromMap(doc.data()))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar transações: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega recompensas disponíveis
  Future<void> loadAvailableRewards() async {
    try {
      _setLoading(true);
      _clearError();

      final query = await _firestore
          .collection('rewards')
          .where('isActive', isEqualTo: true)
          .orderBy('pointsRequired')
          .get();

      _availableRewards = query.docs
          .map((doc) => Reward.fromMap(doc.data()))
          .where((reward) => reward.isAvailable)
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar recompensas: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega resgates do usuário
  Future<void> loadRedemptions() async {
    try {
      _setLoading(true);
      _clearError();

      final user = _auth.currentUser;
      if (user == null) {
        _setError('Usuário não autenticado');
        return;
      }

      final query = await _firestore
          .collection('reward_redemptions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('redeemedAt', descending: true)
          .get();

      _redemptions = query.docs
          .map((doc) => RewardRedemption.fromMap(doc.data()))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar resgates: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Adiciona pontos ao usuário
  Future<bool> addPoints({
    required int points,
    required String description,
    String? orderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = _auth.currentUser;
      if (user == null) {
        _setError('Usuário não autenticado');
        return false;
      }

      if (_loyaltyProgram == null) {
        await loadLoyaltyProgram();
      }

      if (_loyaltyProgram == null) {
        _setError('Programa de fidelidade não encontrado');
        return false;
      }

      // Criar transação de pontos
      final transaction = PointsTransaction(
        id: _firestore.collection('points_transactions').doc().id,
        userId: user.uid,
        points: points,
        type: PointsTransactionType.earned,
        description: description,
        orderId: orderId,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      // Atualizar programa de fidelidade
      final updatedProgram = _loyaltyProgram!.copyWith(
        currentPoints: _loyaltyProgram!.currentPoints + points,
        totalPointsEarned: _loyaltyProgram!.totalPointsEarned + points,
        lastUpdated: DateTime.now(),
      );

      // Verificar se subiu de tier
      final newTier = updatedProgram.calculateTier();
      final programWithTier = (newTier != updatedProgram.currentTier)
          ? updatedProgram.copyWith(currentTier: newTier)
          : updatedProgram;

      // Salvar no Firestore
      final batch = _firestore.batch();

      batch.set(
        _firestore.collection('points_transactions').doc(transaction.id),
        transaction.toMap(),
      );

      batch.set(
        _firestore.collection('loyalty_programs').doc(user.uid),
        programWithTier.toMap(),
      );

      await batch.commit();

      // Atualizar estado local
      _loyaltyProgram = programWithTier;
      _transactions.insert(0, transaction);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Erro ao adicionar pontos: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Método estático para remover pontos (usado em cancelamentos de pedidos)
  static Future<bool> removePointsStatic({
    required String userId,
    required int points,
    required String description,
    String? orderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Buscar programa de fidelidade atual do Firestore
      final programDoc =
          await firestore.collection('loyalty_programs').doc(userId).get();

      if (!programDoc.exists) {
        debugPrint('❌ Programa de fidelidade não encontrado');
        return false;
      }

      final program = LoyaltyProgram.fromMap(programDoc.data()!);

      // Criar transação de pontos negativa
      final transaction = PointsTransaction(
        id: firestore.collection('points_transactions').doc().id,
        userId: userId,
        points: -points,
        type: PointsTransactionType.expired,
        description: description,
        orderId: orderId,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      // Calcular novos pontos (não pode ficar negativo)
      final newPoints =
          (program.currentPoints - points).clamp(0, double.infinity).toInt();

      debugPrint('🔄 Removendo pontos (estático):');
      debugPrint('  - Pontos atuais: ${program.currentPoints}');
      debugPrint('  - Pontos a remover: $points');
      debugPrint('  - Novos pontos: $newPoints');

      // Atualizar programa de fidelidade
      final updatedProgram = program.copyWith(
        currentPoints: newPoints,
        lastUpdated: DateTime.now(),
      );

      // Recalcular tier
      final newTier = updatedProgram.calculateTier();
      final programWithTier = (newTier != updatedProgram.currentTier)
          ? updatedProgram.copyWith(currentTier: newTier)
          : updatedProgram;

      // Salvar no Firestore
      final batch = firestore.batch();

      batch.set(
        firestore.collection('points_transactions').doc(transaction.id),
        transaction.toMap(),
      );

      batch.set(
        firestore.collection('loyalty_programs').doc(userId),
        programWithTier.toMap(),
      );

      await batch.commit();

      debugPrint('✅ Pontos removidos com sucesso (estático)');
      debugPrint('   - Pontos finais: ${programWithTier.currentPoints}');

      return true;
    } catch (e) {
      debugPrint('❌ Erro ao remover pontos (estático): $e');
      return false;
    }
  }

  /// Remove pontos do usuário (usado em cancelamentos)
  Future<bool> removePoints({
    required int points,
    required String description,
    String? orderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = _auth.currentUser;
      if (user == null) {
        _setError('Usuário não autenticado');
        return false;
      }

      if (_loyaltyProgram == null) {
        await loadLoyaltyProgram();
      }

      if (_loyaltyProgram == null) {
        _setError('Programa de fidelidade não encontrado');
        return false;
      }

      // Criar transação de pontos negativa
      final transaction = PointsTransaction(
        id: _firestore.collection('points_transactions').doc().id,
        userId: user.uid,
        points: -points, // Pontos negativos para remoção
        type: PointsTransactionType.expired, // Usar tipo expired para remoções
        description: description,
        orderId: orderId,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      // Calcular novos pontos (não pode ficar negativo)
      final newPoints = (_loyaltyProgram!.currentPoints - points)
          .clamp(0, double.infinity)
          .toInt();

      debugPrint('🔄 Removendo pontos:');
      debugPrint('  - Pontos atuais: ${_loyaltyProgram!.currentPoints}');
      debugPrint('  - Pontos a remover: $points');
      debugPrint('  - Novos pontos: $newPoints');
      debugPrint('  - Tier atual: ${_loyaltyProgram!.currentTier.name}');

      // Atualizar programa de fidelidade (não altera totalPointsEarned, pois ele representa ganhos brutos)
      final updatedProgram = _loyaltyProgram!.copyWith(
        currentPoints: newPoints,
        lastUpdated: DateTime.now(),
      );

      // Recalcular tier com os novos pontos
      final newTier = updatedProgram.calculateTier();
      debugPrint('  - Novo tier calculado: ${newTier.name}');

      final programWithTier = (newTier != updatedProgram.currentTier)
          ? updatedProgram.copyWith(currentTier: newTier)
          : updatedProgram;

      // Salvar no Firestore
      final batch = _firestore.batch();

      batch.set(
        _firestore.collection('points_transactions').doc(transaction.id),
        transaction.toMap(),
      );

      batch.set(
        _firestore.collection('loyalty_programs').doc(user.uid),
        programWithTier.toMap(),
      );

      await batch.commit();

      // Atualizar estado local
      _loyaltyProgram = programWithTier;
      _transactions.insert(0, transaction);

      debugPrint('✅ Pontos removidos e programa atualizado no Firestore');
      debugPrint('   - Pontos finais: ${programWithTier.currentPoints}');
      debugPrint('   - Tier final: ${programWithTier.currentTier.name}');

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('❌ Erro ao remover pontos: $e');
      _setError('Erro ao remover pontos: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Resgata recompensa
  Future<bool> redeemReward(String rewardId) async {
    try {
      _setLoading(true);
      _clearError();

      final user = _auth.currentUser;
      if (user == null) {
        _setError('Usuário não autenticado');
        return false;
      }

      if (_loyaltyProgram == null) {
        await loadLoyaltyProgram();
      }

      if (_loyaltyProgram == null) {
        _setError('Programa de fidelidade não encontrado');
        return false;
      }

      // Buscar recompensa
      final rewardDoc =
          await _firestore.collection('rewards').doc(rewardId).get();

      if (!rewardDoc.exists) {
        _setError('Recompensa não encontrada');
        return false;
      }

      final reward = Reward.fromMap(rewardDoc.data()!);

      // Verificar se tem pontos suficientes
      if (_loyaltyProgram!.currentPoints < reward.pointsRequired) {
        _setError('Pontos insuficientes');
        return false;
      }

      // Verificar se a recompensa está disponível
      if (!reward.isAvailable) {
        _setError('Recompensa não disponível');
        return false;
      }

      // Criar resgate
      final redemption = RewardRedemption(
        id: _firestore.collection('reward_redemptions').doc().id,
        userId: user.uid,
        rewardId: rewardId,
        rewardName: reward.name,
        pointsUsed: reward.pointsRequired,
        redeemedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );

      // Atualizar programa de fidelidade
      final updatedProgram = _loyaltyProgram!.copyWith(
        currentPoints: _loyaltyProgram!.currentPoints - reward.pointsRequired,
        totalPointsRedeemed:
            _loyaltyProgram!.totalPointsRedeemed + reward.pointsRequired,
        lastUpdated: DateTime.now(),
      );

      // Criar transação de resgate
      final transaction = PointsTransaction(
        id: _firestore.collection('points_transactions').doc().id,
        userId: user.uid,
        points: -reward.pointsRequired,
        type: PointsTransactionType.redeemed,
        description: 'Resgate: ${reward.name}',
        rewardId: rewardId,
        createdAt: DateTime.now(),
      );

      // Salvar no Firestore
      final batch = _firestore.batch();

      batch.set(
        _firestore.collection('reward_redemptions').doc(redemption.id),
        redemption.toMap(),
      );

      batch.set(
        _firestore.collection('points_transactions').doc(transaction.id),
        transaction.toMap(),
      );

      batch.set(
        _firestore.collection('loyalty_programs').doc(user.uid),
        updatedProgram.toMap(),
      );

      // Atualizar contador de resgates da recompensa
      batch.update(
        _firestore.collection('rewards').doc(rewardId),
        {'redeemedCount': FieldValue.increment(1)},
      );

      await batch.commit();

      // Atualizar estado local
      _loyaltyProgram = updatedProgram;
      _transactions.insert(0, transaction);
      _redemptions.insert(0, redemption);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Erro ao resgatar recompensa: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Usa resgate de recompensa
  Future<bool> useRedemption(String redemptionId, {String? orderId}) async {
    try {
      _setLoading(true);
      _clearError();

      final redemptionDoc = await _firestore
          .collection('reward_redemptions')
          .doc(redemptionId)
          .get();

      if (!redemptionDoc.exists) {
        _setError('Resgate não encontrado');
        return false;
      }

      final redemption = RewardRedemption.fromMap(redemptionDoc.data()!);

      if (redemption.status != RewardRedemptionStatus.active) {
        _setError('Resgate não está ativo');
        return false;
      }

      if (redemption.hasExpired) {
        _setError('Resgate expirado');
        return false;
      }

      // Atualizar resgate
      final updatedRedemption = RewardRedemption(
        id: redemption.id,
        userId: redemption.userId,
        rewardId: redemption.rewardId,
        rewardName: redemption.rewardName,
        pointsUsed: redemption.pointsUsed,
        orderId: orderId,
        couponCode: _generateCouponCode(),
        status: RewardRedemptionStatus.used,
        redeemedAt: redemption.redeemedAt,
        usedAt: DateTime.now(),
        expiresAt: redemption.expiresAt,
        metadata: redemption.metadata,
      );

      await _firestore
          .collection('reward_redemptions')
          .doc(redemptionId)
          .update(updatedRedemption.toMap());

      // Atualizar estado local
      final index = _redemptions.indexWhere((r) => r.id == redemptionId);
      if (index != -1) {
        _redemptions[index] = updatedRedemption;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Erro ao usar resgate: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Gera código de cupom
  String _generateCouponCode() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return 'LOYALTY${random.toString().substring(8)}';
  }

  /// Calcula pontos baseado no valor da compra
  int calculatePointsFromPurchase(double purchaseValue, LoyaltyTier tier) {
    double multiplier;
    switch (tier) {
      case LoyaltyTier.bronze:
        multiplier = 1.0;
        break;
      case LoyaltyTier.silver:
        multiplier = 1.2;
        break;
      case LoyaltyTier.gold:
        multiplier = 1.5;
        break;
      case LoyaltyTier.platinum:
        multiplier = 2.0;
        break;
    }

    return (purchaseValue * multiplier).round();
  }

  /// Verifica se pode resgatar recompensa
  bool canRedeemReward(Reward reward) {
    if (_loyaltyProgram == null) return false;
    if (!reward.isAvailable) return false;
    return _loyaltyProgram!.currentPoints >= reward.pointsRequired;
  }

  /// Processa indicação de amigo após primeira compra
  Future<bool> processReferral({
    required String referredUserId,
    required String referrerUserId,
    required String orderId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Verificar se o indicado já completou a primeira compra
      final referredUserDoc =
          await _firestore.collection('users').doc(referredUserId).get();

      if (!referredUserDoc.exists) {
        _setError('Usuário indicado não encontrado');
        return false;
      }

      final userData = referredUserDoc.data()!;
      final hasCompletedFirstPurchase =
          userData['hasCompletedFirstPurchase'] as bool? ?? false;

      // Se já completou a primeira compra antes, não dá pontos
      if (hasCompletedFirstPurchase) {
        debugPrint('✅ Usuário já tinha completado primeira compra antes');
        return true;
      }

      // Marcar que completou a primeira compra
      await _firestore
          .collection('users')
          .doc(referredUserId)
          .update({'hasCompletedFirstPurchase': true});

      // Pontos para quem foi indicado (bônus de boas-vindas)
      const referredBonusPoints = 100;
      await _addPointsToUser(
        userId: referredUserId,
        points: referredBonusPoints,
        description: 'Bônus de boas-vindas - Primeira compra',
        orderId: orderId,
      );

      // Pontos para quem indicou (recompensa por indicação bem-sucedida)
      const referrerBonusPoints = 200;
      await _addPointsToUser(
        userId: referrerUserId,
        points: referrerBonusPoints,
        description: 'Bônus por indicação de amigo',
        metadata: {
          'referredUserId': referredUserId,
          'orderId': orderId,
        },
      );

      debugPrint(
          '✅ Indicação processada: $referredBonusPoints pts para indicado, $referrerBonusPoints pts para indicador');
      return true;
    } catch (e) {
      _setError('Erro ao processar indicação: $e');
      debugPrint('❌ Erro ao processar indicação: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Adiciona pontos para um usuário específico
  Future<void> _addPointsToUser({
    required String userId,
    required int points,
    required String description,
    String? orderId,
    Map<String, dynamic>? metadata,
  }) async {
    // Criar transação de pontos
    final transaction = PointsTransaction(
      id: _firestore.collection('points_transactions').doc().id,
      userId: userId,
      points: points,
      type: PointsTransactionType.earned,
      description: description,
      orderId: orderId,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    // Buscar ou criar programa de fidelidade do usuário
    final programDoc =
        await _firestore.collection('loyalty_programs').doc(userId).get();

    LoyaltyProgram program;
    if (programDoc.exists) {
      program = LoyaltyProgram.fromMap(programDoc.data()!);
    } else {
      program = LoyaltyProgram(
        id: _firestore.collection('loyalty_programs').doc().id,
        userId: userId,
        joinedAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
    }

    // Atualizar programa com novos pontos
    final updatedProgram = program.copyWith(
      currentPoints: program.currentPoints + points,
      totalPointsEarned: program.totalPointsEarned + points,
      lastUpdated: DateTime.now(),
    );

    // Verificar se subiu de tier
    final newTier = updatedProgram.calculateTier();
    final programWithTier = (newTier != updatedProgram.currentTier)
        ? updatedProgram.copyWith(currentTier: newTier)
        : updatedProgram;

    // Salvar no Firestore
    final batch = _firestore.batch();

    batch.set(
      _firestore.collection('points_transactions').doc(transaction.id),
      transaction.toMap(),
    );

    batch.set(
      _firestore.collection('loyalty_programs').doc(userId),
      programWithTier.toMap(),
    );

    await batch.commit();
  }

  /// Gera código de indicação único para o usuário
  String generateReferralCode(String userId) {
    // Usa os primeiros 6 caracteres do userId + timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final userPart = userId.length >= 6 ? userId.substring(0, 6) : userId;
    return '${userPart.toUpperCase()}${timestamp.substring(timestamp.length - 4)}';
  }

  /// Valida código de indicação
  Future<String?> validateReferralCode(String referralCode) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('referralCode', isEqualTo: referralCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null; // Código inválido
      }

      return query.docs.first.id; // Retorna ID do usuário que indicou
    } catch (e) {
      debugPrint('Erro ao validar código de indicação: $e');
      return null;
    }
  }

  /// Limpa dados
  void clear() {
    _loyaltyProgram = null;
    _transactions.clear();
    _availableRewards.clear();
    _redemptions.clear();
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
