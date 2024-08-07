import 'package:flutter/material.dart';

class SezioneProgressiProgetti extends StatelessWidget {
  final int progettiCompletati;
  final int progettiUtente;
  final bool isDarkTheme;

  SezioneProgressiProgetti({
    required this.progettiCompletati,
    required this.progettiUtente,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    // Prevenire la divisione per zero
    final progress = progettiUtente > 0 ? progettiCompletati / progettiUtente : 0.0;

    return Card(
      elevation: 16.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: isDarkTheme ? Colors.black : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Corretto
          crossAxisAlignment: CrossAxisAlignment.center, // Centra i widget orizzontalmente
          mainAxisSize: MainAxisSize.min, // Adatta la dimensione alla colonna
          children: [
            Text(
              'Progressi', // Usa Localizations per stringhe localizzate
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 15.0, width: 4.0,),
            Container(
              child: Stack(
                alignment: Alignment.center,
                children: [
                CircularProgressIndicator(
                value: progress,
                color: Colors.red[700],
                strokeWidth: 4.0,
                backgroundColor: isDarkTheme ? Colors.white : Colors.grey[400],
              ),
              Center(
                child: Text(
                  '$progettiCompletati / $progettiUtente',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                    color: isDarkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Continua Così!!!', // Usa Localizations per stringhe localizzate
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: SezioneProgressiProgetti(
          progettiCompletati: 3,
          progettiUtente: 10,
          isDarkTheme: false,
        ),
      ),
    ),
  ));
}
