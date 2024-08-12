import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

// Existing models and priority
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/Model/Progetto.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/ViewModel/ViewModelProgetto.dart';
import 'package:teamsync_flutter/data.models/Priorita.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/View/iTuoiProgettiItem.dart';


class SezioneITUoiProgetti extends StatelessWidget {
  final List<Progetto> progetti;
  final Map<String, int> attivitaProgetti;

  SezioneITUoiProgetti({
    required this.progetti,
    required this.attivitaProgetti,
  });

  @override
  Widget build(BuildContext context) {
    comparatore(Progetto p1, Progetto p2) {
      final priorita1 = p1.priorita;
      final priorita2 = p2.priorita;

      if (priorita1 == Priorita.ALTA && priorita2 != Priorita.ALTA) return -1;
      if (priorita1 != Priorita.ALTA && priorita2 == Priorita.ALTA) return 1;
      if (priorita1 == Priorita.MEDIA && priorita2 == Priorita.BASSA) return -1;
      if (priorita1 == Priorita.BASSA && priorita2 == Priorita.MEDIA) return 1;
      if (priorita1 == Priorita.MEDIA && priorita2 == Priorita.NESSUNA) return -1;
      if (priorita1 == Priorita.NESSUNA && priorita2 == Priorita.MEDIA) return 1;
      if (priorita1 == Priorita.BASSA && priorita2 == Priorita.NESSUNA) return -1;
      if (priorita1 == Priorita.NESSUNA && priorita2 == Priorita.BASSA) return 1;

      return 0;
    }

    // Simulated preferences
    const visualizzaCompletati = false; // Simulate: change as needed
    const ordineProgetti = "cronologico"; // Simulate: change as needed

    // Create a sorted list based on the preference
    List<Progetto> sortedProgetti = List.from(progetti);

    sortedProgetti.sort((p1, p2) {
      switch (ordineProgetti) {
        case "cronologico":
          return p2.dataCreazione.compareTo(p1.dataCreazione);
        case "scadenza":
          return p1.dataScadenza.compareTo(p2.dataScadenza);
        case "priorità":
          return comparatore(p1, p2);
        default:
          return 0;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(right:120.0),
        child:Text(
          'I tuoi progetti',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        ),
        const SizedBox(height: 12),
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
                    "assets/nessun_progetto___image.png", // Percorso dell'immagine
                    fit: BoxFit.scaleDown, // Puoi cambiare il fit a seconda di come vuoi che l'immagine si adatti
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Nessun progetto',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
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
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: sortedProgetti
                  .where((p) => visualizzaCompletati || !p.completato)
                  .map((progetto) {
                final attivitaNonCompletate = attivitaProgetti[progetto.id] ?? 0;
                return ITuoiProgettiItem(
                  progetto: progetto,
                  attivitaNonCompletate: attivitaNonCompletate,
                  progettoScaduto: false,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
