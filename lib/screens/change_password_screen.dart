import 'package:autostop/screens/map_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  String _currentPassword = '';
  String _newPassword = '';
  String _errorMessage = '';

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      final navigator = Navigator.of(context);

      try {
        final user = _auth.currentUser;
        if (user != null) {
          final credential = EmailAuthProvider.credential(
            email: user.email!,
            password: _currentPassword,
          );
          await user.reauthenticateWithCredential(credential);
          await user.updatePassword(_newPassword);

          setState(() {
            _errorMessage = 'Le mot de passe a été changé.';
          });

          // Use the navigator to pop and push routes
          navigator.popUntil((route) => route.isActive);
          navigator.push(MaterialPageRoute(builder: (_) => const MapScreen()));
        }
      } catch (error) {
        setState(() {
          _errorMessage = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Changer son mot de passe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: 400.0,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Mot de passe actuel'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Merci d\'entrer son mot de passe.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _currentPassword = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Nouveau mot de passe'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Merci d\'entrer un nouveau mot de passe.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _newPassword = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Répèter'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Merci de saisir de nouveau le mot de passe";
                      } else if (value != _newPassword) {
                        return 'Les mots de passes ne sont pas pareils';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _changePassword,
                    child: const Text('Changer son mot de passe'),
                  ),
                  const SizedBox(height: 16.0),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
