import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/Model/LeMieAttivita.dart';
import 'package:teamsync_flutter/data.models/Priorita.dart';
class TodoRepository {
  final FirebaseFirestore _database = FirebaseFirestore.instance;


  /// Aggiunge un nuovo task (Todo) al database con le informazioni specificate.
  ///
  /// Questo metodo crea un'istanza di `LeMieAttivita` con i dettagli forniti e la salva nel database.
  ///
  /// [titolo]        Il titolo del task.
  /// [descrizione]   La descrizione del task.
  /// [dataScadenza]  La data di scadenza del task.
  /// [priorita]      La priorità del task (bassa, media, alta).
  /// [completato]    Indica se il task è stato completato.
  /// [utenti]        L'ID dell'utente a cui è assegnato il task.
  /// [progetto]      L'ID del progetto a cui il task appartiene.
  /// [Exception]     Se si verifica un errore durante l'aggiunta del task al database.

  Future<void> addTodo({
    required String titolo,
    required String descrizione,
    required DateTime dataScadenza,
    required Priorita priorita,
    required bool completato,
    required String utenti,
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

  /// Recupera la lista delle attività (Todo) associate a un determinato progetto.
  ///
  /// Questo metodo interroga il database per ottenere tutte le attività che appartengono
  /// a un progetto specifico identificato dal suo ID.
  ///
  /// [progettoId]  L'ID del progetto di cui si vogliono ottenere le attività.
  ///
  /// @return Future<List<LeMieAttivita>>  Una lista di oggetti `LeMieAttivita` associati al progetto specificato.
  ///                                      Se si verifica un errore, viene restituita una lista vuota.
  ///
  /// [Exception]   Se si verifica un errore durante il recupero delle attività dal database.

  Future<List<LeMieAttivita>> getAttivitaByProgettoId(String progettoId) async {
    try {
      final snapshot = await _database.collection('Todo')
          .where('progetto', isEqualTo: progettoId)
          .get();
      return snapshot.docs.map((doc) => LeMieAttivita.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }


  /// Elimina un task (Todo) dal database utilizzando il suo ID.
  ///
  /// Questo metodo rimuove un documento dalla collezione 'Todo' del database
  /// identificato dal suo ID specificato.
  ///
  /// [id]          L'ID del task (Todo) da eliminare.
  ///
  /// @return Future<void>  Un futuro che si completa quando l'operazione di eliminazione è conclusa.
  ///
  /// [Exception]   Se si verifica un errore durante l'eliminazione del task dal database, viene lanciata un'eccezione con un messaggio di errore.

  Future<void> deleteTodo(String id) async {
    try {
      await _database.collection('Todo').doc(id).delete();
    } catch (e) {
      throw Exception("Errore durante l'eliminazione del Todo: ${e.toString()}");
    }
  }


  /// Aggiorna un task (Todo) esistente nel database con le nuove informazioni fornite.
  ///
  /// Questo metodo crea un'istanza aggiornata di `LeMieAttivita` con i dettagli specificati
  /// e la salva nel database sostituendo il documento esistente con lo stesso ID.
  ///
  /// [id]              L'ID del task (Todo) da aggiornare.
  /// [titolo]          Il titolo aggiornato del task.
  /// [descrizione]     La descrizione aggiornata del task.
  /// [dataScadenza]    La data di scadenza aggiornata del task.
  /// [dataCreazione]   La data di creazione originale del task.
  /// [priorita]        La priorità aggiornata del task (bassa, media, alta).
  /// [progetto]        L'ID del progetto a cui il task appartiene.
  /// [utenti]          La lista aggiornata degli ID degli utenti assegnati al task.
  /// [completato]      Indica se il task è stato completato.
  ///
  /// @return Future<void>  Un futuro che si completa quando l'operazione di aggiornamento è conclusa.
  ///
  /// [Exception]       Se si verifica un errore durante l'aggiornamento del task nel database,
  ///                   viene lanciata un'eccezione con un messaggio di errore.

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


  /// Aggiorna lo stato di completamento di un task (Todo) esistente nel database.
  ///
  /// Questo metodo aggiorna il campo `completato` di un documento `Todo` con l'ID specificato
  /// per riflettere se il task è stato completato o meno.
  ///
  /// [id]            L'ID del task (Todo) da aggiornare.
  /// [completato]    Un valore booleano che indica se il task è completato (`true`) o meno (`false`).
  ///
  /// @return Future<void>  Un futuro che si completa quando l'operazione di aggiornamento è conclusa.
  ///
  /// [Exception]     Se si verifica un errore durante l'aggiornamento del task nel database,
  ///                   viene lanciata un'eccezione con un messaggio di errore.
  Future<void> completeTodo(String id, bool completato) async {
    try {
      await _database.collection('Todo').doc(id).update({
        'completato': completato,
      });
    } catch (e) {
      throw Exception("Errore durante il completamento del Todo: ${e.toString()}");
    }
  }


  /// Aggiunge un nuovo utente a un task (Todo) esistente nel database.
  ///
  /// Questo metodo recupera il documento `Todo` con l'ID specificato, aggiunge un nuovo utente
  /// alla lista degli utenti assegnati e aggiorna il documento con la nuova lista.
  ///
  /// [id]        L'ID del task (Todo) a cui aggiungere l'utente.
  /// [newUser]   L'ID del nuovo utente da aggiungere alla lista degli utenti assegnati.
  ///
  /// @return Future<void>  Un futuro che si completa quando l'operazione di aggiornamento è conclusa.
  ///
  /// [Exception]     Se si verifica un errore durante il recupero del documento o l'aggiornamento
  ///                   della lista degli utenti, viene lanciata un'eccezione con un messaggio di errore.
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



  /// Verifica se un utente è assegnato a un task (Todo) nel database.
  ///
  /// Questo metodo recupera il documento del task specificato e controlla se l'ID dell'utente
  /// è presente nella lista degli utenti assegnati al task.
  ///
  /// [userId]   L'ID dell'utente di cui verificare l'assegnazione.
  /// [taskId]   L'ID del task (Todo) da verificare.
  ///
  /// @return Future<bool>  Un futuro che completa con `true` se l'utente è assegnato al task,
  ///                        `false` altrimenti.
  ///
  /// [Exception]     Se si verifica un errore durante il recupero del documento o la verifica
  ///                   della lista degli utenti, viene restituito `false`. Viene anche stampato
  ///                   un messaggio di errore per il debug.
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
      return false;
    }
  }

  /// Rimuove un utente assegnato a un task (Todo) nel database.
  ///
  /// Questo metodo recupera il documento del task specificato, rimuove l'utente dalla lista
  /// degli utenti assegnati e aggiorna il documento nel database. Se, dopo la rimozione,
  /// la lista degli utenti è vuota, il task viene eliminato dal database.
  ///
  /// [id]            L'ID del task (Todo) da cui rimuovere l'utente.
  /// [userToRemove]  L'ID dell'utente da rimuovere dalla lista degli utenti assegnati.
  ///
  /// @return Future<void>  Un futuro che completa senza valore. Se si verifica un errore,
  ///
  /// [Exception]     Se si verifica un errore durante la rimozione dell'utente dal task
  ///                   o durante l'eliminazione del task, viene sollevata un'eccezione con
  ///                   un messaggio di errore descrittivo.
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


  /// Recupera un task (Todo) dal database utilizzando il suo ID.
  ///
  /// Questo metodo recupera il documento del task specificato dal database e lo converte
  /// in un'istanza di `LeMieAttivita`. Se si verifica un errore durante il recupero, viene
  /// sollevata un'eccezione.
  ///
  /// [id]        L'ID del task (Todo) da recuperare.
  ///
  /// @return Future<LeMieAttivita?>  Un futuro che completa con un'istanza di `LeMieAttivita`
  ///                                  se il task esiste, oppure `null` se il task non esiste.
  ///                                  Se si verifica un errore durante il recupero, viene sollevata
  ///                                  un'eccezione con un messaggio di errore descrittivo.
  ///
  /// [Exception] Se si verifica un errore durante il recupero del task dal database, viene
  ///              sollevata un'eccezione con un messaggio di errore descrittivo.
  Future<LeMieAttivita?> getTodoById(String id) async {
    try {
      final doc = await _database.collection('Todo').doc(id).get();
      return LeMieAttivita.fromFirestore(doc);
    } catch (e) {
      throw Exception("Errore durante il recupero del Todo: ${e.toString()}");
    }
  }


  /// Conta il numero di task (Todo) completati per un progetto specificato.
  ///
  /// Questo metodo esegue una query sul database per contare i task che sono stati completati
  /// e appartengono al progetto specificato. Se si verifica un errore durante la query, viene
  /// restituito `0` come valore predefinito.
  ///
  /// [progetto]  L'ID del progetto per cui contare i task completati.
  ///
  /// @return Future<int>  Un futuro che completa con il numero di task completati per il progetto
  ///                       specificato. Se si verifica un errore durante la query, viene restituito `0`.
  ///
  /// [Exception] Se si verifica un errore durante la query, il metodo restituisce `0` come valore predefinito.
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


  /// Conta il numero totale di task (Todo) per un progetto specificato.
  ///
  /// Questo metodo esegue una query sul database per contare tutti i task che appartengono
  /// al progetto specificato. Se si verifica un errore durante la query, viene restituito
  /// `0` come valore predefinito.
  ///
  /// [progetto]  L'ID del progetto per cui contare il numero totale di task.
  ///
  /// @return Future<int>  Un futuro che completa con il numero totale di task per il progetto
  ///                       specificato. Se si verifica un errore durante la query, viene restituito `0`.
  ///
  /// [Exception] Se si verifica un errore durante la query, il metodo restituisce `0` come valore predefinito.

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

  /// Conta il numero di task (Todo) non completati per un progetto specificato.
  ///
  /// Questo metodo esegue una query sul database per contare tutti i task che appartengono
  /// al progetto specificato e che non sono stati completati. Se si verifica un errore durante
  /// la query, viene restituito `0` come valore predefinito.
  ///
  /// [progettoId]  L'ID del progetto per cui contare il numero di task non completati.
  ///
  /// @return Future<int>  Un futuro che completa con il numero di task non completati per il progetto
  ///                       specificato. Se si verifica un errore durante la query, viene restituito `0`.
  ///
  /// [Exception] Se si verifica un errore durante la query, il metodo restituisce `0` come valore predefinito.
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
