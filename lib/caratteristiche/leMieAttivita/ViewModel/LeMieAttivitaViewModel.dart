import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:teamsync_flutter/caratteristiche/LeMieAttivita/Repository/ToDoRepository.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/Model/LeMieAttivita.dart';
import 'package:teamsync_flutter/data.models/Priorita.dart';

class LeMieAttivitaViewModel extends ChangeNotifier {
  final repository = TodoRepository();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final List<LeMieAttivita> _leMieAttivita = [];
  bool _isLoading = false;
  String? _errorMessage;
  Uri? _fileUri;

  List<LeMieAttivita> get leMieAttivita => _leMieAttivita;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Uri? get fileUri => _fileUri;

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

  setFileUri(Uri? uri) {
    _fileUri = uri;
    notifyListeners();
  }

  Future<void> addTodo(
      String titolo,
      String descrizione,
      DateTime dataScadenza,
      bool completato,
      String proprietario,
      String progetto,
      Priorita priorita) async {
    if (titolo.isEmpty) {
      setError("Il titolo non può essere omesso.");
      return;
    }
    if (isDateBeforeToday(dataScadenza)) {
      setError("La data di scadenza non può essere precedente alla data di creazione della task.");
      return;
    }

    try {
      // Chiamata a repository per aggiungere il Todo
      // Esempio:
      await repository.addTodo(titolo: titolo, descrizione: descrizione, dataScadenza: dataScadenza, priorita: priorita , completato: completato, utenti: proprietario, progetto: progetto);

      // Recupera di nuovo i Todo
      await getTodoByProject(progetto);
    } catch (e) {
      setError("Errore durante l'aggiunta della task.");
    }
  }

  Future<void> updateTodo(
      String id,
      String titolo,
      String descrizione,
      DateTime dataScadenza,
      DateTime dataCreazione,
      String progetto,
      List<String> utenti,
      bool completato,
      Priorita priorita
     ) async {
    if (titolo.isEmpty) {
      setError("Il titolo non può essere omesso.");
      return;
    }
    if (isDateBeforeToday(dataScadenza)) {
      setError("La data di scadenza non può essere precedente alla data di creazione della task.");
      return;
    }

    try {
      await repository.updateTodo(id: id, titolo: titolo, descrizione: descrizione, dataScadenza: dataScadenza, priorita: priorita, progetto: progetto, utenti: utenti, completato : completato, dataCreazione : dataCreazione);
    } catch (e) {
      setError("Errore durante l'aggiornamento della task.");
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



  Future<void> getTodoByProject(String progetto) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Chiamata a repository per ottenere tutti i Todo per il progetto
      // Esempio:
      // _leMieAttivita = await repository.getTodosByProject(progetto);

    } catch (e) {
      setError("Errore durante il recupero delle attività.");
    } finally {
      _isLoading = false;
      notifyListeners();
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
