import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/views/widgets/app_background.dart';
import 'package:frentis_cao/views/widgets/app_buttons.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        opacity: 0.38,
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 4),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.primary,
                    ),
                    iconSize: 28,
                    splashRadius: 24,
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/login');
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      Image.asset(
                        'assets/pics/Cadastro/animal-shelter/bro.png',
                        width: 330,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 38),
                      _Tagline(
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.16,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(23, 12, 23, 45),
                child: PrimaryButton(
                  label: 'Continuar',
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

class _Tagline extends StatelessWidget {
  final TextStyle? style;

  const _Tagline({required this.style});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'Conectando quem '),
          TextSpan(
            text: 'ama',
            style: style?.copyWith(color: const Color(0xFFE74C3C)),
          ),
          const TextSpan(text: '\ncom quem precisa de um\n'),
          TextSpan(
            text: 'lar',
            style: style?.copyWith(color: const Color(0xFF2ECC71)),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
      style: style,
    );
  }
}
