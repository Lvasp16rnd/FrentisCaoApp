import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/core/app_router.dart';
import 'package:frentis_cao/viewmodels/auth_view_model.dart';

void main() {
  runApp(const FrentisCaoApp());
}

class FrentisCaoApp extends StatelessWidget {
  const FrentisCaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp.router(
        title: 'FrentisCão',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
