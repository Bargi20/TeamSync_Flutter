import 'package:flutter/material.dart';
import 'package:teamsync_flutter/theme/color.dart';

enum Priorita {
  ALTA,
  MEDIA,
  BASSA,
  NESSUNA,
}

extension PrioritaExtension on Priorita {
  Color get colore {
    switch (this) {
      case Priorita.ALTA:
        return ColorePrioritaAlta;
      case Priorita.MEDIA:
        return ColorePrioritaMedia;
      case Priorita.BASSA:
        return ColorePrioritaBassa;
      case Priorita.NESSUNA:
      default:
        return ColoreSenzaPriorita;
    }
  }

  static Priorita fromString(String value) {
    switch (value) {
      case 'ALTA':
        return Priorita.ALTA;
      case 'MEDIA':
        return Priorita.MEDIA;
      case 'BASSA':
        return Priorita.BASSA;
      case 'NESSUNA':
      default:
        return Priorita.NESSUNA;
    }
  }

  // Convert Priorita enum to string
  String toShortString() {
    return this.toString().split('.').last;
  }
}
