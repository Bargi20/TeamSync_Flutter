import 'package:flutter/material.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/Model/Progetto.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/ViewModel/ViewModelProgetto.dart';
import 'package:teamsync_flutter/caratteristiche/login/Model/UserClass.dart'; // Assicurati di importare ProfiloUtente

class InfoProgetto extends StatelessWidget {
  final String projectId;
  final ProgettoViewModel viewModel;

  InfoProgetto({
    required this.projectId,
    required this.viewModel
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
            return Column(
              mainAxisAlignment: MainAxisAlignment.start, // Align to the top
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      width: double.infinity,
                      height: 270,
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
                          const SizedBox(height: 10.0), // Reduced space
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
                            'Priorità: ${progetto.priorita}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Data Creazione: ${progetto.dataCreazione}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Data Scadenza: ${progetto.dataScadenza}',
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), // Adjusted padding
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
                          height: 380, // Altezza del riquadro scrollabile
                          decoration: BoxDecoration(
                            color: Colors.white, // Colore di sfondo del riquadro
                            borderRadius: BorderRadius.circular(16.0), // Arrotondamento dei bordi
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26, // Ombra per dare un effetto di elevazione
                                blurRadius: 20.0,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.only(top: 7.0, bottom: 7.0, left: 2.0 , right: 2.0),
                          child: SingleChildScrollView(
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
                          ),
                        );
                      }
                    },
                  ),
                )
              ],
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.school, // Icona del cappello da laureando
                size: 40.0,
                color: Colors.black12, // Colore dell'icona
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center, // Centra il testo all'interno del suo spazio
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
