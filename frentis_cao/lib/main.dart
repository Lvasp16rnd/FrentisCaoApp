import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frentis_cao/core/app_theme.dart';
import 'package:frentis_cao/core/app_router.dart';
import 'package:frentis_cao/viewmodels/auth_view_model.dart';
import 'package:frentis_cao/viewmodels/data_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');

    final supabaseUrl = dotenv.env['SUPABASE_URL']?.trim() ?? '';
    final supabaseKey =
        dotenv.env['SUPABASE_ANON_KEY']?.trim() ??
        dotenv.env['SUPABASE_PUBLISHABLE_KEY']?.trim() ??
        '';

    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      runApp(
        const FrentisCaoBootstrapError(
          message:
              'Configure SUPABASE_URL e SUPABASE_ANON_KEY ou '
              'SUPABASE_PUBLISHABLE_KEY no arquivo .env.',
        ),
      );
      return;
    }

    await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);

    runApp(const FrentisCaoApp());
  } catch (error) {
    runApp(FrentisCaoBootstrapError(message: 'Falha ao iniciar o app: $error'));
  }
}

class FrentisCaoBootstrapError extends StatelessWidget {
  final String message;

  const FrentisCaoBootstrapError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FrentisCao',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Configuracao pendente',
                    style: AppTheme.light.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(message, style: AppTheme.light.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Text(
                    'Edite frentis_cao/.env usando frentis_cao/.env.example '
                    'como base.',
                    style: AppTheme.light.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FrentisCaoApp extends StatelessWidget {
  const FrentisCaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DataViewModel()),
      ],
      child: MaterialApp.router(
        title: 'FrentisCao',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR')],
        routerConfig: AppRouter.router,
      ),
    );
  }
}
