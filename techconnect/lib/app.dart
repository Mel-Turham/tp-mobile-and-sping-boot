import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techconnect/screens/auth/login_screen.dart';
import 'package:techconnect/screens/auth/register_technician_screen.dart';
import 'package:techconnect/screens/auth/register_user_screen.dart';
import 'package:techconnect/screens/contact/contact_screen.dart';
import 'package:techconnect/screens/home/technician_detail_screen.dart';
import 'package:techconnect/screens/main_navigation_screen.dart';
import 'package:techconnect/screens/onboarding/onboarding_screen.dart';
import 'package:techconnect/screens/ratings/my_ratings_screen.dart';
import 'package:techconnect/screens/ratings/technician_reviews_screen.dart';
import 'package:techconnect/services/auth_service.dart';
import 'package:techconnect/theme/app_theme.dart';

class TechConnectApp extends StatelessWidget {
  const TechConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/onboarding',
      redirect: (context, state) {
        final authService = context.read<AuthService>();
        final isAuthenticated = authService.isAuthenticated;
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register-user' ||
            state.matchedLocation == '/register-technician' ||
            state.matchedLocation == '/onboarding';

        if (!isAuthenticated && !isAuthRoute) return '/login';
        if (isAuthenticated && isAuthRoute) return '/';
        return null;
      },
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register-user',
          builder: (context, state) => const RegisterUserScreen(),
        ),
        GoRoute(
          path: '/register-technician',
          builder: (context, state) => const RegisterTechnicianScreen(),
        ),
        // Navigation principale avec tabs
        GoRoute(
          path: '/',
          builder: (context, state) => const MainNavigationScreen(initialIndex: 0),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const MainNavigationScreen(initialIndex: 1),
        ),
        GoRoute(
          path: '/ratings',
          builder: (context, state) => const MainNavigationScreen(initialIndex: 2),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const MainNavigationScreen(initialIndex: 3),
        ),
        // Routes secondaires (détails, contact)
        GoRoute(
          path: '/technician/:id',
          builder: (context, state) => TechnicianDetailScreen(
            id: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/technician/:id/reviews',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return TechnicianReviewsScreen(
              technicianId: int.parse(state.pathParameters['id']!),
              technicianName: extra?['name'] ?? 'Technicien',
            );
          },
        ),
        GoRoute(
          path: '/contact',
          builder: (context, state) => ContactScreen(
            technicianEmail: state.extra as String?,
          ),
        ),
        GoRoute(
          path: '/my-ratings',
          builder: (context, state) => const MyRatingsScreen(),
        ),
        // Redirection pour compatibilité avec l'ancienne route
        GoRoute(
          path: '/dashboard',
          redirect: (context, state) => '/',
        ),
      ],
    );

    return MaterialApp.router(
      title: 'TechConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
