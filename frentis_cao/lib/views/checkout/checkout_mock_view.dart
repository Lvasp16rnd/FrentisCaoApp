// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frentis_cao/views/widgets/app_buttons.dart';
import 'package:frentis_cao/views/checkout/payment_success_view.dart';

class CheckoutMockView extends StatefulWidget {
  final String receiverName;
  final bool isRecurring;

  const CheckoutMockView({
    super.key,
    required this.receiverName,
    this.isRecurring = false,
  });

  @override
  State<CheckoutMockView> createState() => _CheckoutMockViewState();
}

class _CheckoutMockViewState extends State<CheckoutMockView> {
  double _selectedAmount = 10.0;
  late String _selectedMethod;
  bool _isLoading = false;

  final List<double> _presetAmounts = [10.0, 20.0, 50.0, 100.0];

  @override
  void initState() {
    super.initState();
    // Se for recorrente, forçar o uso do cartão
    _selectedMethod = widget.isRecurring ? 'card' : 'pix';
  }

  void _processMockPayment() async {
    setState(() {
      _isLoading = true;
    });

    // Simula o tempo de processamento do Mercado Pago (2 segundos)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Navega para a tela de sucesso
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PaymentSuccessView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fazer Doação'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.isRecurring) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.pink[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.pink),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Assinatura Mensal - Apoio Recorrente',
                        style: TextStyle(
                          color: Colors.pink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Cabeçalho
            Text(
              'Ajudando:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.receiverName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 32),

            // Seleção de Valor
            Text(
              'Escolha o valor',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _presetAmounts.map((amount) {
                final isSelected = _selectedAmount == amount;
                return ChoiceChip(
                  label: Text(
                    widget.isRecurring ? 'R\$ ${amount.toInt()}/mês' : 'R\$ ${amount.toInt()}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Theme.of(context).primaryColor,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedAmount = amount;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Seleção de Método de Pagamento
            Text(
              'Método de Pagamento',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (!widget.isRecurring) ...[
                    RadioListTile<String>(
                      title: const Row(
                        children: [
                          Icon(Icons.pix, color: Colors.teal),
                          SizedBox(width: 12),
                          Text('Pix (Aprovação imediata)'),
                        ],
                      ),
                      value: 'pix',
                      groupValue: _selectedMethod,
                      onChanged: (val) {
                        setState(() {
                          _selectedMethod = val!;
                        });
                      },
                    ),
                    const Divider(height: 1),
                  ],
                  RadioListTile<String>(
                    title: const Row(
                      children: [
                        Icon(Icons.credit_card, color: Colors.blue),
                        SizedBox(width: 12),
                        Text('Cartão de Crédito'),
                      ],
                    ),
                    value: 'card',
                    groupValue: _selectedMethod,
                    onChanged: (val) {
                      setState(() {
                        _selectedMethod = val!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Botão de Pagamento
            PrimaryButton(
              label: 'Doar R\$ ${_selectedAmount.toInt()}',
              isLoading: _isLoading,
              onPressed: _processMockPayment,
            ),
            const SizedBox(height: 16),
            const Text(
              'Pagamento 100% seguro processado pelo Mercado Pago.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
