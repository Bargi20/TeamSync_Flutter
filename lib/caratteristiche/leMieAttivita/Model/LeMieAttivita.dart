import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamsync_flutter/data.models/Priorita.dart';

class LeMieAttivita {
  final String? id;
  final String titolo;
  final String descrizione;
  final DateTime dataScadenza;
  final DateTime dataCreazione;
  final Priorita priorita;
  final bool completato;
  final String progetto;
  final List<String> utenti;
  final String? fileUri;

  LeMieAttivita({
    this.id,
    required this.titolo,
    required this.descrizione,
    required this.dataScadenza,
    required this.priorita,
    required this.completato,
    required this.progetto,
    required this.utenti,
    this.fileUri,
    DateTime? dataCreazione,
  }) : dataCreazione = dataCreazione ?? DateTime.now();

  /// Crea un'istanza di [LeMieAttivita] a partire da un [DocumentSnapshot] di Firestore.
  /// [doc] Documento di Firestore contenente i dati del progetto.
  /// Ritorna un'istanza di [LeMieAttivita] con i dati estratti dal documento.
  factory LeMieAttivita.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return LeMieAttivita(
      id: doc.id,
      titolo: data['titolo'] ?? '',
      descrizione: data['descrizione'] ?? '',
      dataScadenza: (data['dataScadenza'] as Timestamp).toDate(),
      dataCreazione: (data['dataCreazione'] as Timestamp).toDate(),
      priorita: Priorita.values.firstWhere(
            (e) => e.name == data['priorita'],
        orElse: () => Priorita.NESSUNA,
      ),
      completato: data['completato'] ?? false,
      progetto: data['progetto'] ?? '',
      utenti: List<String>.from(data['utenti'] ?? []),
      fileUri: data['fileUri'],
    );
  }

  /// Crea un'istanza di [LeMieAttivita] a partire da una mappa di dati.
  ///
  /// [map] Una `Map<String, dynamic>` contenente i valori da convertire in un'istanza di [LeMieAttivita].
  /// [id] ID del task (opzionale, default vuoto).
  /// [titolo] Titolo del task (opzionale, default vuoto).
  /// [descrizione] Descrizione del task (opzionale, default vuoto).
  /// [dataScadenza] Data di scadenza del task, convertita da `Timestamp` a `DateTime` (opzionale).
  /// [dataCreazione] Data di creazione del task, convertita da `Timestamp` a `DateTime` (opzionale).
  /// [priorita] Priorità del task, convertita da `String` all'enum [Priorita] (opzionale, default `Priorita.NESSUNA`).
  /// [completato] Stato di completamento del task (opzionale, default `false`).
  /// [progetto] ID del progetto a cui il task appartiene (opzionale, default vuoto).
  /// [utenti] Lista di ID utenti assegnati al task, convertita da `List<dynamic>` a `List<String>` (opzionale).
  /// [fileUri] URI del file associato al task (opzionale, può essere null).
  ///
  /// Ritorna un'istanza di [LeMieAttivita] con i dati forniti.
  factory LeMieAttivita.fromMap(Map<String, dynamic> map) {
    return LeMieAttivita(
      id: map['id'] ?? '',
      titolo: map['titolo'] ?? '',
      descrizione: map['descrizione'] ?? '',
      dataScadenza: (map['dataScadenza'] as Timestamp).toDate(),
      dataCreazione: (map['dataCreazione'] as Timestamp).toDate(),
      priorita: Priorita.values.firstWhere(
            (e) => e.name == 'Priorita.${map['priorita']}',
        orElse: () => Priorita.NESSUNA,
      ),
      completato: map['completato'] ?? false,
      progetto: map['progetto'] ?? '',
      utenti: List<String>.from(map['utenti'] ?? []),
      fileUri: map['fileUri'],
    );
  }

  /// Converte l'istanza corrente di [LeMieAttivita] in una mappa di dati.
  ///
  /// [titolo] Titolo del task.
  /// [descrizione] Descrizione del task.
  /// [dataScadenza] Data di scadenza del task, convertita da `DateTime` a `Timestamp`.
  /// [dataCreazione] Data di creazione del task, convertita da `DateTime` a `Timestamp`.
  /// [priorita] Priorità del task, convertita dall'enum [Priorita] a `String` tramite il metodo `toShortString`.
  /// [completato] Stato di completamento del task.
  /// [progetto] ID del progetto a cui il task appartiene.
  /// [utenti] Lista di ID utenti assegnati al task.
  /// [fileUri] URI del file associato al task (può essere null).
  ///
  /// Ritorna una `Map<String, dynamic>` rappresentante l'istanza di [LeMieAttivita] con i dati convertiti.

  Map<String, dynamic> toMap() {
    return {
      'titolo': titolo,
      'descrizione': descrizione,
      'dataScadenza': Timestamp.fromDate(dataScadenza),
      'dataCreazione': Timestamp.fromDate(dataCreazione),
      'priorita': priorita.toShortString(),
      'completato': completato,
      'progetto': progetto,
      'utenti': utenti,
      'fileUri': fileUri,

    };
  }
}
