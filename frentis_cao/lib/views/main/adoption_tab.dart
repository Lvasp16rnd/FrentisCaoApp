import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frentis_cao/viewmodels/data_view_model.dart';
import 'package:frentis_cao/views/widgets/adoption_card.dart';
import 'package:frentis_cao/views/widgets/empty_state.dart';
import 'package:frentis_cao/views/adoptions/add_animal_view.dart';
import 'package:frentis_cao/views/widgets/skeleton_cards.dart';

class AdoptionTab extends StatefulWidget {
  const AdoptionTab({super.key});

  @override
  State<AdoptionTab> createState() => _AdoptionTabState();
}

class _AdoptionTabState extends State<AdoptionTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<DataViewModel>();
      if (vm.animals.isEmpty && !vm.isLoadingAnimals) {
        vm.fetchAnimals();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DataViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddAnimalView()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.pets),
        label: const Text('Cadastrar'),
      ),
      body: SafeArea(
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
          if (vm.isLoadingAnimals)
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
                  (context, index) => const AdoptionCardSkeleton(),
                  childCount: 6,
                ),
              ),
            )
          else if (vm.animals.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.pets,
                title: 'Nenhum animal disponível no momento',
                message:
                    'Assim que uma ONG ou protetor cadastrar um animal, ele '
                    'aparecerá aqui para adoção.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final animal = vm.animals[index];
                  return AdoptionCard(
                    animal: animal,
                    onTap: () => context.push('/animal-detail', extra: animal),
                  );
                }, childCount: vm.animals.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
