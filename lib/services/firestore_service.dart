import 'package:casino_app/models/user.dart' as myUser; // Alias para evitar conflitos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para FirebaseAuth.instance.currentUser?.displayName

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método para guardar os detalhes do utilizador no Firestore após o registo ou primeiro login.
  Future<void> saveUserDetails(String uid, String username, String email) async {
    try {
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'balance': 0.0, // Exemplo: saldo inicial
        'profileImageUrl':
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop&crop=face',
      }, SetOptions(merge: true)); // Use merge: true para evitar sobrescrever dados existentes
      print(
          'DEBUG FirestoreService - Documento de utilizador criado/atualizado para $email com UID: $uid');
    } catch (e) {
      print('Erro ao guardar detalhes do utilizador no Firestore: $e');
      rethrow;
    }
  }

  // Método para obter os detalhes do utilizador do Firestore e retornar como myUser.User
  // Este é o método que o AuthService e GameProvider usarão.
  Future<myUser.User?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        print(
            'DEBUG FirestoreService - Dados brutos do Firestore para $uid (tipo: ${data.runtimeType}): $data');
        if (data is Map<String, dynamic>) {
          return myUser.User.fromFirestore(doc);
        } else {
          print('DEBUG FirestoreService - Dados inesperados (não é Map) para $uid: $data');
          return null;
        }
      }
      print('DEBUG FirestoreService - Documento não encontrado para UID: $uid, tentando criar...');
      // Se não existir, tenta criar
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'username': FirebaseAuth.instance.currentUser?.displayName ??
            FirebaseAuth.instance.currentUser?.email?.split('@')[0] ??
            'Usuário Anônimo',
        'email': FirebaseAuth.instance.currentUser?.email ?? 'email_nao_disponivel',
        'createdAt': FieldValue.serverTimestamp(),
        'balance': 100.0, // Créditos iniciais
        'profileImageUrl':
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop&crop=face',
      }, SetOptions(merge: true)); // Garante que não sobrescreve se já existe por algum motivo
      print('DEBUG FirestoreService - Usuário criado com sucesso para UID: $uid com 100 créditos');
      final newDoc = await _db.collection('users').doc(uid).get();
      if (newDoc.exists) {
        return myUser.User.fromFirestore(newDoc);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar ou criar usuário no FirestoreService: $e');
      return null;
    }
  }

  // Renomeado para claridade (foi createUserIfNotExists)
  Future<void> createUserIfNotExists(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) {
        // Criar um novo documento com dados básicos se não existir
        await _db.collection('users').doc(uid).set({
          'uid': uid,
          'username': FirebaseAuth.instance.currentUser?.displayName ??
              FirebaseAuth.instance.currentUser?.email?.split('@')[0] ??
              'Usuário Anônimo',
          'email': FirebaseAuth.instance.currentUser?.email ?? 'email_nao_disponivel',
          'createdAt': FieldValue.serverTimestamp(),
          'balance': 100.0, // Créditos iniciais
          'profileImageUrl':
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop&crop=face',
        });
        print(
            'DEBUG FirestoreService - Usuário criado com sucesso via createUserIfNotExists para UID: $uid');
      } else {
        print('DEBUG FirestoreService - Usuário já existe para UID: $uid, sem ação necessária');
      }
    } catch (e) {
      print('Erro ao criar usuário via createUserIfNotExists: $e');
      rethrow;
    }
  }

  // Método para atualizar os créditos (saldo) de um utilizador.
  Future<void> updateCredits(String uid, double amount) async {
    try {
      await _db.collection('users').doc(uid).update({
        'balance': FieldValue.increment(amount), // Incrementa o saldo
      });
      print('DEBUG FirestoreService - Saldo do utilizador $uid atualizado em $amount');
    } catch (e) {
      print('Erro ao atualizar créditos do utilizador $uid: $e');
      rethrow;
    }
  }

  // Método para obter salas
  Future<List<Map<String, dynamic>>> getRooms() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db.collection('rooms').get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Erro ao carregar salas: $e');
      return [];
    }
  }
}
