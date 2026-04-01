sealed class AppErrors {
  final String message;
  const AppErrors(this.message);
}

class NetworkError extends AppErrors {
  const NetworkError() : super('No Internet Connection');
}

class AuthErrors extends AppErrors {
  const AuthErrors({required String message}) : super(message);
}

class UnknownErrors extends AppErrors {
  const UnknownErrors() : super('Something went wrong. Please try again');
}

///Yo convert Firebase error lcode into readable.
String firebaseAuthErrorToMessage(String code) {
  return switch (code) {
    'user-not-found' => 'No account found with this email.',
    'wrong-password' => 'Incorrect password.',
    'email-already-in-use' => 'An account already exists with this email.',
    'weak-password' => 'Password must be at least 6 characters.',
    'invalid-email' => 'Please enter a valid email address.',
    'too-many-requests' => 'Too many attempts. Try again later.',
    _ => 'Authentication failed. Please try again.',
  };
}
