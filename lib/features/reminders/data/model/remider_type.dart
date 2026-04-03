enum ReminderType {
  medication,
  appointment,
  followup;

  String get label {
    return switch (this) {
      ReminderType.medication   => 'Medication',
      ReminderType.appointment  => 'Appointment',
      ReminderType.followup     => 'Follow-up',
    };
  }

  String get emoji {
    return switch (this) {
      ReminderType.medication   => '💊',
      ReminderType.appointment  => '🏥',
      ReminderType.followup     => '📋',
    };
  }
}