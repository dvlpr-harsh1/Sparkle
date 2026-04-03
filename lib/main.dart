import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkle/core/routers/app_router.dart';
import 'package:sparkle/core/themes/app_theme.dart';
import 'package:sparkle/features/auth/data/auth_repository.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sparkle/features/auth/presentation/bloc/auth_event.dart';
import 'package:sparkle/features/profile/data/repository/profile_repository.dart';
import 'package:sparkle/features/records/data/repository/record_repository.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SparkleApp());
}

class SparkleApp extends StatelessWidget {
  const SparkleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final profileRepository = ProfileRepository();
    final recordRepository = RecordRepository();
    final authBloc = AuthBloc(
      authRepository: authRepository,
      profileRepository: profileRepository,
    )..add(const AuthStarted());

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: profileRepository),
        RepositoryProvider.value(value: recordRepository),
      ],
      child: BlocProvider.value(
        value: authBloc,
        child: MaterialApp.router(
          title: 'Sparkle',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          // pass repositories directly here
          routerConfig: createRouter(
            authBloc,
            profileRepository,
            recordRepository,
          ),
        ),
      ),
    );
  }
}
