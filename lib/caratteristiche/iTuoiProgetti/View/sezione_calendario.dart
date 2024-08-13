import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class SezioneCalendario extends StatelessWidget {

  static const String icCalendarioEvento = 'assets/ic_calendario_evento.png';
  static const String calendarioString = 'Calendario';
  const SezioneCalendario({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final currentDate = DateTime.now();
    final dateFormatter = DateFormat('d MMMM');
    final formattedDate = dateFormatter.format(currentDate);

    return Card(
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: InkWell(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          width: screenWidth*0.4,
          height: screenHeight*0.13,
          padding:  EdgeInsets.symmetric(horizontal: screenWidth*0.03, vertical: screenHeight*0.02),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    calendarioString,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: screenHeight*0.01),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:  Colors.grey[350],
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
                     SizedBox(width: screenWidth*0.01),
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


}


