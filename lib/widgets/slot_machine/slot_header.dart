import 'package:casino_app/providers/game_provider.dart'; // Importe o GameProvider
import 'package:casino_app/services/auth_service.dart'; // Importe o AuthService
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SlotHeader extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(100.0); // Ajuste a altura conforme necessário

  @override
  Widget build(BuildContext context) {
    // Obtenha as instâncias via Provider
    final authService = Provider.of<AuthService>(context);
    final gameProvider = Provider.of<GameProvider>(context);

    // Use authService.appUser para obter os detalhes do seu modelo de utilizador
    // O appUser é do tipo myUser.User, que tem profileImageUrl, username e credits
    final user = authService.appUser; // Este é o seu modelo de utilizador personalizado

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  // Use a imagem de perfil do utilizador se disponível, ou uma fallback
                  user?.profileImageUrl ??
                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop&crop=face',
                ),
              ),
              SizedBox(width: 8),
              Text(
                user?.username ?? 'Convidado', // Aceda ao username do appUser
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.monetization_on, color: Colors.yellow[400], size: 24),
              SizedBox(width: 4),
              Text(
                gameProvider.userCredits.toStringAsFixed(2), // Use os créditos do GameProvider
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.purple[400], size: 28),
                onPressed: () async {
                  await authService.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
