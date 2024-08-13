import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teamsync_flutter/caratteristiche/login/Repository/repository_utente.dart';
import '../../../navigation/navgraph.dart';
import '../Model/user_class.dart';

class ViewModelUtente extends ChangeNotifier {
  final RepositoryUtente repositoryUtente = RepositoryUtente();
  ProfiloUtente? utenteCorrente;
  bool loginSuccessful = false;
  bool firstLogin = false;
  String? erroreLogin;
  bool registrazioneRiuscita = false;
  bool resetPasswordRiuscito = false;
  String? erroreResetPassword;
  bool primoAccesso = false;
  String? erroreRegistrazione;


  /*
   * Gestisce il processo di login dell'utente.
   * @return Future<void> Ritorna un Future che notifica il completamento del login.
   */
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

        await fetchUserProfile(user.uid);
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

  /*
   * Gestisce il processo di registrazione di un nuovo utente.
   * @return Future<void> Ritorna un Future che notifica il completamento della registrazione.
   */
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


  /// Valida i campi del modulo di registrazione.
  /// @return String? Ritorna un messaggio di errore se uno dei campi non è valido, altrimenti null.
  String? _validateRegistrationField(String matricola, String nome, String cognome, String email, DateTime dataNascita, String password, String confermaPassword) {
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


  /// Invia un'email di verifica all'utente registrato.
  /// @return void : Non ritorna nulla, ma invia un'email di verifica.
  void _sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        notifyListeners();
      } catch (e) {
        rethrow;
      }
    }
  }


  /// Gestisce il processo di reset della password per un utente che ha dimenticato la propria password.
  /// @return Future<void> Ritorna un Future che notifica il completamento del reset della password.
  Future<void> resetPassword(String email) async {
    if (email.isNotEmpty) {
      final emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
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


  /// Aggiorna lo stato di primo accesso dell'utente corrente.
  /// @return Future<void> Ritorna un Future che notifica il completamento dell'aggiornamento dello stato di primo accesso.
  Future<void> updateFirstLogin() async {
    if (utenteCorrente != null) {
      await repositoryUtente.updateFirstLogin(utenteCorrente!.id);
      primoAccesso = false;
      notifyListeners();
    }
  }

  /// Gestisce il logout dell'utente corrente.
  /// @param context Il contesto di build di Flutter.
  /// @return Future<void> Ritorna un Future che notifica il completamento del logout.
  Future<void> logout(BuildContext context) async {
    try {
      final navigator = Navigator.of(context);
      await repositoryUtente.logout();
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const NavGraph(),
        ),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Recupera il profilo dell'utente corrente dal database.
  /// @param userId L'ID univoco dell'utente nel database.
  /// @return Future<void> Ritorna un Future che notifica il completamento del recupero del profilo utente.
  Future<void> fetchUserProfile(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('utenti').doc(userId).get();
      if (doc.exists) {
        utenteCorrente = ProfiloUtente.fromFirestore(doc);
      } else {
        utenteCorrente = null;
      }
      notifyListeners();
    } catch (e) {
      utenteCorrente = null;
      notifyListeners();
    }
  }

  /// Ottiene i dettagli del profilo utente dal database.
  /// @param userId L'ID univoco dell'utente nel database.
  /// @return Future<ProfiloUtente?> Ritorna un oggetto ProfiloUtente se il profilo esiste, altrimenti null.
  Future<ProfiloUtente?> ottieniUtente(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('utenti').doc(userId).get();
      if (doc.exists) {

        return ProfiloUtente.fromFirestore(doc);
      } else {

        return null;
      }
    } catch (e) {

      return null;
    }
  }
}
