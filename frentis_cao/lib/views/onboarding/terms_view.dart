import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/viewmodels/auth_view_model.dart';
import 'package:frentis_cao/views/widgets/app_background.dart';
import 'package:frentis_cao/views/widgets/app_buttons.dart';
import 'package:frentis_cao/views/widgets/progression_bar.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

  static const _termsText = '''
Termos de Uso

1. Aceitação dos Termos
Ao acessar e utilizar o aplicativo FrentisCão, você concorda em cumprir e ficar vinculado aos seguintes termos e condições de uso.

2. Descrição do Serviço
O FrentisCão é uma plataforma que conecta ONGs de proteção animal, protetores independentes e doadores, facilitando a adoção de animais, campanhas de cuidados e doações.

3. Cadastro e Conta
O usuário é responsável por manter a confidencialidade de sua conta e senha, e por restringir o acesso ao seu dispositivo.

4. Uso Aceitável
Você concorda em não utilizar o serviço para qualquer propósito ilegal ou não autorizado.

5. Doações
As doações realizadas através do aplicativo são processadas por provedores de pagamento terceirizados. O FrentisCão não armazena dados de cartão de crédito.

6. Privacidade
Seus dados pessoais são tratados conforme nossa Política de Privacidade, em conformidade com a LGPD (Lei Geral de Proteção de Dados).

7. Propriedade Intelectual
Todo o conteúdo do aplicativo é protegido por direitos autorais e outras leis de propriedade intelectual.

8. Limitação de Responsabilidade
O FrentisCão não se responsabiliza por danos diretos, indiretos, incidentais ou consequentes decorrentes do uso do aplicativo.

9. Modificações
Reservamo-nos o direito de modificar estes termos a qualquer momento. Alterações entrarão em vigor após publicação no aplicativo.

10. Contato
Para dúvidas sobre estes termos, entre em contato através do aplicativo.
''';

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
                currentStep: 2,
                totalSteps: 4,
                stepLabel: 'Passo 2: Termos de Privacidade',
                onBack: () => context.pop(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Termos de Uso e Política de Privacidade',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),

                      // Scrollable terms box
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _termsText,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Checkbox
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Li e concordo com os Termos de Uso e Política de Privacidade',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Checkbox(
                            value: vm.termsAccepted,
                            onChanged: (_) => vm.toggleTermsAccepted(),
                            activeColor: AppColors.primary,
                            side: const BorderSide(
                              color: AppColors.onSurfaceVariant,
                              width: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      PrimaryButton(
                        label: 'Próximo',
                        onPressed: vm.termsAccepted
                            ? () => context.push('/onboarding/user-data')
                            : null,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
