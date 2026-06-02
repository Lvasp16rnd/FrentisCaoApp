import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/viewmodels/data_view_model.dart';
import 'package:frentis_cao/views/widgets/ong_post_card.dart';
import 'package:frentis_cao/views/widgets/skeleton_cards.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<DataViewModel>();
      if (vm.posts.isEmpty && !vm.isLoadingPosts) {
        vm.fetchPosts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DataViewModel>();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header: Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 39,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outlineVariant),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Pesquisar ONGs e posts...',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.outlineVariant,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Icon(Icons.search, color: AppColors.outlineVariant),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 39,
                    height: 39,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Category chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  _CategoryChip(label: 'Todos', selected: true),
                  SizedBox(width: 8),
                  _CategoryChip(label: 'ONGs'),
                  SizedBox(width: 8),
                  _CategoryChip(label: 'Protetores'),
                  SizedBox(width: 8),
                  _CategoryChip(label: 'Campanhas'),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // Posts feed
          if (true)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: OngPostCardSkeleton(),
                  );
                }, childCount: 3),
              ),
            )
          else if (vm.posts.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('Nenhum post encontrado.')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final post = vm.posts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OngPostCard(
                      post: post,
                      onTap: () => context.push('/post-detail', extra: post),
                    ),
                  );
                }, childCount: vm.posts.length),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _CategoryChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.white,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: selected ? AppColors.white : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
