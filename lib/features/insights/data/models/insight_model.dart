enum InsightType { warning, info, success, tip }

class InsightModel {
  final String title;
  final String description;
  final InsightType type;
  final String emoji;

  const InsightModel({
    required this.title,
    required this.description,
    required this.type,
    required this.emoji,
  });
}
