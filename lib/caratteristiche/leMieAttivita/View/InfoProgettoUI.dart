import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/Model/progetto.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/ViewModel/view_model_progetto.dart';
import 'package:teamsync_flutter/caratteristiche/login/Model/user_class.dart';
import 'package:teamsync_flutter/theme/color.dart';

class InfoProgetto extends StatelessWidget {
  final String projectId;
  final ProgettoViewModel viewModel;

  const InfoProgetto({super.key,
    required this.projectId,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Progetto'),
        centerTitle: true,
      ),
      body: FutureBuilder<Progetto?>(
        future: viewModel.getProgettoById(projectId),
        builder: (BuildContext context, AsyncSnapshot<Progetto?> progettoSnapshot) {
          if (progettoSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (progettoSnapshot.hasError) {
            return const Center(child: Text('Errore nel caricamento del progetto'));
          } else if (!progettoSnapshot.hasData || progettoSnapshot.data == null) {
            return const Center(child: Text('Progetto non trovato'));
          } else {
            Progetto progetto = progettoSnapshot.data!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Red70,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        width: double.infinity,
                        height: 390,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Center(
                              child: Text(
                                'Informazioni',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            // Reduced space
                            Text(
                              'Nome: ${progetto.nome}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Descrizione: ${progetto.descrizione}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Priorità: ${progetto.priorita.name}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Data Creazione:${DateFormat('dd/MM/yyyy').format(progetto.dataCreazione)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Data Scadenza: ${DateFormat('dd/MM/yyyy').format(progetto.dataScadenza)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: FutureBuilder<List<ProfiloUtente>>(
                      future: viewModel.getPartecipantiByIds(progetto.partecipanti),
                      builder: (context, AsyncSnapshot<List<ProfiloUtente>> partecipantiSnapshot) {
                        if (partecipantiSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (partecipantiSnapshot.hasError) {
                          return const Center(child: Text('Errore nel caricamento dei partecipanti'));
                        } else if (!partecipantiSnapshot.hasData || partecipantiSnapshot.data!.isEmpty) {
                          return const Center(child: Text('Nessun partecipante trovato.'));
                        } else {
                          List<ProfiloUtente> utenti = partecipantiSnapshot.data!;
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 20.0,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: utenti.map((utente) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                                  child: createElevatedCard(
                                    title: '${utente.nome} ${utente.cognome}',
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget createElevatedCard({
    required String title,
    double elevation = 2.0,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16.0),
    double height = 80,
    double width = 358,
    Color cardColor = Colors.white54,
  }) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        height: height,
        width: width,
        padding: padding,
        child: Row(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.person,
                size: 40.0,
                color: Colors.black12,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20.1,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
