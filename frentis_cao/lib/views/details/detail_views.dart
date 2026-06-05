import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/models/content_models.dart';
import 'package:frentis_cao/views/checkout/checkout_mock_view.dart';

/// Tela de detalhes de um post do feed.
/// Layout: AppBar verde → header ONG → imagem grande → conteúdo → botões Doar/Compartilhar
class PostDetailView extends StatelessWidget {
  final PostModel post;
  const PostDetailView({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            _buildAppBar(context, 'FrentisCão'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ONG header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primaryLight,
                            child: Text(
                              _avatarInitial(post.orgName),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              post.orgName,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const Icon(Icons.more_horiz, size: 18),
                        ],
                      ),
                    ),

                    // Image
                    Container(
                      height: 308,
                      width: double.infinity,
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Doação necessária',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            post.fullDescription.isNotEmpty
                                ? post.fullDescription
                                : post.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 10),
                          // Tag chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.outlineVariant,
                              ),
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
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  // Donate button (yellow/amber from Figma #FFC107)
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CheckoutMockView(receiverName: post.orgName),
                          ),
                        );
                      },
                      icon: const Icon(Icons.volunteer_activism, size: 20),
                      label: const Text('Doar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        foregroundColor: AppColors.secondaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Share button (outline)
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: OutlinedButton(
                      onPressed: () => Share.share(_postShareText(post)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondaryContainer,
                        side: const BorderSide(
                          color: AppColors.secondaryContainer,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                      ),
                      child: const Text('Compartilhar'),
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

/// Tela de detalhes do animal para adoção.
/// Layout: AppBar verde → imagem + info row → sobre → galeria de fotos
class AnimalDetailView extends StatelessWidget {
  final AnimalModel animal;
  const AnimalDetailView({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, 'Adoção'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Image + info row (from Figma: 131x131 image + info panel)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Animal photo
                        Container(
                          width: 131,
                          height: 131,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.pets,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Info panel
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoRow('Nome', animal.name),
                              const SizedBox(height: 5),
                              _infoRow('Raça', animal.breed),
                              const SizedBox(height: 5),
                              _infoRow('Idade', animal.age),
                              const SizedBox(height: 5),
                              _infoRow('Sexo', animal.gender),
                              const SizedBox(height: 5),
                              _infoRow('Porte', animal.size),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Status chips
                    Row(
                      children: [
                        _statusChip('Vacinado', animal.vaccinated),
                        const SizedBox(width: 8),
                        _statusChip('Castrado', animal.castrated),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // About section
                    Text(
                      'Sobre ${animal.name}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      animal.about.isNotEmpty
                          ? animal.about
                          : 'Informações sobre o animal em breve.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),

                    // Photo gallery section
                    Text(
                      'Fotos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        separatorBuilder:
                            (context, index) => const SizedBox(width: 8),
                        itemBuilder:
                            (_, i) => Container(
                              width: 120,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.photo_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Contact button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Interesse Registrado!'),
                        content: Text('A ONG responsável pelo ${animal.name} entrará em contato com você em breve pelo WhatsApp.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone, size: 20),
                  label: const Text('Tenho interesse'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.25,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            active
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.progressBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle : Icons.cancel_outlined,
            size: 14,
            color: active ? AppColors.primary : AppColors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: active ? AppColors.primary : AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tela de detalhes da campanha.
/// Layout: AppBar verde → imagem + info row → descrição → instruções → imagem → botões
class CampaignDetailView extends StatelessWidget {
  final CampaignModel campaign;
  const CampaignDetailView({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, 'Campanha'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Image + info row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 131,
                          height: 131,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _CampaignImage(
                            imageUrl: campaign.imageUrl,
                            iconSize: 48,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  campaign.title,
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.1,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        campaign.location,
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.1,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      campaign.date,
                                      style: const TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.1,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      campaign.type.isNotEmpty ? campaign.type : 'Campanha',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      campaign.description.isNotEmpty
                          ? campaign.description
                          : 'Detalhes da campanha em breve.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),

                    // Instructions
                    Text(
                      'Instruções',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      campaign.instructions.isNotEmpty
                          ? campaign.instructions
                          : 'Instruções em breve.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),

                    // Campaign image
                    _CampaignCarousel(imageUrls: campaign.imageUrls),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  if (campaign.donationEnabled) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.volunteer_activism, size: 20),
                        label: const Text('Doar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.secondaryContainer,
                          side: const BorderSide(
                            color: AppColors.secondaryContainer,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CheckoutMockView(receiverName: campaign.title),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondaryContainer,
                        side: const BorderSide(
                          color: AppColors.secondaryContainer,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                      ),
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

String _postShareText(PostModel post) {
  return [
    post.title,
    if (post.description.isNotEmpty) post.description,
    if (post.orgName.isNotEmpty) 'ONG: ${post.orgName}',
  ].join('\n');
}

String _avatarInitial(String value) {
  final text = value.trim();
  if (text.isEmpty) return '?';
  return text[0].toUpperCase();
}

String _campaignShareText(CampaignModel campaign) {
  return [
    campaign.title,
    if (campaign.description.isNotEmpty) campaign.description,
    if (campaign.location.isNotEmpty) 'Local: ${campaign.location}',
    if (campaign.date.isNotEmpty) 'Data: ${campaign.date}',
  ].join('\n');
}

class _CampaignImage extends StatelessWidget {
  final String imageUrl;
  final double iconSize;

  const _CampaignImage({required this.imageUrl, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Icon(
        Icons.image_outlined,
        size: iconSize,
        color: AppColors.primary,
      );
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder:
          (_, _, _) => Icon(
            Icons.image_outlined,
            size: iconSize,
            color: AppColors.primary,
          ),
    );
  }
}

class _CampaignCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const _CampaignCarousel({required this.imageUrls});

  @override
  State<_CampaignCarousel> createState() => _CampaignCarouselState();
}

class _CampaignCarouselState extends State<_CampaignCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final imageUrls = widget.imageUrls;

    if (imageUrls.isEmpty) {
      return Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.image_outlined,
          size: 48,
          color: AppColors.primary,
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: PageView.builder(
              itemCount: imageUrls.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return Image.network(
                  imageUrls[index],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        color: AppColors.primaryLight.withValues(alpha: 0.25),
                        child: const Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                );
              },
            ),
          ),
        ),
        if (imageUrls.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(imageUrls.length, (index) {
              final selected = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 18 : 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color:
                      selected ? AppColors.primary : AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

// Shared app bar matching Figma (back arrow green, title centered green, height 47)
Widget _buildAppBar(BuildContext context, String title) {
  return SizedBox(
    height: 47,
    child: Stack(
      children: [
        Positioned(
          left: 14,
          top: 12,
          child: GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ),
        Center(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.2,
              letterSpacing: -0.02 * 24,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    ),
  );
}
