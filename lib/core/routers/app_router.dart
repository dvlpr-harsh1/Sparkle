import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_event.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_state.dart';
import 'package:sparkle/features/auth/presentation/login_page.dart';
import 'package:sparkle/features/auth/presentation/sign_up_page.dart';
import 'package:sparkle/features/profile/data/repository/profile_repository.dart';
import 'package:sparkle/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:sparkle/features/profile/presentation/bloc/profile_event.dart';
import 'package:sparkle/features/profile/presentation/profile_page.dart';
import 'package:sparkle/features/records/data/repository/record_repository.dart';
import 'package:sparkle/features/records/presentation/bloc/record_bloc.dart';
import 'package:sparkle/features/records/presentation/bloc/record_event.dart';
import 'package:sparkle/features/records/presentation/record_page.dart';
import 'package:sparkle/features/reminders/data/repository/reminder_repository.dart';
import 'package:sparkle/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:sparkle/features/reminders/presentation/bloc/reminder_event.dart';
import 'package:sparkle/features/reminders/presentation/reminder_page.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/records')) return 1;
    if (location.startsWith('/reminders')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0; // home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home');
            case 1:
              context.go('/records');
            case 2:
              context.go('/reminders');
            case 3:
              context.go('/profile');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Records',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sparkle'),
        actions: [
          TextButton(
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthSignOutRequested()),
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: const Center(child: Text('Dashboard coming Saturday!')),
    );
  }
}

GoRouter createRouter(
  AuthBloc authBloc,
  ProfileRepository profileRepository,
  RecordRepository recordRepository,
  ReminderRepository reminderRepository,
) {
  return GoRouter(
    refreshListenable: GoRouterAuthNotifier(authBloc),
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = authBloc.state;
      final isOnAuthScreen =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (authState is AuthAuthenticated && isOnAuthScreen) {
        return '/home';
      }
      if (authState is AuthUnauthenticated && !isOnAuthScreen) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupPage()),

      ShellRoute(
        builder: (context, state, child) {
          final uid = (authBloc.state as AuthAuthenticated).user.uid;

          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => RecordBloc(
                  recordRepository: recordRepository,
                )..add(RecordWatchStarted(uid)),
              ),
              BlocProvider(
                create: (_) => ProfileBloc(
                  profileRepository: profileRepository,
                )..add(ProfileLoadRequested(uid)),
              ),
              BlocProvider(
                create: (_) => ReminderBloc(
                  reminderRepository: reminderRepository,
                )..add(ReminderWatchStarted(uid)),
              ),
            ],
            child: AppShell(child: child),
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/records',
            builder: (_, __) => const RecordsPage(),
          ),
          GoRoute(
            path: '/reminders',      // ← now INSIDE ShellRoute
            builder: (_, __) => const RemindersPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
}

class GoRouterAuthNotifier extends ChangeNotifier {
  GoRouterAuthNotifier(AuthBloc authBloc) {
    authBloc.stream.listen((_) => notifyListeners());
  }
}