import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frentis_cao/viewmodels/auth_view_model.dart';
import 'package:frentis_cao/views/widgets/app_buttons.dart';
import 'package:frentis_cao/views/widgets/app_text_field.dart';
import 'package:frentis_cao/views/widgets/progression_bar.dart';

class UserDataView extends StatefulWidget {
  const UserDataView({super.key});

  @override
  State<UserDataView> createState() => _UserDataViewState();
}

class _UserDataViewState extends State<UserDataView> {
  final _phoneCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _birthCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _cpfCtrl.dispose();
    _birthCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ProgressionBar(
              currentStep: 3,
              totalSteps: 4,
              stepLabel: 'Passo 3: Seus Dados',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      'Precisamos de alguns dados seus',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 30),

                    AppTextField(
                      label: 'Telefone',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      onChanged: vm.setPhone,
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'CPF / CNPJ',
                      controller: _cpfCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Data de nascimento',
                      controller: _birthCtrl,
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 40),

                    if (vm.error != null) ...[
                      Text(
                        vm.error!,
                        style: const TextStyle(color: Color(0xFFF24822), fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                    ],

                    PrimaryButton(
                      label: 'Próximo',
                      isLoading: vm.isLoading,
                      onPressed: () async {
                        final success = await vm.register();
                        if (success && context.mounted) {
                          context.push('/onboarding/verification');
                        }
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
