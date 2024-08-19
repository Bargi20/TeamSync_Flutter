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
      throw Exception("Errore durante l'aggiunta del Todo: ${e.toString()}");
    }
  }

  /*
  Future<void> addUserToTodo(String id, String newUser) async {
    try {
      // Ottieni il riferimento al documento Todo
      DocumentReference documentRef = FirebaseFirestore.instance.collection('Todo').doc(id);

      // Ottieni il documento
      DocumentSnapshot document = await documentRef.get();

      if (document.exists) {
        // Converti il documento in un oggetto
        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

        // Assicurati che i dati esistano e contengano la chiave 'utenti'
        if (data != null && data.containsKey('utenti')) {
          // Ottieni la lista degli utenti e aggiornala
          List<dynamic> utenti = List.from(data['utenti']);
          utenti.add(newUser);

          // Aggiorna il documento con la lista aggiornata
          await documentRef.update({'utenti': utenti});
        } else {
          throw Exception("Campo 'utenti' non trovato nel documento");
        }
      } else {
        throw Exception("Todo non trovato");
      }
    } catch (e) {
      // Gestisci l'errore se necessario
      throw Exception("Errore durante l'aggiornamento degli utenti del Todo: ${e.toString()}");
    }
  }

   */


  Future<List<LeMieAttivita>> getAttivitaByProgettoId(String progettoId) async {
    try {
      final snapshot = await _database.collection('Todo')
          .where('progetto', isEqualTo: progettoId) // Corretto da progettoId a progetto
          .get();
      return snapshot.docs.map((doc) => LeMieAttivita.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _database.collection('Todo').doc(id).delete();
    } catch (e) {
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
      throw Exception("Errore durante l'aggiornamento del Todo: ${e.toString()}");
    }
  }

  Future<void> completeTodo(String id, bool completato) async {
    try {
      await _database.collection('Todo').doc(id).update({
        'completato': completato,
      });
    } catch (e) {
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
      throw Exception("Errore durante l'aggiunta dell'utente al Todo: ${e.toString()}");
    }
  }


  Future<bool> utenteAssegnato(String userId, String taskId) async {
    try {
      DocumentReference taskRef = _database.collection('Todo').doc(taskId);
      DocumentSnapshot taskDoc = await taskRef.get();

      if (taskDoc.exists) {
        Map<String, dynamic>? data = taskDoc.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('utenti')) {
          List<dynamic> utenti = List.from(data['utenti']);
          return utenti.contains(userId);
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print('Errore durante la verifica dell\'assegnazione dell\'utente: ${e.toString()}');
      return false;  // Restituisci false in caso di errore
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
      throw Exception("Errore durante la rimozione dell'utente dal Todo: ${e.toString()}");
    }
  }

  Future<LeMieAttivita?> getTodoById(String id) async {
    try {
      final doc = await _database.collection('Todo').doc(id).get();
      return LeMieAttivita.fromFirestore(doc);
    } catch (e) {
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
      return 0;
    }
  }
}
