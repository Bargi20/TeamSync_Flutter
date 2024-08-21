import 'package:intl/intl.dart' show DateFormat;
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/ViewModel/view_model_progetto.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/Model/LeMieAttivita.dart';
import 'package:flutter/material.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/Model/progetto.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/ViewModel/LeMieAttivitaViewModel.dart';
import 'package:teamsync_flutter/caratteristiche/login/viewModel/view_model_utente.dart';
import 'package:teamsync_flutter/data.models/Priorita.dart';
import '../../login/Model/user_class.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/View/InfoProgettoUI.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/View/ModificaProgetto.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/View/DelegaTask.dart';

import '../../../navigation/schermate.dart';
import 'package:share_plus/share_plus.dart';




class LemieAttivita extends StatefulWidget {
  final String idProgetto;
  ProgettoViewModel viemodelprogetto;
  LeMieAttivitaViewModel viewmodelAttivita;
  ViewModelUtente viewmodelutente;


  LemieAttivita({super.key, required this.idProgetto, required this.viemodelprogetto, required this.viewmodelutente, required this.viewmodelAttivita});

  @override
  _LemieAttivitaState createState() => _LemieAttivitaState();
}

class _LemieAttivitaState extends State<LemieAttivita> {
  Progetto? progetto;
  bool isLoadingProgetto = true;
  bool isLoadingAttivita = true;
  bool isClickedCompletate = false;
  bool isClickedNonCompletate = false;
  bool isClickedLeMie = true;
  DateTime dataScadenzaMassimaLeMieTaskNonCompletate = DateTime(1900, 1, 1);
  DateTime dataScadenzaMassimaTaskNonCompletateAll = DateTime(1900, 1, 1);
  DateTime dataScadenzaMassimaTask = DateTime(1900, 1, 1);
  late DateTime dataScadenzaProgetto;
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
    _fetchAttivitaNonCompletate();
  }

  Future<void> _fetchProgettoData() async {
    setState(() {
      isLoadingProgetto = true;
    });
    try {
      progetto = await widget.viemodelprogetto.getProgettoById(widget.idProgetto);
      dataScadenzaProgetto = await recuperaDataScadenza(widget.idProgetto);
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
      await widget.viemodelprogetto.caricaTutteLeAttivitaCompletate(
          widget.idProgetto);

    } finally {
      setState(() {
        isLoadingAttivita = false;
      });
    }

  }

  Future <void> calcolaDataScadenzaMinimaProgetto(List<LeMieAttivita> listaAttivita, bool provenienzaLeMieTask) async {
    setState(() {
      isLoadingAttivita = true;
    });
    try
    {
      if(provenienzaLeMieTask)
        {
          dataScadenzaMassimaLeMieTaskNonCompletate =  DateTime(1900, 1, 1);
          for(LeMieAttivita a in listaAttivita)
          {
            if (dataScadenzaMassimaLeMieTaskNonCompletate.isBefore(a.dataScadenza))
            {
              dataScadenzaMassimaLeMieTaskNonCompletate = a.dataScadenza;
            }

          }
        } else
        {
          dataScadenzaMassimaTaskNonCompletateAll =  DateTime(1900, 1, 1);
          for(LeMieAttivita a in listaAttivita)
          {
            if (dataScadenzaMassimaTaskNonCompletateAll.isBefore(a.dataScadenza))
            {
              dataScadenzaMassimaTaskNonCompletateAll = a.dataScadenza;
            }

          }
        }

      if(dataScadenzaMassimaTaskNonCompletateAll.isBefore(dataScadenzaMassimaLeMieTaskNonCompletate)) {
        dataScadenzaMassimaTask = dataScadenzaMassimaLeMieTaskNonCompletate;
      }
      else {
        dataScadenzaMassimaTask = dataScadenzaMassimaTaskNonCompletateAll;
      }


    }
    finally {
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
      await widget.viemodelprogetto.caricaTutteLeAttivitaNonCompletate(
          widget.idProgetto);
      await calcolaDataScadenzaMinimaProgetto(widget.viemodelprogetto.attivitaNonCompletateAll, false);
    }
    finally {
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
      await widget.viemodelprogetto.caricaLeMieAttivitaNonCompletate(
          widget.idProgetto,
          widget.viewmodelutente.utenteCorrente!.id
      );
      await calcolaDataScadenzaMinimaProgetto(widget.viemodelprogetto.attivitaNonCompletate, true);
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
    final result = await widget.viewmodelAttivita.updateTodo(
        attivita.id!,
        attivita.titolo,
        attivita.descrizione,
        attivita.dataScadenza,
        attivita.dataCreazione,
        attivita.progetto,
        attivita.utenti,
        attivita.completato,
        attivita.priorita,
        context);
    if (result == null) {
      if (isClickedCompletate) {
        await _fetchAttivitaCompletate();
      }

      if (isClickedLeMie) {
        await _fetchLeMieAttivitaData();
      }
      if (isClickedNonCompletate) {
        await _fetchAttivitaNonCompletate();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Task Aggiornata con successo"),
            duration: const Duration(seconds: 1),
            action: SnackBarAction(
              label: 'Chiudi',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Chiudi',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      });
    }
  }

  Future<DateTime> recuperaDataScadenza(String idProg) async
{
  var progetto = await widget.viemodelprogetto.getProgettoById(idProg);
  return progetto!.dataScadenza;
}
  final _sdf = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(Schermate.ituoiProgetti);

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
                ProgettoViewModel viewModel = ProgettoViewModel();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InfoProgetto(
                      projectId: widget.idProgetto,
                      viewModel: viewModel,
                    ),
                  ),
                );
              }
              
              if (result == 2){
                ProgettoViewModel viewModel = ProgettoViewModel();
                
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ModificaProgetto(
                      projectId:widget.idProgetto,
                      viewModel: viewModel,
                    dataMinimaScadenzaTask:  dataScadenzaMassimaTask,
                    ),
                  ),
                );
              }

              if (result == 3) {
                TextEditingController controller = TextEditingController(text: progetto!.codice);

                showDialog(context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Inserisci il valore'),
                      content: TextField(
                        readOnly: true,
                        controller: controller,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Codice Progetto',
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Annulla'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        ElevatedButton(
                          child: const Text('Condividi'),
                          onPressed: () {
                            Share.share(progetto!.codice);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }

              if (result == 4) {
                final navigator = Navigator.of(context);

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Abbandona Progetto'),
                      content: const Text('Sei sicuro di voler abbandonare il progetto?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Annulla',
                          style: TextStyle(color : Colors.black),),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                          ),
                          onPressed: ()async {
                              Navigator.of(context).pop();

                              ProgettoViewModel viewModel = ProgettoViewModel();

                              if (progetto != null && progetto!.id != null) {
                              await viewModel.abbandonaProgetto(progetto!.id!);
                              } else {
                              }

                              navigator.pushReplacementNamed(Schermate.ituoiProgetti);
                              },
                          child: const Text(
                            'Abbandona Progetto',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }


            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Info'),
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Modifica')
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: 3,
                child: Row(
                  children: [
                    Icon(Icons.share, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Condividi')
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: 4,
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Abbandona')
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: isLoadingProgetto ? null :
          progetto!.completato ?



          Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                    const Text(
                    'Progetto Completato',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  const SizedBox(height: 20.0),
                  Image.asset(
                    'assets/im_progettocompletato.png',
                    width: 180.0,
                    height: 180.0,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Data Consegna',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                           Text(
                             _sdf.format(progetto!.dataConsegna) ,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18.0,

                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Voto',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                           (progetto!.voto) ,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18.0,

                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
              )
          )
          )

              :
          Padding(
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
                      dataScadenzaProgetto: dataScadenzaProgetto,
                    );
                  }).toList(),
                ),
              ),
            if(!isLoadingAttivita && isClickedNonCompletate)
              Expanded(
                child: ListView(
                  children: widget.viemodelprogetto.attivitaNonCompletateAll.map((
                      attivita) {
                    return TodoItem(item: attivita,
                        viewModelUtente: widget.viewmodelutente,
                        leMieAttivitaViewModel: widget.viewmodelAttivita,
                        ondelete: _handleDelete,
                      oncomplete: _handleComplete,
                      onEdit: _handleModificaTask,
                      isclickecdCompletate: isClickedCompletate,
                      dataScadenzaProgetto: dataScadenzaProgetto,
                    );
                  }).toList(),
                ),
              ),
            if(!isLoadingAttivita && isClickedLeMie)
              Expanded(
                child: ListView.builder(
                  itemCount: widget.viemodelprogetto.attivitaNonCompletate
                      .length,
                  itemBuilder: (context, index) {
                    final attivita = widget.viemodelprogetto
                        .attivitaNonCompletate[index];
                    return TodoItem(item: attivita,
                        viewModelUtente: widget.viewmodelutente,
                        leMieAttivitaViewModel: widget.viewmodelAttivita,
                        ondelete: _handleDelete,
                      oncomplete: _handleComplete,
                      onEdit: _handleModificaTask,
                      isclickecdCompletate: isClickedCompletate,
                      dataScadenzaProgetto: dataScadenzaProgetto,
                        );
                  },
                ),
              ),
          ],
        ),


      ),


      floatingActionButton: Visibility(
          visible: !isClickedCompletate,
          child: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddTodoDialog(
                onSave: (LeMieAttivita nuovaAttivita) async {
                  final result = await widget.viewmodelAttivita.addTodo(
                    nuovaAttivita.titolo,
                    nuovaAttivita.descrizione,
                    nuovaAttivita.dataScadenza,
                    nuovaAttivita.completato,
                    widget.viewmodelutente.utenteCorrente!.id,
                    widget.idProgetto,
                    nuovaAttivita.priorita,
                    context,
                  );
                  if (result == null) {
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
                  }
                },
                  onDismiss: () { Navigator.of(context).pop();
                  },
                  dataScadenzaProgetto: dataScadenzaProgetto,

              );
            },
          );
        },
        backgroundColor: Colors.red[700],
        child: const Icon(
          Icons.add,
          color: Colors.white,
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
  final DateTime dataScadenzaProgetto;
  bool isclickecdCompletate;

  TodoItem({super.key,
    required this.item,
    required this.viewModelUtente,
    required this.leMieAttivitaViewModel,
    required this.ondelete,
    required this.oncomplete,
    required this.isclickecdCompletate,
    required this.onEdit,
    required this.dataScadenzaProgetto,
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
      ProfiloUtente? persona = await widget.viewModelUtente.ottieniUtente(
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
                                  : 'Segna come completata',
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
                                      .red[700],
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
                            'Sei sicuro di voler eliminare questa task?',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  dialogDelete =
                                  false;
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
                                    .red[700],
                              ),
                              child: const Text(
                                'Conferma',
                                style: TextStyle(color: Colors
                                    .white
                                ),
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
                        dataScadenzaProgetto: widget.dataScadenzaProgetto,
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
  final DateTime dataScadenzaProgetto;
  final VoidCallback onDismiss;

  const AddTodoDialog({
    super.key,
    required this.onSave,
    required this.onDismiss,
    required this.dataScadenzaProgetto,
  });

  @override
  _AddTodoDialogState createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  late TextEditingController _titoloController;
  late TextEditingController _descrizioneController;
  final DateTime _dataOdierna = DateTime.now();
  DateTime _dataSelezionata = DateTime.now();
  Priorita _priorita = Priorita.BASSA;
  final _sdf = DateFormat('dd/MM/yyyy');
  late final bool dataSelezionabile = DateTime.now().isBefore(widget.dataScadenzaProgetto) ? true : false;
  @override
  void initState() {
    super.initState();
    _titoloController = TextEditingController();
    _descrizioneController = TextEditingController();
    _titoloController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
    });
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
        onPressed: _titoloController.text.isNotEmpty ? _onSave : null,
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
      controller: TextEditingController(text: _sdf.format( _dataSelezionata )),
      decoration: InputDecoration(
        labelText: 'Data di Scadenza',
        labelStyle: const TextStyle(color: Colors.black),
        suffixIcon: dataSelezionabile? IconButton(
          icon: const Icon(
            Icons.calendar_today,
            color: Colors.black,
          ),
          onPressed: () => _selectDate(context),
        ): null,
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
      initialDate: _dataSelezionata,
      firstDate: _dataOdierna,
      lastDate: widget.dataScadenzaProgetto,
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

    if (picked != null && picked != _dataOdierna) {
      setState(() {
        _dataSelezionata = picked;
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
      dataScadenza: _dataSelezionata,
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
  final DateTime dataScadenzaProgetto;
  final void Function(LeMieAttivita) onSave;
  const EditTodoDialog({
    required this.todoItem,
    required this.onSave,
    required this.dataScadenzaProgetto,
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
  late final bool dataSelezionabile = DateTime.now().isBefore(widget.dataScadenzaProgetto) ? true : false;
  @override
  void initState() {
    super.initState();
    titoloController = TextEditingController(text: widget.todoItem.titolo);
    descrizioneController = TextEditingController(text: widget.todoItem.descrizione);
    dataScadenzaController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(widget.todoItem.dataScadenza));
    dataScadenza = widget.todoItem.dataScadenza;
    priorita = widget.todoItem.priorita;
    titoloController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
    });
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
              ),
              onPressed: () {
                ProgettoViewModel viewModel = ProgettoViewModel();
                LeMieAttivitaViewModel viewModelTodo = LeMieAttivitaViewModel();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Delegatask(
                      taskId: widget.todoItem.id!,
                      titolo: widget.todoItem.titolo,
                      descrizione: widget.todoItem.descrizione,
                      priorita: widget.todoItem.priorita.name,
                      data : widget.todoItem.dataScadenza,
                      progettoId : widget.todoItem.progetto,
                      viewModel: viewModel,
                      viewModelTodo: viewModelTodo,
                    ),
                  ),
                );
              },
              child: const Text(
                'Delega Task',
                style: TextStyle(color: Colors.black),
              ),
            ),
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
          onPressed: titoloController.text.isNotEmpty ? _onSave : null,
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
        suffixIcon: dataSelezionabile ? IconButton(
          icon: const Icon(
            Icons.calendar_today,
            color: Colors.black,
          ),
          onPressed: () => _selectDate(context),
        ): null,
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
      firstDate: DateTime.now(),
      lastDate: widget.dataScadenzaProgetto,
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