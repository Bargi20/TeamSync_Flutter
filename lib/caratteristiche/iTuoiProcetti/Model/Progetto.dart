import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/Model/LeMieAttivita.dart'; // Importa il modello di LeMieAttivita
import 'package:teamsync_flutter/data.models/Priorita.dart';
class Progetto {
  final String? id; // L'ID del documento Firestore
  final String nome;
  final String? descrizione;
  final DateTime dataCreazione; // Data di creazione del progetto
  final DateTime dataScadenza; // Data di scadenza del progetto
  final DateTime dataConsegna;
  final Priorita priorita; // Priorità del progetto
  final List<LeMieAttivita> attivita; // Lista di attività associate al progetto
  final List<String> partecipanti; // lista degli id dei partecipanti
  final String voto;
  final bool completato;
  final String codice;

  Progetto({
    this.id,
    required this.nome,
    this.descrizione,
    required this.dataCreazione,
    required this.dataScadenza,
    required this.dataConsegna,
    required this.priorita,
    required this.attivita,
    required this.partecipanti,
    this.voto = "Non Valutato",
    this.completato = false,
    this.codice = "",
  });

  // Factory method to create a Progetto from Firestore DocumentSnapshot
  factory Progetto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Progetto(
      id: doc.id,
      nome: data['nome'] ?? '',
      descrizione: data['descrizione'],
      dataCreazione: (data['dataCreazione'] as Timestamp).toDate(),
      dataScadenza: (data['dataScadenza'] as Timestamp).toDate(),
      dataConsegna: (data['dataConsegna'] as Timestamp).toDate(),
      priorita: Priorita.values.firstWhere(
            (e) => e.toString() == 'Priorita.${data['priorita']}',
        orElse: () => Priorita.NESSUNA,
      ),
      attivita: (data['attivita'] as List<dynamic>)
          .map((item) => LeMieAttivita.fromMap(item as Map<String, dynamic>))
          .toList(),
      partecipanti: List<String>.from(data['partecipanti'] ?? []),
      voto: data['voto'] ?? 'Non Valutato',
      completato: data['completato'] ?? false,
      codice: data['codice'] ?? '',
    );
  }

  // Method to convert Progetto to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descrizione': descrizione,
      'dataCreazione': Timestamp.fromDate(dataCreazione),
      'dataScadenza': Timestamp.fromDate(dataScadenza),
      'dataConsegna': Timestamp.fromDate(dataConsegna),
      'priorita': priorita.toString().split('.').last, // Convert enum to string
      'attivita': attivita.map((item) => item.toMap()).toList(),
      'partecipanti': partecipanti,
      'voto': voto,
      'completato': completato,
      'codice': codice,
    };
  }

  // CopyWith method to create a new Progetto with updated fields
  Progetto copyWith({
    String? id,
    String? nome,
    String? descrizione,
    DateTime? dataCreazione,
    DateTime? dataScadenza,
    DateTime? dataConsegna,
    Priorita? priorita,
    List<LeMieAttivita>? attivita,
    List<String>? partecipanti,
    String? voto,
    bool? completato,
    String? codice,
  }) {
    return Progetto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descrizione: descrizione ?? this.descrizione,
      dataCreazione: dataCreazione ?? this.dataCreazione,
      dataScadenza: dataScadenza ?? this.dataScadenza,
      dataConsegna: dataConsegna ?? this.dataConsegna,
      priorita: priorita ?? this.priorita,
      attivita: attivita ?? this.attivita,
      partecipanti: partecipanti ?? this.partecipanti,
      voto: voto ?? this.voto,
      completato: completato ?? this.completato,
      codice: codice ?? this.codice,
    );
  }
}
