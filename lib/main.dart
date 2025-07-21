import 'package:casino_app/firebase_options.dart';
import 'package:casino_app/providers/game_provider.dart';
import 'package:casino_app/screens/game_history_screen.dart';
import 'package:casino_app/screens/home_screen.dart';
import 'package:casino_app/screens/login_screen.dart';
// import 'package:casino_app/screens/phone_verification_screen.dart'; // REMOVIDO: Não deve ser uma rota direta
import 'package:casino_app/screens/register_screen.dart';
import 'package:casino_app/screens/slot_machine_screen.dart';
import 'package:casino_app/screens/splash_screen.dart';
import 'package:casino_app/services/auth_service.dart';
import 'package:casino_app/services/firestore_service.dart'; // Adicionado
import 'package:firebase_auth/firebase_auth.dart'; // Importar User do firebase_auth
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(CasinoApp());
}

class CasinoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<FirestoreService>(
          // Adicione FirestoreService como um Provider também
          create: (_) => FirestoreService(),
        ),
        ChangeNotifierProxyProvider2<AuthService, FirestoreService, GameProvider>(
          // Use ProxyProvider2
          create: (context) {
            final firestoreService = Provider.of<FirestoreService>(context, listen: false);
            final authService = Provider.of<AuthService>(context, listen: false);
            return GameProvider(firestoreService, authService); // Passar ambos os argumentos
          },
          update: (context, authService, firestoreService, gameProvider) {
            // Se precisar de alguma atualização específica no GameProvider quando o AuthService muda, adicione aqui
            return gameProvider!; // Retorna a mesma instância
          },
        ),
      ],
      child: MaterialApp(
        title: 'Casino App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.transparent,
        ),
        home: AuthWrapper(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
          // '/phone_verification': (context) => PhoneVerificationScreen(), // REMOVIDO: Verificação de telefone deve ser chamada com `verificationId`
          '/game_history': (context) => GameHistoryScreen(),
          '/slot_machine': (context) => SlotMachineScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      // Use User do firebase_auth
      stream: authService.authStateChanges, // Aceder via instância
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen(); // Correct usage of SplashScreen widget
        } else if (snapshot.hasData) {
          // User is logged in
          return HomeScreen();
        } else {
          // User is not logged in
          return LoginScreen();
        }
      },
    );
  }
}
