import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frentis_cao/services/mock_data.dart';
import 'package:frentis_cao/views/widgets/campaign_card.dart';

class CampaignsTab extends StatelessWidget {
  const CampaignsTab({super.key});

  @override
  Widget build(BuildContext context) {
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
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final campaign = MockData.campaigns[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CampaignCard(
                      campaign: campaign,
                      onTap: () => context.push('/campaign-detail', extra: campaign),
                    ),
                  );
                },
                childCount: MockData.campaigns.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
