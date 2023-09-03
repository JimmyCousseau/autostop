import 'package:autostop/screens/forgot_password_screen.dart';
import 'package:autostop/screens/register_screen.dart';
import 'package:autostop/shared/form_layer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'map_screen.dart'; // Import your MapScreen

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final SharedPreferences _preferences;

  bool _rememberCredentials = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  void _loadRememberedCredentials() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      _rememberCredentials =
          _preferences.getBool('rememberCredentials') ?? false;
      if (_rememberCredentials) {
        _emailController.text = _preferences.getString('savedEmail') ?? '';
      }
    });
  }

  void _saveRememberedCredentials() {
    _preferences.setBool('rememberCredentials', _rememberCredentials);
    if (_rememberCredentials) {
      _preferences.setString('savedEmail', _emailController.text.trim());
    } else {
      _preferences.remove('savedEmail');
    }
  }

  void _signIn() async {
    final navigator = Navigator.of(context);
    final String email = _emailController.text.trim();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );
      if (userCredential.user != null) {
        // Navigate to MapScreen after successful login
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const MapScreen()),
        );
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Connecté')),
        );
        _saveRememberedCredentials();
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text('Erreur: mauvais mot de passe ou email')),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentification'),
      ),
      body: SingleChildScrollView(
        child: FormLayer(forms: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            onFieldSubmitted: (_) => _signIn,
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Mot de passe'),
            obscureText: true,
            onFieldSubmitted: (_) => _signIn,
          ),
          CheckboxListTile(
            title: const Text(
              'Se souvenir de moi',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            value: _rememberCredentials,
            onChanged: (value) {
              setState(() {
                _rememberCredentials = value!;
                _saveRememberedCredentials();
              });
            },
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ForgotPasswordScreen()));
            },
            child: const Text("Mot de passe oublié"),
          ),
          ElevatedButton(
            onPressed: _signIn,
            child: const Text('Se connecter'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()));
            },
            child: const Text('S\'enregistrer'),
          ),
        ]),
      ),
    );
  }
}
