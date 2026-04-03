import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
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
      // Combine both streams into one
      // Every time profile changes OR dependents change
      // this fires with the latest value of BOTH
      final combined = Rx.combineLatest2(
        _profileRepository.watchProfile(event.userId),
        _profileRepository.watchDependents(event.userId),
        (UserProfile? profile, List<DependentModel> dependents) {
          // this function runs whenever either stream emits
          // returns a tuple-like record with both values
          return (profile: profile, dependents: dependents);
        },
      );

      await emit.forEach(
        combined,
        onData: (data) {
          if (data.profile == null) {
            return const ProfileFailure('Profile not found');
          }
          return ProfileLoaded(
            profile: data.profile!,
            dependents: data.dependents, // ← now always up to date!
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
      // combined stream fires automatically — no manual emit needed
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
      // combined stream fires automatically — no manual emit needed
    } catch (e) {
      emit(const ProfileFailure('Failed to add dependent'));
    }
  }

  Future<void> _onDependentDeleted(
    ProfileDependentDeleted event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _profileRepository.deleteDependent(event.userId, event.dependentId);
    } catch (e) {
      emit(const ProfileFailure('Failed to delete dependent'));
    }
  }
}