import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frentis_cao/viewmodels/data_view_model.dart';
import 'package:frentis_cao/views/widgets/campaign_card.dart';
import 'package:frentis_cao/views/widgets/skeleton_cards.dart';

class CampaignsTab extends StatefulWidget {
  const CampaignsTab({super.key});

  @override
  State<CampaignsTab> createState() => _CampaignsTabState();
}

class _CampaignsTabState extends State<CampaignsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<DataViewModel>();
      if (vm.campaigns.isEmpty && !vm.isLoadingCampaigns) {
        vm.fetchCampaigns();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DataViewModel>();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Campanhas e Eventos',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          if (vm.isLoadingCampaigns)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: CampaignCardSkeleton(),
                  );
                }, childCount: 4),
              ),
            )
          else if (vm.campaigns.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('Nenhuma campanha cadastrada.')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final campaign = vm.campaigns[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CampaignCard(
                      campaign: campaign,
                      onTap:
                          () =>
                              context.push('/campaign-detail', extra: campaign),
                    ),
                  );
                }, childCount: vm.campaigns.length),
              ),
            ),
        ],
      ),
    );
  }
}
