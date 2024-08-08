import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/Model/Progetto.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/Repository/RepositoryProgetto.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/Model/LeMieAttivita.dart';
import 'package:teamsync_flutter/caratteristiche/LeMieAttivita/Repository/ToDoRepository.dart';
import 'package:teamsync_flutter/caratteristiche/login/Model/UserClass.dart';
import 'package:teamsync_flutter/caratteristiche/login/Repository/RepositoryUtente.dart';
import 'package:teamsync_flutter/data.models/Priorita.dart';
import 'package:share_plus/share_plus.dart';

class ProgettoViewModel extends ChangeNotifier {
  final RepositoryProgetto repositoryProgetto = RepositoryProgetto();
  final RepositoryUtente repositoryUtente = RepositoryUtente();
  final TodoRepository repositoryLeMieAttivita = TodoRepository();

  ProgettoViewModel() {
    _init();
  }

  // State management variables
  bool _aggiungiProgettoRiuscito = false;
  String? _erroreAggiungiProgetto;
  String? _erroreCaricamentoProgetto;
  String? _erroreAbbandonaProgetto;
  List<Progetto> _progettiCompletati = [];
  String? _utenteCorrenteId;

  bool get aggiungiProgettoRiuscito => _aggiungiProgettoRiuscito;
  String? get erroreAggiungiProgetto => _erroreAggiungiProgetto;
  String? get erroreCaricamentoProgetto => _erroreCaricamentoProgetto;
  String? get erroreAbbandonaProgetto => _erroreAbbandonaProgetto;
  List<Progetto> get progettiCompletati => _progettiCompletati;
  String? get utenteCorrenteId => _utenteCorrenteId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<LeMieAttivita> _attivitaNonCompletate = [];
  List<LeMieAttivita> _attivitaCompletate = [];
  List<LeMieAttivita> _LemieattivitanonCompletate = [];
  List<Progetto> _progetti = [];
  Map<String, int> _attivitaProgetti = {};
  List<Progetto> _progettiCollega = [];

  List<LeMieAttivita> get attivitaNonCompletate => _attivitaNonCompletate;
  List<LeMieAttivita> get attivitaCompletate => _attivitaCompletate;
  List<LeMieAttivita> get leMieAttivitaNonCompletate => _LemieattivitanonCompletate;
  List<Progetto> get progetti => _progetti;
  Map<String, int> get attivitaProgetti => _attivitaProgetti;
  List<Progetto> get progettiCollega => _progettiCollega;

  Future<void> _init() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _utenteCorrenteId = user.uid;
        notifyListeners();
        await caricaProgettiUtente(user.uid, false);
        await caricaProgettiCompletatiUtente(user.uid);
      }
    } catch (e) {
      print("Errore durante l'inizializzazione: $e");
    }
  }

  Future<void> logout() async {
    try {
      await repositoryProgetto.logout();
      _utenteCorrenteId = null;
      notifyListeners();  // Notifica i listener (ad es. UI) che lo stato è cambiato
      print("utente corrente: $_utenteCorrenteId");
    } catch (e) {
      // Gestione dell'errore
      print("Errore durante il logout: $e");
    }
  }

  Future<String?> recuperaCodiceProgetto(String progettoId) async {
    try {
      final progetto = await repositoryProgetto.getProgettoById(progettoId);
      if (progetto != null) {
        final codiceProgetto = progetto.codice;
        notifyListeners();
        return codiceProgetto;
      }
      return null;  // Restituisce null se il progetto non è trovato
    } catch (e) {
      print("Errore nel recupero del codice del progetto: $e");
      return null;  // Restituisce null in caso di errore
    }
  }

  Future<void> caricaLeMieAttivita(String progettoId, String UserId) async {
    try {
      final attivitaProgetto = await repositoryLeMieAttivita.getAttivitaByProgettoId(progettoId);
      _LemieattivitanonCompletate = attivitaProgetto.where((a) => !a.completato && a.utenti.contains(UserId)).toList();
      notifyListeners();
    } catch (e) {
      print("Errore nel caricamento delle attività del progetto: $progettoId: $e");
    }
  }

  Future<void> caricaAttivitaCompletate(String progettoId) async {
    try {
      final attivitaProgetto = await repositoryLeMieAttivita.getAttivitaByProgettoId(progettoId);
      _attivitaCompletate = attivitaProgetto.where((a) => a.completato).toList();
      notifyListeners();
    } catch (e) {
      print("Errore nel caricamento delle attività del progetto: $progettoId: $e");
    }
  }

  caricaAttivitaNonCompletate(String progettoId) async {
    try {
      final attivitaProgetto = await repositoryLeMieAttivita.getAttivitaByProgettoId(progettoId);
      _attivitaNonCompletate = attivitaProgetto.where((a) => !a.completato).toList();
      notifyListeners();
    } catch (e) {
      print("Errore nel caricamento delle attività del progetto: $progettoId: $e");
    }
  }


  void condividiCodiceProgetto(BuildContext context, String codiceProgetto) {
    final String testoDaCondividere = "Ecco il codice per poter aggiungere il progetto: $codiceProgetto";
    Share.share(testoDaCondividere);
  }

  Future<void> aggiornaProgetto(
      String progettoId,
      String nome,
      String descrizione,
      DateTime dataScadenza,
      Priorita priorita,
      String voto,
      DateTime dataConsegna,
      ) async {
    try {
      final progetto = await repositoryProgetto.getProgettoById(progettoId);
      if (progetto != null) {
        final progettoAggiornato = Progetto(
          id: progettoId,
          nome: nome,
          descrizione: descrizione,
          dataCreazione: progetto.dataCreazione, // Mantiene la data di creazione originale
          dataScadenza: dataScadenza,
          dataConsegna: dataConsegna,
          priorita: priorita,
          voto: voto,
          attivita: progetto.attivita, // Mantiene le attività originali
          partecipanti: progetto.partecipanti, // Mantiene i partecipanti originali
          completato: progetto.completato, // Mantiene lo stato di completamento originale
          codice: progetto.codice, // Mantiene il codice originale
        );
        await repositoryProgetto.aggiornaProgetto(progettoAggiornato);
        if (_utenteCorrenteId != null) {
          await caricaProgettiUtente(_utenteCorrenteId!, false);
        }
      }
    } catch (e) {
      print("Errore durante l'aggiornamento del progetto: $e");
    }
  }

  Future<void> aggiornaStatoProgetto(String progettoId, bool completato) async {
    try {
      final progetto = await repositoryProgetto.getProgettoById(progettoId);
      if (progetto != null) {
        final progettoAggiornato = Progetto(
          id: progettoId,
          nome: progetto.nome,
          descrizione: progetto.descrizione,
          dataCreazione: progetto.dataCreazione,
          dataScadenza: progetto.dataScadenza,
          dataConsegna: progetto.dataConsegna,
          priorita: progetto.priorita,
          voto: progetto.voto,
          attivita: progetto.attivita,
          partecipanti: progetto.partecipanti,
          completato: completato,
          codice: progetto.codice,
        );
        await repositoryProgetto.aggiornaProgetto(progettoAggiornato);
        if (_utenteCorrenteId != null) {
          await caricaProgettiUtente(_utenteCorrenteId!, true);
        }
      }
    } catch (e) {
      print("Errore durante l'aggiornamento dello stato del progetto: $e");
    }
  }

  Future<String> getNomeProgetto(String idProg) async {
    _isLoading = true;
    notifyListeners();
    try {
      Progetto? progetto;
      while (progetto == null) {
        progetto = await repositoryProgetto.getProgettoById(idProg);
        await Future.delayed(Duration(milliseconds: 200));
      }
      return progetto.nome;
    } catch (e) {
      return "Nome progetto non disponibile";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getUtenteById(String id, Function(ProfiloUtente?) callback) async {
    try {
      final profileData = await repositoryUtente.getUserProfile(id);
      final profile = profileData != null ? ProfiloUtente.fromMap(profileData) : null;
      callback(profile);
    } catch (e) {
      print("Errore durante il recupero dell'utente con ID $id: $e");
      callback(null);
    }
  }

  Future<void> caricaProgettiUtente(String userId, bool loadingInit) async {
    _isLoading = loadingInit;
    notifyListeners();
    try {
      final progetti = await repositoryProgetto.getProgettiUtente(userId);
      _progetti = progetti;
      final attivitaMap = <String, int>{};
      for (final progetto in progetti) {
        final attivitaNonCompletate = await repositoryLeMieAttivita.countNonCompletedTodoByProject(progetto.id ?? "");
        attivitaMap[progetto.id ?? ""] = attivitaNonCompletate;
      }
      _attivitaProgetti = attivitaMap;
      notifyListeners();
    } catch (e) {
      _erroreCaricamentoProgetto = "Errore nel caricamento dei progetti.";
      print("Errore nel caricamento dei progetti: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Progetto?> getProgettoById(String progettoId) async {
    try {
      // Usa il repository per ottenere il progetto
      final progetto = await repositoryProgetto.getProgettoById(progettoId);
      return progetto;  // Restituisce il progetto trovato
    } catch (e) {
      print("Errore durante il recupero del progetto con ID $progettoId: $e");
      return null;  // Restituisce null in caso di errore
    }
  }

  Future<void> caricaProgettiCollega(String userId, bool loadingInit) async {
    _isLoading = loadingInit;
    notifyListeners();
    try {
      final progetti = await repositoryProgetto.getProgettiUtente(userId);
      _progettiCollega = progetti;
      notifyListeners();
    } catch (e) {
      print("Errore nel caricamento dei progetti del collega: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetProgetti() async {
    _progetti = [];
    notifyListeners();
  }

  Future<void> caricaProgettiCompletatiUtente(String userId) async {
    try {
      final progetti = await repositoryProgetto.getProgettiCompletatiUtente(userId);
      _progettiCompletati = progetti;
      notifyListeners();
    } catch (e) {
      _erroreCaricamentoProgetto = "Errore nel caricamento dei progetti completati.";
      print("Errore nel caricamento dei progetti completati: $e");
    }
  }

  bool progettoScaduto(Progetto progetto) {
    return progetto.dataScadenza.isBefore(DateTime.now());
  }

  Future<void> addProgetto({
    required String nome,
    required String descrizione,
    required DateTime dataScadenza,
    required Priorita priorita,
    required DateTime dataConsegna,
    required List<String> partecipanti, // Aggiungi il parametro partecipanti
    required Function(String) onSuccess,
  }) async {
    try {
      final uuid = Uuid();
      final progettoId = uuid.v4();

      final progetto = Progetto(
        id: progettoId,
        nome: nome,
        descrizione: descrizione,
        dataCreazione: DateTime.now(),
        dataScadenza: dataScadenza,
        dataConsegna: dataConsegna,
        priorita: priorita,
        attivita: [],
        partecipanti: partecipanti, // Utilizza i partecipanti qui
        completato: false,
      );

      await repositoryProgetto.creaProgetto(progetto);
      _aggiungiProgettoRiuscito = true;
      notifyListeners();
      onSuccess(progettoId);
    } catch (e) {
      _erroreAggiungiProgetto = "Errore durante l'aggiunta del progetto.";
      print("Errore durante l'aggiunta del progetto: $e");
    }
  }


  Future<void> abbandonaProgetto(String progettoId) async {
    try {
      await repositoryProgetto.eliminaProgetto(progettoId);
      notifyListeners();
    } catch (e) {
      _erroreAbbandonaProgetto = "Errore durante l'abbandono del progetto.";
      print("Errore durante l'abbandono del progetto: $e");
    }
  }
}
