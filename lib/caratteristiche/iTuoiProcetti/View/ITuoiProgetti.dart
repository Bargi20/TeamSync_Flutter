import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/ViewModel/ViewModelProgetto.dart';
import 'package:teamsync_flutter/data.models/Priorita.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/View/SezioneProfiloUtente.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/View/SezioneCalendario.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/View/SezioneProgressiProgetti.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/View/SezioneITuoiProgetti.dart';
import 'package:teamsync_flutter/navigation/Schermate.dart';

class YourProjectsPage extends StatefulWidget {
  @override
  _YourProjectsPageState createState() => _YourProjectsPageState();
}

class _YourProjectsPageState extends State<YourProjectsPage> {
  bool isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    final viewModelProgetto = Provider.of<ProgettoViewModel>(context);
    final isLoading = viewModelProgetto.isLoading;
    final projects = viewModelProgetto.progetti;
    final completedProjects = viewModelProgetto.progettiCompletati;
    final currentUserId = viewModelProgetto.utenteCorrenteId;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkTheme ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: isDarkTheme ? Colors.white : Colors.black),
            onSelected: (value) {
              switch (value) {
                case 'sync':
                  if (currentUserId != null) {
                    viewModelProgetto.caricaProgettiUtente(currentUserId, true);
                    viewModelProgetto.caricaProgettiCompletatiUtente(currentUserId);
                  }
                  break;
                case 'settings':
                  Navigator.of(context).pushNamed('/settings');
                  break;
                case 'logout':
                  viewModelProgetto.logout();
                  Navigator.of(context).pushReplacementNamed('/login');
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'sync',
                child: ListTile(
                  leading: Icon(Icons.refresh, color: isDarkTheme ? Colors.white : Colors.black),
                  title: Text('Sync', style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black)),
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings, color: isDarkTheme ? Colors.white : Colors.black),
                  title: Text('Settings', style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black)),
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: isDarkTheme ? Colors.white : Colors.black),
                  title: Text('Logout', style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black)),
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
                  isDarkTheme: isDarkTheme,
                  currentUserId: currentUserId!, // Utilizza il null-assertion operator
                );
              },
            );
          } else {
            // Gestisci il caso in cui currentUserId è null
            print("Errore: l'ID dell'utente corrente è null");
          }
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(//per la visualizzzione di piu item
          children: [
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            SezioneProfiloUtente(isDarkTheme: isDarkTheme),
            const SizedBox(height: 16),
            SezioneITUoiProgetti(
              progetti: projects,
              attivitaProgetti: viewModelProgetto.attivitaProgetti,
              isDarkTheme: isDarkTheme,
              onProgettoTap: (progetto) {
                Navigator.of(context).pushNamed('/progettoDettagli', arguments: progetto);
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SezioneProgressiProgetti(
                  progettiCompletati: completedProjects.length,
                  progettiUtente: projects.length,
                  isDarkTheme: isDarkTheme,
                ),
                SezioneCalendario(isDarkTheme: isDarkTheme),
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
  final bool isDarkTheme;
  final String currentUserId;


  CreaProgettoDialog({
    required this.onDismissRequest,
    required this.viewModelProgetto,
    required this.isDarkTheme,
    required this.currentUserId,

  });

  @override
  _CreaProgettoDialogState createState() => _CreaProgettoDialogState();
}

class _CreaProgettoDialogState extends State<CreaProgettoDialog> {
  String nome = '';
  String descrizione = '';
  DateTime dataScadenza = DateTime.now();
  Priorita priorita = Priorita.nessuna;
  String voto = '';
  DateTime dataConsegna = DateTime.now();
  final maxCharsNome = 20;
  final maxCharsDescrizione = 200;

  @override
  Widget build(BuildContext context) {
    var dataScadenzaStr = DateFormat('dd/MM/yyyy').format(dataScadenza);
    var dataConsegnaStr = DateFormat('dd/MM/yyyy').format(dataConsegna);

    return AlertDialog(
      title: Text(
        'Crea Nuovo Progetto',
        style: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
      ),
      backgroundColor: widget.isDarkTheme ? Colors.black : Colors.white,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) {
                if (value.length <= maxCharsNome) {
                  setState(() {
                    nome = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Nome',
                labelStyle: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.isDarkTheme ? Colors.white : Colors.black),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade700),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              style: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
              maxLines: 2,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${nome.length} / $maxCharsNome',
                style: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              onChanged: (value) {
                if (value.length <= maxCharsDescrizione) {
                  setState(() {
                    descrizione = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Descrizione',
                labelStyle: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.isDarkTheme ? Colors.white : Colors.black),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade700),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              style: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
              maxLines: 4,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${descrizione.length} / $maxCharsDescrizione',
                style: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
              ),
            ),
            SizedBox(height: 8.0),
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
                      data: widget.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null && pickedDate != dataScadenza) {
                  setState(() {
                    dataScadenza = pickedDate;
                  });
                }
              },
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Data di Scadenza',
                labelStyle: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.isDarkTheme ? Colors.white : Colors.black),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade700),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                suffixIcon: Icon(Icons.calendar_today, color: widget.isDarkTheme ? Colors.white : Colors.black),
              ),
              style: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
            ),
            SizedBox(height: 18.0),
            TextField(
              controller: TextEditingController(text: dataConsegnaStr),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: dataConsegna,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                  builder: (context, child) {
                    return Theme(
                      data: widget.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null && pickedDate != dataConsegna) {
                  setState(() {
                    dataConsegna = pickedDate;
                  });
                }
              },
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Data di Consegna',
                labelStyle: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.isDarkTheme ? Colors.white : Colors.black),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade700),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                suffixIcon: Icon(Icons.calendar_today, color: widget.isDarkTheme ? Colors.white : Colors.black),
              ),
              style: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
            ),
            SizedBox(height: 10.0),
            SizedBox(height: 8.0),
            DropdownButtonFormField<Priorita>(
              value: priorita,
              onChanged: (Priorita? newValue) {
                setState(() {
                  priorita = newValue!;
                });
              },
              items: Priorita.values.map((Priorita classType) {
                return DropdownMenuItem<Priorita>(
                  value: classType,
                  child: Text(
                    classType.name,
                    style: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Priorità',
                labelStyle: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.isDarkTheme ? Colors.white : Colors.black),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade700),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              dropdownColor: widget.isDarkTheme ? Colors.black : Colors.white,
              style: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Annulla',
            style: TextStyle(color: widget.isDarkTheme ? Colors.white : Colors.black),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.viewModelProgetto.addProgetto(
              nome: nome,
              descrizione: descrizione,
              dataScadenza: dataScadenza,
              priorita: priorita,
              dataConsegna: dataConsegna,
              partecipanti: [widget.currentUserId], // Aggiungi il partecipante qui
              onSuccess: (progettoId) {
                Navigator.of(context).pop();
                print('Progetto creato con successo con ID: $progettoId');
              },
            );
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.red.shade700),
          ),
          child: Text('Crea', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
