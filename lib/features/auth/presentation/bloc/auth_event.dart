import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthSignUpRequested extends AuthEvent {
  String name;
  String email;
  String password;
  AuthSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [name, email, password];
}

class AuthSignInRequested extends AuthEvent {
  String email;
  String password;
  AuthSignInRequested({required this.email, required this.password});
  @override
  // TODO: implement props
  List<Object?> get props => [email, password];
}

class AuthSignOutRequrested extends AuthEvent {
  const AuthSignOutRequrested();
}
