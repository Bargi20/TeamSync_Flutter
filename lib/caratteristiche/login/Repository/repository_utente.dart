import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../Model/user_class.dart';

class RepositoryUtente {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Effettua il login di un utente con l'indirizzo email e la password forniti.
  /// [email] L'indirizzo email dell'utente.
  /// [password] La password dell'utente.
  /// Ritorna l'oggetto [User] se il login è avvenuto con successo, altrimenti rethrow dell'eccezione.
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  /// Registra un nuovo utente con i dettagli forniti e salva il profilo dell'utente su Firestore.
  /// [matricola] Il numero di matricola dell'utente.
  /// [nome] Il nome dell'utente.
  /// [cognome] Il cognome dell'utente.
  /// [dataNascita] La data di nascita dell'utente.
  /// [sesso] Il sesso dell'utente.
  /// [email] L'indirizzo email dell'utente.
  /// [password] La password scelta dall'utente.
  /// Ritorna l'oggetto [User] se la registrazione è avvenuta con successo, altrimenti rethrow dell'eccezione.
  Future<User?> signUp(String matricola, String nome, String cognome, DateTime dataNascita, String sesso, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? utente = result.user;

      if (utente != null) {
        var profiloUtente = {
          'id': utente.uid,
          'nome': nome,
          'cognome': cognome,
          'matricola': matricola,
          'dataDiNascita': dataNascita,
          'sesso': sesso,
          'email': email,
          'primoAccesso': true,
          'immagine': null,
          'amici': [],
        };
        await _firestore.collection('utenti').doc(utente.uid).set(profiloUtente);
      }
      return utente;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }



  /// Invia un'email per il reset della password all'indirizzo email fornito.
  /// [email] L'indirizzo email dell'utente che richiede il reset della password.
  /// Ritorna un Future che notifica il completamento dell'operazione, altrimenti rethrow dell'eccezione.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }


  /// Verifica se l'utente ha effettuato il primo accesso.
  /// [userId] L'ID univoco dell'utente.
  /// Ritorna `true` se è il primo accesso dell'utente, altrimenti `false`.
  Future<bool> isFirstLogin(String userId) async {
    try {
      DocumentSnapshot document = await _firestore.collection('utenti').doc(userId).get();
      var profiloUtente = document.data() as Map<String, dynamic>?;
      return profiloUtente?['primoAccesso'] ?? true;
    } catch (e) {
      rethrow;
    }
  }



  /// Aggiorna lo stato di primo accesso dell'utente.
  /// [userId] L'ID univoco dell'utente.
  /// Ritorna un Future che notifica il completamento dell'aggiornamento, altrimenti rethrow dell'eccezione.
  Future<void> updateFirstLogin(String userId) async {
    try {
      await _firestore.collection('utenti').doc(userId).update({'primoAccesso': false});
    } catch (e) {
      rethrow;
    }
  }



  /// Ritorna l'utente attualmente autenticato, se esiste.
  /// Ritorna un oggetto [User] se c'è un utente autenticato, altrimenti `null`.
  User? getUtenteAttuale() {
    return _auth.currentUser;
  }


  /// Invia un'email di verifica all'utente attualmente autenticato.
  /// Ritorna un Future che notifica il completamento dell'invio, altrimenti rethrow dell'eccezione.
  Future<void> sendEmailVerification() async {
    User? utente = getUtenteAttuale();
    try {
      await utente?.sendEmailVerification();
    } catch (e) {
      rethrow;
    }
  }



  /// Recupera il profilo dell'utente dal database Firestore.
  /// [userId] L'ID univoco dell'utente.
  /// Ritorna un oggetto [ProfiloUtente] se il profilo esiste, altrimenti `null`.

  Future<ProfiloUtente?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot document = await _firestore.collection('utenti').doc(userId).get();
      if (document.exists) {
        return ProfiloUtente.fromFirestore(document);
      } else {
        return null;
      }
    } catch (e) {

      rethrow;
    }
  }



  /// Verifica se l'email dell'utente attuale è stata verificata.
  /// Ritorna `true` se l'email è stata verificata, altrimenti `false`.
  Future<bool> isEmailVerified() async {
    User? utenteAttuale = _auth.currentUser;
    try {
      await utenteAttuale?.reload();
      return utenteAttuale?.emailVerified ?? false;
    } catch (e) {
      rethrow;
    }
  }


  /// Effettua il logout dell'utente attualmente autenticato.
  /// Ritorna un Future che notifica il completamento dell'operazione.
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }


}
