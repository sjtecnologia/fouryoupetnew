import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../app_colors.dart';
import '../app_typography.dart';
import 'star_rating.dart';

/// Card de produto melhorado com avaliações
class ProductCard extends StatelessWidget {
  final String name;
  final String? description;
  final String? imageUrl;
  final double price;
  final double? originalPrice;
  final double? averageRating;
  final int? totalReviews;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final bool isLoading;
  final double? discount;

  const ProductCard({
    super.key,
    required this.name,
    this.description,
    this.imageUrl,
    required this.price,
    this.originalPrice,
    this.averageRating,
    this.totalReviews,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.isLoading = false,
    this.discount,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildSkeletonCard();
    }

    return Card(
      elevation: 2,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(context),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildContentSection(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 18,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
          ),
          child: imageUrl != null
              ? ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AppColors.onSurfaceVariant,
                        size: 48,
                      ),
                    ),
                  ),
                )
              : Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: AppColors.onSurfaceVariant,
                    size: 48,
                  ),
                ),
        ),
        if (discount != null && discount! > 0)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '-${discount!.toInt()}%',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onFavorite,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color:
                    isFavorite ? AppColors.error : AppColors.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do produto
          Text(
            name,
            style: AppTypography.h6,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),

          // Avaliação
          if (averageRating != null && totalReviews != null)
            Row(
              children: [
                StarRating(
                  rating: averageRating!,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  averageRating!.toStringAsFixed(1),
                  style: AppTypography.rating.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '($totalReviews)',
                  style: AppTypography.rating.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),

          // Preço
          Row(
            children: [
              Text(
                'R\$ ${price.toStringAsFixed(2)}',
                style: AppTypography.price.copyWith(
                  color: AppColors.primary,
                ),
              ),
              if (originalPrice != null && originalPrice! > price) ...[
                const SizedBox(width: 8),
                Text(
                  'R\$ ${originalPrice!.toStringAsFixed(2)}',
                  style: AppTypography.priceSmall.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Card de produto em lista horizontal
class ProductCardHorizontal extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double price;
  final double? averageRating;
  final int? totalReviews;
  final VoidCallback? onTap;
  final bool isLoading;

  const ProductCardHorizontal({
    super.key,
    required this.name,
    this.imageUrl,
    required this.price,
    this.averageRating,
    this.totalReviews,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildSkeletonCard();
    }

    return Card(
      elevation: 2,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildImage(),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 18,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: AppColors.onSurfaceVariant,
                    size: 32,
                  ),
                ),
              ),
            )
          : Container(
              color: AppColors.surfaceVariant,
              child: const Icon(
                Icons.image_not_supported,
                color: AppColors.onSurfaceVariant,
                size: 32,
              ),
            ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: AppTypography.h6,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (averageRating != null && totalReviews != null)
          Row(
            children: [
              StarRating(
                rating: averageRating!,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '${averageRating!.toStringAsFixed(1)} ($totalReviews)',
                style: AppTypography.rating.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),
        Text(
          'R\$ ${price.toStringAsFixed(2)}',
          style: AppTypography.priceSmall.copyWith(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
