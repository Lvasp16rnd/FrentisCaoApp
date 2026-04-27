import 'package:flutter/material.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/models/content_models.dart';

/// Card de post do feed (Home). Segue o protótipo:
/// Header (avatar + nome + more) → imagem 200px → conteúdo + tag chip
class OngPostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;

  const OngPostCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      post.orgName[0],
                      style: const TextStyle(fontSize: 11, color: AppColors.white),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      post.orgName,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.more_horiz, size: 18),
                ],
              ),
            ),
            // Image
            Container(
              height: 200,
              width: double.infinity,
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              child: const Icon(Icons.image_outlined, size: 48, color: AppColors.primary),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      height: 16 / 12,
                      letterSpacing: 0.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      post.tag,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
