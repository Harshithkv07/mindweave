import 'package:flutter/material.dart';

class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎤 Talk to MindWeave'),
      ),
      body: const Center(
        child: Text(
          'Voice assistant coming here!',
          style: TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}