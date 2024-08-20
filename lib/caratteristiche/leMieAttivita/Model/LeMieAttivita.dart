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
