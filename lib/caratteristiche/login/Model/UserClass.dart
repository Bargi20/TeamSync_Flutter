import 'package:cloud_firestore/cloud_firestore.dart';

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
  SessoUtente sesso; // Cambiato da String a SessoUtente
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

  factory ProfiloUtente.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    // Convert the sesso field from string to SessoUtente enum
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

  // Convert ProfiloUtente to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'cognome': cognome,
      'matricola': matricola,
      'dataDiNascita': Timestamp.fromDate(dataDiNascita),
      'sesso': sesso.toString().split('.').last, // Convert enum to string
      'email': email,
      'primoAccesso': primoAccesso,
      'immagine': immagine,
      'amici': amici,
    };
  }

  // Convert from a map
  factory ProfiloUtente.fromMap(Map<String, dynamic> map) {
    // Convert the sesso field from string to SessoUtente enum
    SessoUtente sessoEnum;
    try {
      sessoEnum = SessoUtente.values.firstWhere(
            (e) => e.toString().split('.').last == map['sesso'],
        orElse: () => SessoUtente.ALTRO,
      );
    } catch (e) {
      sessoEnum = SessoUtente.ALTRO; // Default value
    }

    return ProfiloUtente(
      id: map['id'],
      nome: map['nome'],
      cognome: map['cognome'],
      matricola: map['matricola'],
      dataDiNascita: (map['dataDiNascita'] as Timestamp).toDate(),
      sesso: sessoEnum,
      email: map['email'],
      primoAccesso: map['primoAccesso'],
      immagine: map['immagine'],
      amici: List<String>.from(map['amici'] ?? []),
    );
  }
}
