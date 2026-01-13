import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de avaliação de produto/serviço
class Review {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String productId;
  final String productName;
  final double rating;
  final String comment;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final Map<String, dynamic>? metadata;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.productId,
    required this.productName,
    required this.rating,
    required this.comment,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.metadata,
  });

  /// Converte Review para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'productId': productId,
      'productName': productName,
      'rating': rating,
      'comment': comment,
      'images': images,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isVerified': isVerified,
      'metadata': metadata,
    };
  }

  /// Cria Review a partir de Map (Firestore)
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'],
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerified: map['isVerified'] ?? false,
      metadata: map['metadata'],
    );
  }

  /// Cria cópia do Review com campos alterados
  Review copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? productId,
    String? productName,
    double? rating,
    String? comment,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    Map<String, dynamic>? metadata,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Valida se a avaliação é válida
  bool get isValid {
    return id.isNotEmpty &&
        userId.isNotEmpty &&
        userName.isNotEmpty &&
        productId.isNotEmpty &&
        productName.isNotEmpty &&
        rating >= 1.0 &&
        rating <= 5.0 &&
        comment.isNotEmpty;
  }

  /// Retorna texto da avaliação baseado na nota
  String get ratingText {
    if (rating >= 5.0) return 'Excelente';
    if (rating >= 4.0) return 'Muito bom';
    if (rating >= 3.0) return 'Bom';
    if (rating >= 2.0) return 'Regular';
    return 'Ruim';
  }

  /// Retorna cor da avaliação baseada na nota
  String get ratingColor {
    if (rating >= 4.0) return 'success';
    if (rating >= 3.0) return 'warning';
    return 'error';
  }

  @override
  String toString() {
    return 'Review(id: $id, userId: $userId, userName: $userName, productId: $productId, rating: $rating, comment: $comment)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Modelo de estatísticas de avaliação
class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final int verifiedReviews;
  final double verifiedAverageRating;

  ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.verifiedReviews,
    required this.verifiedAverageRating,
  });

  /// Cria ReviewStats a partir de Map (Firestore)
  factory ReviewStats.fromMap(Map<String, dynamic> map) {
    return ReviewStats(
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      ratingDistribution: Map<int, int>.from(map['ratingDistribution'] ?? {}),
      verifiedReviews: map['verifiedReviews'] ?? 0,
      verifiedAverageRating: (map['verifiedAverageRating'] ?? 0.0).toDouble(),
    );
  }

  /// Converte ReviewStats para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingDistribution': ratingDistribution,
      'verifiedReviews': verifiedReviews,
      'verifiedAverageRating': verifiedAverageRating,
    };
  }

  /// Retorna porcentagem de cada nota
  Map<int, double> get ratingPercentages {
    if (totalReviews == 0) return {};
    
    return ratingDistribution.map(
      (key, value) => MapEntry(key, value / totalReviews),
    );
  }

  /// Retorna se há avaliações suficientes para mostrar
  bool get hasEnoughReviews => totalReviews >= 3;

  /// Retorna se a avaliação é considerada boa
  bool get isGoodRating => averageRating >= 4.0;

  @override
  String toString() {
    return 'ReviewStats(averageRating: $averageRating, totalReviews: $totalReviews)';
  }
}
