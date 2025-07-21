import 'package:casino_app/services/auth_service.dart';
import 'package:casino_app/services/firestore_service.dart';
import 'package:flutter/material.dart';

enum GameState { initial, spinning, stopped, won, lost }

class GameRecord {
  final String id;
  final DateTime date;
  final double bet;
  final double winnings;
  final String outcome;

  GameRecord(
      {required this.id,
      required this.date,
      required this.bet,
      required this.winnings,
      required this.outcome});
}

class GameProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthService _authService;

  double _userCredits = 0.0;
  bool _isLoading = false;
  GameState _gameState = GameState.initial;
  List<GameRecord> _gameHistory = [];
  double _currentBet = 1.0;

  double get userCredits => _userCredits;
  bool get isLoading => _isLoading;
  GameState get gameState => _gameState;
  List<GameRecord> get gameHistory => _gameHistory;
  double get currentBet => _currentBet;

  GameProvider(this._firestoreService, this._authService) {
    // Escuta mudanças no appUser do AuthService para atualizar os créditos
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserCredits(); // Recarrega os créditos quando o estado do Firebase User muda
      } else {
        _userCredits = 0.0;
        notifyListeners();
      }
    });
    // Chamada inicial para carregar créditos
    _loadUserCredits();
  }

  Future<void> _loadUserCredits() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = _authService.firebaseUser; // Obtenha o firebaseUser do AuthService
      if (user != null) {
        // Use o appUser do AuthService para obter os créditos
        final appUser = _authService.appUser; // Este já foi carregado via AuthService
        if (appUser != null) {
          _userCredits = appUser.credits.toDouble(); // Garante que é double
          print('DEBUG GameProvider - Créditos do appUser (AuthService): $_userCredits');
        } else {
          _userCredits = 0.0; // Defina um valor padrão se não houver appUser
          print('DEBUG GameProvider - appUser nulo, créditos definidos para 0.0');
          // O AuthService já deve ter lidado com a criação se o user do Firebase existe mas o appUser não.
        }
      }
    } catch (e) {
      print('Erro ao carregar créditos do utilizador no GameProvider: $e');
      _userCredits = 0.0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCredits(double amount) async {
    final user = _authService.firebaseUser;
    if (user != null) {
      try {
        await _firestoreService.updateCredits(user.uid, amount);
        _userCredits += amount;
        notifyListeners();
        // O AuthService também deve ser notificado para atualizar o seu _appUser
        _authService.updateAppUserCredits(user.uid, amount); // Chamar o método do AuthService
      } catch (e) {
        print('Erro ao adicionar créditos: $e');
      }
    }
  }

  Future<bool> deductCredits(double amount) async {
    final user = _authService.firebaseUser;
    if (user != null && _userCredits >= amount) {
      try {
        await _firestoreService.updateCredits(user.uid, -amount);
        _userCredits -= amount;
        notifyListeners();
        // O AuthService também deve ser notificado para atualizar o seu _appUser
        _authService.updateAppUserCredits(user.uid, -amount); // Chamar o método do AuthService
        return true;
      } catch (e) {
        print('Erro ao deduzir créditos: $e');
        return false;
      }
    }
    return false;
  }

  void setCredits(double newCredits) {
    _userCredits = newCredits;
    notifyListeners();
  }

  void initializeGame() {
    _gameState = GameState.initial;
    _currentBet = 1.0;
    notifyListeners();
  }

  void updateGameState(GameState newState) {
    _gameState = newState;
    notifyListeners();
  }

  void addGameToHistory(GameRecord record) {
    _gameHistory.add(record);
    notifyListeners();
  }

  void decreaseBet() {
    if (_currentBet > 0.5) {
      _currentBet -= 0.5;
      notifyListeners();
    }
  }

  void increaseBet() {
    if (_currentBet < _userCredits && _currentBet < 100.0) {
      _currentBet += 0.5;
      notifyListeners();
    }
  }
}
