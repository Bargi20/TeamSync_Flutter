import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/Model/progetto.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProgetti/Repository/repository_progetto.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/Model/LeMieAttivita.dart';
import 'package:teamsync_flutter/caratteristiche/LeMieAttivita/Repository/ToDoRepository.dart';
import 'package:teamsync_flutter/caratteristiche/login/Model/user_class.dart';
import 'package:teamsync_flutter/caratteristiche/login/Repository/repository_utente.dart';
import 'package:teamsync_flutter/data.models/Priorita.dart';


class ProgettoViewModel extends ChangeNotifier {
  final RepositoryProgetto repositoryProgetto = RepositoryProgetto();
  final RepositoryUtente repositoryUtente = RepositoryUtente();
  final TodoRepository repositoryLeMieAttivita = TodoRepository();

  ProgettoViewModel() {
    _init();
  }


  String? _erroreAggiungiProgetto;
  List<Progetto> _progetti = [];
  List<Progetto> _progettiCompletati = [];
  String? _utenteCorrenteId;
  bool _isLoading = false;
  List<LeMieAttivita> _attivitaNonCompletate = [];
  List<LeMieAttivita> _attivitaCompletate = [];
  Map<String, int> _attivitaProgetti = {};

  String? get erroreAggiungiProgetto => _erroreAggiungiProgetto;
  List<Progetto> get progettiCompletati => _progettiCompletati;
  String? get utenteCorrenteId => _utenteCorrenteId;
  bool get isLoading => _isLoading;
  List<LeMieAttivita> get attivitaNonCompletate => _attivitaNonCompletate;
  List<LeMieAttivita> get attivitaCompletate => _attivitaCompletate;
  List<Progetto> get progetti => _progetti;
  Map<String, int> get attivitaProgetti => _attivitaProgetti;

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
      rethrow;
    }
  }

  /// Carica le attività non completate per un dato progetto e utente.
  /// [progettoId] ID del progetto per cui caricare le attività.
  /// [userId] ID dell'utente per cui filtrare le attività non completate.
  Future<void> caricaLeMieAttivitaNonCompletate(String progettoId, userId) async {
    try {
      final attivitaProgetto = await repositoryLeMieAttivita.getAttivitaByProgettoId(progettoId);
      _attivitaNonCompletate = attivitaProgetto.where((a) => !a.completato && a.utenti.contains(userId)).toList();
      notifyListeners();
    } catch (e) {
     rethrow;
    }
  }

  /// Carica tutte le attività completate per un dato progetto.
  /// [progettoId] ID del progetto per cui caricare le attività completate.
  Future<void> caricaTutteLeAttivitaCompletate(String progettoId) async {
    try {
      final attivitaProgetto = await repositoryLeMieAttivita.getAttivitaByProgettoId(progettoId);
      _attivitaCompletate = attivitaProgetto.where((a) => a.completato).toList();
      notifyListeners();
    } catch (e) {
     rethrow;
    }
  }


  /// Carica tutte le attività non completate per un dato progetto.
  /// [progettoId] ID del progetto per cui caricare le attività non completate.
  caricaTutteLeAttivitaNonCompletate(String progettoId) async {
    try {
      final attivitaProgetto = await repositoryLeMieAttivita.getAttivitaByProgettoId(progettoId);
      _attivitaNonCompletate = attivitaProgetto.where((a) => !a.completato).toList();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }


  /// Carica i progetti dell'utente corrente e aggiorna lo stato.
  /// [userId] ID dell'utente di cui caricare i progetti.
  /// [loadingInit] Indica se lo stato di caricamento deve essere inizializzato.
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
    } catch (e) { rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Recupera un progetto a partire dal suo ID.
  /// [progettoId] ID del progetto da recuperare.
  /// Ritorna il progetto se trovato, altrimenti `null`.
  Future<Progetto?> getProgettoById(String progettoId) async {
    try {

      final progetto = await repositoryProgetto.getProgettoById(progettoId);
      return progetto;
    } catch (e) {

      return null;
    }
  }


  /// Recupera la lista dei partecipanti di un progetto.
  /// [idProgetto] ID del progetto di cui ottenere i partecipanti.
  /// Ritorna una lista di ID dei partecipanti.
  Future<List<String>> getListaPartecipanti(String idProgetto) async {
    try {

      final partecipanti = await repositoryProgetto.getPartecipantiDelProgetto(idProgetto);
      return partecipanti;
    } catch (e) {

      return [];
    }
  }


  /// Recupera i profili degli utenti a partire da una lista di ID utente.
  /// [userIds] Lista degli ID degli utenti di cui ottenere i profili.
  /// Ritorna una lista di profili utente.
  Future<List<ProfiloUtente>> getPartecipantiByIds(List<String> userIds) async {
    List<ProfiloUtente> utenti = [];
    for (String userId in userIds) {
      ProfiloUtente? utente =  await repositoryUtente.getUserProfile(userId);
      if (utente != null) {
        utenti.add(utente);
      }
    }
    return utenti;
  }



  /// Carica i progetti completati dell'utente.
  /// [userId] ID dell'utente di cui caricare i progetti completati.
  Future<void> caricaProgettiCompletatiUtente(String userId) async {
    try {
      final progetti = await repositoryProgetto.getProgettiCompletatiUtente(userId);
      _progettiCompletati = progetti;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }


  /// Aggiorna un progetto esistente.
  Future<void> aggiornaProgetto({required String progettoId, required String nome, required String descrizione, required DateTime dataScadenza, required Priorita priorita, required String voto, required DateTime dataConsegna, }) async
  {
    try {

      Progetto? progetto = await repositoryProgetto.getProgettoById(progettoId);

      if (progetto != null) {
        Progetto progettoAggiornato = progetto.copyWith(
          nome: nome,
          descrizione: descrizione,
          dataScadenza: dataScadenza,
          priorita: priorita,
          voto: voto,
          dataConsegna: dataConsegna,
        );
        await repositoryProgetto.aggiornaProgetto(progettoAggiornato);

        String? utenteCorrenteId = this.utenteCorrenteId;
        if (utenteCorrenteId != null) {
          await caricaProgettiUtente(utenteCorrenteId, false);
        }
      }
    } catch (e) {
      rethrow;
    }
  }





  /// Aggiunge un nuovo progetto.
  /// [onSuccess] Funzione di callback da chiamare al termine dell'aggiunta del progetto, con l'ID del progetto come parametro.
  Future<void> addProgetto({required String nome, required String descrizione, required DateTime dataScadenza, required Priorita priorita, required List<String> partecipanti, required Function(String) onSuccess,}) async
  {
        try {
          const uuid =  Uuid();
          final progettoId = uuid.v4();
          final codice =  repositoryProgetto.generaCodiceProgetto();
          final progetto = Progetto(
            id: progettoId,
            nome: nome,
            descrizione: descrizione,
            dataCreazione: DateTime.now(),
            dataScadenza: dataScadenza,
            dataConsegna: dataScadenza,
            priorita: priorita,
            codice: codice,
            partecipanti: partecipanti,
            completato: false,
          );

          await repositoryProgetto.creaProgetto(progetto);
          notifyListeners();
          onSuccess(progettoId);
        } catch (e) {
          _erroreAggiungiProgetto = "Errore durante l'aggiunta del progetto.";
        }
      }




  /// Rimuove un partecipante da un progetto.
  /// [userID] ID dell'utente che abbandona il progetto.
  /// [progettoID] ID del progetto da cui l'utente abbandona.
  Future<void> abbandonaProgetto(String userID, String progettoID) async {
    try {
      await repositoryProgetto.abbandonaProgetto(userID, progettoID,(bool isProgettoEliminato) {

      });
    } catch (e) {
      rethrow;
    }
  }


  /// Converte una lista di progetti in una lista di ID di progetti.
  /// [listaProgetti] Lista dei progetti da convertire.
  /// Ritorna una lista di ID di progetti.
  Future<List<String>> convertiProgettiInId(List<Progetto> listaProgetti) async {
    List<String> progettiUtenteStringId = [];
    for (var progetto in listaProgetti) {
      if (progetto.id != null) {
        progettiUtenteStringId.add(progetto.id!);
      }
    }
    return progettiUtenteStringId;
  }


  /// Aggiunge un partecipante a un progetto tramite codice.
  /// [userId] ID dell'utente da aggiungere al progetto.
  /// [codiceProgetto] Codice del progetto a cui aggiungere l'utente.
  /// Ritorna `true` se l'aggiunta è avvenuta con successo, altrimenti `false`.
  Future<bool> aggiungiPartecipanteConCodice(String userId, String codiceProgetto) async {
    try {
      final progettoId = await repositoryProgetto.getProgettoIdByCodice(codiceProgetto);
      final progettiUtente = await repositoryProgetto.getProgettiUtente(userId);
      List<String> progettiUtenteStringId = await convertiProgettiInId(progettiUtente);

      if (progettoId != null && !utentePartecipa(progettiUtenteStringId, progettoId)) {
        await repositoryProgetto.aggiungiPartecipante(progettoId, userId);
        _erroreAggiungiProgetto = null;
      } else if (progettoId == null) {
        _erroreAggiungiProgetto =
        "Il codice inserito non è valido. Riprovare o contattare il creatore del progetto";
        return false;
      } else if(utentePartecipa(progettiUtenteStringId, progettoId)){
        _erroreAggiungiProgetto = "Fai già parte di questo progetto!";
        return false;
      }
    }catch (e) {
      _erroreAggiungiProgetto =
      "Si è verificato un errore durante l'aggiunta di un progetto";
      return false;
    }

    notifyListeners();
    return true;
  }


  /// Verifica se l'utente è già partecipante a un progetto.
  /// [progettiUtente] Lista degli ID dei progetti a cui l'utente partecipa.
  /// [progettoId] ID del progetto da verificare.
  /// Ritorna `true` se l'utente partecipa già al progetto, altrimenti `false`.
  bool utentePartecipa(List<String> progettiUtente, String progettoId) {
    return progettiUtente.contains(progettoId);
  }

}

