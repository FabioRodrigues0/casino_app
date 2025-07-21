class GameConstants {
  static const List<String> symbols = ['🍒', '🍋', '🍊', '🍇', '⭐', '💎', '7️⃣'];

  static const Map<String, int> winMultipliers = {
    '💎': 50,
    '7️⃣': 30,
    '⭐': 20,
    '🍇': 10,
    '🍊': 5,
    '🍋': 3,
    '🍒': 2,
  };

  static const int minBet = 10;
  static const int maxBet = 100;
  static const int betIncrement = 10;
  static const int initialCredits = 1000;
}
