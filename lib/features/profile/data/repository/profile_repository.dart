import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparkle/core/constants/app_constants.dart';
import 'package:sparkle/features/profile/data/model/dependents_model.dart';
import 'package:sparkle/features/profile/data/model/user_model.dart';
import 'package:uuid/uuid.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  ProfileRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Reference helpers — keeps code clean
  DocumentReference _userDoc(String userId) =>
      _firestore.collection(AppConstants.usersCollection).doc(userId);

  CollectionReference _dependentsCol(String userId) =>
      _userDoc(userId).collection(AppConstants.dependentsCollection);

  // Called right after signup to create the initial profile
  Future<void> createProfile(UserProfile profile) async {
    await _userDoc(profile.id).set(profile.toMap());
  }

  // Fetch profile once
  Future<UserProfile?> getProfile(String userId) async {
    final doc = await _userDoc(userId).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  // Stream — UI updates in real time when profile changes
  Stream<UserProfile?> watchProfile(String userId) {
    return _userDoc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    });
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _userDoc(profile.id).update(profile.toMap());
  }

  // Dependents
  Future<void> addDependent(String userId, DependentModel dependent) async {
    final id = _uuid.v4();
    await _dependentsCol(userId).doc(id).set(dependent.toMap());
  }

  Stream<List<DependentModel>> watchDependents(String userId) {
    return _dependentsCol(userId).snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => DependentModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    });
  }

  Future<void> deleteDependent(String userId, String dependentId) async {
    await _dependentsCol(userId).doc(dependentId).delete();
  }
}
