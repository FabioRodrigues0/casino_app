import 'dart:math';

import '../models/slot_result.dart';
import '../utils/constants.dart';

class GameService {
  static SlotResult calculateResult(List<String> symbols, int bet) {
    if (symbols[0] == symbols[1] && symbols[1] == symbols[2]) {
      String symbol = symbols[0];
      int multiplier = GameConstants.winMultipliers[symbol] ?? 0;
      return SlotResult(
        symbols: symbols,
        winAmount: bet * multiplier,
        isWin: true,
        winType: 'Três iguais',
      );
    }

    if (symbols[0] == symbols[1] || symbols[1] == symbols[2] || symbols[0] == symbols[2]) {
      return SlotResult(
        symbols: symbols,
        winAmount: bet,
        isWin: true,
        winType: 'Duas iguais',
      );
    }

    return SlotResult(
      symbols: symbols,
      winAmount: 0,
      isWin: false,
      winType: 'Sem vitória',
    );
  }

  static List<String> generateRandomSymbols() {
    final random = Random();
    return List.generate(
        3, (index) => GameConstants.symbols[random.nextInt(GameConstants.symbols.length)]);
  }
}
