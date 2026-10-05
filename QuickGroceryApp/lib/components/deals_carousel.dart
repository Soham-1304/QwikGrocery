import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/banner_item.dart';

/// Auto-scrolling promo banner carousel with smooth page transitions.
class DealsCarousel extends StatefulWidget {
  const DealsCarousel({
    super.key,
    required this.banners,
    this.onSelectCategory,
  });
  final List<BannerItem> banners;
  final void Function(String? category)? onSelectCategory;

  @override
  State<DealsCarousel> createState() => _DealsCarouselState();
}

class _DealsCarouselState extends State<DealsCarousel> {
  late final PageController _page;
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _page = PageController(viewportFraction: 0.88);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.banners.isEmpty) return;
      final next = (_current + 1) % widget.banners.length;
      _page.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _page,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: _BannerCard(
                banner: widget.banners[i],
                onTap: widget.onSelectCategory != null
                    ? () => widget.onSelectCategory!(widget.banners[i].categoryFilter)
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _Dots(count: widget.banners.length, current: _current),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner, this.onTap});
  final BannerItem banner;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [banner.primaryColor, banner.secondaryColor],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.12,
                child: Icon(
                  banner.icon,
                  size: 150,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (banner.tag.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        banner.tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    banner.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  if (banner.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      banner.subtitle,
                      style: TextStyle(
                        color: Colors.white.withAlpha(210),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      count,
      (i) => AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: i == current ? 18 : 6,
        height: 6,
        decoration: BoxDecoration(
          color: i == current
              ? AppColors.emeraldPrimary
              : AppColors.outline,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    ),
  );
}
