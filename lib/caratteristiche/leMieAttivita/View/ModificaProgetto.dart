import 'package:flutter/material.dart';
import 'package:teamsync_flutter/data.models/Priorita.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/Model/progetto.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/ViewModel/view_model_progetto.dart';
import '../../../navigation/Schermate.dart';

class ModificaProgetto extends StatefulWidget {
  final String projectId;
  final ProgettoViewModel viewModel;
  final DateTime DataMinimaScadenzaTask;

  const ModificaProgetto({
    required this.projectId,
    required this.viewModel,
    required this.DataMinimaScadenzaTask,
    Key? key,
  }) : super(key: key);

  @override
  _ModificaProgettoState createState() => _ModificaProgettoState();
}

class _ModificaProgettoState extends State<ModificaProgetto> {
  late TextEditingController _nomeProgettoController;
  late TextEditingController _descrizioneProgettoController;
  late TextEditingController _dataScadenzaController;
  late TextEditingController _dataConsegnaController;
  bool caricaAggiornamenti = false;
  Priorita? _selectedPriorita;
  DateTime? _selectedDate;
  DateTime? _selectedDate2;
  String? _selectedVoto;
  Priorita? _priorita;

  bool _progettoCompletato = false;

  Progetto? _progetto;

  @override
  void initState() {
    super.initState();
    _nomeProgettoController = TextEditingController();
    _descrizioneProgettoController = TextEditingController();
    _dataScadenzaController = TextEditingController();
    _dataConsegnaController = TextEditingController();
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
        _priorita = progetto.priorita;
        _selectedDate = progetto.dataScadenza;
        _selectedDate2 = progetto.dataConsegna;
        _progettoCompletato = progetto.completato ?? false;
        _selectedVoto = progetto.voto ?? "Non valutato";

        _dataConsegnaController.text = _selectedDate2 == null
            ? ''
            : "${_selectedDate2!.day}/${_selectedDate2!.month}/${_selectedDate2!.year}";

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
    _dataConsegnaController.dispose();
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
    final dataConsegna = _selectedDate2;
    final voto = _selectedVoto ?? "Non valutato";

    if (nomeProgetto.isNotEmpty && priorita != null && dataScadenza != null) {
      await widget.viewModel.aggiornaProgetto(
        progettoId: widget.projectId,
        nome: nomeProgetto,
        descrizione: descrizioneProgetto,
        dataScadenza: dataScadenza,
        priorita: priorita,
        completato: _progettoCompletato,
        voto: voto,
        dataConsegna: dataConsegna!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Progetto salvato con successo!')),
      );
      Navigator.pushNamed(
        context,
        Schermate.leMieAttivita,
        arguments: widget.projectId,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Per favore, compila tutti i campi obbligatori.')),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required int maxLength,
    int maxLines = 1,
    int currentLength = 0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(16.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red[700]!),
              borderRadius: BorderRadius.circular(16.0),
            ),
            counter: Text(
              '$currentLength/$maxLength',
              style: const TextStyle(color: Colors.black54, fontSize: 12.0),
            ),
            counterText: '',
          ),
          style: const TextStyle(color: Colors.black),
          onChanged: (text) {
            setState(() {});
          },
        ),
      ],
    );
  }

  // Widget per il dropdown della priorità
  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<Priorita>(
      value: _priorita,
      decoration: InputDecoration(
        labelText: 'Priorità',
        labelStyle: const TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(16.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red[700]!),
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      items: Priorita.values.map((Priorita p) {
        return DropdownMenuItem<Priorita>(
          value: p,
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: p.colore,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                p.name,
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (Priorita? newValue) {
        setState(() {
          _selectedPriorita = newValue!;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_progetto == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Modifica Progetto'),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<String> voti = [
      "Non valutato",
      "18",
      "19",
      "20",
      "21",
      "22",
      "23",
      "24",
      "25",
      "26",
      "27",
      "28",
      "29",
      "30"
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Modifica Progetto'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _nomeProgettoController,
              label: "Nome Progetto",
              maxLength: 20,
              currentLength: _nomeProgettoController.text.length,
            ),
            SizedBox(height: 16.0),
            _buildTextField(
              controller: _descrizioneProgettoController,
              label: "Descrizione Progetto",
              maxLength: 200,
              maxLines: 5,
              currentLength: _descrizioneProgettoController.text.length,
            ),
            SizedBox(height: 16.0),
            _buildPriorityDropdown(),
            SizedBox(height: 16.0),
            TextField(
              controller: _dataScadenzaController,
              decoration: InputDecoration(
                labelText: 'Data Scadenza',
                labelStyle: const TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red[700]!),
                  borderRadius: BorderRadius.circular(16.0),
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
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.red,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                    _dataScadenzaController.text =
                    "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
                  });
                }
              },
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hai finito il progetto e vuoi consegnarlo?'),
                    Text('Attiva il bottone'),
                  ],
                ),
                Switch(
                  value: _progettoCompletato,
                  activeColor: Colors.red[700],
                  onChanged: (bool newValue) {
                    setState(() {
                      _progettoCompletato = newValue;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            if (_progettoCompletato) ...[
              TextField(
                controller: _dataConsegnaController,
                decoration: InputDecoration(
                  labelText: 'Data Consegna',
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red[700]!),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate2 ?? DateTime.now(),
                    firstDate: widget.DataMinimaScadenzaTask,
                    lastDate: DateTime(2101),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Colors.red,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate2 = pickedDate;
                      _dataConsegnaController.text =
                      "${_selectedDate2!.day}/${_selectedDate2!.month}/${_selectedDate2!.year}";
                    });
                  }
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedVoto != null && voti.contains(_selectedVoto) ? _selectedVoto : voti.first,
                menuMaxHeight: 400,
                items: voti.map((String voto) {
                  return DropdownMenuItem<String>(
                    value: voto,
                    child: Text(voto),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedVoto = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Seleziona un voto per questo progetto:',
                  labelStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red[700]!),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: caricaAggiornamenti ? null : _saveChanges,
          child: caricaAggiornamenti
              ? CircularProgressIndicator()
              : Text('Salva'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700], // Colore di sfondo
            foregroundColor: Colors.white, // Colore del testo
            padding: EdgeInsets.symmetric(horizontal: 60, vertical: 12),
          ),
        ),
      ),
    );
  }
}
