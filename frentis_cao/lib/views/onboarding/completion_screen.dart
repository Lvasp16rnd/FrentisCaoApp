import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/views/widgets/app_background.dart';
import 'package:frentis_cao/views/widgets/app_buttons.dart';
import 'package:frentis_cao/views/widgets/progression_bar.dart';

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
              const ProgressionBar(
                currentStep: 5,
                totalSteps: 5,
                stepLabel: 'Passo 5: Conclusão',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 54),
                      Image.asset(
                        'assets/pics/Cadastro/cat-and-dog/cuate.png',
                        width: 330,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 34),
                      _CompletionMessage(
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          color: AppColors.darkText,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(23, 12, 23, 45),
                child: PrimaryButton(
                  label: 'Concluir',
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

class _CompletionMessage extends StatelessWidget {
  final TextStyle? style;

  const _CompletionMessage({required this.style});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'Tudo certo, hora de\n'),
          TextSpan(
            text: 'começar!',
            style: style?.copyWith(color: AppColors.warning),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      style: style,
    );
  }
}
