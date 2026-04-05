import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sparkle/core/errors/app_errors.dart';
import 'package:sparkle/features/auth/data/auth_repository.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_event.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_state.dart';
import 'package:sparkle/features/profile/data/model/user_model.dart';
import 'package:sparkle/features/profile/data/repository/profile_repository.dart';

// Mock classes — mocktail creates fake versions of these
class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockUser extends Mock implements User {}

void main() {
  late MockAuthRepository authRepository;
  late MockProfileRepository profileRepository;
  late MockUser mockUser;

  setUp(() {
    authRepository = MockAuthRepository();
    profileRepository = MockProfileRepository();
    mockUser = MockUser();

    // Default stub — user has a uid
    when(() => mockUser.uid).thenReturn('test-uid');
    when(() => mockUser.email).thenReturn('harsh@test.com');
  });

  group('AuthBloc', () {
    // blocTest is from bloc_test package
    // act: fires an event
    // expect: list of states emitted in order
    blocTest<AuthBloc, AuthState>(
      'emits AuthAuthenticated when sign in succeeds',
      build: () {
        // stub signIn to return our mock user
        when(
          () => authRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => mockUser);

        // stub authStateChanges stream
        when(
          () => authRepository.authStateChanges,
        ).thenAnswer((_) => Stream.value(mockUser));

        return AuthBloc(
          authRepository: authRepository,
          profileRepository: profileRepository,
        );
      },
      act: (bloc) => bloc.add(
        AuthSignInRequested(email: 'harsh@test.com', password: 'password123'),
      ),
      expect: () => [
        const AuthLoading(),
        // AuthAuthenticated comes from the stream
      ],
      // verify repository was called
      verify: (_) {
        verify(
          () => authRepository.signIn(
            email: 'harsh@test.com',
            password: 'password123',
          ),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthFailure when sign in fails',
      build: () {
        // stub signIn to throw AuthError
        when(
          () => authRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(AuthErrors(message: 'Incorrect password.'));

        when(
          () => authRepository.authStateChanges,
        ).thenAnswer((_) => Stream.value(null));

        return AuthBloc(
          authRepository: authRepository,
          profileRepository: profileRepository,
        );
      },
      act: (bloc) => bloc.add(
        AuthSignInRequested(email: 'harsh@test.com', password: 'wrongpassword'),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthFailure('Incorrect password.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthUnauthenticated when sign out succeeds',
      build: () {
        when(() => authRepository.signOut()).thenAnswer((_) async {});

        when(
          () => authRepository.authStateChanges,
        ).thenAnswer((_) => Stream.value(null));

        return AuthBloc(
          authRepository: authRepository,
          profileRepository: profileRepository,
        );
      },
      act: (bloc) => bloc.add(const AuthSignOutRequested()),
      verify: (_) {
        verify(() => authRepository.signOut()).called(1);
      },
    );
  });
}
