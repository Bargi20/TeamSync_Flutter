import 'package:flutter/material.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/Model/progetto.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/ViewModel/view_model_progetto.dart';
import 'package:intl/intl.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/ViewModel/LeMieAttivitaViewModel.dart';
import 'package:teamsync_flutter/caratteristiche/login/Model/user_class.dart';
import 'package:teamsync_flutter/navigation/schermate.dart';

class Delegatask extends StatefulWidget {
  final String taskId;
  final String titolo;
  final String descrizione;
  final String priorita;
  final DateTime data;
  final String progettoId;
  final ProgettoViewModel viewModel;
  final LeMieAttivitaViewModel viewModelTodo;

  const Delegatask({
    required this.taskId,
    required this.progettoId,
    required this.viewModel,
    required this.titolo,
    required this.data,
    required this.descrizione,
    required this.priorita,
    required this.viewModelTodo,

    super.key,
  });

  @override
  _DelegataskState createState() => _DelegataskState();
}

class _DelegataskState extends State<Delegatask> {
  Map<String, bool> _userAssigned = {};
  late Future<Progetto?> _futureProgetto;


  @override
  void initState() {
    super.initState();
    _futureProgetto = widget.viewModel.getProgettoById(widget.progettoId);
    _checkUserAssignments();
  }

  Future<void> _checkUserAssignments() async {
    Progetto? progetto = await _futureProgetto;
    if (progetto != null) {
      Map<String, bool> tempUserAssigned = {};
      for (String userId in progetto.partecipanti) {
        bool isAssigned = await widget.viewModelTodo.utenteAssegnato(userId, widget.taskId);
        tempUserAssigned[userId] = isAssigned;
      }
      setState(() {
        _userAssigned = tempUserAssigned;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delega Task'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
             Navigator.of(context).pushNamed(
                Schermate.leMieAttivita,
                arguments: widget.progettoId,
              );
            }
        ),
      ),

      body: FutureBuilder<Progetto?>(
        future: _futureProgetto,
        builder: (BuildContext context, AsyncSnapshot<Progetto?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Errore nel caricamento del progetto'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Progetto non trovato'));
          } else {
            Progetto progetto = snapshot.data!;

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
                          color: Colors.red[700],
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Center(
                              child: Text(
                                'Dettagli Task',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              'Titolo: ${widget.titolo}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              'Descrizione: ${widget.descrizione}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Priorità Task: ${widget.priorita}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Data Scadenza Task: ${DateFormat('dd/MM/yyyy').format(widget.data)}',
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
                  const SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
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
                        children: <Widget>[
                          const Text(
                            'Assegna Task a:',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          FutureBuilder<List<ProfiloUtente>>(
                            future: widget.viewModel.getPartecipantiByIds(progetto.partecipanti),
                            builder: (context, AsyncSnapshot<List<ProfiloUtente>> partecipantiSnapshot) {
                              if (partecipantiSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (partecipantiSnapshot.hasError) {
                                return const Center(child: Text('Errore nel caricamento dei partecipanti'));
                              } else if (!partecipantiSnapshot.hasData || partecipantiSnapshot.data!.isEmpty) {
                                return const Center(child: Text('Nessun partecipante trovato.'));
                              } else {
                                List<ProfiloUtente> utenti = partecipantiSnapshot.data!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: utenti.map((utente) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Card(
                                        elevation: 4.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.all(16.0),
                                          title: Text('${utente.nome} ${utente.cognome}'),
                                          trailing: IconButton(
                                            icon: Icon(
                                              _userAssigned[utente.id] ?? false
                                                  ? Icons.cancel_outlined
                                                  : Icons.add,
                                            ),
                                            onPressed: () async {
                                              if (_userAssigned[utente.id] ?? false) {
                                                // Rimuovere l'utente dal task
                                                await widget.viewModelTodo.removeUserTodo(utente.id, widget.taskId);
                                                setState(() {
                                                  _userAssigned[utente.id] = false;
                                                });
                                              } else {
                                                // Assegnare l'utente al task
                                                await widget.viewModelTodo.addUserTodo(utente.id, widget.taskId);
                                                setState(() {
                                                  _userAssigned[utente.id] = true;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }
                            },
                          ),
                        ],
                      ),
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
}
