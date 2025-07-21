class GameState {
  final int credits;
  final int bet;
  final bool isSpinning;
  final List<bool> reelSpinning;
  final List<String> currentSymbols;
  final List<int> reelPositions;

  GameState({
    required this.credits,
    required this.bet,
    this.isSpinning = false,
    this.reelSpinning = const [false, false, false],
    this.currentSymbols = const ['?', '?', '?'],
    this.reelPositions = const [0, 0, 0],
  });

  GameState.initial()
      : credits = 100,
        bet = 1,
        isSpinning = false,
        reelSpinning = [false, false, false],
        currentSymbols = ['?', '?', '?'],
        reelPositions = [0, 0, 0];

  GameState copyWith({
    int? credits,
    int? bet,
    bool? isSpinning,
    List<bool>? reelSpinning,
    List<String>? currentSymbols,
    List<int>? reelPositions,
  }) {
    return GameState(
      credits: credits ?? this.credits,
      bet: bet ?? this.bet,
      isSpinning: isSpinning ?? this.isSpinning,
      reelSpinning: reelSpinning ?? this.reelSpinning,
      currentSymbols: currentSymbols ?? this.currentSymbols,
      reelPositions: reelPositions ?? this.reelPositions,
    );
  }
}
