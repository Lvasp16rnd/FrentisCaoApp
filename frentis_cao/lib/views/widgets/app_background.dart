import 'package:flutter/material.dart';

/// Widget que aplica o background decorativo do protótipo Figma usando imagem PNG.
///
/// Figma: Vector — `assets/background/img.png`
/// Posicionado absolutamente: width=357, height=1214, left=6.5, top=-26.
///
/// [opacity] permite variar a intensidade (0.4 nas telas de cadastro, 0.52 nas demais).
class AppBackground extends StatelessWidget {
  final Widget child;
  final double opacity;

  const AppBackground({
    super.key,
    required this.child,
    this.opacity = 0.52,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background decorativo usando imagem PNG (Figma Vector)
        Positioned(
          left: 6.5,
          top: -26,
          child: Opacity(
            opacity: opacity,
            child: Image.asset(
              'assets/background/img.png',
              width: 357,
              height: 1214,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Conteúdo acima do background
        child,
      ],
    );
  }
}
