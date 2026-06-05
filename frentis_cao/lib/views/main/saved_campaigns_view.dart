import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/models/content_models.dart';
import 'package:frentis_cao/viewmodels/data_view_model.dart';
import 'package:frentis_cao/views/widgets/empty_state.dart';
import 'package:frentis_cao/views/widgets/campaign_card.dart';
import 'package:frentis_cao/services/supabase_data_service.dart';

class SavedCampaignsView extends StatefulWidget {
  const SavedCampaignsView({super.key});

  @override
  State<SavedCampaignsView> createState() => _SavedCampaignsViewState();
}

class _SavedCampaignsViewState extends State<SavedCampaignsView> {
  late Future<List<CampaignModel>> _savedCampaignsFuture;

  @override
  void initState() {
    super.initState();
    _savedCampaignsFuture = SupabaseDataService().fetchMySavedCampaigns();
  }

  void _refreshSavedCampaigns() {
    setState(() {
      _savedCampaignsFuture = SupabaseDataService().fetchMySavedCampaigns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DataViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Campanhas Salvas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: FutureBuilder<List<CampaignModel>>(
        future: _savedCampaignsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final campaigns = snapshot.data ?? [];
          if (campaigns.isEmpty) {
            return const EmptyState(
              icon: Icons.bookmark_border,
              title: 'Nenhuma campanha salva',
              message: 'Toque em salvar nas campanhas para encontra-las aqui.',
              topPadding: 0,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            itemCount: campaigns.length,
            itemBuilder: (context, index) {
              final campaign = campaigns[index];
              final isSaved = vm.isCampaignSaved(campaign) || campaign.saves.contains(SupabaseDataService().currentUserId);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CampaignCard(
                  campaign: campaign,
                  isSaved: isSaved,
                  onSave: () async {
                    await vm.toggleCampaignSaved(campaign);
                    _refreshSavedCampaigns();
                  },
                  onTap: () => context.push('/campaign-detail', extra: campaign).then((_) => _refreshSavedCampaigns()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
