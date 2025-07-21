import 'package:casino_app/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:casino_app/services/auth_service.dart';
import 'package:casino_app/providers/game_provider.dart';
import 'package:casino_app/screens/slot_machine_screen.dart'; // Importar o SlotMachineScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FirestoreService _firestoreService;

  List<Map<String, dynamic>> rooms = [];

  @override
  void initState() {
    super.initState();
    _firestoreService = Provider.of<FirestoreService>(context, listen: false);
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final loadedRooms = await _firestoreService.getRooms();
      setState(() {
        rooms = loadedRooms;
      });
    } catch (e) {
      print('Erro ao carregar salas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final gameProvider = Provider.of<GameProvider>(context);

    // O objeto user aqui é o seu modelo myUser.User
    final user = authService.appUser;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1E2F), Color(0xFF2A2A3D), Color(0xFF000000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0).copyWith(top: 48),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      // Aceda ao profileImageUrl do seu modelo de utilizador (appUser)
                      backgroundImage: NetworkImage(
                          user?.profileImageUrl ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop&crop=face'),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, ${user?.username ?? 'Jogador'}', // Aceda ao username do appUser
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                        Text(
                          'Créditos: ${gameProvider.userCredits.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: SlotMachineScreen(), // Correção: Instanciar como um widget
                ),
              ),
              SizedBox(height: 20),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.casino, size: 50, color: Colors.purple[400]),
                          SizedBox(height: 10),
                          Text(
                            room['name'] ?? 'Sala Desconhecida',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Min Bet: \$${room['min_bet']?.toStringAsFixed(2) ?? 'N/A'}',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Container(
                color: Colors.black.withOpacity(0.8),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.logout, color: Colors.purple[400]),
                      onPressed: () async {
                        await authService.signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                    const Icon(Icons.emoji_events, color: Colors.white60),
                    const Icon(Icons.message, color: Colors.white60),
                    const Icon(Icons.person, color: Colors.white60),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}