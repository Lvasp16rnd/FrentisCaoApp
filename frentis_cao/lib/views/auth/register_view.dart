import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/viewmodels/auth_view_model.dart';
import 'package:frentis_cao/views/widgets/app_buttons.dart';
import 'package:frentis_cao/views/widgets/app_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 80),
                // Illustration placeholder
                Container(
                  height: 200,
                  width: 250,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.home_outlined,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 40),

                // Name
                AppTextField(
                  label: 'Nome completo',
                  controller: _nameCtrl,
                  onChanged: vm.setName,
                ),
                const SizedBox(height: 10),

                // Email
                AppTextField(
                  label: 'E-mail',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: vm.setEmail,
                ),
                const SizedBox(height: 10),

                // Password
                AppTextField(
                  label: 'Senha',
                  controller: _passCtrl,
                  obscureText: _obscure,
                  onChanged: vm.setPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 26),

                if (vm.error != null) ...[
                  Text(
                    vm.error!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                ],

                PrimaryButton(
                  label: 'Cadastrar',
                  isLoading: vm.isLoading,
                  onPressed: () {
                    vm.setName(_nameCtrl.text.trim());
                    vm.setEmail(_emailCtrl.text.trim());
                    vm.setPassword(_passCtrl.text);
                    context.push('/onboarding/user-type');
                  },
                ),
                const SizedBox(height: 14),

                GestureDetector(
                  onTap: () => context.pop(),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: const [
                        TextSpan(text: 'Já possui conta? '),
                        TextSpan(
                          text: 'Entrar',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                const SizedBox(
                  width: 230,
                  child: Divider(color: AppColors.surfaceDim),
                ),
                const SizedBox(height: 14),

                AppOutlineButton(
                  label: 'Cadastrar com Google',
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  onPressed: () async {
                    final success = await vm.loginWithGoogle();
                    if (success && context.mounted) {
                      context.push('/onboarding/user-type');
                    }
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
