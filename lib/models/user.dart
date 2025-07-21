// lib/models/user.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String username;
  final String email;
  final double credits;
  final String? profileImageUrl; // Pode ser String? se for opcional
  final DateTime? createdAt;

  User({
    required this.uid,
    required this.username,
    required this.email,
    this.credits = 0.0,
    this.profileImageUrl,
    this.createdAt,
  });

  // Factory constructor para criar um objeto User a partir de um DocumentSnapshot do Firestore
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id,
      username: data['username'] ?? 'Usuário Sem Nome',
      email: data['email'] ?? 'email_nao_disponivel',
      credits: (data['balance'] as num?)?.toDouble() ??
          0.0, // Firestore pode retornar int, então converta para double
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Método para converter o objeto User para um Map<String, dynamic> para o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'balance': credits,
      'profileImageUrl': profileImageUrl,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  // Método copyWith para facilitar a atualização de propriedades imutáveis
  User copyWith({
    String? uid,
    String? username,
    String? email,
    double? credits,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      credits: credits ?? this.credits,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User(uid: $uid, username: $username, email: $email, credits: $credits, profileImageUrl: $profileImageUrl)';
  }
}
