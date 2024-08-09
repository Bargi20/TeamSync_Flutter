import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/Model/LeMieAttivita.dart';
import 'package:teamsync_flutter/data.models/Priorita.dart';
class TodoRepository {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  Future<void> addTodo({
    required String titolo,
    required String descrizione,
    required DateTime dataScadenza,
    required Priorita priorita,
    required bool completato,
    required String utenti, // Corretto da String a List<String>
    required String progetto,
  }) async {
    try {
      final leMieAttivita = LeMieAttivita(
        titolo: titolo,
        descrizione: descrizione,
        dataScadenza: dataScadenza,
        priorita: priorita,
        completato: completato,
        progetto: progetto,
        utenti: [utenti],
        fileUri: null,
      );

      await _database.collection('Todo').add(leMieAttivita.toMap());
    } catch (e) {
      print("Errore durante l'aggiunta del Todo: ${e.toString()}");
      throw Exception("Errore durante l'aggiunta del Todo: ${e.toString()}");
    }
  }

  Future<List<LeMieAttivita>> getAllTodo() async {
    try {
      final snapshot = await _database.collection('Todo')
          .where('completato', isEqualTo: false)
          .orderBy('dataScadenza')
          .get();
      return snapshot.docs.map((doc) => LeMieAttivita.fromFirestore(doc)).toList();
    } catch (e) {
      print("Errore durante il recupero di tutti i Todo: ${e.toString()}");
      return [];
    }
  }

  Future<List<LeMieAttivita>> getTodoByUtente(String idProg, String utenteId) async {
    try {
      final snapshot = await _database.collection('Todo')
          .where('progetto', isEqualTo: idProg)
          .where('utenti', arrayContains: utenteId)
          .where('completato', isEqualTo: false)
          .orderBy('dataScadenza')
          .get();
      return snapshot.docs.map((doc) => LeMieAttivita.fromFirestore(doc)).toList();
    } catch (e) {
      print("Errore durante il recupero dei Todo per utente: ${e.toString()}");
      return [];
    }
  }

  Future<List<LeMieAttivita>> getAllTodoCompletate() async {
    try {
      final snapshot = await _database.collection('Todo')
          .where('completato', isEqualTo: true)
          .orderBy('dataScadenza')
          .get();
      return snapshot.docs.map((doc) => LeMieAttivita.fromFirestore(doc)).toList();
    } catch (e) {
      print("Errore durante il recupero dei Todo completati: ${e.toString()}");
      return [];
    }
  }

  Future<List<LeMieAttivita>> getAttivitaByProgettoId(String progettoId) async {
    try {
      final snapshot = await _database.collection('Todo')
          .where('progetto', isEqualTo: progettoId) // Corretto da progettoId a progetto
          .get();
      return snapshot.docs.map((doc) => LeMieAttivita.fromFirestore(doc)).toList();
    } catch (e) {
      print("Errore durante il recupero delle attività per progetto: ${e.toString()}");
      return [];
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _database.collection('Todo').doc(id).delete();
    } catch (e) {
      print("Errore durante l'eliminazione del Todo: ${e.toString()}");
      throw Exception("Errore durante l'eliminazione del Todo: ${e.toString()}");
    }
  }

  Future<void> updateTodo({
    required String id,
    required String titolo,
    required String descrizione,
    required DateTime dataScadenza,
    required DateTime dataCreazione,
    required Priorita priorita,
    required String progetto,
    required List<String> utenti,
    required bool completato,
  }) async {
    try {
      final updatedTodo = LeMieAttivita(
        id: id,
        titolo: titolo,
        descrizione: descrizione,
        dataScadenza: dataScadenza,
        dataCreazione: dataCreazione,
        priorita: priorita,
        progetto: progetto,
        completato: completato,
        utenti: utenti,
        fileUri: null,
      );
      await _database.collection('Todo').doc(id).set(updatedTodo.toMap());
    } catch (e) {
      print("Errore durante l'aggiornamento del Todo: ${e.toString()}");
      throw Exception("Errore durante l'aggiornamento del Todo: ${e.toString()}");
    }
  }

  Future<void> completeTodo(String id, bool completato) async {
    try {
      await _database.collection('Todo').doc(id).update({
        'completato': completato,
      });
    } catch (e) {
      print("Errore durante il completamento del Todo: ${e.toString()}");
      throw Exception("Errore durante il completamento del Todo: ${e.toString()}");
    }
  }

  Future<void> addUserToTodo(String id, String newUser) async {
    try {
      final doc = await _database.collection('Todo').doc(id).get();
      final leMieAttivita = LeMieAttivita.fromFirestore(doc);
      final updatedUsers = List<String>.from(leMieAttivita.utenti)..add(newUser);
      await _database.collection('Todo').doc(id).update({
        'utenti': updatedUsers,
      });
    } catch (e) {
      print("Errore durante l'aggiunta dell'utente al Todo: ${e.toString()}");
      throw Exception("Errore durante l'aggiunta dell'utente al Todo: ${e.toString()}");
    }
  }

  Future<void> removeUserFromTodo(String id, String userToRemove) async {
    try {
      final doc = await _database.collection('Todo').doc(id).get();
      final leMieAttivita = LeMieAttivita.fromFirestore(doc);
      final updatedUsers = List<String>.from(leMieAttivita.utenti);
      if (updatedUsers.remove(userToRemove)) {
        await _database.collection('Todo').doc(id).update({
          'utenti': updatedUsers,
        });
      } else {
        throw Exception("Utente non trovato nella lista");
      }
      if (updatedUsers.isEmpty) {
        await deleteTodo(id);
      }
    } catch (e) {
      print("Errore durante la rimozione dell'utente dal Todo: ${e.toString()}");
      throw Exception("Errore durante la rimozione dell'utente dal Todo: ${e.toString()}");
    }
  }

  Future<LeMieAttivita?> getTodoById(String id) async {
    try {
      final doc = await _database.collection('Todo').doc(id).get();
      return LeMieAttivita.fromFirestore(doc);
    } catch (e) {
      print("Errore durante il recupero del Todo: ${e.toString()}");
      throw Exception("Errore durante il recupero del Todo: ${e.toString()}");
    }
  }

  Future<int> countCompletedTodo(String progetto) async {
    try {
      final snapshot = await _database.collection('Todo')
          .where('progetto', isEqualTo: progetto)
          .where('completato', isEqualTo: true)
          .get();
      return snapshot.size;
    } catch (e) {
      print("Errore durante il conteggio dei Todo completati: ${e.toString()}");
      return 0;
    }
  }

  Future<int> countAllTodo(String progetto) async {
    try {
      final snapshot = await _database.collection('Todo')
          .where('progetto', isEqualTo: progetto)
          .get();
      return snapshot.size;
    } catch (e) {
      print("Errore durante il conteggio di tutti i Todo: ${e.toString()}");
      return 0;
    }
  }

  Future<int> countNonCompletedTodoByProject(String progettoId) async {
    try {
      final snapshot = await _database.collection('Todo')
          .where('progetto', isEqualTo: progettoId)
          .where('completato', isEqualTo: false)
          .get();
      return snapshot.size;
    } catch (e) {
      print("Errore durante il conteggio dei Todo non completati per progetto: ${e.toString()}");
      return 0;
    }
  }
}
