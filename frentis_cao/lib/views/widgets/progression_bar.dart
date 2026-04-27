import 'package:flutter/material.dart';
import 'package:frentis_cao/core/app_theme.dart';

/// Barra de progresso do fluxo de cadastro (paw icon + step label + progress line)
class ProgressionBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String stepLabel;
  final VoidCallback? onBack;

  const ProgressionBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabel,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 33,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                if (onBack != null)
                  GestureDetector(
                    onTap: onBack,
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                const Spacer(),
                const Icon(Icons.pets, size: 14, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  stepLabel,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const Spacer(),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
        // Progress line
        SizedBox(
          height: 2,
          child: Stack(
            children: [
              Container(color: AppColors.progressBg),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
