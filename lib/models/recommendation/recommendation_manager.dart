import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'recommendation.dart';

/// Gerenciador de recomendações personalizadas
class RecommendationManager extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Recommendation> _recommendations = [];
  UserProfile? _userProfile;
  RecommendationStats? _stats;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Recommendation> get recommendations => _recommendations;
  UserProfile? get userProfile => _userProfile;
  RecommendationStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carrega recomendações do usuário
  Future<void> loadUserRecommendations({int limit = 20}) async {
    try {
      _setLoading(true);
      _clearError();

      final user = _auth.currentUser;
      if (user == null) {
        _setError('Usuário não autenticado');
        return;
      }

      final query = await _firestore
          .collection('recommendations')
          .where('userId', isEqualTo: user.uid)
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .orderBy('expiresAt')
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      _recommendations = query.docs
          .map((doc) => Recommendation.fromMap(doc.data()))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar recomendações: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega perfil do usuário
  Future<void> loadUserProfile() async {
    try {
      _setLoading(true);
      _clearError();

      final user = _auth.currentUser;
      if (user == null) {
        _setError('Usuário não autenticado');
        return;
      }

      final doc = await _firestore
          .collection('user_profiles')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        _userProfile = UserProfile.fromMap(doc.data()!);
      } else {
        // Criar perfil inicial
        _userProfile = UserProfile(
          userId: user.uid,
          lastUpdated: DateTime.now(),
        );
        await _saveUserProfile();
      }

      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar perfil: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Gera recomendações personalizadas
  Future<void> generateRecommendations() async {
    try {
      _setLoading(true);
      _clearError();

      final user = _auth.currentUser;
      if (user == null) {
        _setError('Usuário não autenticado');
        return;
      }

      if (_userProfile == null) {
        await loadUserProfile();
      }

      if (_userProfile == null) {
        _setError('Perfil do usuário não encontrado');
        return;
      }

      // Gerar diferentes tipos de recomendações
      await _generateSimilarRecommendations();
      await _generatePopularRecommendations();
      await _generateCategoryRecommendations();
      await _generatePersonalizedRecommendations();

      // Carregar recomendações atualizadas
      await loadUserRecommendations();
    } catch (e) {
      _setError('Erro ao gerar recomendações: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Gera recomendações de produtos similares
  Future<void> _generateSimilarRecommendations() async {
    if (_userProfile == null) return;

    final viewedProducts = _userProfile!.viewedProducts;
    if (viewedProducts.isEmpty) return;

    // Buscar produtos similares baseados nos visualizados
    for (final productId in viewedProducts.take(3)) {
      final similarProducts = await _findSimilarProducts(productId);
      
      for (final product in similarProducts) {
        await _createRecommendation(
          productId: product['id'],
          productName: product['name'],
          productImage: product['image'],
          price: product['price'].toDouble(),
          category: product['category'],
          subcategory: product['subcategory'],
          score: product['similarity'].toDouble(),
          reason: 'Similar a ${product['originalName']}',
          type: RecommendationType.similar,
        );
      }
    }
  }

  /// Gera recomendações de produtos populares
  Future<void> _generatePopularRecommendations() async {
    final popularProducts = await _getPopularProducts();
    
    for (final product in popularProducts) {
      await _createRecommendation(
        productId: product['id'],
        productName: product['name'],
        productImage: product['image'],
        price: product['price'].toDouble(),
        category: product['category'],
        subcategory: product['subcategory'],
        score: product['popularity'].toDouble(),
        reason: 'Mais populares',
        type: RecommendationType.popular,
      );
    }
  }

  /// Gera recomendações por categoria
  Future<void> _generateCategoryRecommendations() async {
    if (_userProfile == null) return;

    final favoriteCategories = _userProfile!.favoriteCategories;
    if (favoriteCategories.isEmpty) return;

    for (final category in favoriteCategories.take(2)) {
      final categoryProducts = await _getCategoryProducts(category);
      
      for (final product in categoryProducts) {
        await _createRecommendation(
          productId: product['id'],
          productName: product['name'],
          productImage: product['image'],
          price: product['price'].toDouble(),
          category: product['category'],
          subcategory: product['subcategory'],
          score: 0.7, // Score médio para categoria
          reason: 'Nesta categoria',
          type: RecommendationType.category,
        );
      }
    }
  }

  /// Gera recomendações personalizadas
  Future<void> _generatePersonalizedRecommendations() async {
    if (_userProfile == null) return;

    // Buscar produtos baseados no perfil do usuário
    final personalizedProducts = await _getPersonalizedProducts(_userProfile!);
    
    for (final product in personalizedProducts) {
      await _createRecommendation(
        productId: product['id'],
        productName: product['name'],
        productImage: product['image'],
        price: product['price'].toDouble(),
        category: product['category'],
        subcategory: product['subcategory'],
        score: product['personalizationScore'].toDouble(),
        reason: 'Para você',
        type: RecommendationType.personalized,
      );
    }
  }

  /// Cria uma recomendação
  Future<void> _createRecommendation({
    required String productId,
    required String productName,
    String? productImage,
    required double price,
    required String category,
    required String subcategory,
    required double score,
    required String reason,
    required RecommendationType type,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Verificar se já existe recomendação para este produto
    final existingQuery = await _firestore
        .collection('recommendations')
        .where('userId', isEqualTo: user.uid)
        .where('productId', isEqualTo: productId)
        .where('type', isEqualTo: type.name)
        .limit(1)
        .get();

    if (existingQuery.docs.isNotEmpty) return;

    final recommendation = Recommendation(
      id: _firestore.collection('recommendations').doc().id,
      userId: user.uid,
      productId: productId,
      productName: productName,
      productImage: productImage,
      price: price,
      category: category,
      subcategory: subcategory,
      score: score,
      reason: reason,
      type: type,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );

    await _firestore
        .collection('recommendations')
        .doc(recommendation.id)
        .set(recommendation.toMap());
  }

  /// Busca produtos similares
  Future<List<Map<String, dynamic>>> _findSimilarProducts(String productId) async {
    // Implementação simplificada - buscar produtos da mesma categoria
    final query = await _firestore
        .collection('products')
        .where('category', isEqualTo: 'categoria_exemplo') // Substituir por lógica real
        .limit(5)
        .get();

    return query.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'image': data['image'],
        'price': data['price'] ?? 0.0,
        'category': data['category'] ?? '',
        'subcategory': data['subcategory'] ?? '',
        'similarity': 0.8, // Score de similaridade
        'originalName': 'Produto Original',
      };
    }).toList();
  }

  /// Busca produtos populares
  Future<List<Map<String, dynamic>>> _getPopularProducts() async {
    final query = await _firestore
        .collection('products')
        .orderBy('views', descending: true)
        .limit(10)
        .get();

    return query.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'image': data['image'],
        'price': data['price'] ?? 0.0,
        'category': data['category'] ?? '',
        'subcategory': data['subcategory'] ?? '',
        'popularity': 0.9, // Score de popularidade
      };
    }).toList();
  }

  /// Busca produtos por categoria
  Future<List<Map<String, dynamic>>> _getCategoryProducts(String category) async {
    final query = await _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .limit(5)
        .get();

    return query.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'image': data['image'],
        'price': data['price'] ?? 0.0,
        'category': data['category'] ?? '',
        'subcategory': data['subcategory'] ?? '',
      };
    }).toList();
  }

  /// Busca produtos personalizados
  Future<List<Map<String, dynamic>>> _getPersonalizedProducts(UserProfile profile) async {
    // Implementação simplificada - buscar produtos baseados nas preferências
    final query = await _firestore
        .collection('products')
        .limit(10)
        .get();

    return query.docs.map((doc) {
      final data = doc.data();
      final category = data['category'] ?? '';
      final personalizationScore = profile.getCategoryScore(category);
      
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'image': data['image'],
        'price': data['price'] ?? 0.0,
        'category': category,
        'subcategory': data['subcategory'] ?? '',
        'personalizationScore': personalizationScore > 0 ? personalizationScore : 0.5,
      };
    }).where((product) => product['personalizationScore'] > 0.3).toList();
  }

  /// Atualiza perfil do usuário
  Future<void> updateUserProfile({
    String? category,
    String? subcategory,
    double? price,
    String? productId,
    bool isPurchase = false,
  }) async {
    if (_userProfile == null) return;

    final updatedProfile = _userProfile!.copyWith(
      favoriteCategories: category != null 
          ? [..._userProfile!.favoriteCategories, category]
          : _userProfile!.favoriteCategories,
      favoriteSubcategories: subcategory != null
          ? [..._userProfile!.favoriteSubcategories, subcategory]
          : _userProfile!.favoriteSubcategories,
      averagePriceRange: price != null
          ? (_userProfile!.averagePriceRange + price) / 2
          : _userProfile!.averagePriceRange,
      viewedProducts: productId != null && !isPurchase
          ? [..._userProfile!.viewedProducts, productId]
          : _userProfile!.viewedProducts,
      purchasedProducts: productId != null && isPurchase
          ? [..._userProfile!.purchasedProducts, productId]
          : _userProfile!.purchasedProducts,
      lastUpdated: DateTime.now(),
    );

    _userProfile = updatedProfile;
    await _saveUserProfile();
    notifyListeners();
  }

  /// Salva perfil do usuário
  Future<void> _saveUserProfile() async {
    if (_userProfile == null) return;

    await _firestore
        .collection('user_profiles')
        .doc(_userProfile!.userId)
        .set(_userProfile!.toMap());
  }

  /// Marca recomendação como visualizada
  Future<void> markAsViewed(String recommendationId) async {
    try {
      await _firestore
          .collection('recommendations')
          .doc(recommendationId)
          .update({'isViewed': true});

      final index = _recommendations.indexWhere((r) => r.id == recommendationId);
      if (index != -1) {
        _recommendations[index] = _recommendations[index].copyWith(isViewed: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao marcar como visualizada: $e');
    }
  }

  /// Marca recomendação como clicada
  Future<void> markAsClicked(String recommendationId) async {
    try {
      await _firestore
          .collection('recommendations')
          .doc(recommendationId)
          .update({'isClicked': true});

      final index = _recommendations.indexWhere((r) => r.id == recommendationId);
      if (index != -1) {
        _recommendations[index] = _recommendations[index].copyWith(isClicked: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao marcar como clicada: $e');
    }
  }

  /// Remove recomendação
  Future<void> removeRecommendation(String recommendationId) async {
    try {
      await _firestore
          .collection('recommendations')
          .doc(recommendationId)
          .delete();

      _recommendations.removeWhere((r) => r.id == recommendationId);
      notifyListeners();
    } catch (e) {
      _setError('Erro ao remover recomendação: $e');
    }
  }

  /// Carrega estatísticas de recomendações
  Future<void> loadStats() async {
    try {
      _setLoading(true);
      _clearError();

      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore
          .collection('recommendation_stats')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        _stats = RecommendationStats.fromMap(doc.data()!);
      }

      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar estatísticas: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Limpa recomendações expiradas
  Future<void> cleanExpiredRecommendations() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final expiredQuery = await _firestore
          .collection('recommendations')
          .where('userId', isEqualTo: user.uid)
          .where('expiresAt', isLessThan: Timestamp.now())
          .get();

      final batch = _firestore.batch();
      for (final doc in expiredQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Remover da lista local
      _recommendations.removeWhere((r) => r.isExpired);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao limpar recomendações expiradas: $e');
    }
  }

  /// Limpa dados
  void clear() {
    _recommendations.clear();
    _userProfile = null;
    _stats = null;
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
