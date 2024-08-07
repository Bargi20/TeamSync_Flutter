import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

// Assuming you have a resource file or assets for drawable and strings
// Replace with appropriate asset paths and string identifiers
const String icCalendarioEvento = 'assets/ic_calendario_evento.png';
const String calendarioString = 'Calendario';

class SezioneCalendario extends StatelessWidget {
  final bool isDarkTheme;

  SezioneCalendario({required this.isDarkTheme});

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now();
    final dateFormatter = DateFormat('d MMMM');
    final formattedDate = dateFormatter.format(currentDate);

    return Card(
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDarkTheme ? Colors.black : Colors.white,
      child: InkWell(
        onTap: () {
          _showDatePicker(context);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          width: 160,
          height: 100,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    calendarioString,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center, // Center text
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDarkTheme ? Colors.white : Colors.grey[350],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 24,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: isDarkTheme ? ThemeData.dark() : ThemeData.light(),
          child: child!,
        );
      },
    ).then((selectedDate) {
      // Handle date selection
      if (selectedDate != null) {
        // Do something with the selected date
      }
    });
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: SezioneCalendario(isDarkTheme: false),
      ),
    ),
  ));
}
