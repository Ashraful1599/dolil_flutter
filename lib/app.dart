import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/home/screens/about_screen.dart';
import 'features/home/screens/contact_screen.dart';
import 'features/home/screens/privacy_policy_screen.dart';
import 'features/home/screens/terms_screen.dart';
import 'features/writer/screens/writer_profile_screen.dart';
import 'features/dashboard/screens/dashboard_shell.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/dolils/screens/dolils_list_screen.dart';
import 'features/dolils/screens/create_dolil_screen.dart';
import 'features/dolils/screens/dolil_detail_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/appointments/screens/appointments_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/admin/screens/admin_users_screen.dart';
import 'features/admin/screens/admin_dolils_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Splash
      GoRoute(path: '/', builder: (ctx, _) => const SplashScreen()),

      // Public auth
      GoRoute(path: '/login', builder: (ctx, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (ctx, _) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (ctx, _) => const ForgotPasswordScreen()),

      // Public pages
      GoRoute(path: '/home', builder: (ctx, _) => const HomeScreen()),
      GoRoute(path: '/about', builder: (ctx, _) => const AboutScreen()),
      GoRoute(path: '/contact', builder: (ctx, _) => const ContactScreen()),
      GoRoute(path: '/privacy', builder: (ctx, _) => const PrivacyPolicyScreen()),
      GoRoute(path: '/terms', builder: (ctx, _) => const TermsScreen()),

      // Writer profile (public)
      GoRoute(
        path: '/writers/:id',
        builder: (ctx, state) => WriterProfileScreen(writerId: int.parse(state.pathParameters['id']!)),
      ),

      // Create dolil (full screen, outside shell)
      GoRoute(
        path: '/dashboard/dolils/create',
        builder: (ctx, _) => const CreateDolilScreen(),
      ),

      // Dashboard shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (ctx, state, child) => DashboardShell(child: child, location: state.uri.toString()),
        routes: [
          GoRoute(path: '/dashboard', builder: (ctx, _) => const DashboardScreen()),
          GoRoute(
            path: '/dashboard/dolils',
            builder: (ctx, _) => const DolilsListScreen(),
          ),
          GoRoute(
            path: '/dashboard/dolils/:id',
            builder: (ctx, state) => DolilDetailScreen(dolilId: int.parse(state.pathParameters['id']!)),
          ),
          GoRoute(path: '/dashboard/notifications', builder: (ctx, _) => const NotificationsScreen()),
          GoRoute(path: '/dashboard/appointments', builder: (ctx, _) => const AppointmentsScreen()),
          GoRoute(path: '/dashboard/profile', builder: (ctx, _) => const ProfileScreen()),

          // Admin routes (also inside shell for bottom nav)
          GoRoute(path: '/admin', builder: (ctx, _) => const AdminDashboardScreen()),
          GoRoute(path: '/admin/users', builder: (ctx, _) => const AdminUsersScreen()),
          GoRoute(path: '/admin/dolils', builder: (ctx, _) => const AdminDolilsScreen()),
          GoRoute(path: '/admin/notifications', builder: (ctx, _) => const NotificationsScreen()),
        ],
      ),
    ],
  );
});

class DolilApp extends ConsumerWidget {
  const DolilApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return ToastificationWrapper(
      child: MaterialApp.router(
        title: 'DolilBD',
        theme: AppTheme.light,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
