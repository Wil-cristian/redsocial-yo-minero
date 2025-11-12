import 'package:flutter/material.dart';
import 'pages/messaging/conversations_page.dart';

class MessagesPage extends StatelessWidget {
  final Map<String, dynamic>? currentUser;

  const MessagesPage({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return const ConversationsPage();
  }
}
