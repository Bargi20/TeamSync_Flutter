import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/Model/progetto.dart';
import 'package:uuid/uuid.dart';

class RepositoryProgetto {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  /// Recupera la lista dei progetti associati a un dato utente.

  /// [userId] ID dell'utente per cui recuperare i progetti.
  /// Ritorna una lista di oggetti [Progetto] associati all'utente.
  Future<List<Progetto>> getProgettiUtente(String userId) async {
    try {

      final querySnapshot = await firestore
          .collection('progetti')
          .where('partecipanti', arrayContains: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => Progetto.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Recupera l'ID dell'utente attualmente autenticato.
  /// Questo metodo restituisce l'identificatore univoco (UID) dell'utente attualmente autenticato.
  /// Il metodo interagisce con Firebase Authentication per ottenere l'utente corrente.
  /// @return Un `Future` che completa con il UID dell'utente corrente, o `null` se nessun utente è autenticato.
  /// @throws Un'eccezione se si verifica un errore durante il recupero dell'ID utente.
  Future<String?> getUtenteCorrenteId() async {
    try {
      final user = auth.currentUser;
      return user?.uid;
    } catch (e) {
      rethrow;
    }
  }



  /// Crea un nuovo progetto e lo aggiunge alla collezione di Firestore.
  /// [progetto] Oggetto [Progetto] da aggiungere.
  /// Ritorna l'ID del documento creato.
  Future<String> creaProgetto(Progetto progetto) async {
    try {
      final docRef = await FirebaseFirestore.instance.collection('progetti').add({
        'nome': progetto.nome,
        'descrizione': progetto.descrizione,
        'dataCreazione': Timestamp.fromDate(progetto.dataCreazione),
        'dataScadenza': Timestamp.fromDate(progetto.dataScadenza),
        'dataConsegna': Timestamp.fromDate(progetto.dataConsegna),
        'priorita': progetto.priorita.toString().split('.').last,
        'partecipanti': progetto.partecipanti,
        'voto': progetto.voto,
        'completato': progetto.completato,
        'codice': progetto.codice,
      });

      return docRef.id;
    } catch (e) {
      throw Exception("Errore durante la creazione del progetto: $e");
    }
  }


  /// Aggiunge un partecipante a un progetto esistente.
  /// [progettoId] ID del progetto a cui aggiungere il partecipante.
  /// [userId] ID dell'utente da aggiungere come partecipante.
  Future<void> aggiungiPartecipante(String? progettoId, String? userId) async {
    if (progettoId == null || userId == null) return;
    try {
      final progettoRef = firestore.collection('progetti').doc(progettoId);
      await progettoRef.update({
        'partecipanti': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      rethrow;
    }
  }


  /// Rimuove un partecipante da un progetto e elimina il progetto se non ci sono più partecipanti.
  /// [userId] ID dell'utente che abbandona il progetto.
  /// [progettoId] ID del progetto da cui l'utente abbandona.
  /// [callback] Funzione di callback da chiamare al termine dell'abbandono del progetto.
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




  /// Genera un codice unico per un progetto.
  /// Ritorna un codice di 8 caratteri.
  String generaCodiceProgetto() {
    return const Uuid().v4().substring(0, 8);
  }



  /// Recupera l'ID di un progetto a partire dal codice del progetto.
  /// [codice] Codice del progetto di cui ottenere l'ID.
  /// Ritorna l'ID del progetto se trovato, altrimenti `null`.
  Future<String?> getProgettoIdByCodice(String codice) async {
    try {
      final querySnapshot = await firestore
          .collection('progetti')
          .where('codice', isEqualTo: codice)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs[0].id;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }



  /// Elimina un progetto dalla collezione di Firestore.
  /// [progettoId] ID del progetto da eliminare.
  Future<void> eliminaProgetto(String progettoId) async {
    try {
      await firestore.collection('progetti').doc(progettoId).delete();
    } catch (e) {
      throw Exception("Errore durante l'eliminazione del progetto: $e");
    }
  }


  /// Recupera un progetto a partire dal suo ID.
  /// [progettoId] ID del progetto da recuperare.
  /// Ritorna un oggetto [Progetto] se trovato, altrimenti `null`.
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
      return null;
    }
  }



  /// Aggiorna un progetto esistente con i nuovi dati.
  /// [progetto] Oggetto [Progetto] con i dati aggiornati.
  Future<void> aggiornaProgetto(Progetto progetto) async {
    try {
      final String? id = progetto.id;

      if (id != null) {
        await FirebaseFirestore.instance
            .collection("progetti")
            .doc(id)
            .set({
          'nome': progetto.nome,
          'descrizione': progetto.descrizione,
          'dataCreazione': Timestamp.fromDate(progetto.dataCreazione),
          'dataScadenza': Timestamp.fromDate(progetto.dataScadenza),
          'dataConsegna': Timestamp.fromDate(progetto.dataConsegna),
          'priorita': progetto.priorita.toString().split('.').last,
          'partecipanti': progetto.partecipanti,
          'voto': progetto.voto,
          'completato': progetto.completato,
          'codice': progetto.codice,
        });
      }
    } catch (e) {
      rethrow;
    }
  }


  /// Recupera la lista dei partecipanti di un progetto.
  /// [progettoId] ID del progetto di cui ottenere i partecipanti.
  /// Ritorna una lista di ID di partecipanti.
  Future<List<String>> getPartecipantiDelProgetto(String progettoId) async {
    try {

      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('progetti')
          .doc(progettoId)
          .get();


      if (docSnapshot.exists) {

        List<String>? partecipanti = List<String>.from(docSnapshot.get('partecipanti') ?? []);
        return partecipanti;
      } else {
        return [];
      }
    } catch (e) {

      rethrow;
    }
  }


  /// Recupera la lista dei progetti completati da un dato utente.
  /// [userId] ID dell'utente per cui recuperare i progetti completati.
  /// Ritorna una lista di oggetti [Progetto] completati dall'utente.
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
      return [];
    }
  }



}
