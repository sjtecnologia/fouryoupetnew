import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de recomendação de produto
class Recommendation {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final String category;
  final String subcategory;
  final double score;
  final String reason;
  final RecommendationType type;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isViewed;
  final bool isClicked;
  final Map<String, dynamic>? metadata;

  Recommendation({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.category,
    required this.subcategory,
    required this.score,
    required this.reason,
    required this.type,
    required this.createdAt,
    required this.expiresAt,
    this.isViewed = false,
    this.isClicked = false,
    this.metadata,
  });

  /// Converte Recommendation para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'category': category,
      'subcategory': subcategory,
      'score': score,
      'reason': reason,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isViewed': isViewed,
      'isClicked': isClicked,
      'metadata': metadata,
    };
  }

  /// Cria Recommendation a partir de Map (Firestore)
  factory Recommendation.fromMap(Map<String, dynamic> map) {
    return Recommendation(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'],
      price: (map['price'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      score: (map['score'] ?? 0.0).toDouble(),
      reason: map['reason'] ?? '',
      type: RecommendationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => RecommendationType.similar,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isViewed: map['isViewed'] ?? false,
      isClicked: map['isClicked'] ?? false,
      metadata: map['metadata'],
    );
  }

  /// Cria cópia do Recommendation com campos alterados
  Recommendation copyWith({
    String? id,
    String? userId,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    String? category,
    String? subcategory,
    double? score,
    String? reason,
    RecommendationType? type,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isViewed,
    bool? isClicked,
    Map<String, dynamic>? metadata,
  }) {
    return Recommendation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      score: score ?? this.score,
      reason: reason ?? this.reason,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isViewed: isViewed ?? this.isViewed,
      isClicked: isClicked ?? this.isClicked,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Verifica se a recomendação é válida
  bool get isValid {
    return id.isNotEmpty &&
        userId.isNotEmpty &&
        productId.isNotEmpty &&
        productName.isNotEmpty &&
        score >= 0.0 &&
        score <= 1.0 &&
        createdAt.isBefore(expiresAt);
  }

  /// Verifica se a recomendação expirou
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Retorna texto da razão da recomendação
  String get reasonText {
    switch (type) {
      case RecommendationType.similar:
        return 'Produtos similares';
      case RecommendationType.popular:
        return 'Mais populares';
      case RecommendationType.trending:
        return 'Em alta';
      case RecommendationType.personalized:
        return 'Para você';
      case RecommendationType.category:
        return 'Nesta categoria';
      case RecommendationType.price:
        return 'Faixa de preço';
      case RecommendationType.rating:
        return 'Bem avaliados';
      case RecommendationType.recent:
        return 'Recentes';
    }
  }

  @override
  String toString() {
    return 'Recommendation(id: $id, productId: $productId, score: $score, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recommendation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Tipos de recomendação
enum RecommendationType {
  similar,      // Produtos similares
  popular,      // Mais populares
  trending,     // Em alta
  personalized, // Personalizado
  category,     // Por categoria
  price,        // Por faixa de preço
  rating,       // Por avaliação
  recent,       // Recentes
}

/// Modelo de perfil de usuário para recomendações
class UserProfile {
  final String userId;
  final List<String> favoriteCategories;
  final List<String> favoriteSubcategories;
  final double averagePriceRange;
  final List<String> viewedProducts;
  final List<String> purchasedProducts;
  final Map<String, int> categoryPreferences;
  final Map<String, double> brandPreferences;
  final DateTime lastUpdated;
  final Map<String, dynamic>? metadata;

  UserProfile({
    required this.userId,
    this.favoriteCategories = const [],
    this.favoriteSubcategories = const [],
    this.averagePriceRange = 0.0,
    this.viewedProducts = const [],
    this.purchasedProducts = const [],
    this.categoryPreferences = const {},
    this.brandPreferences = const {},
    required this.lastUpdated,
    this.metadata,
  });

  /// Converte UserProfile para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'favoriteCategories': favoriteCategories,
      'favoriteSubcategories': favoriteSubcategories,
      'averagePriceRange': averagePriceRange,
      'viewedProducts': viewedProducts,
      'purchasedProducts': purchasedProducts,
      'categoryPreferences': categoryPreferences,
      'brandPreferences': brandPreferences,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'metadata': metadata,
    };
  }

  /// Cria UserProfile a partir de Map (Firestore)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'] ?? '',
      favoriteCategories: List<String>.from(map['favoriteCategories'] ?? []),
      favoriteSubcategories: List<String>.from(map['favoriteSubcategories'] ?? []),
      averagePriceRange: (map['averagePriceRange'] ?? 0.0).toDouble(),
      viewedProducts: List<String>.from(map['viewedProducts'] ?? []),
      purchasedProducts: List<String>.from(map['purchasedProducts'] ?? []),
      categoryPreferences: Map<String, int>.from(map['categoryPreferences'] ?? {}),
      brandPreferences: Map<String, double>.from(map['brandPreferences'] ?? {}),
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: map['metadata'],
    );
  }

  /// Cria cópia do UserProfile com campos alterados
  UserProfile copyWith({
    String? userId,
    List<String>? favoriteCategories,
    List<String>? favoriteSubcategories,
    double? averagePriceRange,
    List<String>? viewedProducts,
    List<String>? purchasedProducts,
    Map<String, int>? categoryPreferences,
    Map<String, double>? brandPreferences,
    DateTime? lastUpdated,
    Map<String, dynamic>? metadata,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      favoriteSubcategories: favoriteSubcategories ?? this.favoriteSubcategories,
      averagePriceRange: averagePriceRange ?? this.averagePriceRange,
      viewedProducts: viewedProducts ?? this.viewedProducts,
      purchasedProducts: purchasedProducts ?? this.purchasedProducts,
      categoryPreferences: categoryPreferences ?? this.categoryPreferences,
      brandPreferences: brandPreferences ?? this.brandPreferences,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Calcula score de compatibilidade com categoria
  double getCategoryScore(String category) {
    return categoryPreferences[category]?.toDouble() ?? 0.0;
  }

  /// Calcula score de compatibilidade com marca
  double getBrandScore(String brand) {
    return brandPreferences[brand] ?? 0.0;
  }

  /// Verifica se usuário tem histórico suficiente
  bool get hasEnoughHistory {
    return viewedProducts.length >= 5 || purchasedProducts.length >= 2;
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, categories: ${favoriteCategories.length})';
  }
}

/// Modelo de estatísticas de recomendação
class RecommendationStats {
  final int totalRecommendations;
  final int viewedRecommendations;
  final int clickedRecommendations;
  final double clickThroughRate;
  final double conversionRate;
  final Map<RecommendationType, int> typeDistribution;
  final DateTime lastCalculated;

  RecommendationStats({
    required this.totalRecommendations,
    required this.viewedRecommendations,
    required this.clickedRecommendations,
    required this.clickThroughRate,
    required this.conversionRate,
    required this.typeDistribution,
    required this.lastCalculated,
  });

  /// Cria RecommendationStats a partir de Map (Firestore)
  factory RecommendationStats.fromMap(Map<String, dynamic> map) {
    return RecommendationStats(
      totalRecommendations: map['totalRecommendations'] ?? 0,
      viewedRecommendations: map['viewedRecommendations'] ?? 0,
      clickedRecommendations: map['clickedRecommendations'] ?? 0,
      clickThroughRate: (map['clickThroughRate'] ?? 0.0).toDouble(),
      conversionRate: (map['conversionRate'] ?? 0.0).toDouble(),
      typeDistribution: Map<RecommendationType, int>.from(
        (map['typeDistribution'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(
            RecommendationType.values.firstWhere((e) => e.name == key),
            value as int,
          ),
        ) ?? {},
      ),
      lastCalculated: (map['lastCalculated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converte RecommendationStats para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'totalRecommendations': totalRecommendations,
      'viewedRecommendations': viewedRecommendations,
      'clickedRecommendations': clickedRecommendations,
      'clickThroughRate': clickThroughRate,
      'conversionRate': conversionRate,
      'typeDistribution': typeDistribution.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'lastCalculated': Timestamp.fromDate(lastCalculated),
    };
  }

  @override
  String toString() {
    return 'RecommendationStats(ctr: ${clickThroughRate.toStringAsFixed(2)}%, conversion: ${conversionRate.toStringAsFixed(2)}%)';
  }
}
