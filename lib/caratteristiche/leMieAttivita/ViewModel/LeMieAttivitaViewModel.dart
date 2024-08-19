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

  void setErroreAggiungiTask(String message) {
    _erroreAggiungiTaskController.add(message);
  }

  void resetErroreAggiungiTask() {
    _erroreAggiungiTaskController.add('');
  }

  setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

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
      // Chiamata a repository per aggiungere il Todo
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

  Future<bool> utenteAssegnato(String idUtente, String idTask) async {
    try {
      bool isAssigned = await repository.utenteAssegnato(idUtente, idTask);
      return isAssigned;
    } catch (e) {
      print('Errore durante la verifica dell\'assegnazione dell\'utente: ${e.toString()}');
      throw Exception('Errore durante la verifica dell\'assegnazione dell\'utente: ${e.toString()}');
    }
  }

  Future<void> addUserTodo(String idUtente, String idTask) async {
    try {
      // Chiama il metodo del repository per aggiungere l'utente al task
      await repository.addUserToTodo(idTask, idUtente);
    } catch (e) {
      // Gestisci l'errore, ad esempio stampando un messaggio o mostrando un errore all'utente
      print('Errore durante l\'aggiunta dell\'utente al task: ${e.toString()}');
      // Rethrow l'eccezione per gestirla a un livello superiore se necessario
      throw Exception('Errore durante l\'aggiunta dell\'utente al task: ${e.toString()}');
    }
  }

  Future<void> removeUserTodo(String idUtente, String idTask) async {
    try {
      // Chiama il metodo del repository per aggiungere l'utente al task
      await repository.removeUserFromTodo(idTask, idUtente);
    } catch (e) {
      // Gestisci l'errore, ad esempio stampando un messaggio o mostrando un errore all'utente
      print('Errore durante l\'aggiunta dell\'utente al task: ${e.toString()}');
      // Rethrow l'eccezione per gestirla a un livello superiore se necessario
      throw Exception('Errore durante l\'aggiunta dell\'utente al task: ${e.toString()}');
    }
  }


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

  Future<String?> updateDataScadenzaTodo(
      LeMieAttivita todo ,
      DateTime dataScadenzaProgetto,
      ) async {
    try {
      await repository.updateTodo(id: todo.id!, titolo: todo.titolo, descrizione: todo.descrizione, dataScadenza: dataScadenzaProgetto, priorita: todo.priorita, progetto: todo.progetto, utenti: todo.utenti, completato : todo.completato, dataCreazione : todo.dataScadenza);
      return null;
    } catch (e) {
      return "Errore durante la modifica della task.";
    }
  }



  Future<void> deleteTodo(String id) async {
    try {
      await repository.deleteTodo(id);
    } catch (e) {
      setError("Errore durante l'eliminazione della task.");
    }
  }

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
