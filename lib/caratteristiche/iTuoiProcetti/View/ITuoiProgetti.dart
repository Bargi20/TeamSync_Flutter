import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/ViewModel/ViewModelProgetto.dart';
import 'package:teamsync_flutter/data.models/Priorita.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/View/SezioneProfiloUtente.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/View/SezioneCalendario.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/View/SezioneProgressiProgetti.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/View/SezioneITuoiProgetti.dart';
import 'package:teamsync_flutter/navigation/Schermate.dart';
import 'package:teamsync_flutter/caratteristiche/login/viewModel/ViewModelUtente.dart';

class YourProjectsPage extends StatefulWidget {
  ViewModelUtente viewmodelutente;
  ProgettoViewModel viwmodelProgetto;

  YourProjectsPage({required this.viewmodelutente, required this.viwmodelProgetto});

  @override
  _YourProjectsPageState createState() => _YourProjectsPageState();
}

class _YourProjectsPageState extends State<YourProjectsPage> {
  @override
  void initState() {
    super.initState();
    if (widget.viwmodelProgetto.utenteCorrenteId != null) {
      widget.viwmodelProgetto.caricaProgettiUtente(widget.viwmodelProgetto.utenteCorrenteId!, true);
      widget.viwmodelProgetto.caricaProgettiCompletatiUtente(widget.viwmodelProgetto.utenteCorrenteId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModelProgetto = widget.viwmodelProgetto;
    final isLoading = viewModelProgetto.isLoading;
    final projects = viewModelProgetto.progetti;
    final completedProjects = viewModelProgetto.progettiCompletati;
    final currentUserId = viewModelProgetto.utenteCorrenteId;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
            'Home',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) async {
              switch (value) {
                case 'sync':
                  if (currentUserId != null) {
                    viewModelProgetto.caricaProgettiUtente(currentUserId, true);
                    viewModelProgetto.caricaProgettiCompletatiUtente(currentUserId);
                  }
                  break;
                case 'logout':
                  widget.viwmodelProgetto.logout();
                  widget.viewmodelutente.logout(context);
                  Navigator.of(context).pushReplacementNamed(Schermate.login);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sync',
                child: ListTile(
                  leading: Icon(Icons.refresh, color: Colors.black),
                  title: Text('Sync', style: TextStyle(color: Colors.black)),
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.black),
                  title: Text('Logout', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (currentUserId != null) {
            showDialog(
              context: context,
              builder: (context) {
                return CreaProgettoDialog(
                  onDismissRequest: () {
                    Navigator.of(context).pop();
                  },
                  viewModelProgetto: viewModelProgetto,
                  currentUserId: currentUserId,
                );
              },
            );
          } else {
            print("Errore: l'ID dell'utente corrente è null");
          }
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (isLoading)
            const SizedBox(height: 16),
            SezioneProfiloUtente(),
            const SizedBox(height: 16),
            if (!isLoading)
              SezioneITUoiProgetti(
              progetti: projects,
              attivitaProgetti: viewModelProgetto.attivitaProgetti,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SezioneProgressiProgetti(
                  progettiCompletati: completedProjects.length,
                  progettiUtente: projects.length,
                ),
                SezioneCalendario(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CreaProgettoDialog extends StatefulWidget {
  final VoidCallback onDismissRequest;
  ProgettoViewModel viewModelProgetto;
  final String currentUserId;


  CreaProgettoDialog({
    required this.onDismissRequest,
    required this.viewModelProgetto,
    required this.currentUserId,
  });

  @override
  _CreaProgettoDialogState createState() => _CreaProgettoDialogState();
}

class _CreaProgettoDialogState extends State<CreaProgettoDialog> {
  String nome = '';
  String descrizione = '';
  DateTime dataScadenza = DateTime.now();
  Priorita priorita = Priorita.NESSUNA;
  String codiceProgetto = '';
  final maxCharsNome = 20;
  final maxCharsDescrizione = 200;
  bool aggiungiProgetto = false;
  bool creaProgetto = true;

  @override
  Widget build(BuildContext context) {
    var dataScadenzaStr = DateFormat('dd/MM/yyyy').format(dataScadenza);

    return AlertDialog(
      title: const Text(
        'Crea o Unisciti a un Progetto',
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(creaProgetto)
            TextField(
              onChanged: (value) {
                if (value.length <= maxCharsNome) {
                  setState(() {
                    aggiungiProgetto = false;
                    nome = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Nome',
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade700),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              style: TextStyle(color: Colors.black),
              maxLines: 2,
            ) ,
            if(creaProgetto)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${nome.length} / $maxCharsNome',
                style: TextStyle(color: Colors.black),
              ),
            ),
            if(creaProgetto)
            const SizedBox(height: 8.0),
            if(creaProgetto)
            TextField(
              onChanged: (value) {
                if (value.length <= maxCharsDescrizione) {
                  setState(() {
                    aggiungiProgetto = false;
                    descrizione = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Descrizione',
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade700),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              style: TextStyle(color: Colors.black),
              maxLines: 4,
            ),
            if(creaProgetto)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${descrizione.length} / $maxCharsDescrizione',
                style: TextStyle(color: Colors.black),
              ),
            ),
            if(creaProgetto)
            SizedBox(height: 8.0),
            if(creaProgetto)
            TextField(
              controller: TextEditingController(text: dataScadenzaStr),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: dataScadenza,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.light(),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null && pickedDate != dataScadenza) {
                  setState(() {
                    aggiungiProgetto = false;
                    dataScadenza = pickedDate;
                  });
                }
              },
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Data di Scadenza',
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade700),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                suffixIcon: Icon(Icons.calendar_today, color: Colors.black),
              ),
              style: TextStyle(color: Colors.black),
            ),
            if(creaProgetto)
            const SizedBox(height: 8.0),
            if(creaProgetto)
            DropdownButtonFormField<Priorita>(
              value: priorita,
              onChanged: (value) {
                setState(() {
                  aggiungiProgetto = false;
                  priorita = value!;
                });
              },
              items: Priorita.values.map((priorita) {
                return DropdownMenuItem<Priorita>(
                  value: priorita,
                  child: Text(
                    priorita.toString().split('.').last,
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Priorità',
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade700),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
            if(creaProgetto)
            SizedBox(height: 16.0),
            if(aggiungiProgetto)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      setState(() {
                        creaProgetto = !creaProgetto;
                        codiceProgetto = '';
                        aggiungiProgetto = !aggiungiProgetto;
                      });
                    },
                    child: Text(
                      'Oppure crea un progetto',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red[700],
                        decoration: TextDecoration.underline,
                        fontSize: 16.0,
                      ),
                    )
                ),
              ],
            ),
            Divider(color: Colors.black),
            if(creaProgetto)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Unisciti a un Progetto',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),

                GestureDetector(
                    onTap: () {
                      setState(() {
                        creaProgetto = !creaProgetto;
                        nome = '';
                        descrizione = '';
                        priorita = Priorita.NESSUNA;
                        dataScadenzaStr = '';
                        dataScadenza = DateTime.now();
                        codiceProgetto = '';
                        aggiungiProgetto = !aggiungiProgetto;
                      });
                    },
                    child: Text(
                      'Con un Codice',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red[700],
                        decoration: TextDecoration.underline,
                        fontSize: 16.0,
                      ),
                    )
                ),
                ],
              ),
            const SizedBox(height: 10.0),

            if(aggiungiProgetto)
              const Text(
                'Inserisci il codice:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
            if(aggiungiProgetto)
            SizedBox(height: 15.0),
            if(aggiungiProgetto)
              TextField(
              onChanged: (value) {
                setState(() {
                  nome = '';
                  print (nome);
                  codiceProgetto = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Codice Progetto',
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade700),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              style: TextStyle(color: Colors.black),
            ),

            const SizedBox(height: 16.0),

          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            widget.onDismissRequest();
          },
          child: Text(
            'Annulla',
            style: TextStyle(color: Colors.red.shade700),
          ),
        ),
        ElevatedButton(
          onPressed: codiceProgetto.isNotEmpty || nome.isNotEmpty
              ? () async {
            if (codiceProgetto.isNotEmpty) {

              bool success = await widget.viewModelProgetto.aggiungiPartecipanteConCodice(
                widget.currentUserId, codiceProgetto);
              if (success) {
                widget.viewModelProgetto.caricaProgettiUtente(widget.currentUserId, true);
                widget.viewModelProgetto.caricaProgettiCompletatiUtente(widget.currentUserId);
                creaProgetto = false;
                aggiungiProgetto = false;
                Navigator.of(context).pop();
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Errore'),
                      content: Text(widget.viewModelProgetto.erroreAggiungiProgetto!),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            } else {
              // Create a new project
              await widget.viewModelProgetto.addProgetto(
                  nome: nome,
                  descrizione: descrizione,
                  dataScadenza: dataScadenza,
                  priorita: priorita,
                  partecipanti: [widget.currentUserId], // Aggiungi il partecipante qui
                  onSuccess: (progettoId) {
                    widget.viewModelProgetto.caricaProgettiUtente(widget.currentUserId, true);
                    widget.viewModelProgetto.caricaProgettiCompletatiUtente(widget.currentUserId);
                    Navigator.of(context).pushReplacementNamed(Schermate.ituoiProgetti);
                    print('Progetto creato con successo con ID: $progettoId');
                  }

              );
              creaProgetto = false;
              aggiungiProgetto = false;
              Navigator.of(context).pop();
            }
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,

          ),
          child: const Text('Conferma',style: TextStyle(color: Colors.white),),

        ),
      ],
    );
  }
}
