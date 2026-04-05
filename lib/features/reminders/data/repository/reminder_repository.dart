import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparkle/core/constants/app_constants.dart';
import 'package:sparkle/features/reminders/data/model/remider_model.dart';
import 'package:uuid/uuid.dart';

class ReminderRepository {
  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  ReminderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _remindersCol(String userId) => _firestore
      .collection(AppConstants.usersCollection)
      .doc(userId)
      .collection(AppConstants.remindersCollection);

  Future<void> addReminder(ReminderModel reminder) async {
    final id = _uuid.v4();
    await _remindersCol(reminder.userId).doc(id).set(reminder.toMap());
  }


  Stream<List<ReminderModel>> watchReminders(String userId) {
    return _remindersCol(userId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReminderModel.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ))
            .toList());
  }

 
  Future<void> toggleDone(
    String userId,
    String reminderId,
    bool isDone,
  ) async {
    await _remindersCol(userId)
        .doc(reminderId)
        .update({'isDone': isDone});
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _remindersCol(reminder.userId)
        .doc(reminder.id)
        .update(reminder.toMap());
  }

  Future<void> deleteReminder(String userId, String reminderId) async {
    await _remindersCol(userId).doc(reminderId).delete();
  }
}