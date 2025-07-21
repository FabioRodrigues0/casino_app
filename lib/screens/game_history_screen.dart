import 'package:casino_app/providers/game_provider.dart'; // Certifique-se de que está importado
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Jogos'),
        backgroundColor: Color(0xFF1E1E2F),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1E2F), Color(0xFF2A2A3D), Color(0xFF000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: gameProvider.gameHistory.isEmpty // Use gameHistory getter
            ? Center(
                child: Text(
                  'Nenhum histórico de jogo disponível.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: gameProvider.gameHistory.length,
                itemBuilder: (context, index) {
                  final record = gameProvider.gameHistory[index];
                  return Card(
                    color: Colors.white.withOpacity(0.05),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Data: ${record.date.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(color: Colors.white)),
                          Text('Aposta: \$${record.bet.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.white)),
                          Text('Ganhos: \$${record.winnings.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.greenAccent)),
                          Text('Resultado: ${record.outcome}',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
