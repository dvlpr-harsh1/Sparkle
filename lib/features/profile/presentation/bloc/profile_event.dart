import 'package:equatable/equatable.dart';
import 'package:sparkle/features/profile/data/model/dependents_model.dart';
import 'package:sparkle/features/profile/data/model/user_model.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

// Load profile when app starts or user logs in
class ProfileLoadRequested extends ProfileEvent {
  final String userId;
  const ProfileLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ProfileUpdateRequested extends ProfileEvent {
  final UserProfile profile;
  const ProfileUpdateRequested(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileDependentAdded extends ProfileEvent {
  final String userId;
  final DependentModel dependent;
  const ProfileDependentAdded({required this.userId, required this.dependent});

  @override
  List<Object?> get props => [userId, dependent];
}

class ProfileDependentDeleted extends ProfileEvent {
  final String userId;
  final String dependentId;
  const ProfileDependentDeleted({
    required this.userId,
    required this.dependentId,
  });

  @override
  List<Object?> get props => [userId, dependentId];
}
