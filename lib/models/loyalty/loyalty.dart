import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de programa de fidelidade
class LoyaltyProgram {
  final String id;
  final String userId;
  final int currentPoints;
  final int totalPointsEarned;
  final int totalPointsRedeemed;
  final LoyaltyTier currentTier;
  final DateTime joinedAt;
  final DateTime lastUpdated;
  final Map<String, dynamic>? metadata;

  LoyaltyProgram({
    required this.id,
    required this.userId,
    this.currentPoints = 0,
    this.totalPointsEarned = 0,
    this.totalPointsRedeemed = 0,
    this.currentTier = LoyaltyTier.bronze,
    required this.joinedAt,
    required this.lastUpdated,
    this.metadata,
  });

  /// Converte LoyaltyProgram para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'currentPoints': currentPoints,
      'totalPointsEarned': totalPointsEarned,
      'totalPointsRedeemed': totalPointsRedeemed,
      'currentTier': currentTier.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'metadata': metadata,
    };
  }

  /// Cria LoyaltyProgram a partir de Map (Firestore)
  factory LoyaltyProgram.fromMap(Map<String, dynamic> map) {
    return LoyaltyProgram(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      currentPoints: map['currentPoints'] ?? 0,
      totalPointsEarned: map['totalPointsEarned'] ?? 0,
      totalPointsRedeemed: map['totalPointsRedeemed'] ?? 0,
      currentTier: LoyaltyTier.values.firstWhere(
        (e) => e.name == map['currentTier'],
        orElse: () => LoyaltyTier.bronze,
      ),
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated:
          (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: map['metadata'],
    );
  }

  /// Cria cópia do LoyaltyProgram com campos alterados
  LoyaltyProgram copyWith({
    String? id,
    String? userId,
    int? currentPoints,
    int? totalPointsEarned,
    int? totalPointsRedeemed,
    LoyaltyTier? currentTier,
    DateTime? joinedAt,
    DateTime? lastUpdated,
    Map<String, dynamic>? metadata,
  }) {
    return LoyaltyProgram(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currentPoints: currentPoints ?? this.currentPoints,
      totalPointsEarned: totalPointsEarned ?? this.totalPointsEarned,
      totalPointsRedeemed: totalPointsRedeemed ?? this.totalPointsRedeemed,
      currentTier: currentTier ?? this.currentTier,
      joinedAt: joinedAt ?? this.joinedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Calcula tier baseado nos pontos
  LoyaltyTier calculateTier() {
    if (currentPoints >= 10000) return LoyaltyTier.platinum;
    if (currentPoints >= 5000) return LoyaltyTier.gold;
    if (currentPoints >= 2000) return LoyaltyTier.silver;
    return LoyaltyTier.bronze;
  }

  /// Verifica se pode subir de tier
  bool get canUpgradeTier {
    final newTier = calculateTier();
    return newTier.index > currentTier.index;
  }

  /// Retorna pontos necessários para próximo tier
  int get pointsToNextTier {
    int points;
    switch (currentTier) {
      case LoyaltyTier.bronze:
        points = 2000 - currentPoints;
        break;
      case LoyaltyTier.silver:
        points = 5000 - currentPoints;
        break;
      case LoyaltyTier.gold:
        points = 10000 - currentPoints;
        break;
      case LoyaltyTier.platinum:
        return 0; // Já no tier máximo
    }
    return points > 0 ? points : 0;
  }

  /// Retorna benefícios do tier atual
  List<String> get currentTierBenefits {
    return _getTierBenefits(currentTier);
  }

  /// Retorna benefícios do próximo tier
  List<String> get nextTierBenefits {
    final nextTier = _getNextTier();
    return nextTier != null ? _getTierBenefits(nextTier) : [];
  }

  LoyaltyTier? _getNextTier() {
    switch (currentTier) {
      case LoyaltyTier.bronze:
        return LoyaltyTier.silver;
      case LoyaltyTier.silver:
        return LoyaltyTier.gold;
      case LoyaltyTier.gold:
        return LoyaltyTier.platinum;
      case LoyaltyTier.platinum:
        return null;
    }
  }

  List<String> _getTierBenefits(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return [
          '1 ponto por R\$ 1,00 gasto',
          'Desconto de 5% em produtos selecionados',
          'Frete grátis em compras acima de R\$ 100',
        ];
      case LoyaltyTier.silver:
        return [
          '1,2 pontos por R\$ 1,00 gasto',
          'Desconto de 10% em produtos selecionados',
          'Frete grátis em compras acima de R\$ 80',
          'Acesso antecipado a promoções',
        ];
      case LoyaltyTier.gold:
        return [
          '1,5 pontos por R\$ 1,00 gasto',
          'Desconto de 15% em produtos selecionados',
          'Frete grátis em compras acima de R\$ 60',
          'Acesso antecipado a promoções',
          'Suporte prioritário',
        ];
      case LoyaltyTier.platinum:
        return [
          '2 pontos por R\$ 1,00 gasto',
          'Desconto de 20% em produtos selecionados',
          'Frete grátis em todas as compras',
          'Acesso antecipado a promoções',
          'Suporte prioritário',
          'Produtos exclusivos',
        ];
    }
  }

  @override
  String toString() {
    return 'LoyaltyProgram(userId: $userId, points: $currentPoints, tier: $currentTier)';
  }
}

/// Tiers de fidelidade
enum LoyaltyTier {
  bronze,
  silver,
  gold,
  platinum,
}

/// Modelo de transação de pontos
class PointsTransaction {
  final String id;
  final String userId;
  final int points;
  final PointsTransactionType type;
  final String description;
  final String? orderId;
  final String? rewardId;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isExpired;
  final Map<String, dynamic>? metadata;

  PointsTransaction({
    required this.id,
    required this.userId,
    required this.points,
    required this.type,
    required this.description,
    this.orderId,
    this.rewardId,
    required this.createdAt,
    this.expiresAt,
    this.isExpired = false,
    this.metadata,
  });

  /// Converte PointsTransaction para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'points': points,
      'type': type.name,
      'description': description,
      'orderId': orderId,
      'rewardId': rewardId,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'isExpired': isExpired,
      'metadata': metadata,
    };
  }

  /// Cria PointsTransaction a partir de Map (Firestore)
  factory PointsTransaction.fromMap(Map<String, dynamic> map) {
    return PointsTransaction(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      points: map['points'] ?? 0,
      type: PointsTransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PointsTransactionType.earned,
      ),
      description: map['description'] ?? '',
      orderId: map['orderId'],
      rewardId: map['rewardId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
      isExpired: map['isExpired'] ?? false,
      metadata: map['metadata'],
    );
  }

  /// Verifica se a transação expirou
  bool get hasExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Retorna cor da transação baseada no tipo
  String get colorType {
    switch (type) {
      case PointsTransactionType.earned:
        return 'success';
      case PointsTransactionType.redeemed:
        return 'error';
      case PointsTransactionType.expired:
        return 'warning';
      case PointsTransactionType.adjusted:
        return 'info';
    }
  }

  @override
  String toString() {
    return 'PointsTransaction(id: $id, points: $points, type: $type)';
  }
}

/// Tipos de transação de pontos
enum PointsTransactionType {
  earned, // Pontos ganhos
  redeemed, // Pontos resgatados
  expired, // Pontos expirados
  adjusted, // Ajuste manual
}

/// Modelo de recompensa
class Reward {
  final String id;
  final String name;
  final String description;
  final String? image;
  final int pointsRequired;
  final RewardType type;
  final double? discountValue;
  final String? discountType;
  final bool isActive;
  final int stock;
  final int redeemedCount;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    required this.pointsRequired,
    required this.type,
    this.discountValue,
    this.discountType,
    this.isActive = true,
    this.stock = -1, // -1 = ilimitado
    this.redeemedCount = 0,
    required this.createdAt,
    this.expiresAt,
    this.metadata,
  });

  /// Converte Reward para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'pointsRequired': pointsRequired,
      'type': type.name,
      'discountValue': discountValue,
      'discountType': discountType,
      'isActive': isActive,
      'stock': stock,
      'redeemedCount': redeemedCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'metadata': metadata,
    };
  }

  /// Cria Reward a partir de Map (Firestore)
  factory Reward.fromMap(Map<String, dynamic> map) {
    return Reward(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      image: map['image'],
      pointsRequired: map['pointsRequired'] ?? 0,
      type: RewardType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => RewardType.discount,
      ),
      discountValue: map['discountValue']?.toDouble(),
      discountType: map['discountType'],
      isActive: map['isActive'] ?? true,
      stock: map['stock'] ?? -1,
      redeemedCount: map['redeemedCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
      metadata: map['metadata'],
    );
  }

  /// Verifica se a recompensa está disponível
  bool get isAvailable {
    if (!isActive) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    if (stock > 0 && redeemedCount >= stock) return false;
    return true;
  }

  /// Retorna quantidade restante em estoque
  int get remainingStock {
    if (stock == -1) return -1; // Ilimitado
    return stock - redeemedCount;
  }

  /// Retorna texto do valor do desconto
  String get discountText {
    if (discountValue == null) return '';

    switch (type) {
      case RewardType.discount:
        if (discountType == 'percentage') {
          return '${discountValue!.toInt()}% de desconto';
        } else {
          return 'R\$ ${discountValue!.toStringAsFixed(2)} de desconto';
        }
      case RewardType.freeShipping:
        return 'Frete grátis';
      case RewardType.product:
        return 'Produto grátis';
      case RewardType.points:
        return '${discountValue!.toInt()} pontos extras';
    }
  }

  @override
  String toString() {
    return 'Reward(id: $id, name: $name, pointsRequired: $pointsRequired)';
  }
}

/// Tipos de recompensa
enum RewardType {
  discount, // Desconto
  freeShipping, // Frete grátis
  product, // Produto grátis
  points, // Pontos extras
}

/// Modelo de resgate de recompensa
class RewardRedemption {
  final String id;
  final String userId;
  final String rewardId;
  final String rewardName;
  final int pointsUsed;
  final String? orderId;
  final String? couponCode;
  final RewardRedemptionStatus status;
  final DateTime redeemedAt;
  final DateTime? usedAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;

  RewardRedemption({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.rewardName,
    required this.pointsUsed,
    this.orderId,
    this.couponCode,
    this.status = RewardRedemptionStatus.active,
    required this.redeemedAt,
    this.usedAt,
    this.expiresAt,
    this.metadata,
  });

  /// Converte RewardRedemption para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'rewardId': rewardId,
      'rewardName': rewardName,
      'pointsUsed': pointsUsed,
      'orderId': orderId,
      'couponCode': couponCode,
      'status': status.name,
      'redeemedAt': Timestamp.fromDate(redeemedAt),
      'usedAt': usedAt != null ? Timestamp.fromDate(usedAt!) : null,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'metadata': metadata,
    };
  }

  /// Cria RewardRedemption a partir de Map (Firestore)
  factory RewardRedemption.fromMap(Map<String, dynamic> map) {
    return RewardRedemption(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      rewardId: map['rewardId'] ?? '',
      rewardName: map['rewardName'] ?? '',
      pointsUsed: map['pointsUsed'] ?? 0,
      orderId: map['orderId'],
      couponCode: map['couponCode'],
      status: RewardRedemptionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RewardRedemptionStatus.active,
      ),
      redeemedAt: (map['redeemedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      usedAt: (map['usedAt'] as Timestamp?)?.toDate(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
      metadata: map['metadata'],
    );
  }

  /// Verifica se o resgate expirou
  bool get hasExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Retorna cor do status
  String get statusColor {
    switch (status) {
      case RewardRedemptionStatus.active:
        return 'success';
      case RewardRedemptionStatus.used:
        return 'info';
      case RewardRedemptionStatus.expired:
        return 'warning';
      case RewardRedemptionStatus.cancelled:
        return 'error';
    }
  }

  @override
  String toString() {
    return 'RewardRedemption(id: $id, rewardName: $rewardName, status: $status)';
  }
}

/// Status do resgate de recompensa
enum RewardRedemptionStatus {
  active, // Ativo
  used, // Usado
  expired, // Expirado
  cancelled, // Cancelado
}
