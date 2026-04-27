import 'package:flutter/material.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/views/main/home_tab.dart';
import 'package:frentis_cao/views/main/adoption_tab.dart';
import 'package:frentis_cao/views/main/campaigns_tab.dart';
import 'package:frentis_cao/views/main/profile_tab.dart';

/// Shell principal com BottomNavigationBar customizada.
/// Tab bar do Figma: height 53px, white, shadow, 4 items com
/// ícone ativo em pill verde (#27C840) e label Inter 11px.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _tabs = [
    HomeTab(),
    AdoptionTab(),
    CampaignsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              spreadRadius: -2,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _TabItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isSelected: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _TabItem(
              icon: Icons.pets,
              label: 'Adoção',
              isSelected: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            _TabItem(
              icon: Icons.event,
              label: 'Eventos',
              isSelected: _currentIndex == 2,
              onTap: () => setState(() => _currentIndex = 2),
            ),
            _TabItem(
              icon: Icons.person,
              label: 'Perfil',
              isSelected: _currentIndex == 3,
              onTap: () => setState(() => _currentIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF27C840) : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.white : AppColors.darkText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
