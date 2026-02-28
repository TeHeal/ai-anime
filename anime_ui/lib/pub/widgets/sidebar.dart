import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      color: Colors.black26,
      child: Column(
        children: [
          IconButton(icon: const Icon(Icons.star), onPressed: () {}),
          IconButton(icon: const Icon(Icons.history), onPressed: () {}),
          IconButton(icon: const Icon(Icons.folder), onPressed: () {}),
        ],
      ),
    );
  }
}
