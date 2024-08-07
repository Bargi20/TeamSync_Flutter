import 'package:flutter/material.dart';
import 'package:teamsync_flutter/theme/color.dart';

enum Priorita {
  alta,
  media,
  bassa,
  nessuna,
}

extension PrioritaExtension on Priorita {
  Color get colore {
    switch (this) {
      case Priorita.alta:
        return ColorePrioritaAlta;
      case Priorita.media:
        return ColorePrioritaMedia;
      case Priorita.bassa:
        return ColorePrioritaBassa;
      case Priorita.nessuna:
      default:
        return ColoreSenzaPriorita;
    }
  }
  static Priorita fromString(String value) {
    switch (value) {
      case 'alta':
        return Priorita.alta;
      case 'media':
        return Priorita.media;
      case 'bassa':
        return Priorita.bassa;
      case 'nessuna':
      default:
        return Priorita.nessuna;
    }
  }

  // Convert Priorita enum to string
  String toShortString() {
    return this.toString().split('.').last;
  }
}
