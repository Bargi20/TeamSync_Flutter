import 'package:intl/intl.dart' show DateFormat;
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/ViewModel/ViewModelProgetto.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/Model/LeMieAttivita.dart';
import 'package:flutter/material.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/Model/Progetto.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/ViewModel/LeMieAttivitaViewModel.dart';
import 'package:teamsync_flutter/caratteristiche/login/viewModel/ViewModelUtente.dart';
import 'package:teamsync_flutter/data.models/Priorita.dart';
import '../../login/Model/UserClass.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/View/InfoProgettoUI.dart';




class lemieAttivita extends StatefulWidget {
  final String idProgetto;
  ProgettoViewModel viemodelprogetto;
  LeMieAttivitaViewModel viewmodelAttivita;
  ViewModelUtente viewmodelutente;
  lemieAttivita({super.key, required this.idProgetto, required this.viemodelprogetto, required this.viewmodelutente, required this.viewmodelAttivita});

  @override
  _LemieAttivitaState createState() => _LemieAttivitaState();
}



class _LemieAttivitaState extends State<lemieAttivita> {
  Progetto? progetto;
  bool isLoadingProgetto = true;
  bool isLoadingAttivita = true;
  bool isClickedCompletate = false;
  bool isClickedNonCompletate = false;
  bool isClickedLeMie = true;

  @override
  void initState() {
    super.initState();
    _fetchProgettoData();
    _fetchLeMieAttivitaData();
  }

  void _handleCompletate() {
    setState(() {
      isClickedCompletate = true;
      isClickedNonCompletate = false;
      isClickedLeMie = false;
    });
    _fetchAttivitaCompletate();
  }

  void _handleNonCompletate() {
    setState(() {
      isClickedCompletate = false;
      isClickedNonCompletate = true;
      isClickedLeMie = false;
    });
    _fetchAttivitaNonCompletate();
  }

  void _handleLeMie() {
    setState(() {
      isClickedCompletate = false;
      isClickedNonCompletate = false;
      isClickedLeMie = true;
    });
    _fetchLeMieAttivitaData();
  }

  Future<void> _fetchProgettoData() async {
    setState(() {
      isLoadingProgetto = true;
    });
    try {
      progetto =
      await widget.viemodelprogetto.getProgettoById(widget.idProgetto);
    } finally {
      setState(() {
        isLoadingProgetto = false;
      });
    }
  }

  Future<void> _fetchAttivitaCompletate() async {
    setState(() {
      isLoadingAttivita = true;
    });
    try {
      await widget.viemodelprogetto.caricaAttivitaCompletate(widget.idProgetto);
    } finally {
      setState(() {
        isLoadingAttivita = false;
      });
    }
  }

  Future<void> _fetchAttivitaNonCompletate() async {
    setState(() {
      isLoadingAttivita = true;
    });
    try {
      await widget.viemodelprogetto.caricaAttivitaNonCompletate(
          widget.idProgetto);
    } finally {
      setState(() {
        isLoadingAttivita = false;
      });
    }
  }

  Future<void> _fetchLeMieAttivitaData() async {
    setState(() {
      isLoadingAttivita = true;
    });
    try {
      await widget.viemodelprogetto.caricaLeMieAttivita(
          widget.idProgetto,
          widget.viewmodelutente.utenteCorrente!.id
      );
    } finally {
      setState(() {
        isLoadingAttivita = false;
      });
    }
  }

  Future<void> _handleDelete(LeMieAttivita attivita) async {
    await widget.viewmodelAttivita.deleteTodo(attivita.id!);
    if (isClickedLeMie) {
      _fetchLeMieAttivitaData();
    }
    if (isClickedNonCompletate) {
      _fetchAttivitaNonCompletate();
    }
    if (isClickedCompletate) {
      _fetchAttivitaCompletate();
    }
  }

  Future<void> _handleComplete(LeMieAttivita attivita) async {
    if (isClickedCompletate) {
      await widget.viewmodelAttivita.completeTodo(attivita.id!, false);
      _fetchAttivitaCompletate();
    }
    else {
      await widget.viewmodelAttivita.completeTodo(attivita.id!, true);
    }

    if (isClickedLeMie) {
      _fetchLeMieAttivitaData();
    }
    if (isClickedNonCompletate) {
      _fetchAttivitaNonCompletate();
    }
  }

  Future<void> _handleModificaTask(LeMieAttivita attivita) async {
    await widget.viewmodelAttivita.updateTodo(attivita.id!, attivita.titolo, attivita.descrizione, attivita.dataScadenza, attivita.dataCreazione, attivita.progetto, attivita.utenti, attivita.completato, attivita.priorita);
    if (isClickedCompletate) {
      _fetchAttivitaCompletate();
    }

    if (isClickedLeMie) {
      _fetchLeMieAttivitaData();
    }
    if (isClickedNonCompletate) {
      _fetchAttivitaNonCompletate();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: isLoadingProgetto
            ? const Center(child: CircularProgressIndicator())
            : Center(child: Text(progetto?.nome ?? 'Nome non disponibile')),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert),
            onSelected: (int result) {
              if (result == 1) {
                ProgettoViewModel viewModel = ProgettoViewModel(); // Creazione dell'istanza

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InfoProgetto(
                      projectId: widget.idProgetto, // Passaggio dell'ID del progetto
                      viewModel: viewModel, // Passaggio dell'istanza del ViewModel
                    ),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: const [
                    Icon(Icons.info, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Info'),
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Text('Opzione 2'),
              ),
              const PopupMenuItem<int>(
                value: 3,
                child: Text('Opzione 3'),
              ),
            ],
          ),
        ],
      ),
      body: isLoadingProgetto
          ? null : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Qui troverai le Task che sono assegnate per questo progetto',
              textAlign: TextAlign.center,
            ),
            const Divider(
              color: Colors.red,
              thickness: 2,
              height: 32,
            ),
            TodoButtons(
              idProg: widget.idProgetto,
              isClickedLeMie: isClickedLeMie,
              isClickedCompletate: isClickedCompletate,
              isClickedNonCompletate: isClickedNonCompletate,
              onCompletate: _handleCompletate,
              onNonCompletate: _handleNonCompletate,
              onLeMie: _handleLeMie,
            ),
            if(!isLoadingAttivita && isClickedCompletate)
              Expanded(
                child: ListView(
                  children: widget.viemodelprogetto.attivitaCompletate.map((
                      attivita) {
                    return TodoItem(item: attivita,
                        viewModelUtente: widget.viewmodelutente,
                        leMieAttivitaViewModel: widget.viewmodelAttivita,
                        ondelete: _handleDelete,
                      oncomplete: _handleComplete,
                      isclickecdCompletate: isClickedCompletate,
                      onEdit: _handleModificaTask,
                    );
                  }).toList(),
                ),
              ),
            if(!isLoadingAttivita && isClickedNonCompletate)
              Expanded(
                child: ListView(
                  children: widget.viemodelprogetto.attivitaNonCompletate.map((
                      attivita) {
                    return TodoItem(item: attivita,
                        viewModelUtente: widget.viewmodelutente,
                        leMieAttivitaViewModel: widget.viewmodelAttivita,
                        ondelete: _handleDelete,
                      oncomplete: _handleComplete,
                      onEdit: _handleModificaTask,
                      isclickecdCompletate: isClickedCompletate,

                    );
                  }).toList(),
                ),
              ),
            if(!isLoadingAttivita && isClickedLeMie)
              Expanded(
                child: ListView.builder(
                  itemCount: widget.viemodelprogetto.leMieAttivitaNonCompletate
                      .length,
                  itemBuilder: (context, index) {
                    final attivita = widget.viemodelprogetto
                        .leMieAttivitaNonCompletate[index];
                    return TodoItem(item: attivita,
                        viewModelUtente: widget.viewmodelutente,
                        leMieAttivitaViewModel: widget.viewmodelAttivita,
                        ondelete: _handleDelete,
                      oncomplete: _handleComplete,
                      onEdit: _handleModificaTask,
                      isclickecdCompletate: isClickedCompletate,
                        );
                  },
                ),
              ),
          ],
        ),


      ),


      floatingActionButton: Visibility(
          visible: !isClickedCompletate, // Mostra o nasconde il FAB in base a questa variabile
          child: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddTodoDialog(
                onSave: (LeMieAttivita nuovaAttivita) async {
                  await widget.viewmodelAttivita.addTodo(
                      nuovaAttivita.titolo,
                      nuovaAttivita.descrizione,
                      nuovaAttivita.dataScadenza,
                      nuovaAttivita.completato,
                      widget.viewmodelutente.utenteCorrente!.id,
                      widget.idProgetto,
                      nuovaAttivita.priorita);
                  if (isClickedLeMie) {
                    _fetchLeMieAttivitaData();
                  }
                  if (isClickedNonCompletate) {
                    _fetchAttivitaNonCompletate();
                  }
                  if (isClickedCompletate) {
                    _fetchAttivitaCompletate();
                  }
                  Navigator.of(context).pop();
                },

                onDismiss: () {
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
        backgroundColor: Colors.red[700],
        child: const Icon(
          Icons.add,
          color: Colors.white, // Colore dell'icona
        ),

      ),
      )
    );
  }
}


class TodoItem extends StatefulWidget {
  final LeMieAttivita item;
  LeMieAttivitaViewModel leMieAttivitaViewModel;
  final ViewModelUtente viewModelUtente;
  final Function(LeMieAttivita) oncomplete;
  final Function(LeMieAttivita) onEdit;
  final Function(LeMieAttivita) ondelete;
  bool isclickecdCompletate;

  TodoItem({super.key,
    required this.item,
    required this.viewModelUtente,
    required this.leMieAttivitaViewModel,
    required this.ondelete,
    required this.oncomplete,
    required this.isclickecdCompletate,
    required this.onEdit,
  });

  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  bool dialogDelete = false;
  bool dialogExpanded = false;
  String listaUtenti = "";
  bool modifica = false;
  bool caricamento = true;
  bool dialogComplete = false;

  @override

  void initState() {
    super.initState();
   _fetchUsers();
  }

  void _fetchUsers() async {
    listaUtenti = "";
    int size = widget.item.utenti.length;
    int contatore = 0;

    for (String idUtente in widget.item.utenti) {
      ProfiloUtente? persona = await widget.viewModelUtente.ottieni_utente(
          idUtente);
      if (persona != null) {
        setState(() {
          contatore++;
          if (contatore == size) {
            listaUtenti += "${persona.nome} ${persona.cognome}";
          } else {
            listaUtenti += "${persona.nome} ${persona.cognome}\n";
          }
        }
        );
      }
    }

    if (widget.item.utenti.contains(widget.viewModelUtente.utenteCorrente?.id) == true) {
      caricamento = false;
      setState(() {
        modifica = true;
      });
    }
    else
      {
        setState(() {
          caricamento = false;
        });
      }



  }



  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        setState(() {
          dialogExpanded = true;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color:  Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.white),
        ),
        child:  caricamento ?
        const Center(
          child:
          CircularProgressIndicator(),
        ) :
        Row(
          children: [
            if (modifica) ...[
              IconButton(
                icon: Icon(
                  widget.item.completato ? Icons.clear : Icons.check,
                  color: widget.item.completato ? Colors.red : Colors.green,
                  size: 15.0,
                ),
                onPressed: () {
                  setState(() {
                    dialogComplete = true;
                  });
                  if (dialogComplete) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.grey[350],
                            title: const Text(
                              'Conferma',
                              style: TextStyle(color: Colors.black),
                            ),
                            content: Text(
                              widget.isclickecdCompletate ? 'Segna come non completata'
                                  : 'Segna come non completata',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Annulla',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  widget.oncomplete(widget.item);
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .red[700], // Sfondo rosso
                                ),
                                child: const Text(
                                  'Conferma',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        });
                  }

                },
              ),
            ] else ...[
              const SizedBox(width: 50),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.titolo,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                  ),
                  Text(
                    widget.item.descrizione ,
                    style: const TextStyle(
                      color:  Colors.black,
                    ),
                    maxLines: 1,
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(widget.item.dataScadenza),
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.item.dataScadenza.isBefore(DateTime.now())
                          ? Colors.red
                          : Colors.black),
                    ),
                  Text(
                    listaUtenti,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),

                   Icon(
                    Icons.circle,
                    color: widget.item.priorita.colore,
                    size: 16.0,
                  ),
                ],
              ),
            ),
            if (modifica) ...[
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    dialogDelete = true;
                  });

                  if (dialogDelete) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.grey[350],
                          title: const Text(
                            'Elimina Todo',
                            style: TextStyle(color: Colors.black),
                          ),
                          content: Text(
                            'Sei sicuro di voler eliminare questo Todo?',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  dialogDelete =
                                  false; // Chiudi il dialogo senza fare nulla
                                });
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Annulla',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                widget.ondelete(widget.item);
                                setState(() {
                                  dialogDelete = false;
                                });
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .red[700], // Colore rosso del pulsante di conferma
                              ),
                              child: const Text(
                                'Conferma',
                                style: TextStyle(color: Colors
                                    .white), // Testo bianco sul pulsante
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }


                }),
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Colors.grey,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return EditTodoDialog(
                        todoItem: widget.item,
                        onSave: (updatedItem) {
                          widget.onEdit(updatedItem);
                        },
                      );
                    },
                  );
                },
              ),

            ],
          ],
        ),
      ),
    );
  }
}

class TodoButtons extends StatefulWidget {
  final String idProg;
  bool isClickedCompletate;
  bool isClickedNonCompletate;
  bool isClickedLeMie;
  final VoidCallback onCompletate;
  final VoidCallback onNonCompletate;
  final VoidCallback onLeMie;

  TodoButtons({super.key,
    required this.idProg,
    required this.isClickedLeMie,
    required this.isClickedCompletate,
    required this.isClickedNonCompletate,
    required this.onCompletate,
    required this.onNonCompletate,
    required this.onLeMie,
  });

  @override
  State<TodoButtons> createState() => _TodoButtonsState();
}

class _TodoButtonsState extends State<TodoButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ElevatedButton(
              onPressed: widget.onCompletate,
              style: ElevatedButton.styleFrom(
                foregroundColor: widget.isClickedCompletate ? Colors.white : Colors.black,
                backgroundColor: widget.isClickedCompletate ? Colors.red[700] : Colors.grey[350],
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Complete',
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ElevatedButton(
              onPressed: widget.onNonCompletate,
              style: ElevatedButton.styleFrom(
                foregroundColor: widget.isClickedNonCompletate ? Colors.white : Colors.black,
                backgroundColor: widget.isClickedNonCompletate ? Colors.red[700] : Colors.grey[350],
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Not Complete',
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ),


        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ElevatedButton(
              onPressed: widget.onLeMie,
              style: ElevatedButton.styleFrom(
                foregroundColor: widget.isClickedLeMie ? Colors.white : Colors.black,
                backgroundColor: widget.isClickedLeMie ? Colors.red[700] : Colors.grey[350],
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'My Task',
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class AddTodoDialog extends StatefulWidget {
  final Function(LeMieAttivita) onSave;

  final VoidCallback onDismiss;

  const AddTodoDialog({
    super.key,
    required this.onSave,
    required this.onDismiss,
  });

  @override
  _AddTodoDialogState createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  late TextEditingController _titoloController;
  late TextEditingController _descrizioneController;
  DateTime _dataScadenza = DateTime.now();
  Priorita _priorita = Priorita.BASSA;
  final _sdf = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _titoloController = TextEditingController();
    _descrizioneController = TextEditingController();
  }

  @override
  void dispose() {
    _titoloController.dispose();
    _descrizioneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[350],
      title: const Text(
        'Aggiungi Todo',
        style: TextStyle(color: Colors.black),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildTextField(
              controller: _titoloController,
              label: 'Titolo',
              maxLength: 50,
            ),
            const SizedBox(height: 10.0),
            _buildTextField(
              controller: _descrizioneController,
              label: 'Descrizione',
              maxLength: 1000,
              maxLines: 10,
            ),
            const SizedBox(height: 16.0),
            _buildDateField(context),
            const SizedBox(height: 16.0),
            _buildPriorityDropdown(),
            const SizedBox(height: 16.0),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: widget.onDismiss,
          child: const Text(
            'Annulla',
            style: TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
          ),
          onPressed: _onSave,
          child: const Text(
            'Aggiungi Todo',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int? maxLength,
    int maxLines = 1,
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
          ),
          style: const TextStyle(color: Colors.black),
        ),

      ],
    );
  }
  Widget _buildDateField(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: _sdf.format(_dataScadenza)),
      decoration: InputDecoration(
        labelText: 'Data di Scadenza',
        labelStyle: const TextStyle(color: Colors.black),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.calendar_today,
            color: Colors.black,
          ),
          onPressed: () => _selectDate(context),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(16.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red[700]!),
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataScadenza,
      firstDate: DateTime(2000),
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

    if (picked != null && picked != _dataScadenza) {
      setState(() {
        _dataScadenza = picked;
      });
    }
  }


  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<Priorita>(

    value: _priorita,
    decoration: InputDecoration(
    labelText: 'Priorità',
    labelStyle: const TextStyle(color:  Colors.black),
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
    _priorita = newValue!;
    });
    },
    );
  }

  void _onSave() {
    final titolo = _titoloController.text;
    final descrizione = _descrizioneController.text;

    final nuovaAttivita = LeMieAttivita(
      titolo: titolo,
      descrizione: descrizione,
      dataScadenza: _dataScadenza,
      priorita: _priorita,
      completato: false,
      progetto: '',
      utenti: [],
    );

    widget.onSave(nuovaAttivita);
  }
}



class EditTodoDialog extends StatefulWidget {
  final LeMieAttivita todoItem;
  final void Function(LeMieAttivita) onSave;
  const EditTodoDialog({
    required this.todoItem,
    required this.onSave,
    super.key,
  });

  @override
  _EditTodoDialogState createState() => _EditTodoDialogState();
}

class _EditTodoDialogState extends State<EditTodoDialog> {
  late TextEditingController titoloController;
  late TextEditingController descrizioneController;
  late TextEditingController dataScadenzaController;
  late DateTime dataScadenza;
  late Priorita priorita;

  @override
  void initState() {
    super.initState();
    titoloController = TextEditingController(text: widget.todoItem.titolo);
    descrizioneController = TextEditingController(text: widget.todoItem.descrizione);
    dataScadenzaController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(widget.todoItem.dataScadenza));
    dataScadenza = widget.todoItem.dataScadenza;
    priorita = widget.todoItem.priorita;
  }




  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[350],
      title: const Text(
        'Modifica Attività',
        style: TextStyle(color: Colors.black),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildTextField(
              controller: titoloController,
              label: 'Titolo',
              maxLength: 50,
            ),
            const SizedBox(height: 10.0),
            _buildTextField(
              controller: descrizioneController,
              label: 'Descrizione',
              maxLength: 1000,
              maxLines: 5,
            ),
            const SizedBox(height: 16.0),
            _buildDateField(context),
            const SizedBox(height: 16.0),
            _buildPriorityDropdown(),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Annulla',
            style: TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
          ),
          onPressed: _onSave,
          child: const Text(
            'Salva',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int? maxLength,
    int maxLines = 1,
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
          ),
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: DateFormat('dd/MM/yyyy').format(dataScadenza)),
      decoration: InputDecoration(
        labelText: 'Data Scadenza',
        labelStyle: const TextStyle(color: Colors.black),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.calendar_today,
            color: Colors.black,
          ),
          onPressed: () => _selectDate(context),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(16.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red[700]!),
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dataScadenza,
      firstDate: DateTime(2000),
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

    if (picked != null && picked != dataScadenza) {
      setState(() {
        dataScadenza = picked;
      });
    }
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<String>(
      value: priorita.toShortString(),
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
        return DropdownMenuItem<String>(
          value: p.toShortString(),
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
                p.toShortString(),
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          priorita = PrioritaExtension.fromString(newValue!);
        });
      },
    );
  }


  void _onSave() {
    final titolo = titoloController.text;
    final descrizione = descrizioneController.text;



    final updatedTodo = LeMieAttivita(
      id: widget.todoItem.id,
      titolo: titolo,
      descrizione: descrizione,
      dataScadenza: dataScadenza,
      priorita: priorita,
      completato: widget.todoItem.completato,
      progetto: widget.todoItem.progetto,
      utenti: widget.todoItem.utenti,
    );

    widget.onSave(updatedTodo);
    Navigator.of(context).pop();
  }

}




