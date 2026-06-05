import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/models/content_models.dart';
import 'package:frentis_cao/models/user_model.dart';
import 'package:frentis_cao/viewmodels/data_view_model.dart';
import 'package:frentis_cao/views/widgets/app_background.dart';
import 'package:frentis_cao/views/widgets/campaign_card.dart';
import 'package:frentis_cao/views/widgets/ong_post_card.dart';
import 'package:frentis_cao/views/widgets/skeleton_cards.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _searchCtrl = TextEditingController();
  final _ongSuggestionsScrollCtrl = ScrollController();
  String _searchText = '';
  String _submittedSearchText = '';
  _HomeFilter _selectedFilter = _HomeFilter.ongs;
  bool _showOngSuggestions = false;
  Timer? _ongSuggestionsDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<DataViewModel>();
      if (vm.posts.isEmpty && !vm.isLoadingPosts) {
        vm.fetchPosts();
      }
    });
    _ongSuggestionsScrollCtrl.addListener(_onOngSuggestionsScroll);
  }

  @override
  void dispose() {
    _ongSuggestionsDebounce?.cancel();
    _ongSuggestionsScrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openNewPost() async {
    final created = await context.push<bool>('/post-new');
    if (created == true && mounted) {
      context.read<DataViewModel>().fetchPosts();
    }
  }

  Future<void> _refreshFeed() async {
    final vm = context.read<DataViewModel>();
    final futures = <Future<void>>[vm.fetchPosts()];
    if (_submittedSearchText.trim().isNotEmpty) {
      futures.add(vm.fetchCampaigns());
    }
    await Future.wait(futures);
  }

  Future<void> _openEditPost(PostModel post) async {
    final updated = await context.push<bool>('/post-edit', extra: post);
    if (updated == true && mounted) {
      context.read<DataViewModel>().fetchPosts();
    }
  }

  Future<void> _confirmDeletePost(PostModel post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Deletar post'),
            content: const Text('Tem certeza que deseja deletar este post?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Deletar',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true || !mounted) return;

    final deleted = await context.read<DataViewModel>().deletePost(post);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted ? 'Post deletado.' : 'Nao foi possivel deletar o post.',
        ),
      ),
    );
  }

  void _sharePost(PostModel post) {
    SharePlus.instance.share(ShareParams(text: _postShareText(post)));
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchText = value;
      _showOngSuggestions = value.trim().isNotEmpty;
    });

    _ongSuggestionsDebounce?.cancel();
    final query = value.trim();
    final vm = context.read<DataViewModel>();
    if (query.isEmpty) {
      vm.clearOngSuggestions();
      return;
    }

    _ongSuggestionsDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      context.read<DataViewModel>().searchOngSuggestions(query, reset: true);
    });
  }

  Future<void> _submitSearch([String? value]) async {
    final query = (value ?? _searchCtrl.text).trim();
    _ongSuggestionsDebounce?.cancel();
    FocusScope.of(context).unfocus();
    setState(() {
      _searchText = query;
      _submittedSearchText = query;
      _showOngSuggestions = false;
    });

    if (query.isEmpty) return;

    final vm = context.read<DataViewModel>();
    if (vm.campaigns.isEmpty && !vm.isLoadingCampaigns) {
      await vm.fetchCampaigns();
    }
  }

  void _clearSearch() {
    _ongSuggestionsDebounce?.cancel();
    _searchCtrl.clear();
    context.read<DataViewModel>().clearOngSuggestions();
    setState(() {
      _searchText = '';
      _submittedSearchText = '';
      _showOngSuggestions = false;
    });
  }

  void _selectOngSuggestion(UserModel ong) {
    _ongSuggestionsDebounce?.cancel();
    _searchCtrl.text = ong.name.trim();
    context.read<DataViewModel>().clearOngSuggestions();
    setState(() {
      _searchText = ong.name.trim();
      _submittedSearchText = ong.name.trim();
      _showOngSuggestions = false;
    });
    FocusScope.of(context).unfocus();
    context.push('/ong-profile', extra: ong);
  }

  void _onOngSuggestionsScroll() {
    if (!_ongSuggestionsScrollCtrl.hasClients || !_showOngSuggestions) return;
    final position = _ongSuggestionsScrollCtrl.position;
    if (position.pixels < position.maxScrollExtent - 80) return;

    final vm = context.read<DataViewModel>();
    if (!vm.isLoadingOngSuggestions && vm.hasMoreOngSuggestions) {
      vm.searchOngSuggestions(_searchText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DataViewModel>();
    final query = _normalize(_submittedSearchText);
    final isSearching = query.isNotEmpty;
    final searchedPosts =
        isSearching
            ? vm.posts
                .where(
                  (post) => _matches(query, [
                    post.title,
                    post.orgName,
                    post.description,
                  ]),
                )
                .toList()
            : vm.posts;
    final filteredPosts = _applyPostFilter(searchedPosts, _selectedFilter);
    final filteredCampaigns =
        isSearching
            ? vm.campaigns
                .where(
                  (campaign) => _matches(query, [
                    campaign.title,
                    campaign.location,
                    campaign.description,
                  ]),
                )
                .toList()
            : const <CampaignModel>[];
    final isLoading =
        vm.isLoadingPosts || (isSearching && vm.isLoadingCampaigns);

    return SafeArea(
      child: AppBackground(
        opacity: 0.42,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refreshFeed,
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                                color: AppColors.white,
                                border: Border.all(
                                  color: AppColors.outlineVariant,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _searchCtrl,
                                      onChanged: _onSearchChanged,
                                      onSubmitted: _submitSearch,
                                      textInputAction: TextInputAction.search,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        hintText: 'Search',
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.darkText,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    onPressed:
                                        _searchText.isEmpty
                                            ? null
                                            : _clearSearch,
                                    icon: Icon(
                                      _searchText.isEmpty
                                          ? Icons.search
                                          : Icons.close,
                                      color: AppColors.outlineVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 39,
                            height: 39,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.outlineVariant,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 22,
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
                        children: [
                          _CategoryChip(
                            label: "ONG's",
                            selected: _selectedFilter == _HomeFilter.ongs,
                            onTap:
                                () => setState(
                                  () => _selectedFilter = _HomeFilter.ongs,
                                ),
                          ),
                          const SizedBox(width: 8),
                          _CategoryChip(
                            label: 'Pets',
                            selected: _selectedFilter == _HomeFilter.pets,
                            onTap:
                                () => setState(
                                  () => _selectedFilter = _HomeFilter.pets,
                                ),
                          ),
                          const SizedBox(width: 8),
                          _CategoryChip(
                            label: 'Caes',
                            selected: _selectedFilter == _HomeFilter.dogs,
                            onTap:
                                () => setState(
                                  () => _selectedFilter = _HomeFilter.dogs,
                                ),
                          ),
                          const SizedBox(width: 8),
                          _CategoryChip(
                            label: 'Gatos',
                            selected: _selectedFilter == _HomeFilter.cats,
                            onTap:
                                () => setState(
                                  () => _selectedFilter = _HomeFilter.cats,
                                ),
                          ),
                          const SizedBox(width: 8),
                          _CategoryChip(
                            label: 'Recentes',
                            selected: _selectedFilter == _HomeFilter.recent,
                            onTap:
                                () => setState(
                                  () => _selectedFilter = _HomeFilter.recent,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 10)),

                  // Posts feed
                  if (isLoading)
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
                  else if (filteredPosts.isEmpty && filteredCampaigns.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          isSearching
                              ? 'Nenhum resultado encontrado.'
                              : 'Nenhum post encontrado.',
                        ),
                      ),
                    )
                  else
                    ..._buildResultSlivers(
                      context,
                      filteredPosts,
                      filteredCampaigns,
                      isSearching,
                    ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                onPressed: _openNewPost,
                tooltip: 'Novo post',
                child: const Icon(Icons.add),
              ),
            ),
            if (_showOngSuggestions)
              Positioned(
                left: 20,
                right: 69,
                top: 69,
                child: _OngSuggestionsDropdown(
                  controller: _ongSuggestionsScrollCtrl,
                  suggestions: vm.ongSuggestions,
                  isLoading: vm.isLoadingOngSuggestions,
                  onSelected: _selectOngSuggestion,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResultSlivers(
    BuildContext context,
    List<PostModel> filteredPosts,
    List<CampaignModel> filteredCampaigns,
    bool isSearching,
  ) {
    return [
      if (filteredPosts.isNotEmpty) ...[
        if (isSearching) const _ResultSectionTitle(label: 'Posts'),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            filteredCampaigns.isEmpty ? 92 : 18,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final post = filteredPosts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OngPostCard(
                  post: post,
                  onTap: () => context.push('/post-detail', extra: post),
                  onOrgTap: () => context.push('/ong-profile', extra: post),
                  canManage: context.read<DataViewModel>().ownsPost(post),
                  onEdit: () => _openEditPost(post),
                  onDelete: () => _confirmDeletePost(post),
                  isLiked: context.watch<DataViewModel>().isPostLiked(post),
                  isSaved: context.watch<DataViewModel>().isPostSaved(post),
                  likeCount: context.watch<DataViewModel>().likeCountForPost(
                    post,
                  ),
                  onLike:
                      () => context.read<DataViewModel>().togglePostLike(post),
                  onSave:
                      () => context.read<DataViewModel>().togglePostSaved(post),
                  onShare: () => _sharePost(post),
                ),
              );
            }, childCount: filteredPosts.length),
          ),
        ),
      ],
      if (filteredCampaigns.isNotEmpty) ...[
        const _ResultSectionTitle(label: 'Campanhas'),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 92),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final campaign = filteredCampaigns[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CampaignCard(
                  campaign: campaign,
                  onTap:
                      () => context.push('/campaign-detail', extra: campaign),
                ),
              );
            }, childCount: filteredCampaigns.length),
          ),
        ),
      ],
    ];
  }
}

bool _matches(String query, List<String> values) {
  return values.any((value) => _normalize(value).contains(query));
}

List<PostModel> _applyPostFilter(List<PostModel> posts, _HomeFilter filter) {
  final filtered = switch (filter) {
    _HomeFilter.ongs || _HomeFilter.pets || _HomeFilter.recent => posts,
    _HomeFilter.dogs =>
      posts
          .where(
            (post) =>
                _postHasAnyTerm(post, const ['cao', 'caes', 'cachorro', 'dog']),
          )
          .toList(),
    _HomeFilter.cats =>
      posts
          .where(
            (post) => _postHasAnyTerm(post, const ['gato', 'gatos', 'cat']),
          )
          .toList(),
  };

  if (filter == _HomeFilter.recent) {
    return [...filtered];
  }

  return filtered;
}

bool _postHasAnyTerm(PostModel post, List<String> terms) {
  final haystack = _normalize(
    '${post.title} ${post.description} ${post.fullDescription} ${post.tag}',
  );
  return terms.any(haystack.contains);
}

String _normalize(String value) {
  return value.trim().toLowerCase();
}

enum _HomeFilter { ongs, pets, dogs, cats, recent }

String _postShareText(PostModel post) {
  return [
    post.title,
    if (post.description.isNotEmpty) post.description,
    if (post.orgName.isNotEmpty) 'ONG: ${post.orgName}',
  ].join('\n');
}

class _ResultSectionTitle extends StatelessWidget {
  final String label;

  const _ResultSectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
      ),
    );
  }
}

class _OngSuggestionsDropdown extends StatelessWidget {
  final ScrollController controller;
  final List<UserModel> suggestions;
  final bool isLoading;
  final ValueChanged<UserModel> onSelected;

  const _OngSuggestionsDropdown({
    required this.controller,
    required this.suggestions,
    required this.isLoading,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = suggestions.length + (isLoading ? 1 : 0);

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 280),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child:
            suggestions.isEmpty && !isLoading
                ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'Nenhuma ONG encontrada.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                )
                : ListView.separated(
                  controller: controller,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: itemCount,
                  separatorBuilder:
                      (context, index) => const Divider(
                        height: 1,
                        color: AppColors.outlineVariant,
                      ),
                  itemBuilder: (context, index) {
                    if (index >= suggestions.length) {
                      return const SizedBox(
                        height: 46,
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    final ong = suggestions[index];
                    return InkWell(
                      onTap: () => onSelected(ong),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: AppColors.primaryLight,
                              backgroundImage:
                                  ong.photoUrl == null || ong.photoUrl!.isEmpty
                                      ? null
                                      : NetworkImage(ong.photoUrl!),
                              child:
                                  ong.photoUrl == null || ong.photoUrl!.isEmpty
                                      ? Text(
                                        _avatarInitial(ong.name),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.white,
                                        ),
                                      )
                                      : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                ong.name.isEmpty ? 'ONG' : ong.name,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
