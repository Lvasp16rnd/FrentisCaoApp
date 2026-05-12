import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/views/widgets/app_background.dart';
import 'package:frentis_cao/views/widgets/app_buttons.dart';

/// Completion screen que aparece após o usuário concluir toda a verificação.
/// Mostra mensagem de sucesso "Tudo certo, hora de começar!" com ilustração e botão para ir à home.
class CompletionScreen extends StatelessWidget {
  const CompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        opacity: 0.4,
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
                        const SizedBox(height: 40),

                        // Success icon
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            size: 50,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Illustration placeholder - cat-and-dog/cuate style
                        Container(
                          height: 250,
                          width: 280,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.pets,
                            size: 100,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Main message
                        Text(
                          'Tudo certo, hora de começar!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.darkText,
                            fontWeight: FontWeight.w700,
                            fontSize: 25,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'Seu cadastro foi concluído com sucesso! 🎉\n\nAgora você pode explorar o mundo de adoções, campanhas e fazer a diferença na vida de muitos animais.',
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
                  label: 'Explorar Home',
                  onPressed: () => context.go('/home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

