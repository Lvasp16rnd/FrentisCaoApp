import 'package:flutter/material.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/models/content_models.dart';
import 'package:frentis_cao/services/supabase_data_service.dart';
import 'package:frentis_cao/views/widgets/empty_state.dart';

class MyAdoptionsView extends StatefulWidget {
  const MyAdoptionsView({super.key});

  @override
  State<MyAdoptionsView> createState() => _MyAdoptionsViewState();
}

class _MyAdoptionsViewState extends State<MyAdoptionsView> {
  late Future<List<AdoptionModel>> _adoptionsFuture;

  @override
  void initState() {
    super.initState();
    _adoptionsFuture = SupabaseDataService().fetchMyAdoptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Minhas Adoções'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: FutureBuilder<List<AdoptionModel>>(
        future: _adoptionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar adoções.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          final adoptions = snapshot.data ?? [];

          if (adoptions.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border,
              title: 'Você ainda não adotou nenhum animal.',
              message: 'Visite a aba de adoções, encontre seu novo melhor amigo e mude uma vida!',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: adoptions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final adoption = adoptions[index];
              final animal = adoption.animal;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppColors.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Imagem do Animal
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.primaryLight.withValues(alpha: 0.2),
                          image: animal != null && animal.imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(animal.imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: animal == null || animal.imageUrl.isEmpty
                            ? const Icon(Icons.pets, color: AppColors.primary)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      
                      // Informações
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              animal?.name ?? 'Animal Excluído',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Raça: ${animal?.breed ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Badge de Status
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(adoption.status).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                adoption.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(adoption.status),
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
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aprovado':
      case 'aprovada':
        return Colors.green;
      case 'rejeitado':
      case 'rejeitada':
        return AppColors.error;
      case 'em análise':
      case 'pendente':
      default:
        return Colors.orange;
    }
  }
}
