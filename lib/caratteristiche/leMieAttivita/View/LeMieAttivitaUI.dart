import 'package:intl/intl.dart' show DateFormat;
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/ViewModel/ViewModelProgetto.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/Model/LeMieAttivita.dart';
import 'package:flutter/material.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/Model/Progetto.dart';
import 'package:teamsync_flutter/caratteristiche/login/viewModel/ViewModelUtente.dart';
import '../../login/Model/UserClass.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/View/InfoProgettoUI.dart';




class lemieAttivita extends StatefulWidget {
  final String idProgetto;
  ProgettoViewModel viemodelprogetto;
  ViewModelUtente viewmodelutente;
  lemieAttivita({super.key, required this.idProgetto, required this.viemodelprogetto, required this.viewmodelutente});
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
      progetto = await widget.viemodelprogetto.getProgettoById(widget.idProgetto);
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
      await widget.viemodelprogetto.caricaAttivitaNonCompletate(widget.idProgetto);
    }  finally {
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
                    children: widget.viemodelprogetto.attivitaCompletate.map((attivita) {
                      return TodoItem(item: attivita, viewModelUtente: widget.viewmodelutente);
                    }).toList(),
                  ),
                ),
            if(!isLoadingAttivita && isClickedNonCompletate)
              Expanded(
                child: ListView(
                  children: widget.viemodelprogetto.attivitaNonCompletate.map((attivita) {
                    return TodoItem(item: attivita, viewModelUtente: widget.viewmodelutente);
                  }).toList(),
                ),
              ),
            if(!isLoadingAttivita && isClickedLeMie)
              Expanded(
                child: ListView.builder(
                  itemCount: widget.viemodelprogetto.leMieAttivitaNonCompletate.length,
                  itemBuilder: (context, index) {
                    final attivita = widget.viemodelprogetto.leMieAttivitaNonCompletate[index];
                    return TodoItem(item: attivita, viewModelUtente: widget.viewmodelutente);
                  },
                ),
              )



          ],
        ),
      ),
    );
  }
}




class TodoItem extends StatefulWidget {
  final LeMieAttivita item;
  /*final Function(String) onDelete;
  final Function(LeMieAttivita) onEdit;
  final Function(LeMieAttivita) onComplete;*/
  final ViewModelUtente viewModelUtente;
  const TodoItem({super.key,
    required this.item,
    /*required this.onDelete,
    required this.onEdit,
    required this.onComplete,*/
    required this.viewModelUtente,

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
                  //widget.onComplete(widget.item);
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

                  const Icon(
                    Icons.circle,
                    color: Colors.blue,
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
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Colors.grey,
                ),
                onPressed: () {
                 // widget.onEdit(widget.item);
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
              child: const Text(
                'Completate',
                style: TextStyle(fontSize: 12),
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
              child: const Text(
                'Non Completate',
                style: TextStyle(fontSize: 12),
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
              child: const Text(
                'Le Mie',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

