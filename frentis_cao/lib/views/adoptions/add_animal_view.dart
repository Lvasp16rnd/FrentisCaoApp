import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:frentis_cao/viewmodels/data_view_model.dart';
import 'package:frentis_cao/services/supabase_data_service.dart';

class AddAnimalView extends StatefulWidget {
  const AddAnimalView({super.key});

  @override
  State<AddAnimalView> createState() => _AddAnimalViewState();
}

class _AddAnimalViewState extends State<AddAnimalView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _aboutController = TextEditingController();

  String _gender = 'Macho';
  String _size = 'Médio';
  bool _vaccinated = false;
  bool _castrated = false;

  final List<File> _selectedImages = [];
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        final newImages = images.map((e) => File(e.path)).toList();
        if (_selectedImages.length + newImages.length > 4) {
          final remainingSlots = 4 - _selectedImages.length;
          if (remainingSlots > 0) {
            _selectedImages.addAll(newImages.take(remainingSlots));
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Você pode adicionar no máximo 4 fotos.')),
          );
        } else {
          _selectedImages.addAll(newImages);
        }
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, adicione pelo menos uma foto do animal.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await SupabaseDataService().insertAnimal(
      name: _nameController.text.trim(),
      breed: _breedController.text.trim(),
      age: _ageController.text.trim(),
      gender: _gender,
      size: _size,
      about: _aboutController.text.trim(),
      vaccinated: _vaccinated,
      castrated: _castrated,
      imageFiles: _selectedImages,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        if (context.mounted) {
          context.read<DataViewModel>().fetchAnimals();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animal cadastrado com sucesso!')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao cadastrar animal. Tente novamente.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cadastrar Animal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Picker
                Column(
                  children: [
                    if (_selectedImages.isEmpty)
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 48, color: AppColors.primary),
                                SizedBox(height: 12),
                                Text(
                                  'Adicionar Fotos (Até 4)',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          // Lista horizontal das imagens selecionadas
                          SizedBox(
                            height: 120,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              separatorBuilder: (context, idx) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: FileImage(_selectedImages[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImages.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close, size: 16, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_selectedImages.length < 4)
                            TextButton.icon(
                              onPressed: _pickImages,
                              icon: const Icon(Icons.add_photo_alternate),
                              label: const Text('Adicionar mais fotos'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Animal *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),

                // Breed & Age row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _breedController,
                        decoration: const InputDecoration(
                          labelText: 'Raça',
                          border: OutlineInputBorder(),
                          hintText: 'Ex: SRD',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _ageController,
                        decoration: const InputDecoration(
                          labelText: 'Idade',
                          border: OutlineInputBorder(),
                          hintText: 'Ex: 2 anos',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Gender & Size Dropdowns
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _gender,
                        decoration: const InputDecoration(
                          labelText: 'Gênero',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Macho', 'Fêmea'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _gender = val!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _size,
                        decoration: const InputDecoration(
                          labelText: 'Porte',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Pequeno', 'Médio', 'Grande'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _size = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Switches
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: AppColors.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Vacinado'),
                        value: _vaccinated,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setState(() => _vaccinated = val),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Castrado'),
                        value: _castrated,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setState(() => _castrated = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // About
                TextFormField(
                  controller: _aboutController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Sobre o Animal (História)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Cadastrar Animal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
