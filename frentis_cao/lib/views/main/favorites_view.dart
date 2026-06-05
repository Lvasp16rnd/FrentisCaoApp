import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/models/content_models.dart';
import 'package:frentis_cao/viewmodels/data_view_model.dart';
import 'package:frentis_cao/views/widgets/empty_state.dart';
import 'package:frentis_cao/views/widgets/ong_post_card.dart';

import 'package:frentis_cao/services/supabase_data_service.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  late Future<List<PostModel>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = SupabaseDataService().fetchMyFavoritePosts();
  }

  void _refreshFavorites() {
    setState(() {
      _favoritesFuture = SupabaseDataService().fetchMyFavoritePosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DataViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _FavoritesAppBar(onBack: () => context.pop()),
            Expanded(
              child: FutureBuilder<List<PostModel>>(
                future: _favoritesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final posts = snapshot.data ?? [];
                  if (posts.isEmpty) {
                    return const EmptyState(
                      icon: Icons.favorite_border,
                      title: 'Você ainda não tem posts favoritos',
                      message: 'Toque no coração nos posts para encontra-los aqui.',
                      topPadding: 0,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      // Sincronizando com o viewmodel (otimista) pra sumir/voltar o coração
                      final isLiked = vm.isPostLiked(post) || post.likes.contains(SupabaseDataService().currentUserId);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: OngPostCard(
                          post: post,
                          onTap: () => context.push('/post-detail', extra: post).then((_) => _refreshFavorites()),
                          isLiked: isLiked,
                          likeCount: vm.likeCountForPost(post),
                          onLike: () async {
                            await vm.togglePostLike(post);
                            _refreshFavorites();
                          },
                          onShare: () => SharePlus.instance.share(
                            ShareParams(text: _postShareText(post)),
                          ),
                        ),
                      );
                    },
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
