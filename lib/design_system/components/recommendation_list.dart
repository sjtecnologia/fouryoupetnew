import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_colors.dart';
import '../app_typography.dart';
import '../../models/recommendation/recommendation.dart';
import '../../models/recommendation/recommendation_manager.dart';
import 'product_card.dart';
import 'package:fouryoupet/common/app_network_image.dart';

/// Lista de recomendações personalizadas
class RecommendationList extends StatelessWidget {
  final String title;
  final RecommendationType? type;
  final int maxItems;
  final VoidCallback? onSeeAll;
  final bool showHeader;

  const RecommendationList({
    super.key,
    this.title = 'Recomendados para você',
    this.type,
    this.maxItems = 10,
    this.onSeeAll,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendationManager>(
      builder: (context, recommendationManager, child) {
        if (recommendationManager.isLoading) {
          return _buildLoadingState();
        }

        if (recommendationManager.error != null) {
          return _buildErrorState(context, recommendationManager.error!);
        }

        final recommendations = _filterRecommendations(
          recommendationManager.recommendations,
          type,
          maxItems,
        );

        if (recommendations.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) _buildHeader(context, recommendations.length),
            const SizedBox(height: 16),
            _buildRecommendationsList(context, recommendations),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Container(
            height: 24,
            width: 200,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 16),
                child: ProductCard(
                  name: '',
                  price: 0.0,
                  isLoading: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 8),
            Text(
              'Erro ao carregar recomendações',
              style: AppTypography.h6,
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<RecommendationManager>().loadUserRecommendations();
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.recommend_outlined,
              size: 48,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma recomendação disponível',
              style: AppTypography.h6,
            ),
            const SizedBox(height: 8),
            Text(
              'Continue navegando para receber recomendações personalizadas',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int itemCount) {
    return Row(
      children: [
        Text(
          title,
          style: AppTypography.h5,
        ),
        const Spacer(),
        if (itemCount > 0) ...[
          Text(
            '$itemCount itens',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('Ver todos'),
          ),
      ],
    );
  }

  Widget _buildRecommendationsList(BuildContext context, List<Recommendation> recommendations) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final recommendation = recommendations[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            child: _buildRecommendationCard(context, recommendation),
          );
        },
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, Recommendation recommendation) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Marcar como clicada
          context.read<RecommendationManager>().markAsClicked(recommendation.id);
          // Navegar para produto
          _navigateToProduct(context, recommendation);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do produto
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: recommendation.productImage != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: AppNetworkImage(
                        imageUrl: recommendation.productImage!,
                        fit: BoxFit.cover,
                        placeholderColor: AppColors.surfaceVariant,
                      ),
                    )
                  : Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
            ),
            
            // Conteúdo do card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Razão da recomendação
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getReasonColor(recommendation.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        recommendation.reasonText,
                        style: AppTypography.labelSmall.copyWith(
                          color: _getReasonColor(recommendation.type),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Nome do produto
                    Text(
                      recommendation.productName,
                      style: AppTypography.h6,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Categoria
                    Text(
                      recommendation.category,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    
                    // Preço
                    Text(
                      'R\$ ${recommendation.price.toStringAsFixed(2)}',
                      style: AppTypography.priceSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    
                    // Score de recomendação
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(recommendation.score * 100).toInt()}% match',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Recommendation> _filterRecommendations(
    List<Recommendation> recommendations,
    RecommendationType? type,
    int maxItems,
  ) {
    var filtered = recommendations;
    
    if (type != null) {
      filtered = filtered.where((r) => r.type == type).toList();
    }
    
    // Ordenar por score e data
    filtered.sort((a, b) {
      if (a.score != b.score) {
        return b.score.compareTo(a.score);
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return filtered.take(maxItems).toList();
  }

  Color _getReasonColor(RecommendationType type) {
    switch (type) {
      case RecommendationType.similar:
        return AppColors.accent;
      case RecommendationType.popular:
        return AppColors.warning;
      case RecommendationType.trending:
        return AppColors.error;
      case RecommendationType.personalized:
        return AppColors.primary;
      case RecommendationType.category:
        return AppColors.secondary;
      case RecommendationType.price:
        return AppColors.info;
      case RecommendationType.rating:
        return AppColors.starFilled;
      case RecommendationType.recent:
        return AppColors.onSurfaceVariant;
    }
  }

  void _navigateToProduct(BuildContext context, Recommendation recommendation) {
    // Implementar navegação para tela de produto
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (context) => ProductDetailScreen(productId: recommendation.productId),
    // ));
  }
}

/// Widget de recomendação em grid
class RecommendationGrid extends StatelessWidget {
  final String title;
  final RecommendationType? type;
  final int crossAxisCount;
  final double childAspectRatio;
  final VoidCallback? onSeeAll;

  const RecommendationGrid({
    super.key,
    this.title = 'Recomendados para você',
    this.type,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.75,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendationManager>(
      builder: (context, recommendationManager, child) {
        if (recommendationManager.isLoading) {
          return _buildLoadingGrid();
        }

        if (recommendationManager.error != null) {
          return _buildErrorState(context, recommendationManager.error!);
        }

        final recommendations = recommendationManager.recommendations
            .where((r) => type == null || r.type == type)
            .take(6)
            .toList();

        if (recommendations.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: AppTypography.h5,
                ),
                const Spacer(),
                if (onSeeAll != null)
                  TextButton(
                    onPressed: onSeeAll,
                    child: const Text('Ver todos'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final recommendation = recommendations[index];
                return _buildGridCard(context, recommendation);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 24,
          width: 200,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return ProductCard(
              name: '',
              price: 0.0,
              isLoading: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 8),
            Text(
              'Erro ao carregar recomendações',
              style: AppTypography.h6,
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.recommend_outlined,
              size: 48,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma recomendação disponível',
              style: AppTypography.h6,
            ),
            const SizedBox(height: 8),
            Text(
              'Continue navegando para receber recomendações personalizadas',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, Recommendation recommendation) {
    return ProductCard(
      name: recommendation.productName,
      imageUrl: recommendation.productImage,
      price: recommendation.price,
      onTap: () {
        context.read<RecommendationManager>().markAsClicked(recommendation.id);
        // Navegar para produto
      },
    );
  }
}
