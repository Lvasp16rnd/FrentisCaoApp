import 'package:flutter/material.dart';
import 'package:frentis_cao/core/app_theme.dart';

class PostImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final double placeholderIconSize;
  final bool rounded;
  final Widget? overlay;

  const PostImageGallery({
    super.key,
    required this.imageUrls,
    required this.height,
    this.placeholderIconSize = 48,
    this.rounded = false,
    this.overlay,
  });

  @override
  State<PostImageGallery> createState() => _PostImageGalleryState();
}

class _PostImageGalleryState extends State<PostImageGallery> {
  int _currentIndex = 0;

  List<String> get _imageUrls =>
      widget.imageUrls
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toList();

  @override
  Widget build(BuildContext context) {
    final imageUrls = _imageUrls;

    Widget child;
    if (imageUrls.isEmpty) {
      child = _PostImagePlaceholder(
        iconSize: widget.placeholderIconSize,
        message: 'Sem imagem',
      );
    } else {
      child = Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: imageUrls.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openImageViewer(context, imageUrls, index),
                child: _NetworkPostImage(
                  imageUrl: imageUrls[index],
                  iconSize: widget.placeholderIconSize,
                ),
              );
            },
          ),
          if (imageUrls.length > 1) ...[
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: _ImageDots(
                count: imageUrls.length,
                currentIndex: _currentIndex,
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: _ImageCounter(
                currentIndex: _currentIndex,
                count: imageUrls.length,
              ),
            ),
          ],
          if (widget.overlay != null) widget.overlay!,
        ],
      );
    }

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius:
            widget.rounded ? BorderRadius.circular(8) : BorderRadius.zero,
        child: child,
      ),
    );
  }
}

class _NetworkPostImage extends StatelessWidget {
  final String imageUrl;
  final double iconSize;

  const _NetworkPostImage({required this.imageUrl, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      Uri.encodeFull(imageUrl),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder:
          (context, error, stackTrace) => _PostImagePlaceholder(
            iconSize: iconSize,
            message: 'Imagem indisponivel',
          ),
    );
  }
}

class _PostImagePlaceholder extends StatelessWidget {
  final double iconSize;
  final String message;

  const _PostImagePlaceholder({required this.iconSize, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight.withValues(alpha: 0.25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: iconSize, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageDots extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _ImageDots({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final selected = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: selected ? 18 : 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(color: Color(0x26000000), blurRadius: 2),
            ],
          ),
        );
      }),
    );
  }
}

class _ImageCounter extends StatelessWidget {
  final int currentIndex;
  final int count;

  const _ImageCounter({required this.currentIndex, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${currentIndex + 1}/$count',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }
}

void _openImageViewer(
  BuildContext context,
  List<String> imageUrls,
  int initialIndex,
) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder:
          (_) => _PostImageViewer(
            imageUrls: imageUrls,
            initialIndex: initialIndex,
          ),
    ),
  );
}

class _PostImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _PostImageViewer({required this.imageUrls, required this.initialIndex});

  @override
  State<_PostImageViewer> createState() => _PostImageViewerState();
}

class _PostImageViewerState extends State<_PostImageViewer> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: Image.network(
                      Uri.encodeFull(widget.imageUrls[index]),
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.broken_image_outlined,
                            size: 56,
                            color: AppColors.white,
                          ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              left: 8,
              top: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.white),
              ),
            ),
            if (widget.imageUrls.length > 1)
              Positioned(
                right: 16,
                top: 18,
                child: Text(
                  '${_currentIndex + 1}/${widget.imageUrls.length}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
