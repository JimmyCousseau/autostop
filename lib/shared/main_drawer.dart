import 'package:autostop/screens/change_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                if (currentUser != null)
                  const Text(
                    'Bonjour !',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                if (currentUser != null)
                  Text(
                    "${currentUser.email}",
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
              ],
            ),
          ),
          if (currentUser != null)
            ListTile(
              title: const Text('Changer mon mot de passe'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen()));
              },
            ),
          ListTile(
            title: const Text('Se déconnecter'),
            onTap: () async {
              final scaffold = Scaffold.of(context);
              await FirebaseAuth.instance.signOut();
              scaffold.closeDrawer();
            },
          ),
        ],
      ),
    );
  }
}
