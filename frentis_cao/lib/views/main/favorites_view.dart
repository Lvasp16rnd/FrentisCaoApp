import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/models/content_models.dart';
import 'package:frentis_cao/viewmodels/data_view_model.dart';
import 'package:frentis_cao/views/widgets/empty_state.dart';
import 'package:frentis_cao/views/widgets/ong_post_card.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DataViewModel>();
    final posts = vm.savedPosts;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _FavoritesAppBar(onBack: () => context.pop()),
            Expanded(
              child:
                  posts.isEmpty
                      ? const EmptyState(
                        icon: Icons.bookmark_border,
                        title: 'Voce ainda nao salvou posts',
                        message:
                            'Toque em Salvar nos posts que quiser encontrar novamente aqui.',
                        topPadding: 0,
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: OngPostCard(
                              post: post,
                              onTap:
                                  () =>
                                      context.push('/post-detail', extra: post),
                              isLiked: vm.isPostLiked(post),
                              isSaved: vm.isPostSaved(post),
                              likeCount: vm.likeCountForPost(post),
                              onLike: () => vm.togglePostLike(post),
                              onSave: () => vm.togglePostSaved(post),
                              onShare: () => Share.share(_postShareText(post)),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

String _postShareText(PostModel post) {
  return [
    post.title,
    if (post.description.isNotEmpty) post.description,
    if (post.orgName.isNotEmpty) 'ONG: ${post.orgName}',
  ].join('\n');
}

class _FavoritesAppBar extends StatelessWidget {
  final VoidCallback onBack;

  const _FavoritesAppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47,
      child: Stack(
        children: [
          Positioned(
            left: 14,
            top: 12,
            child: GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
          const Center(
            child: Text(
              'Favoritos',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
