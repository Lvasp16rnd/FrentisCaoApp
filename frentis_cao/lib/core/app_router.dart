import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frentis_cao/models/content_models.dart';
import 'package:frentis_cao/views/auth/login_view.dart';
import 'package:frentis_cao/views/auth/register_view.dart';
import 'package:frentis_cao/views/onboarding/welcome_screen.dart';
import 'package:frentis_cao/views/onboarding/user_type_view.dart';
import 'package:frentis_cao/views/onboarding/terms_view.dart';
import 'package:frentis_cao/views/onboarding/user_data_view.dart';
import 'package:frentis_cao/views/onboarding/verification_code_view.dart';
import 'package:frentis_cao/views/onboarding/completion_screen.dart';
import 'package:frentis_cao/views/main/favorites_view.dart';
import 'package:frentis_cao/views/main/main_shell.dart';
import 'package:frentis_cao/views/details/detail_views.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    errorBuilder:
        (context, state) => const Scaffold(
          body: Center(
            child:
                CircularProgressIndicator(), // Uma tela neutra enquanto o Supabase processa o deep link
          ),
        ),
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/login'),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: '/onboarding/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/user-type',
        name: 'userType',
        builder: (context, state) => const UserTypeView(),
      ),
      GoRoute(
        path: '/onboarding/terms',
        name: 'terms',
        builder: (context, state) => const TermsView(),
      ),
      GoRoute(
        path: '/onboarding/user-data',
        name: 'userData',
        builder: (context, state) => const UserDataView(),
      ),
      GoRoute(
        path: '/onboarding/verification',
        name: 'verification',
        builder: (context, state) => const VerificationCodeView(),
      ),
      GoRoute(
        path: '/onboarding/completion',
        name: 'completion',
        builder: (context, state) => const CompletionScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesView(),
      ),
      GoRoute(
        path: '/post-detail',
        name: 'postDetail',
        builder:
            (context, state) => PostDetailView(post: state.extra! as PostModel),
      ),
      GoRoute(
        path: '/animal-detail',
        name: 'animalDetail',
        builder:
            (context, state) =>
                AnimalDetailView(animal: state.extra! as AnimalModel),
      ),
      GoRoute(
        path: '/campaign-detail',
        name: 'campaignDetail',
        builder:
            (context, state) =>
                CampaignDetailView(campaign: state.extra! as CampaignModel),
      ),
    ],
  );
}
