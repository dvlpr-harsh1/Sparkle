import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkle/features/profile/data/model/dependents_model.dart';
import 'package:sparkle/features/profile/data/model/user_model.dart';
import 'package:sparkle/features/profile/data/repository/profile_repository.dart';
import 'package:sparkle/features/profile/presentation/bloc/profile_event.dart';
import 'package:sparkle/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileDependentAdded>(_onDependentAdded);
    on<ProfileDependentDeleted>(_onDependentDeleted);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      // Watch profile stream
      await emit.forEach(
        _profileRepository.watchProfile(event.userId),
        onData: (UserProfile? profile) {
          if (profile == null) return const ProfileFailure('Profile not found');
          // Keep existing dependents if already loaded
          final currentDependents = state is ProfileLoaded
              ? (state as ProfileLoaded).dependents
              : <DependentModel>[];
          return ProfileLoaded(
            profile: profile,
            dependents: currentDependents,
          );
        },
        onError: (_, __) => const ProfileFailure('Failed to load profile'),
      );
    } catch (e) {
      emit(const ProfileFailure('Something went wrong'));
    }
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _profileRepository.updateProfile(event.profile);
      // Stream will automatically emit new state via watchProfile
    } catch (e) {
      emit(const ProfileFailure('Failed to update profile'));
    }
  }

  Future<void> _onDependentAdded(
    ProfileDependentAdded event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _profileRepository.addDependent(event.userId, event.dependent);
    } catch (e) {
      emit(const ProfileFailure('Failed to add dependent'));
    }
  }

  Future<void> _onDependentDeleted(
    ProfileDependentDeleted event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _profileRepository.deleteDependent(
          event.userId, event.dependentId);
    } catch (e) {
      emit(const ProfileFailure('Failed to delete dependent'));
    }
  }
}