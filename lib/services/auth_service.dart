import 'package:casino_app/models/user.dart' as myUser; // Alias para evitar conflitos
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Alias para FirebaseAuth
import 'package:google_sign_in/google_sign_in.dart'; // Para Google Sign-In

import 'firestore_service.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // _currentUser deve ser o user do Firebase Auth
  firebase_auth.User? _firebaseUser;
  // E aqui guardamos o seu modelo de utilizador, carregado do Firestore
  myUser.User? _appUser;

  // Getter para o utilizador atual do Firebase Auth
  firebase_auth.User? get firebaseUser => _firebaseUser ?? _auth.currentUser;

  // Getter para o seu modelo de utilizador carregado do Firestore
  myUser.User? get appUser => _appUser;

  // Stream para monitorar mudanças no estado de autenticação do Firebase
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Construtor para inicializar o _firebaseUser e _appUser quando a instância for criada
  AuthService() {
    _auth.authStateChanges().listen((user) async {
      _firebaseUser = user;
      if (user != null) {
        // Quando o Firebase User muda, tente carregar os dados do seu appUser
        await _loadAppUserData(user.uid);
      } else {
        _appUser = null; // Limpa o appUser se o Firebase User for nulo
      }
    });
  }

  // Novo método para carregar os detalhes do seu modelo de utilizador (myUser.User)
  // Chamado internamente quando o firebaseUser muda.
  Future<void> _loadAppUserData(String uid) async {
    try {
      _appUser = await _firestoreService.getUser(uid); // Use o método getUser do FirestoreService
      print('DEBUG AuthService - Dados do appUser carregados: $_appUser');
      if (_appUser == null) {
        print(
            'DEBUG AuthService - appUser não encontrado no Firestore, criando com base no UID: $uid');
        // Se o appUser não existir, podemos criar um aqui.
        // O método createUserIfNotExists do FirestoreService já lida com isso.
        // Podemos chamar saveUser ou apenas garantir que getUser() chama createUserIfNotExists
        // como está no seu firestore_service.dart
        await _firestoreService.createUserIfNotExists(uid); // Garante que o documento é criado
        _appUser = await _firestoreService.getUser(uid); // Tenta carregar novamente
      }
    } catch (e) {
      print('Erro ao carregar dados do appUser do Firestore: $e');
      _appUser = null;
    }
  }

  // --- Métodos de Autenticação ---

  Future<firebase_auth.User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // await _auth.setSettings(appVerificationDisabledForTesting: true); // Remover em produção
      firebase_auth.UserCredential result =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      final firebase_auth.User? user = result.user;

      if (user != null) {
        // Não chame _firestoreService.getUserDetails diretamente aqui.
        // O `authStateChanges` listener no construtor já vai chamar _loadAppUserData
        // que por sua vez chama _firestoreService.getUser.
        print('Login com Email/Senha bem-sucedido: ${user.uid}');
      }
      return user;
    } catch (e) {
      print('Erro no login (Email/Senha): $e');
      rethrow;
    }
  }

  Future<firebase_auth.User?> registerWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      firebase_auth.UserCredential result =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final firebase_auth.User? user = result.user;

      if (user != null) {
        // Guarde os detalhes iniciais do utilizador no Firestore
        await _firestoreService.saveUserDetails(user.uid, username, email);
        print('Registo com Email/Senha bem-sucedido: ${user.uid}');
        // O listener de authStateChanges cuidará de carregar o _appUser
      }
      return user;
    } catch (e) {
      print('Erro no registo (Email/Senha): $e');
      rethrow;
    }
  }

  Future<firebase_auth.User?> signInWithGoogle() async {
    try {
      // O GoogleAuthProvider é uma classe do firebase_auth, não um método do AuthService
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // O utilizador cancelou o processo de login
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      firebase_auth.UserCredential userCredential = await _auth.signInWithCredential(credential);
      final firebase_auth.User? user = userCredential.user;

      if (user != null) {
        // Crie ou atualize os detalhes do utilizador no Firestore
        await _firestoreService.saveUserDetails(
            user.uid, user.displayName ?? user.email?.split('@')[0] ?? 'GoogleUser', user.email!);
        print('Login com Google bem-sucedido: ${user.uid}');
        // O listener de authStateChanges cuidará de carregar o _appUser
      }
      return user;
    } catch (e) {
      print('Erro no login com Google: $e');
      rethrow;
    }
  }

  Future<void> signInWithFacebook() async {
    // Implementação de login com Facebook, se necessário
    throw UnimplementedError('Facebook Sign-In não implementado.');
  }

  // Adicione este método ao AuthService se precisar de um UID em algum lugar
  String? get uid => firebaseUser?.uid;

  // Removido: loadUserData. A lógica agora está no construtor e _loadAppUserData
  // Removido: getUserDetails. Isso é responsabilidade do FirestoreService.

  // Métodos de telefone (se for usar o fluxo de SMS de verdade)
  Future<void> loginWithPhone(
      String phoneNumber,
      firebase_auth.PhoneVerificationCompleted verificationCompleted,
      firebase_auth.PhoneVerificationFailed verificationFailed,
      firebase_auth.PhoneCodeSent codeSent,
      firebase_auth.PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
      print('DEBUG: Verificação de telefone iniciada para $phoneNumber');
    } catch (e) {
      print('Erro ao iniciar verificação de telefone: $e');
      rethrow;
    }
  }

  Future<firebase_auth.User?> verifyPhoneCode(String verificationId, String smsCode) async {
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      firebase_auth.UserCredential result = await _auth.signInWithCredential(credential);
      final firebase_auth.User? user = result.user;

      if (user != null) {
        // Crie ou atualize os detalhes do utilizador no Firestore, se for um novo utilizador de telefone
        await _firestoreService.saveUserDetails(
            user.uid, user.phoneNumber ?? 'PhoneUser', user.email ?? '');
        print('Verificação de código de telefone bem-sucedida: ${user.uid}');
      }
      return user;
    } catch (e) {
      print('Erro na verificação do código do telefone: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _firebaseUser = null;
      _appUser = null;
      print('Utilizador desconectado.');
    } catch (e) {
      print('Erro ao fazer logout: $e');
      rethrow;
    }
  }

  // Novo método para atualizar créditos através do AuthService
  Future<void> updateAppUserCredits(String uid, double amount) async {
    try {
      await _firestoreService.updateCredits(uid, amount);
      // Atualize o _appUser localmente após a atualização do Firestore
      if (_appUser != null && _appUser!.uid == uid) {
        // Garante que credits é tratado como double
        _appUser = _appUser!.copyWith(credits: (_appUser!.credits + amount));
      }
      print('Créditos do appUser atualizados para $uid: $_appUser');
    } catch (e) {
      print('Erro ao atualizar créditos do appUser via AuthService: $e');
      rethrow;
    }
  }
}
