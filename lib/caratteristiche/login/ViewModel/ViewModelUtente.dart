import 'package:cloud_firestore/cloud_firestore.dart'; // Per accedere a Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:teamsync_flutter/caratteristiche/login/Repository/repositoryUtente.dart';
import '../Model/UserClass.dart'; // Assicurati che contenga ProfiloUtente

class ViewModelUtente extends ChangeNotifier {
  final RepositoryUtente repositoryUtente = RepositoryUtente();
  ProfiloUtente? utenteCorrente; // Cambia User? a ProfiloUtente?
  bool loginSuccessful = false;
  bool firstLogin = false;
  String? erroreLogin;
  String? erroreVerificaEmail;
  bool registrazioneRiuscita = false;
  bool resetPasswordRiuscito = false;
  String? erroreResetPassword;
  bool primoAccesso = false;
  String? erroreRegistrazione;

  Future<void> login(String email, String password) async {
    if (email.isEmpty) {
      erroreLogin = "Per favore, inserisci l'indirizzo email.";
      notifyListeners();
      return;
    }
    if (!RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(email)) {
      erroreLogin = "L'indirizzo email inserito non è valido.";
      notifyListeners();
      return;
    }
    if (password.isEmpty) {
      erroreLogin = "Per favore, inserisci la password.";
      notifyListeners();
      return;
    }

    try {
      final user = await repositoryUtente.login(email, password);
      if (user != null && await repositoryUtente.isEmailVerified()) {
        // Recupera ProfiloUtente da Firestore
        await _fetchUserProfile(user.uid);
        firstLogin = await repositoryUtente.isFirstLogin(user.uid);
        loginSuccessful = true;
        erroreLogin = null;
      } else {
        erroreLogin = "L'email non è stata verificata. Per favore, verifica il tuo indirizzo email.";
      }
    } catch (e) {
      erroreLogin = "Email o password errate. Controlla le tue credenziali e riprova.";
    }

    notifyListeners();
  }

  Future<void> signUp(String matricola, String nome, String cognome, String email, DateTime dataNascita, SessoUtente sesso, String password, String confermaPassword) async {
    erroreRegistrazione = null;
    String? errore = _validateRegistrationField(matricola, nome, cognome, email, dataNascita, password, confermaPassword);
    if (errore != null) {
      erroreRegistrazione = errore;
      notifyListeners();
      return;
    }

    try {
      String sessoStringa = sesso.toString().split('.').last;
      await repositoryUtente.signUp(matricola, nome, cognome, dataNascita, sessoStringa, email, password);
      _sendEmailVerification();
      erroreRegistrazione = null;
      registrazioneRiuscita = true;

      notifyListeners();
    } catch (e) {
      print("Eccezione nella registrazione: $e");
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            erroreRegistrazione = "L'email è già in uso.";
            break;
          case 'invalid-email':
            erroreRegistrazione = "L'email non è valida.";
            break;
          case 'operation-not-allowed':
            erroreRegistrazione = "Operazione non permessa.";
            break;
          case 'weak-password':
            erroreRegistrazione = "La password è troppo debole.";
            break;
          default:
            erroreRegistrazione = "Errore: ${e.message}";
            break;
        }
      } else {
        erroreRegistrazione = "Registrazione fallita. Riprovare.";
      }

      registrazioneRiuscita = false;
      notifyListeners();
    }
  }

  String? _validateRegistrationField(String matricola, String nome, String cognome, String email, DateTime dataNascita, String password, String confermaPassword) {
    print("Fammi vedere : $confermaPassword");
    if (matricola.isEmpty) return "Per favore, inserisci il numero di matricola.";
    if (email.isEmpty) return "Per favore, inserisci il tuo indirizzo email.";
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) return "L'indirizzo email inserito non è valido.";
    if (nome.isEmpty) return "Per favore, inserisci il tuo nome.";
    if (cognome.isEmpty) return "Per favore, inserisci il tuo cognome.";
    if (password.isEmpty) return "Per favore, inserisci la password.";
    if (confermaPassword.isEmpty) return "Per favore, conferma la password inserita.";
    if (password != confermaPassword) return "Le password non coincidono.";
    return null;
  }

  void resetErroreLogin() {
    erroreLogin = null;
    notifyListeners();
  }

  void resetErroreVerificaEmail() {
    erroreVerificaEmail = null;
    notifyListeners();
  }

  void _sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        erroreVerificaEmail = null;
        notifyListeners();
      } catch (e) {
        erroreVerificaEmail = "Si è verificato un errore durante la conferma dell'email.";
        notifyListeners();
      }
    }
  }

  Future<void> resetPassword(String email) async {
    if (email.isNotEmpty) {
      final emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
      if (!emailValid.hasMatch(email)) {
        resetPasswordRiuscito = false;
        erroreResetPassword = "L'indirizzo email inserito non è valido.";
        notifyListeners();
        return;
      }

      try {
        await repositoryUtente.resetPassword(email);
        resetPasswordRiuscito = true;
        erroreResetPassword = null;
      } catch (e) {
        resetPasswordRiuscito = false;
        erroreResetPassword = "Reset della password fallito. Riprova.";
        debugPrint("Reset password fallito: $e");
      }

      notifyListeners();
    } else {
      erroreResetPassword = "Per favore, inserisci l'indirizzo email.";
      notifyListeners();
    }
  }

  Future<void> updateFirstLogin() async {
    if (utenteCorrente != null) {
      await repositoryUtente.updateFirstLogin(utenteCorrente!.id);
      primoAccesso = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUserProfile(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('utenti').doc(userId).get();
      if (doc.exists) {
        utenteCorrente = ProfiloUtente.fromFirestore(doc);
      } else {
        utenteCorrente = null;
      }
      notifyListeners();
    } catch (e) {
      print("Errore nel recupero del profilo utente: $e");
      utenteCorrente = null;
      notifyListeners();
    }
  }
}
