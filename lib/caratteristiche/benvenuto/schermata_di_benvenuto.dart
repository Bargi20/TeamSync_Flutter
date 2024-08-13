import 'package:flutter/material.dart';
import 'package:teamsync_flutter/caratteristiche/login/viewModel/view_model_utente.dart';
import 'package:teamsync_flutter/navigation/Schermate.dart';
import 'pagina_di_benvenuto.dart';

class SchermataDiBenvenuto extends StatefulWidget {
  final ViewModelUtente viewModelUtente;

  const SchermataDiBenvenuto({super.key, required this.viewModelUtente});

  @override
  SchermataDiBenvenutoState createState() => SchermataDiBenvenutoState();
}

class SchermataDiBenvenutoState extends State<SchermataDiBenvenuto> {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body:  Stack(
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
                  Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth*0.05),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(pagina.immagine, height: 240),
                        SizedBox(height: screenHeight*0.02),
                        Text(
                          pagina.titolo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight*0.015),
                        Text(
                          pagina.sottotitolo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight*0.03), // Spazio tra il sottotitolo e il pulsante
                        AnimatedOpacity(
                          opacity: _currentPage == _pages.length - 1 ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: ElevatedButton(
                            onPressed: () async {
                              final navigator = Navigator.of(context);
                              await widget.viewModelUtente.updateFirstLogin();

                              // Naviga verso la pagina dei tuoi progetti
                              navigator.pushReplacementNamed(Schermate.ituoiProgetti);

                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Inizia Ora'),
                          )

                        ),
                      ],
                    ),
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
                  margin: const EdgeInsets.symmetric(horizontal: 4),
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
