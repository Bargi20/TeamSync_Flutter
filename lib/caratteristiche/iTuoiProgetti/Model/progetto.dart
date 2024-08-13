import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamsync_flutter/data.models/Priorita.dart';
class Progetto {
  final String? id;
  final String nome;
  final String? descrizione;
  final DateTime dataCreazione;
  final DateTime dataScadenza;
  final DateTime dataConsegna;
  final Priorita priorita;
  final List<String> partecipanti;
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
    required this.partecipanti,
    this.voto = "Non Valutato",
    this.completato = false,
    this.codice = "",
  });


  /// Crea un'istanza di [Progetto] a partire da un [DocumentSnapshot] di Firestore.
  /// [doc] Documento di Firestore contenente i dati del progetto.
  /// Ritorna un'istanza di [Progetto] con i dati estratti dal documento.
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
      partecipanti: List<String>.from(data['partecipanti'] ?? []),
      voto: data['voto'] ?? 'Non Valutato',
      completato: data['completato'] ?? false,
      codice: data['codice'] ?? '',
    );
  }




  /// Crea una copia dell'istanza di [Progetto] con eventuali modifiche.
  /// [id] Nuovo ID del progetto (opzionale).
  /// [nome] Nuovo nome del progetto (opzionale).
  /// [descrizione] Nuova descrizione del progetto (opzionale).
  /// [dataCreazione] Nuova data di creazione del progetto (opzionale).
  /// [dataScadenza] Nuova data di scadenza del progetto (opzionale).
  /// [dataConsegna] Nuova data di consegna del progetto (opzionale).
  /// [priorita] Nuova priorità del progetto (opzionale).
  /// [partecipanti] Nuova lista di partecipanti (opzionale).
  /// [voto] Nuovo voto del progetto (opzionale).
  /// [completato] Nuovo stato di completamento del progetto (opzionale).
  /// [codice] Nuovo codice identificativo del progetto (opzionale).
  /// Ritorna una nuova istanza di [Progetto] con i dati aggiornati.
  Progetto copyWith({String? id, String? nome, String? descrizione, DateTime? dataCreazione, DateTime? dataScadenza, DateTime? dataConsegna, Priorita? priorita, List<String>? partecipanti, String? voto, bool? completato, String? codice,}) {
    return Progetto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descrizione: descrizione ?? this.descrizione,
      dataCreazione: dataCreazione ?? this.dataCreazione,
      dataScadenza: dataScadenza ?? this.dataScadenza,
      dataConsegna: dataConsegna ?? this.dataConsegna,
      priorita: priorita ?? this.priorita,
      partecipanti: partecipanti ?? this.partecipanti,
      voto: voto ?? this.voto,
      completato: completato ?? this.completato,
      codice: codice ?? this.codice,
    );
  }





}
