import 'package:casino_app/providers/game_provider.dart';
import 'package:casino_app/widgets/slot_machine/slot_header.dart'; // Certifique-se de que está importado
import 'package:firebase_auth/firebase_auth.dart'; // Importe FirebaseAuth
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Placeholder for your slot machine game logic
class SlotMachineGame {
  // Example fields, replace with your actual game state
  int reels = 3;
  int rows = 3;
  List<List<int>> currentSymbols = []; // Symbols on reels
  double currentBet = 1.0;
  double lastWin = 0.0;
  bool isSpinning = false;

  SlotMachineGame() {
    // Initialize symbols, etc.
    resetSymbols();
  }

  void resetSymbols() {
    currentSymbols =
        List.generate(reels, (_) => List.generate(rows, (_) => 0)); // All zeros initially
  }

  // This method would contain the core spin logic, returning win amount
  double spin() {
    isSpinning = true;
    // Simulate spinning and symbol generation
    // For demonstration, let's just return a random win
    double win = (DateTime.now().millisecond % 5 == 0)
        ? currentBet * 2
        : 0; // 20% chance of winning double bet
    // Update currentSymbols based on random outcome
    isSpinning = false;
    return win;
  }
}

class SlotMachineScreen extends StatefulWidget {
  @override
  _SlotMachineScreenState createState() => _SlotMachineScreenState();
}

class _SlotMachineScreenState extends State<SlotMachineScreen> {
  // Assuming SlotMachineGame handles the game logic, not GameProvider directly
  final SlotMachineGame _slotGame = SlotMachineGame(); // Instantiate your game logic

  @override
  void initState() {
    super.initState();
    // Initialize game state when screen starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(context, listen: false).initializeGame(); // Use initializeGame
    });
  }

  Future<void> _handleSpin(GameProvider gameProvider) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in, handle appropriately
      print('Usuário não logado.');
      return;
    }

    if (gameProvider.userCredits < gameProvider.currentBet) {
      // Use currentBet getter
      print('Créditos insuficientes!');
      // Show snackbar or alert
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Créditos insuficientes para esta aposta!')),
      );
      return;
    }

    // Deduct bet
    final deducted =
        await gameProvider.deductCredits(gameProvider.currentBet); // Use currentBet getter
    if (!deducted) {
      print('Falha ao deduzir créditos.');
      return;
    }

    // Update game state to spinning
    gameProvider.updateGameState(GameState.spinning); // Use updateGameState

    setState(() {
      _slotGame.isSpinning = true; // Update local game state
    });

    // Simulate spin delay
    await Future.delayed(Duration(seconds: 2));

    // Perform spin logic
    double winnings = _slotGame.spin(); // Get winnings from game logic

    if (winnings > 0) {
      // Add winnings to credits
      await gameProvider.addCredits(winnings);
      gameProvider.updateGameState(GameState.won); // Use updateGameState
      setState(() {
        _slotGame.lastWin = winnings;
      });
      print('Ganhou: \$${winnings.toStringAsFixed(2)}');
    } else {
      gameProvider.updateGameState(GameState.lost); // Use updateGameState
      setState(() {
        _slotGame.lastWin = 0.0;
      });
      print('Não ganhou desta vez.');
    }

    // Add game to history
    gameProvider.addGameToHistory(
      // Use addGameToHistory
      GameRecord(
        id: DateTime.now().toIso8601String(),
        date: DateTime.now(),
        bet: gameProvider.currentBet, // Use currentBet getter
        winnings: winnings,
        outcome: winnings > 0 ? 'Win' : 'Loss',
      ),
    );

    setState(() {
      _slotGame.isSpinning = false; // Update local game state
    });

    gameProvider.updateGameState(GameState.stopped); // Use updateGameState
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: SlotHeader(), // Assumindo que SlotHeader já cuida dos seus próprios providers
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E1E2F), Color(0xFF2A2A3D), Color(0xFF000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Display current credits
                Text(
                  'Créditos: \$${gameProvider.userCredits.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // Slot Machine Reels Display (Simplified)
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey.withOpacity(0.2),
                  alignment: Alignment.center,
                  child: gameProvider.gameState == GameState.spinning // Use gameState getter
                      ? CircularProgressIndicator(color: Colors.yellow)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _slotGame.lastWin > 0
                                  ? 'GANHOU: \$${_slotGame.lastWin.toStringAsFixed(2)}'
                                  : 'Gire para ganhar!',
                              style: TextStyle(
                                  color: _slotGame.lastWin > 0 ? Colors.greenAccent : Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold),
                            ),
                            // Display of symbols (replace with your actual reels rendering)
                            Text(
                              '${_slotGame.currentSymbols.map((row) => row.join(' ')).join(' | ')}',
                              style: TextStyle(color: Colors.white, fontSize: 24),
                            ),
                          ],
                        ),
                ),
                SizedBox(height: 20),

                // Bet controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed:
                          gameProvider.gameState == GameState.spinning // Use gameState getter
                              ? null
                              : () => gameProvider.decreaseBet(), // Use decreaseBet
                      child: Text('-'),
                    ),
                    SizedBox(width: 20),
                    Text(
                      'Aposta: \$${gameProvider.currentBet.toStringAsFixed(2)}', // Use currentBet getter
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed:
                          gameProvider.gameState == GameState.spinning // Use gameState getter
                              ? null
                              : () => gameProvider.increaseBet(), // Use increaseBet
                      child: Text('+'),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Spin Button
                ElevatedButton(
                  onPressed: gameProvider.gameState == GameState.spinning // Use gameState getter
                      ? null
                      : () => _handleSpin(gameProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ).copyWith(
                    elevation: MaterialStateProperty.all(0),
                    overlayColor: MaterialStateProperty.all(Colors.purple.withOpacity(0.2)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: const [Color(0xFF800080), Color(0xFFFF69B4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        gameProvider.gameState == GameState.spinning
                            ? 'GIRANDO...'
                            : 'GIRAR', // Use gameState getter
                        style: TextStyle(
                            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Navigation to Game History (example)
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/game_history');
                  },
                  child: Text(
                    'Ver Histórico de Jogos',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
