import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/Model/Progetto.dart';
import 'package:uuid/uuid.dart';

class RepositoryProgetto {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  /// Recupera la lista dei progetti a cui partecipa un utente specifico.
  Future<List<Progetto>> getProgettiUtente(String userId) async {
    try {
      // Ottieni i documenti dalla collezione "progetti" in cui il campo "partecipanti" contiene userId
      final querySnapshot = await firestore
          .collection('progetti')
          .where('partecipanti', arrayContains: userId)
          .get();
      print("persone: $querySnapshot");
      // Mappa i documenti a oggetti Progetto usando fromFirestore
      return querySnapshot.docs
          .map((doc) => Progetto.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Errore nel recupero dei progetti: $e");
      return [];
    }
  }


  /// Crea un nuovo progetto nel database Firestore.
  Future<String> creaProgetto(Progetto progetto) async {
    try {
      final docRef = await firestore.collection('progetti').add(progetto.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception("Errore durante la creazione del progetto: $e");
    }
  }

  /// Aggiunge un partecipante a un progetto.
  Future<void> aggiungiPartecipante(String? progettoId, String? userId) async {
    if (progettoId == null || userId == null) return;
    try {
      final progettoRef = firestore.collection('progetti').doc(progettoId);
      await progettoRef.update({
        'partecipanti': FieldValue.arrayUnion([userId])
      });
      print("aggiunto");
    } catch (e) {
      throw Exception("Errore durante l'aggiunta del partecipante: $e");
    }
  }


  /// Permette a un utente di abbandonare un progetto.
  Future<void> abbandonaProgetto(String? userId, String progettoId, Function(bool) callback) async {
    if (userId == null) return;
    try {
      final progettoRef = firestore.collection('progetti').doc(progettoId);
      await progettoRef.update({
        'partecipanti': FieldValue.arrayRemove([userId])
      });

      final listaPartecipanti = await getPartecipantiDelProgetto(progettoId);
      if (listaPartecipanti.isEmpty) {
        await eliminaProgetto(progettoId);
        callback(listaPartecipanti.isEmpty);
      }
    } catch (e) {
      throw Exception("Errore durante l'abbandono del progetto: $e");
    }
  }

  /// Recupera l'utente attualmente autenticato.
  Future<User?> getUtenteCorrente() async {
    try {
      return auth.currentUser;
    } catch (e) {
      throw Exception("Errore durante il recupero dell'utente attualmente autenticato: $e");
    }
  }

  /// Genera un codice univoco per un progetto.
  String generaCodiceProgetto() {
    return Uuid().v4().substring(0, 8);
  }

  /// Recupera l'ID di un progetto in base a un codice specificato.
  Future<String?> getProgettoIdByCodice(String codice) async {
    try {
      final querySnapshot = await firestore
          .collection('progetti')
          .where('codice', isEqualTo: codice)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        print("trovato");
        return querySnapshot.docs[0].id;
      } else {
        return null;
      }
    } catch (e) {
      print("Errore durante il recupero dell'ID del progetto: $e");
      return null;
    }
  }




  /// Elimina un progetto dal database.
  Future<void> eliminaProgetto(String progettoId) async {
    try {
      await firestore.collection('progetti').doc(progettoId).delete();
    } catch (e) {
      throw Exception("Errore durante l'eliminazione del progetto: $e");
    }
  }

  /// Elimina tutte le notifiche associate a un progetto.
  Future<void> eliminaNotificheDelProgetto(String progettoId) async {
    try {
      final querySnapshot = await firestore
          .collection('Notifiche')
          .where('progetto_id', isEqualTo: progettoId)
          .get();
      for (final document in querySnapshot.docs) {
        await firestore.collection('Notifiche').doc(document.id).delete();
      }
    } catch (e) {
      throw Exception("Errore durante l'eliminazione delle notifiche: $e");
    }
  }

  /// Recupera un progetto in base al suo ID.
  Future<Progetto?> getProgettoById(String progettoId) async {
    try {
      final documentSnapshot = await firestore
          .collection('progetti')
          .doc(progettoId)
          .get();
      if (documentSnapshot.exists) {
        return Progetto.fromFirestore(documentSnapshot);
      } else {
        return null;
      }
    } catch (e) {
      print("Errore nel caricamento del progetto: $e");
      return null;
    }
  }

  Future<void> aggiornaProgetto(Progetto progetto) async {
    try {
      final String? id = progetto.id;

      if (id != null) {
        await FirebaseFirestore.instance
            .collection("progetti")
            .doc(id)
            .set(progetto.toMap());
      }
    } catch (e) {
      print("Errore durante l'aggiornamento del progetto: $e");
      rethrow; // Rilancia l'eccezione per gestirla a un livello superiore, se necessario.
    }
  }


  Future<List<String>> getPartecipantiDelProgetto(String progettoId) async {
    try {
      // Ottieni il riferimento al documento
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('progetti')
          .doc(progettoId)
          .get();

      // Verifica se il documento esiste
      if (docSnapshot.exists) {
        // Ottieni il campo "partecipanti" dal documento
        List<String>? partecipanti = List<String>.from(docSnapshot.get('partecipanti') ?? []);
        return partecipanti;
      } else {
        return []; // Se il documento non esiste, restituisci una lista vuota
      }
    } catch (e) {
      print('Errore durante il recupero dei partecipanti: $e');
      rethrow; // Rilancia l'eccezione per una gestione più ampia
    }
  }

  /// Recupera la lista dei progetti a cui partecipa un utente specifico e utilizza un callback.
  Future<void> getProgettiUtenteCallback(String userId, Function(List<Progetto>) callback) async {
    try {
      final querySnapshot = await firestore
          .collection('progetti')
          .where('partecipanti', arrayContains: userId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final progettiUtente = querySnapshot.docs
            .map((doc) => Progetto.fromFirestore(doc))
            .toList();
        callback(progettiUtente);
      } else {
        callback([]);
      }
    } catch (e) {
      print("Errore nel recupero dei progetti: $e");
      callback([]);
    }
  }

  Future<List<Progetto>> getProgettiCompletatiUtente(String userId) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('progetti')
          .where('partecipanti', arrayContains: userId)
          .where('completato', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Progetto.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Errore nel recupero dei progetti completati: $e');
      return [];
    }
  }
}
