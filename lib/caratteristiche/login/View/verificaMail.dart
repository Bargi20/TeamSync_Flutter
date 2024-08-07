import 'package:flutter/material.dart';


class VerificaEmail extends StatelessWidget {
  final VoidCallback onButtonPressed;

  const VerificaEmail({super.key, required this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/sfondo_pagina_di_benvenuto1.png',
              fit: BoxFit.cover,
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Image at the top
                Image.asset(
                  'assets/im_mailbox.png',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                // First text
                const Text(
                  'Controlla la tua email',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Second text
                const Text(
                  'Per verificare il tuo account.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Button
                ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, // Text color
                    backgroundColor: Colors.white, // Button color
                  ),
                  child: const Text('Ho Capito'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
