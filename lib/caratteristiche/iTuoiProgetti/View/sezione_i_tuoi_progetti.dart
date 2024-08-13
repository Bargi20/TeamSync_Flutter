import 'package:flutter/material.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/Model/progetto.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/View/i_tuoi_progetti_item.dart';


class SezioneITUoiProgetti extends StatelessWidget {
  final List<Progetto> progetti;
  final Map<String, int> attivitaProgetti;

  const SezioneITUoiProgetti({super.key,
    required this.progetti,
    required this.attivitaProgetti,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I tuoi progetti',
          style: TextStyle(
            fontSize: screenHeight * 0.03,
            color: Colors.black,
          ),
        ),

        SizedBox(height: screenHeight*0.01),
        if (progetti.isEmpty)
          Card(
            elevation: 16,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.asset(
                    "assets/nessun_progetto___image.png",
                    fit: BoxFit.scaleDown,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Nessun progetto',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenHeight*0.02,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )

        else
          SizedBox(
            height: screenHeight*0.15,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: progetti
                  .map((progetto) {
                final attivitaNonCompletate = attivitaProgetti[progetto.id] ?? 0;
                return ITuoiProgettiItem(
                  progetto: progetto,
                  attivitaNonCompletate: attivitaNonCompletate,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
