import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamsync_flutter/caratteristiche/LeMieAttivita/Repository/ToDoRepository.dart';
import 'package:teamsync_flutter/caratteristiche/iTuoiProcetti/Repository/RepositoryProgetto.dart';
import 'package:teamsync_flutter/caratteristiche/login/Repository/RepositoryUtente.dart';
import 'caratteristiche/login/ViewModel/ViewModelUtente.dart';
import 'caratteristiche/iTuoiProcetti/ViewModel/ViewModelProgetto.dart';  // Importa il ViewModelProgetto
import 'firebase_options.dart';
import 'navigation/navgraph.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final repositoryProgetto = RepositoryProgetto();
  final repositoryUtente = RepositoryUtente();
  final repositoryLeMieAttivita = TodoRepository();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ViewModelUtente()),
        ChangeNotifierProvider(create: (_) => ProgettoViewModel(repositoryProgetto: repositoryProgetto, repositoryUtente: repositoryUtente, repositoryLeMieAttivita: repositoryLeMieAttivita)), // Aggiungi il ProgettoViewModel
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: NavGraph()
    );
  }
}
