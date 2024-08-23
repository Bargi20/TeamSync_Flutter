import 'dart:async';
import 'package:flutter/material.dart';
import 'package:teamsync_flutter/caratteristiche/LeMieAttivita/Repository/ToDoRepository.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/Model/LeMieAttivita.dart';
import 'package:teamsync_flutter/data.models/Priorita.dart';


class LeMieAttivitaViewModel extends ChangeNotifier {
  final repository = TodoRepository();
  final List<LeMieAttivita> _leMieAttivita = [];
  String? _errorMessage;


  List<LeMieAttivita> get leMieAttivita => _leMieAttivita;
  String? get errorMessage => _errorMessage;

  final StreamController<String> _erroreAggiungiTaskController =
  StreamController<String>.broadcast();

  Stream<String> get erroreAggiungiTaskStream =>
      _erroreAggiungiTaskController.stream;



  /// Aggiunge un messaggio di errore al controller di errore per l'aggiunta di un task.
  ///
  /// Questo metodo invia un messaggio di errore al flusso di errore per l'aggiunta di un task. Il messaggio
  /// viene inviato tramite il controller `_erroreAggiungiTaskController`. Utilizza questo metodo per segnalare
  /// errori specifici all'utente durante l'aggiunta di un task.
  ///
  void setErroreAggiungiTask(String message) {
    _erroreAggiungiTaskController.add(message);
  }


  /// Resetta il messaggio di errore per l'aggiunta di un task.
  ///
  /// Questo metodo invia una stringa vuota al controller `_erroreAggiungiTaskController`, resettando
  /// il messaggio di errore corrente. Utilizza questo metodo per rimuovere eventuali messaggi di errore
  /// precedenti una volta che l'errore è stato gestito o risolto.
  ///
  void resetErroreAggiungiTask() {
    _erroreAggiungiTaskController.add('');
  }

  setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }


  /// Aggiunge un nuovo task alla lista dei task.
  ///
  /// [titolo] Il titolo del task. Non può essere vuoto.
  /// [descrizione] Una descrizione opzionale del task.
  /// [dataScadenza] La data di scadenza del task. Deve essere una data futura rispetto alla data odierna.
  /// [completato] Indica se il task è stato completato (`true`) o meno (`false`).
  /// [proprietario] Il nome dell'utente a cui è assegnato il task.
  /// [progetto] Il nome del progetto a cui il task è associato.
  /// [priorita] La priorità del task. Deve essere un valore valido del tipo `Priorita`.
  /// [context] Il contesto dell'interfaccia utente, utilizzato per eventuali operazioni di visualizzazione.

  Future<String?> addTodo(
      String titolo,
      String descrizione,
      DateTime dataScadenza,
      bool completato,
      String proprietario,
      String progetto,
      Priorita priorita,
      BuildContext context,
      ) async {
    if (titolo.isEmpty) {
      return "Il titolo non può essere omesso.";
    }
    if (isDateBeforeToday(dataScadenza)) {
      return "La data di scadenza non può essere precedente alla data di creazione della task.";
    }

    try {
      await repository.addTodo(
        titolo: titolo,
        descrizione: descrizione,
        dataScadenza: dataScadenza,
        priorita: priorita,
        completato: completato,
        utenti: proprietario,
        progetto: progetto,
      );
      return null;
    } catch (e) {
      return "Errore durante l'aggiunta della task.";
    }
  }

  /// Verifica se un utente è assegnato a un task.
  ///
  /// [idUtente] ID dell'utente da verificare.
  /// [idTask] ID del task al quale l'utente potrebbe essere assegnato.
  ///
  /// Ritorna `true` se l'utente è assegnato al task, altrimenti `false`.
  ///
  /// Solleva un'eccezione se si verifica un errore durante la verifica dell'assegnazione.

  Future<bool> utenteAssegnato(String idUtente, String idTask) async {
    try {
      bool isAssigned = await repository.utenteAssegnato(idUtente, idTask);
      return isAssigned;
    } catch (e) {
      throw Exception('Errore durante la verifica dell\'assegnazione dell\'utente: ${e.toString()}');
    }
  }


  /// Aggiunge un utente a un task.
  ///
  /// [idUtente] ID dell'utente da aggiungere al task.
  /// [idTask] ID del task al quale l'utente deve essere aggiunto.
  ///
  /// Questo metodo tenta di aggiungere l'utente specificato al task indicato.
  /// Non ritorna nulla. Se si verifica un errore durante l'operazione, viene sollevata un'eccezione
  /// con un messaggio descrittivo.
  Future<void> addUserTodo(String idUtente, String idTask) async {
    try {
      await repository.addUserToTodo(idTask, idUtente);
    } catch (e) {

      throw Exception('Errore durante l\'aggiunta dell\'utente al task: ${e.toString()}');
    }
  }



  /// Rimuove un utente da un task.
  ///
  /// [idUtente] ID dell'utente da rimuovere dal task.
  /// [idTask] ID del task dal quale l'utente deve essere rimosso.
  ///
  /// Questo metodo tenta di rimuovere l'utente specificato dal task indicato.
  /// Non ritorna nulla. Se si verifica un errore durante l'operazione, viene sollevata un'eccezione
  /// con un messaggio descrittivo.
  Future<void> removeUserTodo(String idUtente, String idTask) async {
    try {
      await repository.removeUserFromTodo(idTask, idUtente);
    } catch (e) {

      throw Exception('Errore durante l\'aggiunta dell\'utente al task: ${e.toString()}');
    }
  }


  /// Modifica un task esistente.
  ///
  /// [id] ID del task da modificare.
  /// [titolo] Nuovo titolo del task. Non può essere vuoto.
  /// [descrizione] Nuova descrizione del task.
  /// [dataScadenza] Nuova data di scadenza del task. Deve essere una data futura rispetto alla data di creazione.
  /// [dataCreazione] Data di creazione originale del task.
  /// [progetto] Nuovo nome del progetto associato al task.
  /// [utenti] Nuova lista di ID degli utenti assegnati al task.
  /// [completato] Indica se il task è stato completato (`true`) o meno (`false`).
  /// [priorita] Nuova priorità del task. Deve essere un valore valido del tipo `Priorita`.
  /// [context] Il contesto dell'interfaccia utente, utilizzato per eventuali operazioni di visualizzazione.

  Future<String?> updateTodo(
      String id,
      String titolo,
      String descrizione,
      DateTime dataScadenza,
      DateTime dataCreazione,
      String progetto,
      List<String> utenti,
      bool completato,
      Priorita priorita,
      BuildContext context,
      ) async {
    if (titolo.isEmpty) {
      return "Modifica annullata: Il titolo non può essere omesso.";
    }
    if (isDateBeforeToday(dataScadenza)) {
      return "Modifica annullata: la data di scadenza non può essere precedente alla data di creazione della task.";
    }
    try {
      await repository.updateTodo(id: id, titolo: titolo, descrizione: descrizione, dataScadenza: dataScadenza, priorita: priorita, progetto: progetto, utenti: utenti, completato : completato, dataCreazione : dataCreazione);
      return null;
    } catch (e) {
     return "Errore durante la modifica della task.";
    }
  }


  /// Aggiorna la data di scadenza di un task.
  ///
  /// [attivita] L'oggetto `LeMieAttivita` che rappresenta il task da aggiornare.
  /// [dataScadenzaProgetto] La nuova data di scadenza del task. Deve essere una data futura rispetto alla data di creazione.

  Future<String?> updateDataScadenzaTodo(
      LeMieAttivita attivita ,
      DateTime dataScadenzaProgetto,
      ) async {
    try {
      await repository.updateTodo(id: attivita.id!, titolo: attivita.titolo, descrizione: attivita.descrizione, dataScadenza: dataScadenzaProgetto, priorita: attivita.priorita, progetto: attivita.progetto, utenti: attivita.utenti, completato : attivita.completato, dataCreazione : attivita.dataScadenza);
      return null;
    } catch (e) {
      return "Errore durante la modifica della task.";
    }
  }


  /// Elimina un task identificato dal suo ID.
  ///
  /// [id] ID del task da eliminare.
  ///
  /// Questo metodo tenta di eliminare il task con l'ID specificato.
  /// Non ritorna nulla. Se si verifica un errore durante l'eliminazione, viene invocato il metodo
  /// `setError` con un messaggio descrittivo dell'errore.
  ///
  Future<void> deleteTodo(String id) async {
    try {
      await repository.deleteTodo(id);
    } catch (e) {
      setError("Errore durante l'eliminazione della task.");
    }
  }

  /// Aggiorna lo stato di completamento di un task.
  ///
  /// [id] ID del task il cui stato di completamento deve essere aggiornato.
  /// [completato] Indica se il task è stato completato (`true`) o meno (`false`).
  ///
  /// Questo metodo tenta di aggiornare lo stato di completamento del task identificato dall'ID specificato.
  /// Non ritorna nulla. Se si verifica un errore durante l'aggiornamento, viene invocato il metodo
  /// `setError` con un messaggio descrittivo dell'errore.
  Future<void> completeTodo(String id, bool completato) async {
    try {
      await repository.completeTodo(id, completato);
    } catch (e) {
      setError("Errore durante l'aggiornamento dello stato della task.");
    }
  }


  bool isDateBeforeToday(DateTime date) {
    final today = DateTime.now().toUtc().startOfDay();
    return date.isBefore(today);
  }
}

extension DateTimeExtensions on DateTime {
  DateTime startOfDay() {
    return DateTime(year, month, day);
  }
}
