import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../navigation/schermate.dart';
import '../../../theme/color.dart';
import 'package:teamsync_flutter/caratteristiche/login/viewModel/ViewModelUtente.dart';


class LoginScreen extends StatefulWidget {

  ViewModelUtente viewmodelutente;

  LoginScreen({super.key, required this.viewmodelutente});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';
  bool passwordVisible = false;
  bool isLoading = false;
  bool hasAttemptedLogin = false;

  @override
  Widget build(BuildContext context) {
    final viewModelUtente = Provider.of<ViewModelUtente>(context);
    //final viewModelProgetto = Provider.of<ViewModelProgetto>(context);

    if (hasAttemptedLogin && viewModelUtente.erroreLogin != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModelUtente.erroreLogin!),
            duration: const Duration(seconds: 1), // Durata del SnackBar
            action: SnackBarAction(
              label: 'Chiudi',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      });
      hasAttemptedLogin = false;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100), // Aggiungi uno spazio iniziale per centrare meglio il contenuto
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icon.png',
                          width: 70,
                          height: 70,
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Image.asset(
                      "assets/user_icon.png",
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Accedi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Column(
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)), // Angoli arrotondati
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) => setState(() => email = value),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => passwordVisible = !passwordVisible),
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)), // Angoli arrotondati
                              ),
                            ),
                            obscureText: !passwordVisible,
                            onChanged: (value) => setState(() => password = value),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, Schermate.recuperoPassword);
                            },
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Password dimenticata?',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 50,
                      child: Stack(
                        children: [
                          if (isLoading) const Center(child: CircularProgressIndicator()),
                          if (!isLoading)
                            ElevatedButton(
                              onPressed: () async {
                                setState(() => isLoading = true);

                                await viewModelUtente.login(email, password);
                                hasAttemptedLogin = true;
                                if (viewModelUtente.loginSuccessful) {
                                  if (viewModelUtente.firstLogin) {
                                    Navigator.pushReplacementNamed(context, Schermate.benvenuto);
                                  } else {
                                    await Future.delayed(const Duration(seconds: 2));
                                    Navigator.pushReplacementNamed(context, Schermate.ituoiProgetti);
                                  }
                                }

                                setState(() => isLoading = false);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: Red70,
                                minimumSize: const Size(200, 50),
                              ),
                              child: const Text('Accedi'),
                            )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Non hai un account? ',
                          style: TextStyle(color: Colors.black),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, Schermate.registrazione);
                          },
                          child: const Text(
                            'Registrati',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 90), // Questo spazio potrebbe essere ridotto se necessario
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
