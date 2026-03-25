import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/customer/home_screen.dart';
import '../screens/customer/service_list_screen.dart';
import '../screens/customer/package_builder_screen.dart';
import '../screens/customer/package_summary_screen.dart';
import '../screens/customer/my_bookings_screen.dart';
import '../screens/customer/saved_packages_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_services_screen.dart';
import '../screens/admin/admin_add_service_screen.dart';
import '../screens/admin/admin_add_addon_screen.dart';
import '../screens/admin/admin_bookings_screen.dart';
import '../screens/admin/admin_analytics_screen.dart';
import '../models/service_model.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAdmin = authState.isAdmin;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplash = state.matchedLocation == '/splash';

      if (isSplash) return null;
      if (!isAuthenticated && !isAuthRoute) return '/auth/login';
      if (isAuthenticated && isAuthRoute) {
        return isAdmin ? '/admin' : '/home';
      }
      if (isAuthenticated &&
          isAdmin &&
          state.matchedLocation.startsWith('/home')) {
        return '/admin';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),

      // Auth routes
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/auth/register',
        builder: (_, __) => const RegisterScreen(),
      ),

      // Customer routes
      ShellRoute(
        builder: (context, state, child) => CustomerShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(
            path: '/services',
            builder: (_, __) => const ServiceListScreen(),
          ),
          GoRoute(
            path: '/my-bookings',
            builder: (_, __) => const MyBookingsScreen(),
          ),
          GoRoute(
            path: '/saved',
            builder: (_, __) => const SavedPackagesScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/package-builder/:serviceId',
        builder: (context, state) {
          final serviceId = state.pathParameters['serviceId']!;
          final service = state.extra as ServiceModel?;
          return PackageBuilderScreen(serviceId: serviceId, service: service);
        },
      ),
      GoRoute(
        path: '/package-summary',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return PackageSummaryScreen(bookingData: data);
        },
      ),

      // Admin routes
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (_, __) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/services',
            builder: (_, __) => const AdminServicesScreen(),
          ),
          GoRoute(
            path: '/admin/bookings',
            builder: (_, __) => const AdminBookingsScreen(),
          ),
          GoRoute(
            path: '/admin/analytics',
            builder: (_, __) => const AdminAnalyticsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/admin/add-service',
        builder: (_, __) => const AdminAddServiceScreen(),
      ),
      GoRoute(
        path: '/admin/add-addon/:serviceId',
        builder: (context, state) {
          final serviceId = state.pathParameters['serviceId']!;
          return AdminAddAddonScreen(serviceId: serviceId);
        },
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
});

// Customer shell with bottom navigation
class CustomerShell extends StatelessWidget {
  final Widget child;
  const CustomerShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child, bottomNavigationBar: _CustomerBottomNav());
  }
}

class _CustomerBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;
    if (location == '/home') currentIndex = 0;
    if (location == '/services') currentIndex = 1;
    if (location == '/my-bookings') currentIndex = 2;
    if (location == '/saved') currentIndex = 3;

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF2A2A44), width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/services');
              break;
            case 2:
              context.go('/my-bookings');
              break;
            case 3:
              context.go('/saved');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_rounded),
            label: 'Saved',
          ),
        ],
      ),
    );
  }
}

// Admin shell with bottom navigation
class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child, bottomNavigationBar: _AdminBottomNav());
  }
}

class _AdminBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;
    if (location == '/admin') currentIndex = 0;
    if (location == '/admin/services') currentIndex = 1;
    if (location == '/admin/bookings') currentIndex = 2;
    if (location == '/admin/analytics') currentIndex = 3;

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF2A2A44), width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/admin');
              break;
            case 1:
              context.go('/admin/services');
              break;
            case 2:
              context.go('/admin/bookings');
              break;
            case 3:
              context.go('/admin/analytics');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services_rounded),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}
