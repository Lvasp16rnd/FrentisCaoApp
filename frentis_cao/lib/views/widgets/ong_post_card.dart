import 'package:flutter/material.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/models/content_models.dart';
import 'package:frentis_cao/views/widgets/post_image_gallery.dart';

class OngPostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onOrgTap;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isLiked;
  final bool isSaved;
  final int likeCount;
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  const OngPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onOrgTap,
    this.canManage = false,
    this.onEdit,
    this.onDelete,
    this.isLiked = false,
    this.isSaved = false,
    this.likeCount = 0,
    this.onLike,
    this.onSave,
    this.onShare,
  });

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                children: [
                  InkWell(
                    onTap: onOrgTap,
                    borderRadius: BorderRadius.circular(20),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage:
                          post.orgAvatarUrl.isEmpty
                              ? null
                              : NetworkImage(post.orgAvatarUrl),
                      child:
                          post.orgAvatarUrl.isEmpty
                              ? Text(
                                _avatarInitial(post.orgName),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.white,
                                ),
                              )
                              : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: InkWell(
                      onTap: onOrgTap,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          post.orgName,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  if (canManage)
                    PopupMenuButton<_PostAction>(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_vert, size: 18),
                      onSelected: (action) {
                        switch (action) {
                          case _PostAction.edit:
                            onEdit?.call();
                            break;
                          case _PostAction.delete:
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder:
                          (context) => const [
                            PopupMenuItem(
                              value: _PostAction.edit,
                              child: Text('Editar post'),
                            ),
                            PopupMenuItem(
                              value: _PostAction.delete,
                              child: Text(
                                'Deletar post',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                    ),
                ],
              ),
            ),
            PostImageGallery(
              imageUrls: post.imageUrls,
              height: 280,
              overlay:
                  _isUrgent(post.tag)
                      ? Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error,
                                size: 14,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Urgente',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : null,
            ),
            Padding(
              padding: const EdgeInsets.all(7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
                  const SizedBox(height: 8),
                  _PostActionBar(
                    isLiked: isLiked,
                    isSaved: isSaved,
                    likeCount: likeCount,
                    onLike: onLike,
                    onSave: onSave,
                    onShare: onShare,
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

enum _PostAction { edit, delete }

class _PostActionBar extends StatelessWidget {
  final bool isLiked;
  final bool isSaved;
  final int likeCount;
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  const _PostActionBar({
    required this.isLiked,
    required this.isSaved,
    required this.likeCount,
    this.onLike,
    this.onSave,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          label: likeCount.toString(),
          color: isLiked ? AppColors.error : AppColors.onSurfaceVariant,
          onTap: onLike,
        ),
        const SizedBox(width: 4),
        _ActionButton(
          icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
          label: 'Salvar',
          color: isSaved ? AppColors.primary : AppColors.onSurfaceVariant,
          onTap: onSave,
        ),
        const Spacer(),
        _ActionButton(
          icon: Icons.share_outlined,
          label: 'Compartilhar',
          color: AppColors.onSurfaceVariant,
          onTap: onShare,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _avatarInitial(String value) {
  final text = value.trim();
  if (text.isEmpty) return '?';
  return text[0].toUpperCase();
}

bool _isUrgent(String value) => value.trim().toLowerCase() == 'urgente';
