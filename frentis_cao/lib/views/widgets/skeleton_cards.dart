import 'package:flutter/material.dart';
import 'package:frentis_cao/core/app_theme.dart';

/// Skeleton reutilizavel para o card de animal em adocao.
class AdoptionCardSkeleton extends StatelessWidget {
  const AdoptionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SkeletonBox(
              width: double.infinity,
              borderRadius: BorderRadius.zero,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 72, height: 14),
                SizedBox(height: 6),
                SkeletonBox(width: 96, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton reutilizavel para o card de post de ONG.
class OngPostCardSkeleton extends StatelessWidget {
  const OngPostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              children: [
                SkeletonBox(
                  width: 24,
                  height: 24,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                SizedBox(width: 6),
                Expanded(child: SkeletonBox(height: 14)),
                SizedBox(width: 12),
                SkeletonBox(
                  width: 18,
                  height: 18,
                  borderRadius: BorderRadius.all(Radius.circular(9)),
                ),
              ],
            ),
          ),
          SkeletonBox(
            height: 200,
            width: double.infinity,
            borderRadius: BorderRadius.zero,
          ),
          Padding(
            padding: EdgeInsets.all(7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 180, height: 14),
                SizedBox(height: 8),
                SkeletonBox(width: double.infinity, height: 12),
                SizedBox(height: 4),
                SkeletonBox(width: 220, height: 12),
                SizedBox(height: 8),
                SkeletonBox(width: 86, height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton reutilizavel para o card de campanha.
class CampaignCardSkeleton extends StatelessWidget {
  const CampaignCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: const Row(
        children: [
          SkeletonBox(
            width: 120,
            height: double.infinity,
            borderRadius: BorderRadius.zero,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 78, height: 18),
                  SizedBox(height: 10),
                  SkeletonBox(width: double.infinity, height: 14),
                  SizedBox(height: 8),
                  SkeletonBox(width: 140, height: 12),
                  SizedBox(height: 8),
                  SkeletonBox(width: 96, height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloco base de shimmer para compor estados de carregamento.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadiusGeometry borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceDim.withValues(alpha: 0.55),
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  final Widget child;

  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final shimmerWidth = bounds.width * 0.8;
            final dx =
                (bounds.width + shimmerWidth) * _controller.value -
                shimmerWidth;

            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.surfaceDim.withValues(alpha: 0.55),
                AppColors.white.withValues(alpha: 0.85),
                AppColors.surfaceDim.withValues(alpha: 0.55),
              ],
              stops: const [0.1, 0.5, 0.9],
            ).createShader(Rect.fromLTWH(dx, 0, shimmerWidth, bounds.height));
          },
          child: child,
        );
      },
    );
  }
}
