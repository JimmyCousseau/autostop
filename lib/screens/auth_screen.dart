import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:autostop/screens/map_screen.dart'; // Import your MapScreen

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isRegistering = false; // Track if user is registering
  String _errorMessage = ''; // Store error message

  void _signIn() async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (userCredential.user != null) {
        // Navigate to MapScreen after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MapScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Mot de passe ou adresse mail invalides';
      });
    }
  }

  void _register() async {
    try {
      if (_passwordController.text == _confirmPasswordController.text) {
        final UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (userCredential.user != null) {
          // Navigate to MapScreen after successful registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MapScreen()),
          );
        } else {
          setState(() {
            _errorMessage = "Email déjà utilisée";
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Les mots de passes ne correspondent pas';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Problème lors de l\'enregistrement';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            if (_isRegistering) // Conditionally show Confirm Password field
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                    labelText: 'Confirmer le mot de passe'),
                obscureText: true,
              ),
            const SizedBox(height: 20),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
            if (!_isRegistering)
              ElevatedButton(
                onPressed: _signIn,
                child: const Text('Se connecter'),
              ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isRegistering = !_isRegistering;
                });
              },
              child: Text(_isRegistering ? 'Annuler' : 'S\'enregistrer'),
            ),
            if (_isRegistering)
              ElevatedButton(
                onPressed: _register,
                child: const Text('Valider l\'enregistrement'),
              ),
          ],
        ),
      ),
    );
  }
}
