import 'package:cloud_firestore/cloud_firestore.dart';


/// Enum che rappresenta i possibili valori del sesso dell'utente.
enum SessoUtente {
  UOMO,
  DONNA,
  ALTRO
}

class ProfiloUtente {
  String id;
  String nome;
  String cognome;
  String matricola;
  DateTime dataDiNascita;
  SessoUtente sesso;
  String email;
  bool primoAccesso;
  String? immagine;
  List<String> amici;

  ProfiloUtente({
    required this.id,
    required this.nome,
    required this.cognome,
    required this.matricola,
    required this.dataDiNascita,
    required this.sesso,
    required this.email,
    this.primoAccesso = true,
    this.immagine,
    this.amici = const [],
  });


  /// Crea un'istanza di [ProfiloUtente] a partire da un documento Firestore.
  /// [doc] Il documento Firestore da cui estrarre i dati.
  /// Ritorna un'istanza di [ProfiloUtente] con i dati estratti dal documento.
  /// In caso di errore nel parsing del campo 'sesso', il valore di default sarà [SessoUtente.ALTRO].
  factory ProfiloUtente.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    SessoUtente sessoEnum;

    try {
      sessoEnum = SessoUtente.values.firstWhere(
            (e) => e.toString().split('.').last == data['sesso'],
        orElse: () => SessoUtente.ALTRO,
      );
    } catch (e) {
      sessoEnum = SessoUtente.ALTRO; // Default value
    }

    return ProfiloUtente(
      id: doc.id,
      nome: data['nome'],
      cognome: data['cognome'],
      matricola: data['matricola'],
      dataDiNascita: (data['dataDiNascita'] as Timestamp).toDate(),
      sesso: sessoEnum,
      email: data['email'],
      primoAccesso: data['primoAccesso'],
      immagine: data['immagine'],
      amici: List<String>.from(data['amici'] ?? []),
    );
  }


}
