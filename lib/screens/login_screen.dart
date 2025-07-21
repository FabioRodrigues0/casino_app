import 'package:casino_app/screens/phone_verification_screen.dart';
import 'package:casino_app/screens/register_screen.dart';
import 'package:casino_app/services/auth_service.dart'; // Importe o seu serviço AuthService
import 'package:casino_app/utils/country_codes.dart'; // IMPORTAR CountryCodes
import 'package:casino_app/utils/helpers.dart'; // Se ainda usa isso
import 'package:casino_app/widgets/common/custom_button.dart';
import 'package:casino_app/widgets/common/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importar Provider

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+351';
  bool _useEmailPassword = false;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _errorMessage = 'Credenciais inválidas.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro no login: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loginWithPhoneNumber() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final phoneNumber = '$_selectedCountryCode${_phoneController.text}';
      await authService.loginWithPhone(
        phoneNumber,
        (credential) async {
          // Auto-sign in
          await authService.verifyPhoneCode(credential.verificationId!, credential.smsCode!);
          if (authService.firebaseUser != null) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        (e) {
          setState(() {
            _errorMessage = 'Falha na verificação do telefone: ${e.message}';
          });
          GameHelpers.showSnackBar(context, 'Falha na verificação do telefone: ${e.message}');
        },
        (verificationId, resendToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhoneVerificationScreen(
                  verificationId: verificationId), // Passa verificationId aqui
            ),
          );
        },
        (verificationId) {
          print('Auto retrieval timeout. verificationId: $verificationId');
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro com Telefone: ${e.toString()}';
      });
      GameHelpers.showSnackBar(context, 'Erro com Telefone: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signInWithGoogle(); // Chamar método da instância
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _errorMessage = 'Falha no login com Google.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro com Google: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithFacebook(); // Chamar método da instância
      // Navigator.pushReplacementNamed(context, '/home'); // Uncomment after implementing
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro com Facebook: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ... (seu logo e outros widgets)

                // Mensagem de erro
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Alternar entre Email/Senha e Telefone
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _useEmailPassword = true;
                        });
                      },
                      child: Text(
                        'Email/Senha',
                        style: TextStyle(
                          color: _useEmailPassword ? Colors.white : Colors.white54,
                          fontWeight: _useEmailPassword ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _useEmailPassword = false;
                        });
                      },
                      child: Text(
                        'Telefone',
                        style: TextStyle(
                          color: !_useEmailPassword ? Colors.white : Colors.white54,
                          fontWeight: !_useEmailPassword ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                _useEmailPassword
                    ? Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
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
                          SizedBox(height: 20),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Senha',
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
                          CustomButton(
                            text: 'Login',
                            onPressed: _isLoading ? null : _loginWithEmail,
                          ),
                          SizedBox(height: 10),
                          CustomButton(
                            text: 'Criar Conta',
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                                    );
                                  },
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          // UI para login com telefone
                          Row(
                            children: [
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCountryCode,
                                  dropdownColor: Colors.grey[800],
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedCountryCode = newValue!;
                                    });
                                  },
                                  items: CountryCodes.countryCodes
                                      .map<DropdownMenuItem<String>>((Map<String, String> country) {
                                    return DropdownMenuItem<String>(
                                      value: country['code'],
                                      child: Text('${country['flag']} ${country['code']}',
                                          style: TextStyle(color: Colors.white)),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'Número de Telefone',
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
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          CustomButton(
                            text: 'Login com Telefone',
                            onPressed: _isLoading ? null : _loginWithPhoneNumber,
                          ),
                        ],
                      ),

                SizedBox(height: 20),
                Text(
                  'Ou continue com',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 30,
                      icon: Image.asset('assets/icons/google_icon.png', height: 30),
                      onPressed: _isLoading ? null : _signInWithGoogle,
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      iconSize: 30,
                      icon: Image.asset('assets/icons/facebook_icon.png', height: 30),
                      onPressed: _isLoading ? null : _signInWithFacebook,
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      iconSize: 30,
                      icon: Icon(Icons.phone, color: Colors.blueAccent, size: 30),
                      onPressed: _isLoading ? null : _loginWithPhoneNumber,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
