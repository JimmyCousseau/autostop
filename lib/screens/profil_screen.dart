import 'package:autostop/screens/change_password_screen.dart';
import 'package:autostop/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Nom d\'utilisateur: ${user.displayName ?? 'N/A'}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'Email: ${user.email}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
                child: const Text('Changer mon mot de passe'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  UserService().logout(context);
                },
                child: const Text('Se déconnecter'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  UserService().deleteAccount(context);
                },
                child: const Text('Delete Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
