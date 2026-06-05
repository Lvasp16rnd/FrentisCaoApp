import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/viewmodels/data_view_model.dart';
import 'package:frentis_cao/views/widgets/app_buttons.dart';
import 'package:frentis_cao/views/widgets/app_text_field.dart';

class NewCampaignView extends StatefulWidget {
  const NewCampaignView({super.key});

  @override
  State<NewCampaignView> createState() => _NewCampaignViewState();
}

class _NewCampaignViewState extends State<NewCampaignView> {
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();

  bool _isFreeService = true;
  bool _donationEnabled = true;
  DateTime? _selectedDate;
  final List<Uint8List> _imageBytes = [];
  final List<String> _imageFileNames = [];
  String? _error;

  String get _campaignType => _isFreeService ? 'Gratuito' : 'Pago';

  String get _formattedDate {
    final date = _selectedDate;
    if (date == null) return '';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String get _displayDate {
    final date = _selectedDate;
    if (date == null) return 'Selecionar data';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final images = await ImagePicker().pickMultiImage(limit: 3);
    if (images.isEmpty) return;

    final selectedImages = images.take(3).toList();
    final bytes = <Uint8List>[];
    for (final image in selectedImages) {
      bytes.add(await image.readAsBytes());
    }
    setState(() {
      _imageBytes
        ..clear()
        ..addAll(bytes);
      _imageFileNames
        ..clear()
        ..addAll(selectedImages.map((image) => image.name));
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (selected == null) return;
    setState(() => _selectedDate = selected);
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Informe o título da campanha.');
      return;
    }

    setState(() => _error = null);

    final vm = context.read<DataViewModel>();
    final success = await vm.createCampaign(
      title: title,
      description: _descriptionCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      date: _formattedDate,
      type: _campaignType,
      instructions: _instructionsCtrl.text.trim(),
      donationEnabled: _donationEnabled,
      imageBytes: _imageBytes,
      imageFileNames: _imageFileNames,
    );

    if (!mounted) return;
    if (success) {
      context.pop(true);
      return;
    }

    setState(() => _error = 'Não foi possível criar a campanha.');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DataViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Stack(
                children: [
                  Positioned(
                    left: 12,
                    top: 8,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Nova campanha',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child:
                            _imageBytes.isEmpty
                                ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      color: AppColors.primary,
                                      size: 42,
                                    ),
                                    SizedBox(height: 8),
                                    Text('Adicionar até 3 imagens'),
                                  ],
                                )
                                : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.all(8),
                                  itemCount: _imageBytes.length,
                                  separatorBuilder:
                                      (context, index) =>
                                          const SizedBox(width: 8),
                                  itemBuilder:
                                      (context, index) => ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.memory(
                                          _imageBytes[index],
                                          width: 140,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppTextField(label: 'Título', controller: _titleCtrl),
                    const SizedBox(height: 12),
                    _ServiceSwitch(
                      isFreeService: _isFreeService,
                      onChanged:
                          (value) => setState(() => _isFreeService = value),
                    ),
                    const SizedBox(height: 12),
                    _DonationSwitch(
                      donationEnabled: _donationEnabled,
                      onChanged:
                          (value) => setState(() => _donationEnabled = value),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Local', controller: _locationCtrl),
                    const SizedBox(height: 12),
                    _DatePickerField(
                      value: _displayDate,
                      hasValue: _selectedDate != null,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 12),
                    _MultiLineField(
                      label: 'Descrição',
                      controller: _descriptionCtrl,
                    ),
                    const SizedBox(height: 12),
                    _MultiLineField(
                      label: 'Instruções',
                      controller: _instructionsCtrl,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: PrimaryButton(
                label: 'Publicar campanha',
                isLoading: vm.isCreatingCampaign,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceSwitch extends StatelessWidget {
  final bool isFreeService;
  final ValueChanged<bool> onChanged;

  const _ServiceSwitch({required this.isFreeService, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_outlined, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isFreeService ? 'Servico gratuito' : 'Servico pago',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Switch(
            value: isFreeService,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _DonationSwitch extends StatelessWidget {
  final bool donationEnabled;
  final ValueChanged<bool> onChanged;

  const _DonationSwitch({
    required this.donationEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.volunteer_activism, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              donationEnabled
                  ? 'Botao de doacao habilitado'
                  : 'Botao de doacao desabilitado',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Switch(
            value: donationEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String value;
  final bool hasValue;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.value,
    required this.hasValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outline),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      hasValue
                          ? AppColors.darkText
                          : AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.outline),
          ],
        ),
      ),
    );
  }
}

class _MultiLineField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _MultiLineField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 5,
      decoration: InputDecoration(labelText: label, alignLabelWithHint: true),
    );
  }
}
