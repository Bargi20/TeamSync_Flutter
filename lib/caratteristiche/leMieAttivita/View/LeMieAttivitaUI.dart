import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/ViewModel/ViewModelProgetto.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/Repository/ToDoRepository.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/ViewModel/LeMieAttivitaViewModel.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/Model/LeMieAttivita.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/Model/Progetto.dart';
import 'package:teamsync_flutter/navigation/schermate.dart';

void showAbbandonaProgettoDialog({
  required BuildContext context,
  required String progettoId,
  required VoidCallback onDismissRequest,
}) {
  final viewModelProgetto = Provider.of<ProgettoViewModel>(context, listen: false);
  final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
  final userId = viewModelProgetto.utenteCorrenteId;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Abbandona il progetto?',
          style: TextStyle(
            color: isDarkTheme ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center, // Center align the title
          ),
        ),
        backgroundColor: isDarkTheme ? Colors.black : Colors.grey[350],
        content: Text(
          'Sei sicuro di voler abbandonare questo progetto?',
          style: TextStyle(
            color: isDarkTheme ? Colors.white : Colors.black,
            textAlign: TextAlign.center, // Center align the content text
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              onDismissRequest();
              viewModelProgetto.abbandonaProgetto(userId, progettoId);
              Navigator.pushReplacementNamed(context, Schermate.ituoiProgetti);
            },
            child: Text(
              'Abbandona',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          TextButton(
            onPressed: () {
              onDismissRequest();
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text(
              'Annulla',
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      );
    },
  );
}
