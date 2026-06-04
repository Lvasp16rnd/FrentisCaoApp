import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/views/widgets/empty_state.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _FavoritesAppBar(onBack: () => context.pop()),
            const Expanded(
              child: EmptyState(
                icon: Icons.favorite_border,
                title: 'Você ainda não favoritou ninguém',
                message:
                    'Toque no coração dos animais que chamarem sua atenção '
                    'para encontrá-los novamente aqui.',
                topPadding: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesAppBar extends StatelessWidget {
  final VoidCallback onBack;

  const _FavoritesAppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 47,
      child: Stack(
        children: [
          Positioned(
            left: 14,
            top: 12,
            child: GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
          const Center(
            child: Text(
              'Favoritos',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
