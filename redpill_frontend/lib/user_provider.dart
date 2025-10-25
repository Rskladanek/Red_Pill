import 'package:flutter/material.dart';
import 'models.dart';
import 'api.dart';

// Używamy ChangeNotifier do trzymania danych usera
// i powiadamiania widgetów o zmianach.
class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  // Ustawia usera (np. po logowaniu)
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  // Czyści usera (po wylogowaniu)
  void clearUser() {
    _user = null;
    notifyListeners();
  }

  // Pobiera świeże dane usera z API
  Future<void> fetchUser() async {
    try {
      final r = await Api.getProfile();
      _user = User.fromJson(r.data as Map<String, dynamic>);
      notifyListeners();
    } catch (e) {
      // Błąd (np. token wygasł)
      debugPrint("Błąd fetchUser: $e");
      // Tutaj można by obsłużyć globalne wylogowanie
      clearUser();
    }
  }
}


