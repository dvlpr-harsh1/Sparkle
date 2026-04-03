import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparkle/core/constants/app_constants.dart';
import 'package:sparkle/features/records/data/model/health_records.dart';
import 'package:uuid/uuid.dart';

class RecordRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  RecordRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _recordsCol(String userId) => _firestore
      .collection(AppConstants.usersCollection)
      .doc(userId)
      .collection(AppConstants.recordsCollection);

  Future<void> addRecord(HealthRecord record) async {
    final id = _uuid.v4();
    await _recordsCol(record.userId).doc(id).set(record.toMap());
  }

  Stream<List<HealthRecord>> watchRecords(String userId) {
    return _recordsCol(userId)
        .orderBy('date', descending: true)  
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => HealthRecord.fromMap(
                    doc.id,
                    doc.data() as Map<String, dynamic>,
                  ))
              .toList();
        });
  }
  Future<void> updateRecord(HealthRecord record) async {
    await _recordsCol(record.userId).doc(record.id).update(record.toMap());
  }

  Future<void> deleteRecord(String userId, String recordId) async {
    await _recordsCol(userId).doc(recordId).delete();
  }

  Future<void> updateSharing(
    String userId,
    String recordId, {
    required bool isShared,
    required List<String> sharedWith,
  }) async {
    await _recordsCol(userId).doc(recordId).update({
      'isShared': isShared,
      'sharedWith': sharedWith,
    });
  }
}