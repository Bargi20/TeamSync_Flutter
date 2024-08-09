import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/Model/LeMieAttivita.dart';

class LeMieAttivitaViewModel extends ChangeNotifier {
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
      String progetto) async {
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
      // await repository.addTodo(titolo, descrizione, dataScadenza, priorita, completato, proprietario, progetto);

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
      String progetto,
      List<String> utenti,
      String? fileUri) async {
    if (titolo.isEmpty) {
      setError("Il titolo non può essere omesso.");
      return;
    }
    if (isDateBeforeToday(dataScadenza)) {
      setError("La data di scadenza non può essere precedente alla data di creazione della task.");
      return;
    }

    try {
      // Chiamata a repository per aggiornare il Todo
      // Esempio:
      // await repository.updateTodo(id, titolo, descrizione, dataScadenza, priorita, progetto, utenti, fileUri);

      // Recupera di nuovo i Todo
      await getTodoByProject(progetto);
    } catch (e) {
      setError("Errore durante l'aggiornamento della task.");
    }
  }

  Future<void> deleteTodo(String id, String progetto) async {
    try {
      // Chiamata a repository per eliminare il Todo
      // Esempio:
      // await repository.deleteTodo(id);

      // Recupera di nuovo i Todo
      await getTodoByProject(progetto);
    } catch (e) {
      setError("Errore durante l'eliminazione della task.");
    }
  }

  Future<void> completeTodo(String id, bool completato, String progetto) async {
    try {
      // Chiamata a repository per aggiornare lo stato completato del Todo
      // Esempio:
      // await repository.completeTodo(id, completato);

      // Recupera di nuovo i Todo
      await getTodoByProject(progetto);
    } catch (e) {
      setError("Errore durante l'aggiornamento dello stato della task.");
    }
  }

  Future<void> uploadFileAndSaveTodo(
      String id,
      String titolo,
      String descrizione,
      DateTime dataScadenza,
      String progetto)
  async {
    if (titolo.isEmpty) {
      setError("Il titolo non può essere omesso.");
      return;
    }
    if (isDateBeforeToday(dataScadenza)) {
      setError("La data di scadenza non può essere precedente alla data di creazione della task.");
      return;
    }

    try {
      if (_fileUri == null) return;

      final file = File.fromUri(_fileUri!);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('files/$fileName');

      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      // Chiamata a repository per aggiornare il Todo con l'URL del file
      await updateTodo(id, titolo, descrizione, dataScadenza, progetto, [], downloadUrl);
    } catch (e) {
      setError("Errore durante l'upload del file.");
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
