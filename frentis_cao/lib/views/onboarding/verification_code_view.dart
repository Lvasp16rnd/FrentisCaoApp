import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/viewmodels/auth_view_model.dart';
import 'package:frentis_cao/views/widgets/app_background.dart';
import 'package:frentis_cao/views/widgets/app_buttons.dart';
import 'package:frentis_cao/views/widgets/progression_bar.dart';
import 'package:go_router/go_router.dart';

class VerificationCodeView extends StatefulWidget {
  const VerificationCodeView({super.key});

  @override
  State<VerificationCodeView> createState() => _VerificationCodeViewState();
}

class _VerificationCodeViewState extends State<VerificationCodeView> {
  static const _codeLength = 8;

  final List<TextEditingController> _controllers = List.generate(
    _codeLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _codeLength,
    (_) => FocusNode(),
  );

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _handleCodeChanged(String value, int index) {
    final sanitized = value.replaceAll(RegExp(r'\s'), '');

    if (sanitized.length > 1) {
      final startIndex = sanitized.length >= _codeLength ? 0 : index;
      _fillCode(sanitized, startIndex);
      return;
    }

    if (sanitized != value) {
      _controllers[index].text = sanitized;
    }

    if (sanitized.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (sanitized.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _fillCode(String value, int startIndex) {
    final chars = value.replaceAll(RegExp(r'\s'), '').split('');
    final availableSlots = _codeLength - startIndex;
    final charsToApply = chars.take(availableSlots).toList();

    for (var i = 0; i < charsToApply.length; i++) {
      final controller = _controllers[startIndex + i];
      controller.text = charsToApply[i];
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    }

    final nextIndex = (startIndex + charsToApply.length).clamp(
      0,
      _codeLength - 1,
    );
    _focusNodes[nextIndex].requestFocus();
  }

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
                currentStep: 4,
                totalSteps: 5,
                stepLabel: 'Passo 4: Verificação',
                onBack: () => context.pop(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        'Verifique seu e-mail',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Verifique na sua caixa de e-mails e preencha o código a seguir',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_codeLength, (i) {
                          return Container(
                            width: 36,
                            height: 55,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            child: TextField(
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.characters,
                              autocorrect: false,
                              enableSuggestions: false,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.outline,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged:
                                  (value) => _handleCodeChanged(value, i),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      if (vm.error != null)
                        Text(
                          vm.error!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                child: Column(
                  children: [
                    PrimaryButton(
                      label: 'Verificar',
                      isLoading: vm.isLoading,
                      onPressed: () async {
                        final success = await vm.verifyCode(_code);
                        if (success && context.mounted) {
                          context.push('/onboarding/completion');
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Código reenviado!')),
                        );
                      },
                      child: const Text(
                        'Reenviar código',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
