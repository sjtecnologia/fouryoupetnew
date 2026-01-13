import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Componente de avaliação com estrelas
class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool interactive;
  final ValueChanged<double>? onRatingChanged;
  final Color? filledColor;
  final Color? emptyColor;
  final int maxRating;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 20.0,
    this.interactive = false,
    this.onRatingChanged,
    this.filledColor,
    this.emptyColor,
    this.maxRating = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= rating;
        final isHalfFilled = starIndex - 0.5 <= rating && starIndex > rating;

        return GestureDetector(
          onTap: interactive ? () => onRatingChanged?.call(starIndex.toDouble()) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Icon(
              isFilled
                  ? Icons.star
                  : isHalfFilled
                      ? Icons.star_half
                      : Icons.star_border,
              size: size,
              color: isFilled || isHalfFilled
                  ? (filledColor ?? AppColors.starFilled)
                  : (emptyColor ?? AppColors.starEmpty),
            ),
          ),
        );
      }),
    );
  }
}

/// Widget para exibir resumo de avaliações
class RatingSummary extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final VoidCallback? onTap;

  const RatingSummary({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Avaliações',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Média das avaliações
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      StarRating(
                        rating: averageRating,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalReviews avaliações',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Distribuição das avaliações
                  Expanded(
                    child: Column(
                      children: List.generate(5, (index) {
                        final rating = 5 - index;
                        final count = ratingDistribution[rating] ?? 0;
                        final percentage = totalReviews > 0 ? count / totalReviews : 0.0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                '$rating',
                                style: Theme.of(context).textTheme.bodySmall,
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
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para seleção de avaliação
class RatingSelector extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double> onRatingChanged;
  final double size;
  final String? label;

  const RatingSelector({
    super.key,
    this.initialRating = 0.0,
    required this.onRatingChanged,
    this.size = 32.0,
    this.label,
  });

  @override
  State<RatingSelector> createState() => _RatingSelectorState();
}

class _RatingSelectorState extends State<RatingSelector> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            final isFilled = starIndex <= _currentRating;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentRating = starIndex.toDouble();
                });
                widget.onRatingChanged(_currentRating);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  isFilled ? Icons.star : Icons.star_border,
                  size: widget.size,
                  color: isFilled
                      ? AppColors.starFilled
                      : AppColors.starEmpty,
                ),
              ),
            );
          }),
        ),
        if (_currentRating > 0) ...[
          const SizedBox(height: 8),
          Text(
            _getRatingText(_currentRating),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  String _getRatingText(double rating) {
    switch (rating.toInt()) {
      case 1:
        return 'Muito ruim';
      case 2:
        return 'Ruim';
      case 3:
        return 'Regular';
      case 4:
        return 'Bom';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }
}
