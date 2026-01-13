import 'package:cloud_firestore/cloud_firestore.dart';

enum DiscountType {
  percentage,
  fixed,
}

class CouponCode {
  final String id;
  final String code;
  final String description;
  final DiscountType discountType;
  final double discountValue;
  final DateTime expirationDate;
  final bool isActive;
  final double minimumValue;
  final double? maxDiscount;
  final List<String> usedBy;
  final int? maxUses;

  CouponCode({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.expirationDate,
    required this.isActive,
    this.minimumValue = 0.0,
    this.maxDiscount,
    this.usedBy = const [],
    this.maxUses,
    required usageCount,
  });

  // Getter para compatibilidade com código antigo
  bool get isPercentage => discountType == DiscountType.percentage;
  double get value => discountValue;

  factory CouponCode.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CouponCode(
      id: doc.id,
      code: data['code'] ?? '',
      description: data['description'] ?? '',
      discountType: data['discountType'] == 'percentage'
          ? DiscountType.percentage
          : DiscountType.fixed,
      discountValue: (data['discountValue'] ?? 0.0).toDouble(),
      expirationDate: (data['expirationDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      minimumValue: (data['minimumValue'] ?? 0.0).toDouble(),
      maxDiscount: data['maxDiscount']?.toDouble(),
      usedBy: List<String>.from(data['usedBy'] ?? []),
      maxUses: data['maxUses'],
      usageCount: data['usageCount'] ?? 0,
    );
  }

  get minimumOrderValue => null;

  get usageLimit => null;

  get usageCount => null;

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'description': description,
      'discountType':
          discountType == DiscountType.percentage ? 'percentage' : 'fixed',
      'discountValue': discountValue,
      'expirationDate': Timestamp.fromDate(expirationDate),
      'isActive': isActive,
      'minimumValue': minimumValue,
      'maxDiscount': maxDiscount,
      'usedBy': usedBy,
      'maxUses': maxUses,
      'usageCount': usageCount,
    };
  }

  CouponCode copyWith(
      {String? id,
      String? code,
      String? description,
      DiscountType? discountType,
      double? discountValue,
      DateTime? expirationDate,
      bool? isActive,
      double? minimumValue,
      double? maxDiscount,
      List<String>? usedBy,
      int? maxUses,
      int? usageCount}) {
    return CouponCode(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      expirationDate: expirationDate ?? this.expirationDate,
      isActive: isActive ?? this.isActive,
      minimumValue: minimumValue ?? this.minimumValue,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      usedBy: usedBy ?? this.usedBy,
      maxUses: maxUses ?? this.maxUses,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  double calculateDiscount(double totalValue) {
    if (discountType == DiscountType.percentage) {
      double discount = totalValue * (discountValue / 100);
      if (maxDiscount != null && discount > maxDiscount!) {
        return maxDiscount!;
      }
      return discount;
    } else {
      return discountValue;
    }
  }

  bool isValid() {
    return isActive &&
        DateTime.now().isBefore(expirationDate) &&
        (maxUses == null || usedBy.length < maxUses!);
  }

  bool canBeUsedBy(String userId, double totalValue) {
    return isValid() && !usedBy.contains(userId) && totalValue >= minimumValue;
  }
}
