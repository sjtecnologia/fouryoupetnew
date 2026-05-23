import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_typography.dart';
import '../../design_system/components/star_rating.dart';
import '../../design_system/components/app_button.dart';
import '../../models/review/review_manager.dart';
import '../../models/review/review.dart';
import 'package:fouryoupet/common/app_network_image.dart';

/// Tela de avaliações de produto
class ReviewsScreen extends StatefulWidget {
  final String productId;
  final String productName;

  const ReviewsScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewManager>().loadProductReviews(widget.productId);
      context.read<ReviewManager>().loadProductStats(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Avaliações - ${widget.productName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddReviewDialog(),
          ),
        ],
      ),
      body: Consumer<ReviewManager>(
        builder: (context, reviewManager, child) {
          if (reviewManager.isLoading && reviewManager.reviews.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (reviewManager.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar avaliações',
                    style: AppTypography.h5,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reviewManager.error!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Tentar novamente',
                    onPressed: () {
                      reviewManager.loadProductReviews(widget.productId);
                      reviewManager.loadProductStats(widget.productId);
                    },
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Estatísticas
              if (reviewManager.productStats.containsKey(widget.productId))
                _buildStatsSection(reviewManager.productStats[widget.productId]!),
              
              // Lista de avaliações
              Expanded(
                child: reviewManager.reviews.isEmpty
                    ? _buildEmptyState()
                    : _buildReviewsList(reviewManager.reviews),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(ReviewStats stats) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Avaliações',
                  style: AppTypography.h5,
                ),
                const Spacer(),
                if (stats.totalReviews > 0) ...[
                  Text(
                    stats.averageRating.toStringAsFixed(1),
                    style: AppTypography.h3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StarRating(
                    rating: stats.averageRating,
                    size: 24,
                  ),
                ],
              ],
            ),
            if (stats.totalReviews > 0) ...[
              const SizedBox(height: 16),
              Text(
                '${stats.totalReviews} avaliações',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_outline,
            size: 64,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma avaliação ainda',
            style: AppTypography.h5,
          ),
          const SizedBox(height: 8),
          Text(
            'Seja o primeiro a avaliar este produto!',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Avaliar produto',
            onPressed: () => _showAddReviewDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList(List<Review> reviews) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return _buildReviewCard(review);
      },
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da avaliação
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  backgroundImage: review.userAvatar != null
                      ? NetworkImage(review.userAvatar!)
                      : null,
                  child: review.userAvatar == null
                      ? Text(
                          review.userName.isNotEmpty
                              ? review.userName[0].toUpperCase()
                              : 'U',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          StarRating(
                            rating: review.rating,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            review.ratingText,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(review.createdAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Comentário
            Text(
              review.comment,
              style: AppTypography.bodyMedium,
            ),
            
            // Imagens (se houver)
            if (review.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AppNetworkImage(
                          imageUrl: review.images[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholderColor: AppColors.surfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            // Verificado
            if (review.isVerified) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.verified,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Compra verificada',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(
        productId: widget.productId,
        productName: widget.productName,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks semana${weeks > 1 ? 's' : ''} atrás';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months mês${months > 1 ? 'es' : ''} atrás';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ano${years > 1 ? 's' : ''} atrás';
    }
  }
}

/// Dialog para adicionar avaliação
class AddReviewDialog extends StatefulWidget {
  final String productId;
  final String productName;

  const AddReviewDialog({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Avaliar ${widget.productName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Seleção de nota
            RatingSelector(
              initialRating: _rating,
              onRatingChanged: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
              size: 40,
            ),
            const SizedBox(height: 24),
            
            // Campo de comentário
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comentário',
                hintText: 'Conte sua experiência com este produto...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              maxLength: 500,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        AppButton(
          text: _isSubmitting ? 'Enviando...' : 'Enviar',
          onPressed: _rating > 0 && _commentController.text.isNotEmpty && !_isSubmitting
              ? _submitReview
              : null,
          isLoading: _isSubmitting,
        ),
      ],
    );
  }

  Future<void> _submitReview() async {
    if (_rating == 0 || _commentController.text.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    final success = await context.read<ReviewManager>().addReview(
      productId: widget.productId,
      productName: widget.productName,
      rating: _rating,
      comment: _commentController.text.trim(),
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avaliação enviada com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<ReviewManager>().error ?? 'Erro ao enviar avaliação'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    setState(() {
      _isSubmitting = false;
    });
  }
}
