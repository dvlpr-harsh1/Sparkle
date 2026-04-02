import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkle/core/errors/app_errors.dart';
import 'package:sparkle/features/auth/data/auth_repository.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_event.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_state.dart';
import 'package:sparkle/features/profile/data/model/user_model.dart';
import 'package:sparkle/features/profile/data/repository/profile_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthRepository authRepository;
  final ProfileRepository _profileRepository;
  AuthBloc({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
  }) : authRepository = authRepository,
       _profileRepository = profileRepository,
       super(const AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignOutRequrested>(_onSignOut);
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await emit.forEach(
      authRepository.authStateChanges,
      onData: (user) =>
          user != null ? AuthAuthenticated(user) : const AuthUnauthenticated(),
      onError: (error, stackTrace) => const AuthUnauthenticated(),
    );
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.signUp(
        email: event.email,
        password: event.password,
      );
      
      await _profileRepository.createProfile(
        UserProfile(id: user.uid, name: event.name, email: event.email),
      );
    } on AppError catch (e) {
      emit(AuthFailure(e.message));
    }
  }

  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.signIn(email: event.email, password: event.password);
    } on AppError catch (e) {
      emit(AuthFailure(e.message));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequrested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.signOut();
  }
}
