import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/models/content_models.dart';
import 'package:frentis_cao/viewmodels/data_view_model.dart';
import 'package:frentis_cao/views/widgets/app_background.dart';
import 'package:frentis_cao/views/widgets/app_buttons.dart';
import 'package:frentis_cao/views/widgets/app_text_field.dart';

class NewPostView extends StatefulWidget {
  final PostModel? post;

  const NewPostView({super.key, this.post});

  @override
  State<NewPostView> createState() => _NewPostViewState();
}

class _NewPostViewState extends State<NewPostView> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _fullDescriptionCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();

  final List<Uint8List> _imageBytes = [];
  final List<String> _imageFileNames = [];
  String? _error;

  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    final post = widget.post;
    if (post == null) return;
    _titleCtrl.text = post.title;
    _descriptionCtrl.text = post.description;
    _fullDescriptionCtrl.text = post.fullDescription;
    _tagCtrl.text = post.tag;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _fullDescriptionCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
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

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Informe o titulo do post.');
      return;
    }

    setState(() => _error = null);

    final vm = context.read<DataViewModel>();
    final post = widget.post;
    final success =
        post == null
            ? await vm.createPost(
              title: title,
              description: _descriptionCtrl.text.trim(),
              fullDescription: _fullDescriptionCtrl.text.trim(),
              tag: _tagCtrl.text.trim(),
              imageBytes: _imageBytes,
              imageFileNames: _imageFileNames,
            )
            : await vm.updatePost(
              post: post,
              title: title,
              description: _descriptionCtrl.text.trim(),
              fullDescription: _fullDescriptionCtrl.text.trim(),
              tag: _tagCtrl.text.trim(),
              imageBytes: _imageBytes,
              imageFileNames: _imageFileNames,
            );

    if (!mounted) return;
    if (success) {
      context.pop(true);
      return;
    }

    setState(
      () =>
          _error =
              _isEditing
                  ? 'Nao foi possivel atualizar o post.'
                  : 'Nao foi possivel criar o post.',
    );
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
                        _isEditing ? 'Editar post' : 'Novo post',
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
                        onTap: _pickImages,
                        child: Container(
                          height: 230,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _PostImagePickerPreview(
                            imageBytes: _imageBytes,
                            imageUrls: widget.post?.imageUrls ?? const [],
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
                      const SizedBox(height: 12),
                      AppTextField(label: 'Tag (ex: Recorrente)', controller: _tagCtrl),
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
                  label: _isEditing ? 'Salvar post' : 'Publicar post',
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

class _PostImagePickerPreview extends StatelessWidget {
  final List<Uint8List> imageBytes;
  final List<String> imageUrls;

  const _PostImagePickerPreview({
    required this.imageBytes,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    if (imageBytes.isEmpty && imageUrls.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            color: AppColors.primary,
            size: 42,
          ),
          SizedBox(height: 8),
          Text('Adicionar ate 3 imagens'),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageBytes.isNotEmpty)
          _MemoryImagePreview(imageBytes: imageBytes)
        else
          _NetworkImagePreview(imageUrls: imageUrls),
        Positioned(
          right: 10,
          bottom: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _MemoryImagePreview extends StatelessWidget {
  final List<Uint8List> imageBytes;

  const _MemoryImagePreview({required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      itemCount: imageBytes.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder:
          (context, index) => ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.memory(
              imageBytes[index],
              width: 150,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
    );
  }
}

class _NetworkImagePreview extends StatelessWidget {
  final List<String> imageUrls;

  const _NetworkImagePreview({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      itemCount: imageUrls.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder:
          (context, index) => ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              Uri.encodeFull(imageUrls[index].trim()),
              width: 150,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    width: 150,
                    color: AppColors.primaryLight.withValues(alpha: 0.25),
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.primary,
                    ),
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
