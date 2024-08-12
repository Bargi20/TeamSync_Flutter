import 'package:flutter/material.dart';
import 'package:teamsync_flutter/caratteristiche/login/viewModel/ViewModelUtente.dart';
import 'package:teamsync_flutter/navigation/Schermate.dart';
import 'pagina_di_benvenuto.dart';
import 'package:provider/provider.dart';

class SchermataDiBenvenuto extends StatefulWidget {
  ViewModelUtente viewModelUtente;

  SchermataDiBenvenuto({required this.viewModelUtente});

  @override
  _SchermataDiBenvenutoState createState() => _SchermataDiBenvenutoState();
}

class _SchermataDiBenvenutoState extends State<SchermataDiBenvenuto> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<PaginaDiBenvenuto> _pages = [
    PaginaDiBenvenuto.primaPagina,
    PaginaDiBenvenuto.secondaPagina,
    PaginaDiBenvenuto.terzaPagina,
    PaginaDiBenvenuto.quartaPagina,
    PaginaDiBenvenuto.quintaPagina,
    PaginaDiBenvenuto.sestaPagina,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final pagina = _pages[index];
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      pagina.sfondo,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(pagina.immagine, height: 240),
                        SizedBox(height: 16),
                        Text(
                          pagina.titolo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          pagina.sottotitolo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20), // Spazio tra il sottotitolo e il pulsante
                        AnimatedOpacity(
                          opacity: _currentPage == _pages.length - 1 ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 200),
                          child: ElevatedButton(
                            onPressed: () async {

                              await widget.viewModelUtente.updateFirstLogin();

                              // Naviga verso la pagina dei tuoi progetti
                              Navigator.pushReplacementNamed(context, Schermate.ituoiProgetti);

                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                            ),
                            child: Text('Inizia Ora'),
                          )

                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.red : Colors.grey,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
