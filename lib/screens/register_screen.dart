import 'package:autostop/shared/form_layer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'map_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _register() async {
    final password = _passwordController.text;
    final email = _emailController.text.trim();
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      if (password == _confirmPasswordController.text) {
        final UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (userCredential.user != null) {
          // Navigate to MapScreen after successful registration
          navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const MapScreen()),
          );
          scaffoldMessenger
              .showSnackBar(const SnackBar(content: Text("Enregistré")));
        } else {
          scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text("Email déjà utilisée")));
        }
      } else {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('Les mots de passes ne correspondent pas')));
      }
    } catch (e) {
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("S'enregistrer"),
      ),
      body: FormLayer(forms: [
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Mot de passe'),
          obscureText: true,
        ),
        TextFormField(
          controller: _confirmPasswordController,
          decoration:
              const InputDecoration(labelText: 'Confirmer le mot de passe'),
          obscureText: true,
        ),
        ElevatedButton(
          onPressed: _register,
          child: const Text('Valider l\'enregistrement'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Annuler'),
        ),
      ]),
    );
  }
}
