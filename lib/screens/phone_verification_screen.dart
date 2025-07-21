import 'package:casino_app/services/auth_service.dart';
import 'package:casino_app/utils/helpers.dart';
import 'package:casino_app/widgets/common/custom_button.dart';
import 'package:casino_app/widgets/common/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String verificationId; // Recebe verificationId via construtor

  PhoneVerificationScreen({required this.verificationId});

  @override
  _PhoneVerificationScreenState createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user =
          await authService.verifyPhoneCode(widget.verificationId, _codeController.text.trim());

      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _errorMessage = 'Código de verificação inválido.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro na verificação: ${e.toString()}';
      });
      GameHelpers.showSnackBar(context, 'Erro na verificação: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Não precisa mais obter verificationId de ModalRoute.of(context).settings.arguments
    // Agora é passado diretamente pelo construtor (widget.verificationId)

    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone_android, size: 100, color: Colors.amber),
                SizedBox(height: 20),
                Text(
                  'Verificação por Telefone',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Código SMS',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.purple, width: 2),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 30),
                _isLoading
                    ? CircularProgressIndicator(color: Colors.purple)
                    : CustomButton(
                        text: 'Verificar',
                        onPressed: _verifyCode,
                      ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    print('Re-enviar código - (Lógica a implementar)');
                    // Implemente a lógica de reenvio aqui, se necessário
                  },
                  child: Text(
                    'Re-enviar código',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
