import 'package:flutter/material.dart';

class BtnIconText extends StatelessWidget {
  const BtnIconText(
      {super.key,
      required this.icon,
      required this.text,
      required this.onPressed});

  final IconData icon;
  final String text;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.start, // Alignement horizontal centré
        children: [
          Icon(icon), // Remplacez "icon_name" par le nom de l'icône souhaitée
          const SizedBox(width: 8.0), // Espace entre l'icône et le texte
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}
