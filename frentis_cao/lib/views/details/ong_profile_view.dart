import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/models/content_models.dart';
import 'package:frentis_cao/models/user_model.dart';
import 'package:frentis_cao/viewmodels/data_view_model.dart';
import 'package:frentis_cao/views/widgets/empty_state.dart';
import 'package:frentis_cao/views/widgets/ong_post_card.dart';

class OngProfileView extends StatelessWidget {
  final String orgId;
  final String orgName;
  final String orgAvatarUrl;
  final String cnpj;
  final String description;
  final String phone;

  const OngProfileView({
    super.key,
    required this.orgId,
    required this.orgName,
    this.orgAvatarUrl = '',
    this.cnpj = '12.345.678/0001-90',
    this.description =
        'Esta ONG atua no acolhimento, cuidado e divulgação de animais que precisam de ajuda, adoção responsável e doações.',
    this.phone = '(63) 99999-9999',
  });

  factory OngProfileView.fromPost(PostModel post) {
    return OngProfileView(
      orgId: post.orgId,
      orgName: post.orgName.isEmpty ? 'ONG' : post.orgName,
      orgAvatarUrl: post.orgAvatarUrl,
    );
  }

  factory OngProfileView.fromUser(UserModel ong) {
    return OngProfileView(
      orgId: ong.id ?? '',
      orgName: ong.name.isEmpty ? 'ONG' : ong.name,
      orgAvatarUrl: ong.photoUrl ?? '',
      phone: ong.phone?.trim().isNotEmpty == true ? ong.phone! : '(63) 99999-9999',
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DataViewModel>();
    final ongPosts = vm.posts.where(_belongsToOng).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Campanhas',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Column(
          children: [
            _OngHeader(
              orgName: orgName,
              orgAvatarUrl: orgAvatarUrl,
              cnpj: cnpj,
              description: description,
              phone: phone,
              onShare: () => SharePlus.instance.share(
                ShareParams(text: 'Conheça a ONG $orgName no FrentisCão.'),
              ),
            ),
            const Material(
              color: AppColors.white,
              child: TabBar(
                labelColor: AppColors.darkText,
                unselectedLabelColor: AppColors.grey,
                indicatorColor: AppColors.darkText,
                tabs: [Tab(text: 'Posts'), Tab(text: 'Campanhas')],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _OngPostsList(posts: ongPosts),
                  const _MockCampaignsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _belongsToOng(PostModel post) {
    if (orgId.trim().isNotEmpty && post.orgId == orgId) return true;
    return _normalize(post.orgName) == _normalize(orgName);
  }
}

class _OngHeader extends StatelessWidget {
  final String orgName;
  final String orgAvatarUrl;
  final String cnpj;
  final String description;
  final String phone;
  final VoidCallback onShare;

  const _OngHeader({
    required this.orgName,
    required this.orgAvatarUrl,
    required this.cnpj,
    required this.description,
    required this.phone,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: orgAvatarUrl.isEmpty ? null : NetworkImage(orgAvatarUrl),
                child: orgAvatarUrl.isEmpty
                    ? Text(
                        _avatarInitial(orgName),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orgName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text('CNPJ: $cnpj'),
                  ],
                ),
              ),
              Column(
                children: [
                  OutlinedButton(
                    onPressed: onShare,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: const Text('Compartilhar', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone, size: 14),
                    label: const Text('Contatar', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Descrição',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.darkText),
          ),
          const SizedBox(height: 8),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _OngPostsList extends StatelessWidget {
  final List<PostModel> posts;

  const _OngPostsList({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const EmptyState(
        icon: Icons.article_outlined,
        title: 'Nenhum post desta ONG',
        message: 'Quando esta ONG publicar posts, eles aparecerão aqui.',
      );
    }

    final vm = context.watch<DataViewModel>();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OngPostCard(
            post: post,
            onTap: () => context.push('/post-detail', extra: post),
            canManage: vm.ownsPost(post),
            isLiked: vm.isPostLiked(post),
            likeCount: vm.likeCountForPost(post),
            onLike: () => context.read<DataViewModel>().togglePostLike(post),
            onShare: () => SharePlus.instance.share(ShareParams(text: _postShareText(post))),
          ),
        );
      },
    );
  }
}

class _MockCampaignsList extends StatelessWidget {
  const _MockCampaignsList();

  @override
  Widget build(BuildContext context) {
    const campaigns = [
      ('Doação de ração', 'Ajude a manter os animais alimentados este mês.'),
      ('Campanha de adoção', 'Divulgação de animais que estão aguardando um lar.'),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        final campaign = campaigns[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: AppColors.white,
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.volunteer_activism, color: AppColors.white),
            ),
            title: Text(campaign.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(campaign.$2),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}

String _avatarInitial(String value) {
  final text = value.trim();
  if (text.isEmpty) return '?';
  return text[0].toUpperCase();
}

String _normalize(String value) => value.trim().toLowerCase();

String _postShareText(PostModel post) {
  return [
    post.title,
    if (post.description.isNotEmpty) post.description,
    if (post.orgName.isNotEmpty) 'ONG: ${post.orgName}',
  ].join('\n');
}
