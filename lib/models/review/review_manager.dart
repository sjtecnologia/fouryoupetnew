import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'review.dart';

/// Gerenciador de avaliações
class ReviewManager extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Review> _reviews = [];
  Map<String, ReviewStats> _productStats = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Review> get reviews => _reviews;
  Map<String, ReviewStats> get productStats => _productStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carrega avaliações de um produto
  Future<void> loadProductReviews(String productId, {int limit = 20}) async {
    try {
      _setLoading(true);
      _clearError();

      final query = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      _reviews = query.docs
          .map((doc) => Review.fromMap(doc.data()))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar avaliações: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega estatísticas de um produto
  Future<void> loadProductStats(String productId) async {
    try {
      _setLoading(true);
      _clearError();

      final doc = await _firestore
          .collection('product_stats')
          .doc(productId)
          .get();

      if (doc.exists) {
        _productStats[productId] = ReviewStats.fromMap(doc.data()!);
      } else {
        // Se não existir, criar estatísticas vazias
        _productStats[productId] = ReviewStats(
          averageRating: 0.0,
          totalReviews: 0,
          ratingDistribution: {},
          verifiedReviews: 0,
          verifiedAverageRating: 0.0,
        );
      }

      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar estatísticas: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Adiciona nova avaliação
  Future<bool> addReview({
    required String productId,
    required String productName,
    required double rating,
    required String comment,
    List<String> images = const [],
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = _auth.currentUser;
      if (user == null) {
        _setError('Usuário não autenticado');
        return false;
      }

      // Buscar dados do usuário
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        _setError('Dados do usuário não encontrados');
        return false;
      }

      final userData = userDoc.data()!;
      final userName = userData['name'] ?? 'Usuário';
      final userAvatar = userData['avatar'];

      // Criar avaliação
      final review = Review(
        id: _firestore.collection('reviews').doc().id,
        userId: user.uid,
        userName: userName,
        userAvatar: userAvatar,
        productId: productId,
        productName: productName,
        rating: rating,
        comment: comment,
        images: images,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: false,
      );

      // Salvar avaliação
      await _firestore
          .collection('reviews')
          .doc(review.id)
          .set(review.toMap());

      // Atualizar estatísticas do produto
      await _updateProductStats(productId);

      // Adicionar à lista local
      _reviews.insert(0, review);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Erro ao adicionar avaliação: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza avaliação existente
  Future<bool> updateReview({
    required String reviewId,
    required double rating,
    required String comment,
    List<String> images = const [],
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final reviewDoc = await _firestore
          .collection('reviews')
          .doc(reviewId)
          .get();

      if (!reviewDoc.exists) {
        _setError('Avaliação não encontrada');
        return false;
      }

      final reviewData = reviewDoc.data()!;
      final updatedReview = Review.fromMap(reviewData).copyWith(
        rating: rating,
        comment: comment,
        images: images,
        updatedAt: DateTime.now(),
      );

      // Atualizar no Firestore
      await _firestore
          .collection('reviews')
          .doc(reviewId)
          .update(updatedReview.toMap());

      // Atualizar estatísticas do produto
      await _updateProductStats(updatedReview.productId);

      // Atualizar na lista local
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        _reviews[index] = updatedReview;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Erro ao atualizar avaliação: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Remove avaliação
  Future<bool> deleteReview(String reviewId) async {
    try {
      _setLoading(true);
      _clearError();

      final reviewDoc = await _firestore
          .collection('reviews')
          .doc(reviewId)
          .get();

      if (!reviewDoc.exists) {
        _setError('Avaliação não encontrada');
        return false;
      }

      final reviewData = reviewDoc.data()!;
      final productId = reviewData['productId'];

      // Remover do Firestore
      await _firestore
          .collection('reviews')
          .doc(reviewId)
          .delete();

      // Atualizar estatísticas do produto
      await _updateProductStats(productId);

      // Remover da lista local
      _reviews.removeWhere((r) => r.id == reviewId);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Erro ao remover avaliação: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza estatísticas de um produto
  Future<void> _updateProductStats(String productId) async {
    try {
      // Buscar todas as avaliações do produto
      final reviewsQuery = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .get();

      final reviews = reviewsQuery.docs
          .map((doc) => Review.fromMap(doc.data()))
          .toList();

      if (reviews.isEmpty) {
        // Se não há avaliações, criar estatísticas vazias
        await _firestore
            .collection('product_stats')
            .doc(productId)
            .set(ReviewStats(
              averageRating: 0.0,
              totalReviews: 0,
              ratingDistribution: {},
              verifiedReviews: 0,
              verifiedAverageRating: 0.0,
            ).toMap());
        return;
      }

      // Calcular estatísticas
      final totalReviews = reviews.length;
      final averageRating = reviews
          .map((r) => r.rating)
          .reduce((a, b) => a + b) / totalReviews;

      final ratingDistribution = <int, int>{};
      for (int i = 1; i <= 5; i++) {
        ratingDistribution[i] = reviews.where((r) => r.rating.toInt() == i).length;
      }

      final verifiedReviews = reviews.where((r) => r.isVerified).length;
      final verifiedAverageRating = verifiedReviews > 0
          ? reviews
              .where((r) => r.isVerified)
              .map((r) => r.rating)
              .reduce((a, b) => a + b) / verifiedReviews
          : 0.0;

      final stats = ReviewStats(
        averageRating: averageRating,
        totalReviews: totalReviews,
        ratingDistribution: ratingDistribution,
        verifiedReviews: verifiedReviews,
        verifiedAverageRating: verifiedAverageRating,
      );

      // Salvar estatísticas
      await _firestore
          .collection('product_stats')
          .doc(productId)
          .set(stats.toMap());

      // Atualizar cache local
      _productStats[productId] = stats;
    } catch (e) {
      debugPrint('Erro ao atualizar estatísticas: $e');
    }
  }

  /// Busca avaliações por texto
  Future<List<Review>> searchReviews(String query) async {
    try {
      _setLoading(true);
      _clearError();

      final searchQuery = await _firestore
          .collection('reviews')
          .where('comment', isGreaterThanOrEqualTo: query)
          .where('comment', isLessThan: query + 'z')
          .limit(20)
          .get();

      return searchQuery.docs
          .map((doc) => Review.fromMap(doc.data()))
          .toList();
    } catch (e) {
      _setError('Erro ao buscar avaliações: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega avaliações do usuário atual
  Future<void> loadUserReviews() async {
    try {
      _setLoading(true);
      _clearError();

      final user = _auth.currentUser;
      if (user == null) {
        _setError('Usuário não autenticado');
        return;
      }

      final query = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _reviews = query.docs
          .map((doc) => Review.fromMap(doc.data()))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar avaliações do usuário: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Verifica se usuário pode avaliar produto
  Future<bool> canUserReview(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Verificar se já avaliou
      final existingReview = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: user.uid)
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      return existingReview.docs.isEmpty;
    } catch (e) {
      debugPrint('Erro ao verificar se pode avaliar: $e');
      return false;
    }
  }

  /// Limpa dados
  void clear() {
    _reviews.clear();
    _productStats.clear();
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
