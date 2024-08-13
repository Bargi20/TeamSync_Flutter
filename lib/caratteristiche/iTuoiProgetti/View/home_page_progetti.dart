import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/ViewModel/view_model_progetto.dart';
import 'package:teamsync_flutter/data.models/Priorita.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/View/sezione_profilo_utente.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/View/sezione_calendario.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/View/sezione_progressi_progetti.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/View/sezione_i_tuoi_progetti.dart';
import 'package:teamsync_flutter/navigation/Schermate.dart';
import 'package:teamsync_flutter/caratteristiche/login/viewModel/view_model_utente.dart';

class YourProjectsPage extends StatefulWidget {
  final ViewModelUtente viewmodelutente;
  final ProgettoViewModel viewmodelProgetto;

  const YourProjectsPage({super.key, required this.viewmodelutente, required this.viewmodelProgetto});

  @override
  YourProjectsPageState createState() => YourProjectsPageState();
}

class YourProjectsPageState extends State<YourProjectsPage> {
  @override
  void initState() {
    super.initState();
    if (widget.viewmodelProgetto.utenteCorrenteId != null) {
      widget.viewmodelProgetto.caricaProgettiUtente(widget.viewmodelProgetto.utenteCorrenteId!, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModelProgetto = widget.viewmodelProgetto;
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
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) async {
              switch (value) {
                case 'sync':
                  if (currentUserId != null) {
                    viewModelProgetto.caricaProgettiUtente(currentUserId, true);
                    viewModelProgetto.caricaProgettiCompletatiUtente(currentUserId);
                  }
                  break;
                case 'logout':
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
              const PopupMenuItem(
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
          }
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
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
            const SezioneProfiloUtente(),
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
                const SezioneCalendario(),
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
  final ProgettoViewModel viewModelProgetto;
  final String currentUserId;


  const CreaProgettoDialog({super.key,
    required this.onDismissRequest,
    required this.viewModelProgetto,
    required this.currentUserId,
  });

  @override
  CreaProgettoDialogState createState() => CreaProgettoDialogState();
}

class CreaProgettoDialogState extends State<CreaProgettoDialog> {
  String nome = '';
  String descrizione = '';
  DateTime dataScadenza = DateTime.now();
  Priorita priorita = Priorita.NESSUNA;
  String codiceProgetto = '';
  final maxCharsNome = 20;
  final maxCharsDescrizione = 200;
  bool uniscitiProgetto = false;
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
                    uniscitiProgetto = false;
                    nome = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Nome',
                labelStyle: const TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade700),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              style: const TextStyle(color: Colors.black),
              maxLines: 2,
            ) ,
            if(creaProgetto)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${nome.length} / $maxCharsNome',
                style: const TextStyle(color: Colors.black),
              ),
            ),
            if(creaProgetto)
            const SizedBox(height: 8.0),
            if(creaProgetto)
            TextField(
              onChanged: (value) {
                if (value.length <= maxCharsDescrizione) {
                  setState(() {
                    uniscitiProgetto = false;
                    descrizione = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Descrizione',
                labelStyle: const TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade700),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              style: const TextStyle(color: Colors.black),
              maxLines: 4,
            ),
            if(creaProgetto)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${descrizione.length} / $maxCharsDescrizione',
                style: const TextStyle(color: Colors.black),
              ),
            ),
            if(creaProgetto)
            const SizedBox(height: 8.0),
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
                    uniscitiProgetto = false;
                    dataScadenza = pickedDate;
                  });
                }
              },
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Data di Scadenza',
                labelStyle: const TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade700),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                suffixIcon: const Icon(Icons.calendar_today, color: Colors.black),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            if(creaProgetto)
            const SizedBox(height: 8.0),
            if(creaProgetto)
            DropdownButtonFormField<Priorita>(
              value: priorita,
              onChanged: (value) {
                setState(() {
                  uniscitiProgetto = false;
                  priorita = value!;
                });
              },
              items: Priorita.values.map((priorita) {
                return DropdownMenuItem<Priorita>(
                  value: priorita,
                  child: Text(
                    priorita.toString().split('.').last,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Priorità',
                labelStyle: const TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade700),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
            if(creaProgetto)
            const SizedBox(height: 16.0),
            if(uniscitiProgetto)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      setState(() {
                        creaProgetto = !creaProgetto;
                        codiceProgetto = '';
                        uniscitiProgetto = !uniscitiProgetto;
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
            const Divider(color: Colors.black),
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
                        uniscitiProgetto = !uniscitiProgetto;
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

            if(uniscitiProgetto)
              const Text(
                'Inserisci il codice:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
            if(uniscitiProgetto)
            const SizedBox(height: 15.0),
            if(uniscitiProgetto)
              TextField(
              onChanged: (value) {
                setState(() {
                  nome = '';
                  codiceProgetto = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Codice Progetto',
                labelStyle: const TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade700),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              style: const TextStyle(color: Colors.black),
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
              final navigator = Navigator.of(context);
              bool success = await widget.viewModelProgetto.aggiungiPartecipanteConCodice(
                widget.currentUserId, codiceProgetto);
              if (success) {
                widget.viewModelProgetto.caricaProgettiUtente(widget.currentUserId, true);
                widget.viewModelProgetto.caricaProgettiCompletatiUtente(widget.currentUserId);
                creaProgetto = false;
                uniscitiProgetto = false;
                navigator.pop();
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Errore'),
                      content: Text(widget.viewModelProgetto.erroreAggiungiProgetto!),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            } else {
              final navigator = Navigator.of(context);
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
                  }

              );
              creaProgetto = false;
              uniscitiProgetto = false;
              navigator.pop();
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
