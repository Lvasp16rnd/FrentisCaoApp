import 'package:flutter/material.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/views/widgets/empty_state.dart';

class RecurringDonationsView extends StatelessWidget {
  const RecurringDonationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Doações Recorrentes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: const SafeArea(
        child: EmptyState(
          icon: Icons.autorenew,
          title: 'Nenhuma doação recorrente',
          message: 'Você ainda não possui assinaturas de doações recorrentes ativas.',
          topPadding: 40,
        ),
      ),
    );
  }
}
