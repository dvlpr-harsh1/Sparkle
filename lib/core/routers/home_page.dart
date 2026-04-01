import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_event.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_state.dart';
import 'package:sparkle/features/auth/presentation/login_page.dart';
import 'package:sparkle/features/auth/presentation/sign_up_page.dart';

// Placeholder — replace Thursday onwards
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sparkle')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You are logged in!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<AuthBloc>().add(const AuthSignOutRequrested()),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

GoRouter createRouter(AuthBloc authBloc) {
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
      GoRoute(path: '/home', builder: (_, __) => const HomePage()),
    ],
  );
}


class GoRouterAuthNotifier extends ChangeNotifier {
  GoRouterAuthNotifier(AuthBloc authBloc) {
    authBloc.stream.listen((_) => notifyListeners());
  }
}
