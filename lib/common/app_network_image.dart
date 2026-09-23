import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Widget reutilizável para exibir imagens da rede com cache,
/// placeholder de loading e fallback de erro.
///
/// Substitui o uso direto de [Image.network] no projeto.
///
/// Parâmetros opcionais:
///   [width] / [height] — dimensões do widget.
///   [fit]              — BoxFit (padrão: BoxFit.cover).
///   [borderRadius]     — arredondamento de cantos.
///   [placeholderColor] — cor do placeholder (padrão: cinza claro).
class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color placeholderColor;

  const AppNetworkImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderColor = const Color(0xFFEEEEEE),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget image = _buildImage();
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _buildImage() {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return _placeholder();
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _placeholder(),
      errorWidget: (_, __, ___) => _errorWidget(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: placeholderColor,
      child: const Center(
        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
      ),
    );
  }

  Widget _errorWidget() {
    return Container(
      width: width,
      height: height,
      color: placeholderColor,
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
      ),
    );
  }
}
