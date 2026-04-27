import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frentis_cao/services/mock_data.dart';
import 'package:frentis_cao/views/widgets/adoption_card.dart';

class AdoptionTab extends StatelessWidget {
  const AdoptionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Animais para Adoção',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final animal = MockData.animals[index];
                  return AdoptionCard(
                    animal: animal,
                    onTap: () => context.push('/animal-detail', extra: animal),
                  );
                },
                childCount: MockData.animals.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
