import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:frentis_cao/views/main/donations_mock_view.dart';
import 'package:frentis_cao/views/adoptions/my_adoptions_view.dart';
import 'package:frentis_cao/services/supabase_data_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final SupabaseDataService _dataService = SupabaseDataService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isUploading = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _dataService.fetchUserProfile();
    if (mounted) {
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );

      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      final imageUrl = await _dataService.uploadUserAvatar(File(image.path));

      if (imageUrl != null && mounted) {
        setState(() {
          _userData?['avatar_url'] = imageUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto atualizada com sucesso!')),
        );
      }
    } catch (e) {
      debugPrint('Erro no upload: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar foto.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
  Future<void> _showEditDialog(String currentName, String currentPhone) async {
    final nameController = TextEditingController(text: currentName == 'Adicionar Nome' ? '' : currentName);
    final phoneController = TextEditingController(text: currentPhone == '(00) 00000-0000' ? '' : currentPhone);
    final maskFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####', 
      filter: {"#": RegExp(r'[0-9]')},
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Perfil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                inputFormatters: [maskFormatter],
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Telefone'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      setState(() => _isLoading = true);
      final success = await _dataService.updateProfileData(nameController.text, phoneController.text);
      if (success) {
        await _loadProfile();
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao atualizar perfil.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final nameStr = _userData?['name']?.toString();
    final phoneStr = _userData?['phone']?.toString();

    final name = (nameStr == null || nameStr.isEmpty) ? 'Adicionar Nome' : nameStr;
    final email = _userData?['email'] ?? 'usuario@email.com';
    final phone = (phoneStr == null || phoneStr.isEmpty) ? '(00) 00000-0000' : phoneStr;
    final avatarUrl = _userData?['avatar_url'] as String?;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
        child: Column(
          children: [
            // Avatar
            GestureDetector(
              onTap: _isUploading ? null : _pickAndUploadImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 50,
                          spreadRadius: -2,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: _isUploading
                        ? const Center(child: CircularProgressIndicator())
                        : (avatarUrl != null && avatarUrl.isNotEmpty)
                            ? Image.network(avatarUrl, fit: BoxFit.cover)
                            : const Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.primary,
                              ),
                  ),
                  if (!_isUploading)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Info and Edit Icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const SizedBox(width: 48), // Spacer to balance the IconButton
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryContainer,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$email | $phone',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            letterSpacing: 0.4,
                            color: AppColors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primary),
                    onPressed: () => _showEditDialog(name, phone),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Feature cards container
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
              child: Column(
                children: [
                  _ProfileOption(
                    icon: Icons.favorite_border,
                    label: 'Favoritos',
                    onTap: () => context.push('/favorites'),
                  ),
                  const SizedBox(height: 4),
                  _ProfileOption(
                    icon: Icons.pets,
                    label: 'Minhas Adoções',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MyAdoptionsView(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  _ProfileOption(
                    icon: Icons.access_time_filled,
                    label: 'Doações Recorrentes',
                    onTap: () => context.push('/recurring-donations'),
                  ),
                  const SizedBox(height: 4),
                  _ProfileOption(
                    icon: Icons.event,
                    label: 'Campanhas Salvas',
                    onTap: () => context.push('/saved-campaigns'),
                  ),
                  const SizedBox(height: 4),
                  _ProfileOption(
                    icon: Icons.payments_outlined,
                    label: 'Últimas Doações',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DonationsMockView(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  _ProfileOption(
                    icon: Icons.logout,
                    label: 'Logout',
                    isLogout: true,
                    onTap: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLogout;

  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: isLogout ? const Color(0x78FF2D55) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.secondaryContainer),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
                color: AppColors.secondaryContainer,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.secondaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}
