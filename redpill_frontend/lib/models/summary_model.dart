class SummaryModel {
  final int xpMind;
  final int xpBody;
  final int xpSoul;
  final int streakDays;
  final int experience;

  const SummaryModel({
    required this.xpMind,
    required this.xpBody,
    required this.xpSoul,
    required this.streakDays,
    required this.experience,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> m) => SummaryModel(
        xpMind: (m['xp_mind'] ?? 0) as int,
        xpBody: (m['xp_body'] ?? 0) as int,
        xpSoul: (m['xp_soul'] ?? 0) as int,
        streakDays: (m['streak_days'] ?? 0) as int,
        experience: (m['experience'] ?? 0) as int,
      );
}

