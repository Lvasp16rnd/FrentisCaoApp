import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:frentis_cao/views/main/donations_mock_view.dart';
import 'package:frentis_cao/views/adoptions/my_adoptions_view.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 130,
              height: 130,
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
              child: const Icon(
                Icons.person,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Name
            Text(
              'Usuário FrentisCão',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryContainer,
              ),
            ),
            const SizedBox(height: 3),

            // Contact
            Text(
              'usuario@email.com | (63) 99999-9999',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                letterSpacing: 0.4,
                color: AppColors.grey,
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
                    onTap: () {},
                  ),
                  const SizedBox(height: 4),
                  _ProfileOption(
                    icon: Icons.event,
                    label: 'Campanhas Salvas',
                    onTap: () {},
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
