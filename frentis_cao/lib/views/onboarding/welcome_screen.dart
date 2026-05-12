import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/views/widgets/app_background.dart';
import 'package:frentis_cao/views/widgets/app_buttons.dart';

/// Welcome screen que aparece após o usuário se registrar em RegisterView.
/// Mostra uma mensagem de boas-vindas com ilustração e botão para prosseguir.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        opacity: 0.52,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),

                        // Illustration placeholder - animal-shelter/bro style
                        Container(
                          height: 280,
                          width: 280,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.home_work_outlined,
                            size: 120,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Welcome message
                        Text(
                          'Conectando quem ama com quem precisa de um lar.',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.darkText,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'Bem-vindo ao FrentisCão! 🐾\n\nVocê está a poucos passos de se tornar parte de uma comunidade dedicada ao bem-estar animal.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),

              // Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: PrimaryButton(
                  label: 'Vamos Começar',
                  onPressed: () => context.push('/onboarding/user-type'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

