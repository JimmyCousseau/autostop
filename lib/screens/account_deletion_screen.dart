import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountDeletionPage extends StatefulWidget {
  const AccountDeletionPage({super.key});

  @override
  State<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await _auth
          .signInWithCustomToken(_auth.currentUser!.getIdToken() as String);
      User? user = _auth.currentUser;

      if (user != null) {
        await user.delete();
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Compte supprimé')),
        );
        Future.delayed(const Duration(seconds: 2), () {
          navigator.pop();
        });
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
              content: Text('Erreur, le compte n\'a pas pu être supprimé')),
        );
        Future.delayed(const Duration(seconds: 2), () {
          navigator.pop();
        });
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
            content: Text('Erreur, le compte n\'a pas pu être supprimé')),
      );
      Future.delayed(const Duration(seconds: 2), () {
        navigator.pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CircularProgressIndicator(),
              Text("Suppression du compte",
                  style: Theme.of(context).textTheme.displayLarge),
            ],
          ),
        ),
      ),
    );
  }
}
