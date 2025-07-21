class GameHistory {
  final String id;
  final String gameType;
  final int bet;
  final int winAmount;
  final bool isWin;
  final List<String> symbols;
  final DateTime timestamp;

  GameHistory({
    required this.id,
    required this.gameType,
    required this.bet,
    required this.winAmount,
    required this.isWin,
    required this.symbols,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'gameType': gameType,
        'bet': bet,
        'winAmount': winAmount,
        'isWin': isWin,
        'symbols': symbols,
        'timestamp': timestamp.toIso8601String(),
      };

  factory GameHistory.fromJson(Map<String, dynamic> json) => GameHistory(
        id: json['id'],
        gameType: json['gameType'],
        bet: json['bet'],
        winAmount: json['winAmount'],
        isWin: json['isWin'],
        symbols: List<String>.from(json['symbols']),
        timestamp: DateTime.parse(json['timestamp']),
      );
}
