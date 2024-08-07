import 'package:flutter/material.dart';
import 'package:teamsync_flutter/caratteristiche/benvenuto/schermata_di_benvenuto.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/View/ITuoiProgetti.dart';
import 'package:teamsync_flutter/caratteristiche/login/View/PasswordDimenticata.dart';
import 'package:teamsync_flutter/caratteristiche/login/View/login.dart';
import 'package:teamsync_flutter/caratteristiche/login/View/registrazione.dart';
import 'package:teamsync_flutter/caratteristiche/login/View/verificaMail.dart';
import 'package:teamsync_flutter/caratteristiche/login/viewModel/ViewModelUtente.dart';
import 'package:teamsync_flutter/navigation/schermate.dart';
import 'package:provider/provider.dart';

class NavGraph extends StatelessWidget {
  const NavGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ViewModelUtente>(
      create: (BuildContext context) => ViewModelUtente(),
      child: MaterialApp(
        initialRoute: Schermate.login,
        routes: {
          Schermate.benvenuto: (context) => SchermataDiBenvenuto(
            onStart: () {
              Navigator.pushReplacementNamed(context, Schermate.login);
            },
          ),
          Schermate.registrazione: (context) {
            final viewModel = Provider.of<ViewModelUtente>(context, listen: false);
            return Registrazione(viewModel);
          },
          Schermate.verificaEmail: (context) => VerificaEmail(onButtonPressed: () {
            Navigator.pushReplacementNamed(context, Schermate.login);
          }),
          Schermate.login: (context) => LoginScreen(),
          Schermate.recuperoPassword: (context) {
            var viewModel = Provider.of<ViewModelUtente>(context, listen: false);
            return PasswordDimenticata(viewModel);
          },
          Schermate.ituoiProgetti: (context) => YourProjectsPage(),
          // Aggiungi altre schermate qui
        },
      ),
    );
  }
}
