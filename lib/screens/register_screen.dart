import 'package:autostop/services/user_service.dart';
import 'package:autostop/shared/form_layer.dart';
import 'package:flutter/foundation.dart';
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
  final TextEditingController _usernameController = TextEditingController();

  void _register() async {
    final password = _passwordController.text;
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      if (password == _confirmPasswordController.text) {
        // Check if the username is already used
        bool isUnique = await UserService().checkUsernameAvailability(username);
        if (!isUnique) {
          scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text("Nom d'utilisateur déjà utilisée")));
          return;
        }
        bool response = await UserService()
            .registerUser(User(email: email, username: username));
        if (response) {
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
      if (kDebugMode) {
        print(e);
      }
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content:
              Text('Erreur: une erreur est survenu lors de l\'enregistrement'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("S'enregistrer"),
      ),
      body: SingleChildScrollView(
        child: FormLayer(forms: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Nom d\'utilisateur'),
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
      ),
    );
  }
}
