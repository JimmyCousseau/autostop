import 'package:autostop/screens/map_screen.dart';
import 'package:autostop/shared/form_layer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _auth = FirebaseAuth.instance;

  String _currentPassword = '';
  String _newPassword = '';
  String _errorMessage = '';

  void _changePassword() async {
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

        _showSuccessMessage();
        // Use the navigator to pop and push routes
        navigator.popUntil((route) => route.isActive);
        navigator.push(MaterialPageRoute(builder: (_) => const MapScreen()));
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      _showErrorMessage("Une erreur est survenue");
    }
  }

  void _showSuccessMessage() {
    Navigator.of(context).pop(); // Close the comment screen

    const snackBar = SnackBar(
      duration: Duration(milliseconds: 5000),
      content: Text(
        'Le mot de passe a été changé.',
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showErrorMessage(String errorMessage) {
    setState(() {
      _errorMessage = errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Changer son mot de passe'),
        ),
        body: FormLayer(forms: [
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Mot de passe actuel'),
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
          TextFormField(
            obscureText: true,
            decoration:
                const InputDecoration(labelText: 'Nouveau mot de passe'),
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
          ElevatedButton(
            onPressed: _changePassword,
            child: const Text('Changer son mot de passe'),
          ),
          if (_errorMessage.isNotEmpty)
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
        ]));
  }
}
