import 'package:flutter/material.dart';

class SezioneProgressiProgetti extends StatelessWidget {
  final int? progettiCompletati;
  final int progettiUtente;

  const SezioneProgressiProgetti({super.key,
    required this.progettiCompletati,
    required this.progettiUtente,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final progress = progettiUtente > 0 ? progettiCompletati! / progettiUtente : 0.0;

    return Card(
      elevation: 16.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth*0.08, vertical: screenHeight*0.03),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Progressi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: screenHeight*0.02, width: screenWidth*0.04,),
            Stack(
              alignment: Alignment.center,
              children: [
              CircularProgressIndicator(
              value: progress,
              color: Colors.red[700],
              strokeWidth: 4.0,
              backgroundColor: Colors.grey[400],
            ),
            Center(
              child: Text(
                '$progettiCompletati / $progettiUtente',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                  color: Colors.black,
                  ),
                ),
                ),
              ],
            ),
            SizedBox(height: screenHeight*0.02),
            Text(
              'Continua Così !',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color:  Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

