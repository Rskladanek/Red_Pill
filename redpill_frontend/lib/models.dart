// Ten plik definiuje klasy Dart, które odpowiadają schematom
// JSON zwracanym przez Twoje API.

class User {
  final int id;
  final String email;
  final String rank;
  final int xp;
  final bool hardMode;
  final String timezone;

  User({
    required this.id,
    required this.email,
    required this.rank,
    required this.xp,
    required this.hardMode,
    required this.timezone,
  });

  // Fabryka do parsowania JSONa
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      rank: json['rank'] as String,
      xp: json['xp'] as int,
      hardMode: json['hard_mode'] as bool,
      timezone: json['timezone'] as String,
    );
  }
}

class Lesson {
  final int id;
  final String title;
  final String content;
  final String source;
  final String application;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.source,
    required this.application,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      source: json['source'] as String,
      application: json['application'] as String,
    );
  }
}


