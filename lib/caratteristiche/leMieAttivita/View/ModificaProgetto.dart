import 'package:flutter/material.dart';
import 'package:teamsync_flutter/data.models/Priorita.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/Model/progetto.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/ViewModel/view_model_progetto.dart';

import '../../../navigation/Schermate.dart';

class ModificaProgetto extends StatefulWidget {
  final String projectId;
  final ProgettoViewModel viewModel;
  final DateTime DataMinimaScadenzaTask;

  const ModificaProgetto({required this.projectId, required this.viewModel, required this.DataMinimaScadenzaTask, Key? key}) : super(key: key);

  @override
  _ModificaProgettoState createState() => _ModificaProgettoState();
}

class _ModificaProgettoState extends State<ModificaProgetto> {
  late TextEditingController _nomeProgettoController;
  late TextEditingController _descrizioneProgettoController;
  late TextEditingController _dataScadenzaController;
  bool caricaAggiornamenti = false;
  Priorita? _selectedPriorita;
  DateTime? _selectedDate;

  Progetto? _progetto;

  @override
  void initState() {
    super.initState();
    _nomeProgettoController = TextEditingController();
    _descrizioneProgettoController = TextEditingController();
    _dataScadenzaController = TextEditingController();
    _loadProgetto();
  }

  Future<void> _loadProgetto() async {
    final progetto = await widget.viewModel.getProgettoById(widget.projectId);
    if (progetto != null) {
      setState(() {
        _progetto = progetto;
        _nomeProgettoController.text = progetto.nome ?? '';
        _descrizioneProgettoController.text = progetto.descrizione ?? '';
        _selectedPriorita = progetto.priorita;
        _selectedDate = progetto.dataScadenza;
        _dataScadenzaController.text = _selectedDate == null
            ? ''
            : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
      });
    }
  }

  @override
  void dispose() {
    _nomeProgettoController.dispose();
    _descrizioneProgettoController.dispose();
    _dataScadenzaController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_progetto == null) return;
    setState(() {
      caricaAggiornamenti = true;
    });

    final nomeProgetto = _nomeProgettoController.text;
    final descrizioneProgetto = _descrizioneProgettoController.text;
    final priorita = _selectedPriorita;
    final dataScadenza = _selectedDate;

    if (nomeProgetto.isNotEmpty && priorita != null && dataScadenza != null) {


     await widget.viewModel.aggiornaProgetto(
        progettoId: widget.projectId,
        nome: nomeProgetto,
        descrizione: descrizioneProgetto,
        dataScadenza: dataScadenza,
        priorita: priorita,
        voto: _progetto!.voto,
        dataConsegna: _progetto!.dataConsegna,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Progetto salvato con successo!')),
      );
      Navigator.pushNamed(
        context,
        Schermate.leMieAttivita, // Il nome della rotta
        arguments: widget.projectId, // Passa l'idProgetto come argomento
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Per favore, compila tutti i campi obbligatori.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.DataMinimaScadenzaTask);
    if (_progetto == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Modifica Progetto'),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Modifica Progetto'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nomeProgettoController,
              decoration: InputDecoration(
                labelText: 'Nome Progetto',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descrizioneProgettoController,
              decoration: InputDecoration(
                labelText: 'Descrizione Progetto',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<Priorita>(
              value: _selectedPriorita,
              decoration: InputDecoration(
                labelText: 'Priorità',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              items: Priorita.values.map((Priorita value) {
                return DropdownMenuItem<Priorita>(
                  value: value,
                  child: SizedBox(
                    width: 100,
                    child: Text(value.toShortString()),
                  ),
                );
              }).toList(),
              onChanged: (Priorita? newValue) {
                setState(() {
                  _selectedPriorita = newValue;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _dataScadenzaController,
              decoration: InputDecoration(
                labelText: 'Data Scadenza',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: widget.DataMinimaScadenzaTask,
                  lastDate: DateTime(2101),
                );

                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                    _dataScadenzaController.text = "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
                  });
                }
              },
            ),
            SizedBox(height: 16.0), // Spazio tra Data Scadenza e il testo

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hai finito il progetto e vuoi consegnarlo?'),
                SizedBox(height: 8.0), // Spazio tra il testo e il switch
                Row(
                  children: [
                    Text('Attiva il bottone'),
                    SizedBox(width: 8.0), // Spazio tra il testo e il switch
                    Switch(
                      value: false, // Imposta il valore del switch come desiderato
                      onChanged: (bool newValue) {
                        // Non gestiamo questo cambiamento per adesso
                        // ma puoi aggiungere la logica se necessario
                      },
                    ),
                  ],
                ),
              ],
            ),

            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: caricaAggiornamenti ? null : _saveChanges,
                child: caricaAggiornamenti? CircularProgressIndicator() : Text('Salva') ,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Colore di sfondo
                  foregroundColor: Colors.white, // Colore del testo
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
