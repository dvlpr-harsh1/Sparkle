enum RecordCategory {
  prescription,
  lab,
  vaccine,
  visit;

  String get label {
    return switch (this) {
      RecordCategory.prescription => 'Prescription',
      RecordCategory.lab => 'Lab Report',
      RecordCategory.vaccine => 'Vaccination',
      RecordCategory.visit => 'Visit Summary',
    };
  }

  String get emoji {
    return switch (this) {
      RecordCategory.prescription => '💊',
      RecordCategory.lab => '🧪',
      RecordCategory.vaccine => '💉',
      RecordCategory.visit => '🏥',
    };
  }
}
