import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamsync_flutter/data.models/Priorita.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/Model/Progetto.dart';

import '../../../navigation/Schermate.dart'; // Assicurati di avere il modello Progetto

class ITuoiProgettiItem extends StatelessWidget {
  final Progetto progetto;
  final int attivitaNonCompletate;
  final bool progettoScaduto; // Nuovo parametro per la scadenza del progetto

  ITuoiProgettiItem({
    required this.progetto,
    required this.attivitaNonCompletate,
    required this.progettoScaduto,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final dataScadenza = dateFormatter.format(progetto.dataScadenza);
    final dataConsegna = dateFormatter.format(progetto.dataConsegna);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Schermate.leMieAttivita,
          arguments: progetto.id, // Il parametro idProgetto
        );
      },
      child: Card(
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color:Colors.white,


      child: Container(
          width: 220,
          height: 140,
          padding: const EdgeInsets.all(16),///ciao
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (progetto.completato)
                    Icon(
                      Icons.check_circle,
                      color: Colors.black,
                    ),
                  Flexible(
                    child: Text(
                      progetto.nome,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:  Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis, // Assicura che il testo non strabordi
                    ),
                  ),
                  if (!progetto.completato)
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: progetto.priorita.colore,
                    ),
                ],
              ),
              Divider(
                color:Colors.grey[350],
                thickness: 1,
              ),
              if (progetto.completato)
                _buildCompletedProjectRow(dataConsegna)
              else
                _buildIncompleteProjectRow(attivitaNonCompletate),
              _buildDeadlineRow(dataScadenza, progettoScaduto),
            ],
          ),
        ),
    )
    );
  }

  Row _buildCompletedProjectRow(String dataConsegna) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(
          Icons.date_range,
          size: 16,
          color: Colors.black,
        ),
        const SizedBox(width: 5),
        Text(
          dataConsegna,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Row _buildIncompleteProjectRow(int attivitaNonCompletate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(
          Icons.task,
          size: 16,
          color:  Colors.black,
        ),
        SizedBox(width: 5),
        Text(
          '$attivitaNonCompletate attività',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Row _buildDeadlineRow(String dataScadenza, bool progettoScaduto) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(
          progettoScaduto ? Icons.error : Icons.calendar_today,
          size: 16,
          color: progettoScaduto ? Colors.red : Colors.black,
        ),
        const SizedBox(width: 5),
        Text(
          dataScadenza,
          style: TextStyle(
            fontSize: 12,
            color: progettoScaduto ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }
}


