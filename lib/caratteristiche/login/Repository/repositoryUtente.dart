import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class RepositoryUtente {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

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


  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isFirstLogin(String userId) async {
    try {
      DocumentSnapshot document = await _firestore.collection('utenti').doc(userId).get();
      var profiloUtente = document.data() as Map<String, dynamic>?;
      return profiloUtente?['primoAccesso'] ?? true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateFirstLogin(String userId) async {
    try {
      await _firestore.collection('utenti').doc(userId).update({'primoAccesso': false});
    } catch (e) {
      rethrow;
    }
  }

  User? getUtenteAttuale() {
    return _auth.currentUser;
  }

  Future<void> sendEmailVerification() async {
    User? utente = getUtenteAttuale();
    try {
      await utente?.sendEmailVerification();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot document = await _firestore.collection('utenti').doc(userId).get();
      return document.data() as Map<String, dynamic>?;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> profiloUtente) async {
    try {
      await _firestore.collection('utenti').doc(profiloUtente['id']).set(profiloUtente);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getAllUtenti() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('utenti').get();
      List<String> utentiList = [];
      for (var document in querySnapshot.docs) {
        var nomeUtente = document.id; // Assumendo che l'ID dell'utente sia l'ID del documento
        utentiList.add(nomeUtente);
      }
      return utentiList;
    } catch (e) {
      // Gestione dell'errore
      return [];
    }
  }

  Future<bool> isEmailVerified() async {
    User? utenteAttuale = _auth.currentUser;
    try {
      await utenteAttuale?.reload();
      return utenteAttuale?.emailVerified ?? false;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }


}
