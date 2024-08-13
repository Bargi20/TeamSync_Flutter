

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamsync_flutter/data.models/Priorita.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/Model/progetto.dart';
import '../../../navigation/Schermate.dart';

class ITuoiProgettiItem extends StatelessWidget {
  final Progetto progetto;
  final int attivitaNonCompletate;


  const ITuoiProgettiItem({super.key,
    required this.progetto,
    required this.attivitaNonCompletate,
  });


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final dataScadenza = dateFormatter.format(progetto.dataScadenza);
    final dataConsegna = dateFormatter.format(progetto.dataConsegna);
    final bool progettoScaduto = DateTime.now().isAfter(progetto.dataScadenza);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Schermate.leMieAttivita,
          arguments: progetto.id,
        );
      },
      child: Card(
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color:Colors.white,

      child: Container(
          width: screenWidth*0.5,
          padding:  EdgeInsets.symmetric(vertical: screenHeight*0.02, horizontal: screenWidth*0.03 ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [


                  Flexible(
                    child: Text(
                      progetto.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color:  Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (progetto.completato)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.black,
                    size: 20,
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
                _buildCompletedProjectRow(dataConsegna),
              if (progetto.completato)
                _buildVotoRow(progetto.voto),
              if (!progetto.completato)
                _buildIncompleteProjectRow(attivitaNonCompletate),
              if (!progetto.completato)
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
        const Icon(
          Icons.date_range,
          size: 16,
          color: Colors.black,
        ),
        const SizedBox(width: 5),
        Text(
          dataConsegna,
          style: const TextStyle(
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
        const Icon(
          Icons.task,
          size: 16,
          color:  Colors.black,
        ),
        const SizedBox(width: 5),
        Text(
          '$attivitaNonCompletate attività',
          style: const TextStyle(
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

  Row _buildVotoRow(String voto) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Icon(
          Icons.grade,
          size: 16,
          color: Colors.black,
        ),
        const SizedBox(width: 5),
        Text(
          voto,
          style: const TextStyle(
            fontSize: 12,
            color:  Colors.black,
          ),
        ),
      ],
    );
  }


}


