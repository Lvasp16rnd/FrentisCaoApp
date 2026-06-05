import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/viewmodels/data_view_model.dart';
import 'package:frentis_cao/views/widgets/app_background.dart';
import 'package:frentis_cao/views/widgets/app_buttons.dart';
import 'package:frentis_cao/views/widgets/app_text_field.dart';

class NewPostView extends StatefulWidget {
  const NewPostView({super.key});

  @override
  State<NewPostView> createState() => _NewPostViewState();
}

class _NewPostViewState extends State<NewPostView> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _fullDescriptionCtrl = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageFileName;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _fullDescriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imageFileName = image.name;
    });
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Informe o titulo do post.');
      return;
    }

    setState(() => _error = null);

    final vm = context.read<DataViewModel>();
    final success = await vm.createPost(
      title: title,
      description: _descriptionCtrl.text.trim(),
      fullDescription: _fullDescriptionCtrl.text.trim(),
      imageBytes: _imageBytes,
      imageFileName: _imageFileName,
    );

    if (!mounted) return;
    if (success) {
      context.pop(true);
      return;
    }

    setState(() => _error = 'Nao foi possivel criar o post.');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DataViewModel>();

    return Scaffold(
      body: SafeArea(
        child: AppBackground(
          opacity: 0.3,
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
                        'Novo post',
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
                          height: 230,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child:
                              _imageBytes == null
                                  ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        color: AppColors.primary,
                                        size: 42,
                                      ),
                                      SizedBox(height: 8),
                                      Text('Adicionar imagem'),
                                    ],
                                  )
                                  : Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.memory(
                                        _imageBytes!,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        right: 10,
                                        bottom: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.edit_outlined,
                                            size: 18,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      AppTextField(label: 'Titulo', controller: _titleCtrl),
                      const SizedBox(height: 12),
                      _MultiLineField(
                        label: 'Descricao breve',
                        controller: _descriptionCtrl,
                        minLines: 2,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 12),
                      _MultiLineField(
                        label: 'Descricao completa',
                        controller: _fullDescriptionCtrl,
                        minLines: 4,
                        maxLines: 7,
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
                  label: 'Publicar post',
                  isLoading: vm.isCreatingPost,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MultiLineField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;

  const _MultiLineField({
    required this.label,
    required this.controller,
    required this.minLines,
    required this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, alignLabelWithHint: true),
    );
  }
}
