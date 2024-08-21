import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'caratteristiche/login/ViewModel/view_model_utente.dart';
import 'caratteristiche/iTuoiProgetti/ViewModel/view_model_progetto.dart';
import 'firebase_options.dart';
import 'navigation/navgraph.dart';
import 'package:teamsync_flutter/caratteristiche/leMieAttivita/ViewModel/LeMieAttivitaViewModel.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ViewModelUtente()),
        ChangeNotifierProvider(create: (_) => ProgettoViewModel()),
        ChangeNotifierProvider(create: (_) => LeMieAttivitaViewModel()),
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
