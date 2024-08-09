import 'package:flutter/material.dart';
import 'package:teamsync_flutter/caratteristiche/benvenuto/schermata_di_benvenuto.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/View/ITuoiProgetti.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/ViewModel/ViewModelProgetto.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/View/LeMieAttivitaUI.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/ViewModel/LeMieAttivitaViewModel.dart';
import 'package:teamsync_flutter/caratteristiche/login/View/PasswordDimenticata.dart';
import 'package:teamsync_flutter/caratteristiche/login/View/login.dart';
import 'package:teamsync_flutter/caratteristiche/login/View/registrazione.dart';
import 'package:teamsync_flutter/caratteristiche/login/View/verificaMail.dart';
import 'package:teamsync_flutter/caratteristiche/login/viewModel/ViewModelUtente.dart';
import 'package:teamsync_flutter/navigation/schermate.dart';
import 'package:provider/provider.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/Repository/RepositoryProgetto.dart';

class NavGraph extends StatelessWidget {
  const NavGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ViewModelUtente>(
            create: (BuildContext context) => ViewModelUtente(),
          ),
          ChangeNotifierProvider<ProgettoViewModel>(
            create: (BuildContext context) => ProgettoViewModel(),
          ),
          ChangeNotifierProvider<LeMieAttivitaViewModel>(
            create: (BuildContext context) => LeMieAttivitaViewModel(),
          ),
        ],


      child: MaterialApp(
        initialRoute: Schermate.login,
        routes: {
          Schermate.benvenuto: (context) => SchermataDiBenvenuto(
            onStart: () {
              Navigator.pushReplacementNamed(context, Schermate.login);
            },
          ),
          Schermate.registrazione: (context) {
            final viewModel = Provider.of<ViewModelUtente>(context, listen: true);
            return Registrazione(viewModel);
          },
          Schermate.verificaEmail: (context) => VerificaEmail(onButtonPressed: () {
            Navigator.pushReplacementNamed(context, Schermate.login);
          }),
          Schermate.login: (context) {
            var viewModelutente = Provider.of<ViewModelUtente>(context, listen: true);
            return LoginScreen(viewmodelutente: viewModelutente);
          },
          Schermate.recuperoPassword: (context) {
            var viewModel = Provider.of<ViewModelUtente>(context, listen: true);
            return PasswordDimenticata(viewModel);
          },
          Schermate.ituoiProgetti: (context) {
            var viewModel = Provider.of<ViewModelUtente>(context, listen: true);
            return YourProjectsPage(viewmodelutente: viewModel);
          },


          Schermate.leMieAttivita: (context) {
            final String idProgetto = ModalRoute.of(context)!.settings.arguments as String;
            var viewModelProgetto = Provider.of<ProgettoViewModel>(context, listen: true);
            var viewModelutente = Provider.of<ViewModelUtente>(context, listen: true);
            var viewModelAttivita = Provider.of<LeMieAttivitaViewModel>(context, listen: true);
            return lemieAttivita(
              idProgetto: idProgetto,
              viemodelprogetto: viewModelProgetto,
              viewmodelutente: viewModelutente,
              viewmodelAttivita: viewModelAttivita,
            );
    },

        },
      ),
    );
  }
}
