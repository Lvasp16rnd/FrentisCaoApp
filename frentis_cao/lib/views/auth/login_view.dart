import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/viewmodels/auth_view_model.dart';
import 'package:frentis_cao/views/widgets/app_buttons.dart';
import 'package:frentis_cao/views/widgets/app_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
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
                    Icons.pets,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 40),

                // Email
                AppTextField(
                  label: 'E-mail',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),

                // Password
                AppTextField(
                  label: 'Senha',
                  controller: _passCtrl,
                  obscureText: _obscure,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 26),

                // Error
                if (vm.error != null) ...[
                  Text(
                    vm.error!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                ],

                // Login button
                PrimaryButton(
                  label: 'Entrar',
                  isLoading: vm.isLoading,
                  onPressed: () async {
                    final success = await vm.login(
                      _emailCtrl.text.trim(),
                      _passCtrl.text,
                    );
                    if (success && context.mounted) {
                      context.go('/home');
                    }
                  },
                ),
                const SizedBox(height: 14),

                // Create account link
                GestureDetector(
                  onTap: () => context.push('/register'),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: const [
                        TextSpan(text: 'Não possui conta? '),
                        TextSpan(
                          text: 'Criar uma',
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

                // Divider
                const SizedBox(
                  width: 230,
                  child: Divider(color: AppColors.surfaceDim),
                ),
                const SizedBox(height: 14),

                // Google login
                AppOutlineButton(
                  label: 'Entrar com Google',
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  onPressed: () async {
                    final success = await vm.loginWithGoogle();
                    if (success && context.mounted) {
                      context.go('/home');
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
