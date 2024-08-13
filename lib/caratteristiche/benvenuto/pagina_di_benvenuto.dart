
class PaginaDiBenvenuto {
  final String immagine;
  final String titolo;
  final String sottotitolo;
  final String sfondo;

  PaginaDiBenvenuto({
    required this.immagine,
    required this.titolo,
    required this.sottotitolo,
    required this.sfondo,
  });


  // Pagine di benvenuto predefinite
  static final primaPagina = PaginaDiBenvenuto(
    immagine: 'assets/im_pagina_di_benvenuto1.png',
    titolo: 'Benvenuto in TeamSync',
    sottotitolo: 'Il modo più semplice e veloce per organizzare i tuoi progetti universitari.',
    sfondo: 'assets/sfondo_pagina_di_benvenuto1.png',
  );

  static final secondaPagina = PaginaDiBenvenuto(
    immagine: 'assets/im_pagina_di_benvenuto2.png',
    titolo: 'Tieni traccia di tutti i tuoi progetti',
    sottotitolo: '',
    sfondo: 'assets/sfondo_pagina_di_benvenuto2.png',
  );

  static final terzaPagina = PaginaDiBenvenuto(
    immagine: 'assets/im_pagina_di_benvenuto3.png',
    titolo: 'Gestisci i task',
    sottotitolo: 'Crea,assegna e tieni traccia dei tuoi compiti efficacemente, tutto da un unica schermata intuitiva.',
    sfondo: 'assets/sfondo_pagina_di_benvenuto3.png',
  );

  static final quartaPagina = PaginaDiBenvenuto(
    immagine: 'assets/im_pagina_di_benvenuto4.png',
    titolo: 'Resta sempre aggiornato',
    sottotitolo: 'Attiva le notifiche di gruppo per non perdere mai un aggiornamento importante o una scadenza imminente nei tuoi progetti di gruppo.',
    sfondo: 'assets/sfondo_pagina_di_benvenuto6.png',
  );

  static final quintaPagina = PaginaDiBenvenuto(
    immagine: 'assets/im_pagina_di_benvenuto5.png',
    titolo: 'Aggiungi studenti ai tuoi amici',
    sottotitolo: 'Costruisci connessioni con nuovi compagni di corso.',
    sfondo: 'assets/sfondo_pagina_di_benvenuto5.png',
  );

  static final sestaPagina = PaginaDiBenvenuto(
    immagine: 'assets/im_pagina_di_benvenuto6.png',
    titolo: 'Inizia Ora! ',
    sottotitolo: 'Sei solo a un passo dall essere più organizzato e connesso che mai. Entra ora e trasforma il modo in cui lavori sui tuoi progetti!',
    sfondo: 'assets/sfondo_pagina_di_benvenuto6.png',
  );
}
