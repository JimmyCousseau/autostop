import 'package:flutter/material.dart';
import '../services/comment_service.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;

  const CommentCard({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 8),
                Text(_sanitizeText(comment.userMail)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              "Temps d'attente estimé: ${comment.estimatedTime.toStringAsFixed(0)} minutes",
              softWrap: true,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              "Commenté le ${_formatDate(comment.updatedAt)}",
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 8),
            Text(comment.content),
          ],
        ),
      ),
    );
  }

  String _sanitizeText(String input) {
    final sanitizedInput = input.trim();

    // Define a map of characters and their corresponding HTML entities
    final htmlEntities = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#x27;',
      '/': '&#x2F;',
    };

    // Replace characters with their HTML entities
    return sanitizedInput.replaceAllMapped(RegExp('[&<>"\'/]'), (match) {
      return htmlEntities[match.group(0)]!;
    });
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
