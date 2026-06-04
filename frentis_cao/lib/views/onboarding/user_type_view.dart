import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/models/user_model.dart';
import 'package:frentis_cao/viewmodels/auth_view_model.dart';
import 'package:frentis_cao/views/widgets/app_background.dart';
import 'package:frentis_cao/views/widgets/app_buttons.dart';
import 'package:frentis_cao/views/widgets/progression_bar.dart';

class UserTypeView extends StatelessWidget {
  const UserTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      body: AppBackground(
        opacity: 0.4,
        child: SafeArea(
          child: Column(
            children: [
              ProgressionBar(
                currentStep: 1,
                totalSteps: 5,
                stepLabel: 'Passo 1: Tipo de Usuário',
                onBack: () => context.pop(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        'Como você quer fazer parte dessa causa?',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Selecione o tipo de usuário que representa você.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w200,
                          color: AppColors.darkText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      _UserTypeOption(
                        label: 'Doador',
                        selected: vm.selectedUserType == UserType.donor,
                        onTap: () => vm.selectUserType(UserType.donor),
                      ),
                      const SizedBox(height: 12),
                      _UserTypeOption(
                        label: 'Protetor Independente',
                        selected:
                            vm.selectedUserType ==
                            UserType.independentProtector,
                        onTap:
                            () => vm.selectUserType(
                              UserType.independentProtector,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _UserTypeOption(
                        label: 'ONG',
                        selected: vm.selectedUserType == UserType.ong,
                        onTap: () => vm.selectUserType(UserType.ong),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                child: PrimaryButton(
                  label: 'Próximo',
                  onPressed:
                      vm.selectedUserType != null
                          ? () => context.push('/onboarding/terms')
                          : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTypeOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _UserTypeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(41),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: selected ? AppColors.white : AppColors.secondaryContainer,
          ),
        ),
      ),
    );
  }
}
