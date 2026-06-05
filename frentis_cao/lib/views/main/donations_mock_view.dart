import 'package:flutter/material.dart';

class DonationsMockView extends StatelessWidget {
  const DonationsMockView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista mockada de doações com FOTOS para a apresentação
    final mockDonations = [
      {
        'receiver': 'Gatinhos da Vila',
        'amount': 'R\$ 15,00',
        'date': 'Agora mesmo',
        'status': 'Processando',
        'image': 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=200&h=200&fit=crop',
      },
      {
        'receiver': 'ONG Cão Amigo',
        'amount': 'R\$ 50,00',
        'date': '04 de Jun, 2026',
        'status': 'Aprovado',
        'image': 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=200&h=200&fit=crop',
      },
      {
        'receiver': 'Protetora Maria',
        'amount': 'R\$ 20,00',
        'date': '28 de Mai, 2026',
        'status': 'Aprovado',
        'image': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&h=200&fit=crop',
      },
      {
        'receiver': 'Campanha: Ração Solidária',
        'amount': 'R\$ 100,00',
        'date': '15 de Abr, 2026',
        'status': 'Aprovado',
        'image': 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=200&h=200&fit=crop',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Últimas Doações'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockDonations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final donation = mockDonations[index];
          final isProcessing = donation['status'] == 'Processando';
          final badgeColor = isProcessing ? Colors.orange : Colors.green;

          return GestureDetector(
            onTap: () => _showReceiptModal(context, donation, isProcessing),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Foto do Recebedor
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(donation['image'] as String),
                        backgroundColor: Colors.grey[200],
                      ),
                      // Bolinha piscante se estiver processando
                      if (isProcessing)
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  // Detalhes da Doação
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donation['receiver'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          donation['date'] as String,
                          style: TextStyle(
                            color: isProcessing ? Colors.orange[700] : Colors.grey,
                            fontSize: 12,
                            fontWeight: isProcessing ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Valor e Status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        donation['amount'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            if (isProcessing) ...[
                              const SizedBox(
                                width: 8,
                                height: 8,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              donation['status'] as String,
                              style: TextStyle(
                                color: badgeColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // MODAL DE RECIBO OU AVISO DE PROCESSAMENTO
  void _showReceiptModal(BuildContext context, Map<String, dynamic> donation, bool isProcessing) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isProcessing ? 'Aguardando Aprovação' : 'Comprovante de Doação',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              if (isProcessing)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Estamos aguardando o banco confirmar o pagamento. Isso pode levar alguns minutos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.orange, fontSize: 13),
                  ),
                ),

              _buildReceiptRow('Beneficiário', donation['receiver'] as String),
              const Divider(height: 24),
              _buildReceiptRow('Valor', donation['amount'] as String),
              const Divider(height: 24),
              _buildReceiptRow('Status', donation['status'] as String, highlightColor: isProcessing ? Colors.orange : Colors.green),
              const Divider(height: 24),
              _buildReceiptRow('ID da Transação', isProcessing ? 'Gerando...' : 'MP-89237498234'),
              const Divider(height: 24),
              _buildReceiptRow('Método', 'Pix'),
              const SizedBox(height: 32),
              
              if (!isProcessing)
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.download),
                  label: const Text('Baixar Comprovante'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )
                  ),
                )
              else
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    elevation: 0,
                  ),
                  child: const Text('Fechar'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value, {Color? highlightColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value, 
          style: TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 14,
            color: highlightColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
