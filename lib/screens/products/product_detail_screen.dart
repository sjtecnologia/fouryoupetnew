import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_typography.dart';
import '../../design_system/components/product_card.dart';
import '../../design_system/components/star_rating.dart';
import '../../design_system/components/app_button.dart';
import '../../models/review/review_manager.dart';
import '../../models/recommendation/recommendation_manager.dart';
import '../../models/loyalty/loyalty_manager.dart';
import '../../screens/reviews/reviews_screen.dart';

/// Tela de detalhes do produto com avaliações e recomendações
class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final String? description;
  final String? category;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    this.description,
    this.category,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Carregar dados do produto
      context.read<ReviewManager>().loadProductReviews(widget.productId);
      context.read<ReviewManager>().loadProductStats(widget.productId);
      
      // Atualizar perfil do usuário com visualização
      context.read<RecommendationManager>().updateUserProfile(
        category: widget.category,
        productId: widget.productId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productName),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareProduct(),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => _toggleFavorite(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            _buildProductInfo(),
            _buildReviewsSection(),
            _buildRecommendationsSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 300,
      width: double.infinity,
      color: AppColors.surfaceVariant,
      child: widget.productImage != null
          ? Image.network(
              widget.productImage!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: AppColors.onSurfaceVariant,
                    size: 64,
                  ),
                );
              },
            )
          : Container(
              color: AppColors.surfaceVariant,
              child: const Icon(
                Icons.image_not_supported,
                color: AppColors.onSurfaceVariant,
                size: 64,
              ),
            ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.productName,
            style: AppTypography.h4,
          ),
          if (widget.category != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.category!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'R\$ ${widget.price.toStringAsFixed(2)}',
                style: AppTypography.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Consumer<LoyaltyManager>(
                builder: (context, loyaltyManager, child) {
                  if (loyaltyManager.loyaltyProgram != null) {
                    final points = loyaltyManager.calculatePointsFromPurchase(
                      widget.price,
                      loyaltyManager.loyaltyProgram!.currentTier,
                    );
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.starFilled.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.starFilled,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$points pontos',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.starFilled,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          if (widget.description != null) ...[
            const SizedBox(height: 16),
            Text(
              'Descrição',
              style: AppTypography.h6,
            ),
            const SizedBox(height: 8),
            Text(
              widget.description!,
              style: AppTypography.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Consumer<ReviewManager>(
      builder: (context, reviewManager, child) {
        if (reviewManager.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final stats = reviewManager.productStats[widget.productId];
        if (stats == null || stats.totalReviews == 0) {
          return _buildNoReviewsSection();
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Avaliações',
                    style: AppTypography.h5,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _navigateToReviews(),
                    child: const Text('Ver todas'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    stats.averageRating.toStringAsFixed(1),
                    style: AppTypography.h2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StarRating(
                        rating: stats.averageRating,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${stats.totalReviews} avaliações',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Distribuição das avaliações
              ...List.generate(5, (index) {
                final rating = 5 - index;
                final count = stats.ratingDistribution[rating] ?? 0;
                final percentage = stats.totalReviews > 0 ? count / stats.totalReviews : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '$rating',
                        style: AppTypography.bodySmall,
                        textAlign: TextAlign.end,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.star,
                        size: 12,
                        color: AppColors.starFilled,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: AppColors.outline,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.starFilled,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$count',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              AppButton(
                text: 'Avaliar produto',
                onPressed: () => _navigateToReviews(),
                type: AppButtonType.secondary,
                fullWidth: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoReviewsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avaliações',
            style: AppTypography.h5,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.star_outline,
                    size: 48,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma avaliação ainda',
                    style: AppTypography.h6,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seja o primeiro a avaliar este produto!',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Avaliar produto',
                    onPressed: () => _navigateToReviews(),
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Consumer<RecommendationManager>(
      builder: (context, recommendationManager, child) {
        if (recommendationManager.recommendations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Produtos relacionados',
                style: AppTypography.h5,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendationManager.recommendations.take(5).length,
                  itemBuilder: (context, index) {
                    final recommendation = recommendationManager.recommendations[index];
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 16),
                      child: ProductCard(
                        name: recommendation.productName,
                        imageUrl: recommendation.productImage,
                        price: recommendation.price,
                        averageRating: 4.5, // Placeholder
                        totalReviews: 10, // Placeholder
                        onTap: () {
                          // Navegar para produto relacionado
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Adicionar ao carrinho',
              onPressed: () => _addToCart(),
              type: AppButtonType.secondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppButton(
              text: 'Comprar agora',
              onPressed: () => _buyNow(),
            ),
          ),
        ],
      ),
    );
  }

  void _shareProduct() {
    // Implementar compartilhamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de compartilhamento em desenvolvimento'),
      ),
    );
  }

  void _toggleFavorite() {
    // Implementar favoritos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de favoritos em desenvolvimento'),
      ),
    );
  }

  void _navigateToReviews() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewsScreen(
          productId: widget.productId,
          productName: widget.productName,
        ),
      ),
    );
  }

  void _addToCart() {
    // Implementar adição ao carrinho
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Produto adicionado ao carrinho!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _buyNow() {
    // Implementar compra imediata
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de compra em desenvolvimento'),
      ),
    );
  }
}
