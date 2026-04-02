import 'package:equatable/equatable.dart';
import 'package:sparkle/features/profile/data/model/dependents_model.dart';
import 'package:sparkle/features/profile/data/model/user_model.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final List<DependentModel> dependents;

  const ProfileLoaded({required this.profile, this.dependents = const []});

  // Handy for updating just one field without rebuilding whole state
  ProfileLoaded copyWith({
    UserProfile? profile,
    List<DependentModel>? dependents,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      dependents: dependents ?? this.dependents,
    );
  }

  @override
  List<Object?> get props => [profile, dependents];
}

class ProfileFailure extends ProfileState {
  final String message;
  const ProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}
