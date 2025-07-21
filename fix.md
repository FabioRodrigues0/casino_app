Entendido! Vamos corrigir os erros reportados no `home_screen.dart` com base nas mensagens de erro fornecidas. Vou ajustar o código sem alterar a estrutura ou lógica original ao máximo, apenas resolvendo os problemas indicados. Aqui estão as correções:

### Análise dos Erros
1. **"The method 'getRooms' isn't defined for the type 'FirestoreService'" (linha 21)**:
    - O método `getRooms()` não está implementado em `FirestoreService`. Vou assumir que ele deveria existir e adicioná-lo com base no contexto.
2. **"Invalid constant value" (linhas 61, 115, 117, 119)**:
    - Valores constantes inválidos em `TextStyle` ou outras propriedades. Isso ocorre porque propriedades como `color` ou `backgroundColor` não podem ser constantes se dependem de valores dinâmicos (ex.: `Colors.purple[300]`). Vou remover o `const` onde necessário.
3. **"The named parameter 'primary' isn't defined" (linha 126)**:
    - O parâmetro `primary` não existe em `ElevatedButton.styleFrom`. Vou usar `background` ou `foreground` conforme a versão atual do Flutter (a partir do Flutter 3.x, `primary` foi substituído por `background`).

### Código Ajustado

#### `lib/screens/home_screen.dart`
```dart
import 'package:flutter/material.dart';
// import 'package:rive/rive.dart' as rive; // Comentado por agora
import 'package:casino_app/models/user.dart' as myUser;
import 'package:casino_app/services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> rooms = [];

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final loadedRooms = await _firestoreService.getRooms(); // Corrigido com base no contexto
      setState(() {
        rooms = loadedRooms;
      });
    } catch (e) {
      print('Erro ao carregar salas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0).copyWith(top: 48),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop&crop=face'),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Poker Ghost', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                        Text('Online', style: TextStyle(color: Colors.purple[300], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return Card(
                    color: Colors.white.withOpacity(0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Image.network(
                              room['image'] ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=300&h=200&fit=crop',
                              width: double.infinity,
                              height: 128,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Text('ATIVO', style: TextStyle(color: Colors.white, fontSize: 10, backgroundColor: Colors.green)),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(room['name'] ?? 'Sala Desconhecida', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('\$25', style: TextStyle(color: Colors.yellow[400], fontSize: 14)),
                                  Text('\$1250', style: TextStyle(color: Colors.green[400], fontSize: 14)),
                                  Text('12/20', style: TextStyle(color: Colors.blue[400], fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  background: LinearGradient( // Substituído 'primary' por 'background'
                                    colors: const [Color(0xFF800080), Color(0xFFFF69B4)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Entrar Agora', style: TextStyle(color: Colors.white, fontSize: 14)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Container(
                color: Colors.black.withOpacity(0.8),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.home, color: Colors.purple[400]),
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
```

#### `lib/services/firestore_service.dart` (Ajustado)
Como o método `getRooms()` não estava definido, vou adicioná-lo com uma implementação básica. Por favor, confirme se isso corresponde ao seu código original.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getRooms() async {
    try {
      final snapshot = await _db.collection('rooms').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Erro ao carregar salas: $e');
      return [];
    }
  }
}
```

### Correções Aplicadas
1. **Método `getRooms`**:
    - Adicionado a `FirestoreService` para resolver o erro na linha 21.
2. **Valores Constantes Inválidos**:
    - Removido `const` de `Text` e `TextStyle` onde `Colors.purple[300]` ou outros valores dinâmicos eram usados (linhas 61, 115, 117, 119).
3. **Parâmetro `primary`**:
    - Substituído por `background` em `ElevatedButton.styleFrom` (linha 126), conforme a API atual do Flutter.

### Instruções para Aplicar
1. **Substituir Ficheiros**:
    - Atualize `home_screen.dart` e `firestore_service.dart` com os códigos acima.
2. **Testar**:
    - Execute `flutter pub get` e `flutter run`.
3. **Verificar Firestore**:
    - Certifique-se de que a coleção `rooms` existe no Firebase e que as permissões estão configuradas corretamente.

### Validação
Por favor, teste o código ajustado e informe:
- Se o erro foi resolvido.
- Se a lógica original foi preservada (ex.: carregamento de salas).
- Se o aspeto visual está próximo ao do TSX.

### Próximos Passos
```
"Teste o código ajustado e confirme se os erros foram resolvidos ou se há outros problemas"
```

Ou:

```
"Se precisar de ajustes adicionais em outros ficheiros (ex.: login_screen.dart), envie os erros ou instruções"
```

Aguardo seu feedback! O horário atual é 09:50 PM WEST em 17 de julho de 2025.