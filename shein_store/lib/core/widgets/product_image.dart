import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_motion.dart';
import '../constants/app_sizes.dart';
import '../extensions/localization_extension.dart';
import 'app_skeleton_loader.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    this.imageUrl,
    this.imageUrls = const [],
    this.height,
    this.width,
    this.radius = AppSizes.radius,
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final List<String> imageUrls;
  final double? height;
  final double? width;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl =
        imageUrl ?? (imageUrls.isNotEmpty ? imageUrls.first : null);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: width,
        child: resolvedUrl == null || resolvedUrl.isEmpty
            ? const _ProductImageFallback()
            : _ResolvedProductImage(resolvedUrl: resolvedUrl, fit: fit),
      ),
    );
  }
}

class _ResolvedProductImage extends StatelessWidget {
  const _ResolvedProductImage({required this.resolvedUrl, required this.fit});

  final String resolvedUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final looksRemote =
        resolvedUrl.startsWith('http://') || resolvedUrl.startsWith('https://');

    if (!looksRemote && !kIsWeb) {
      final file = File(resolvedUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return const _ProductImageFallback();
          },
        );
      }
    }

    return Image.network(
      resolvedUrl,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: AppMotion.duration(context, AppMotion.normal),
          curve: AppMotion.standard,
          child: child,
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return const _ProductImageLoading();
      },
      errorBuilder: (context, error, stackTrace) {
        return const _ProductImageFallback();
      },
    );
  }
}

class _ProductImageLoading extends StatelessWidget {
  const _ProductImageLoading();

  @override
  Widget build(BuildContext context) {
    return const AppSkeletonLoader(height: double.infinity, borderRadius: 0);
  }
}

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        border: Border.all(color: colors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact =
              constraints.maxHeight < 92 || constraints.maxWidth < 92;
          final iconSize = isCompact ? 20.0 : 26.0;
          final spacing = isCompact ? 4.0 : 6.0;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      color: colors.inactiveIcon,
                      size: iconSize,
                    ),
                    if (!isCompact) ...[
                      SizedBox(height: spacing),
                      Text(
                        context.tr('Image unavailable', 'الصورة غير متاحة'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
