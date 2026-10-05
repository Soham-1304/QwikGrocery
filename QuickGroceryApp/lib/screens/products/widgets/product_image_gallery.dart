import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ProductImageGallery extends StatelessWidget {
  const ProductImageGallery({
    super.key,
    required this.images,
    required this.imageUrl,
    required this.index,
    required this.controller,
    required this.onPageChanged,
  });

  final List<String> images;
  final String imageUrl;
  final int index;
  final PageController controller;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final urls = images.isNotEmpty ? images : (imageUrl.isNotEmpty ? [imageUrl] : <String>[]);
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          SizedBox(
            height: 260,
            child: urls.isEmpty
                ? const _NoImage()
                : PageView.builder(
                    controller: controller,
                    itemCount: urls.length,
                    onPageChanged: onPageChanged,
                    itemBuilder: (_, i) => Image.network(
                      urls[i],
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const _NoImage(),
                    ),
                  ),
          ),
          if (urls.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                urls.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == index
                        ? AppColors.emeraldPrimary
                        : AppColors.outline,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _NoImage extends StatelessWidget {
  const _NoImage();

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surfaceContainerLow,
    child: const Center(
      child: Icon(
        Icons.local_grocery_store_outlined,
        size: 64,
        color: AppColors.emeraldPrimary,
      ),
    ),
  );
}
