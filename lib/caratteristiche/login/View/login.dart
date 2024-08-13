import 'package:flutter/material.dart';
import '../../../navigation/schermate.dart';
import '../../../theme/color.dart';
import 'package:teamsync_flutter/caratteristiche/login/viewModel/view_model_utente.dart';


class LoginScreen extends StatefulWidget {

  final ViewModelUtente viewmodelutente;

  const LoginScreen({super.key, required this.viewmodelutente});
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';
  bool passwordVisible = false;
  bool isLoading = false;
  bool hasAttemptedLogin = false;

  @override
  Widget build(BuildContext context) {
    var viewModelUtente = widget.viewmodelutente;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double horizontalPaddingText = screenWidth * 0.15;

    if (hasAttemptedLogin && viewModelUtente.erroreLogin != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModelUtente.erroreLogin!),
            duration: const Duration(seconds: 1),
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
      body: Stack(
        children: [
          const Image(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPaddingText),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: (screenHeight*0.05)),
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
                     SizedBox(height: (screenHeight*0.06)),
                    Image.asset(
                      "assets/user_icon.png",
                      width: 150,
                      height: 150,
                    ),
                    SizedBox(height: (screenHeight*0.02)),
                    const Text(
                      'Accedi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: (screenHeight*0.02)),
                    Column(
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) => setState(() => email = value),
                          ),
                          SizedBox(height: (screenHeight*0.01)),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => passwordVisible = !passwordVisible),
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                            ),
                            obscureText: !passwordVisible,
                            onChanged: (value) => setState(() => password = value),
                          ),
                          SizedBox(height: (screenHeight*0.02)),
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

                    SizedBox(height: (screenHeight*0.03)),
                    SizedBox(
                      height: (screenHeight*0.06),
                      child: Stack(
                        children: [
                          if (isLoading) const Center(child: CircularProgressIndicator()),
                          if (!isLoading)
                            ElevatedButton(
                              onPressed: () async {
                                setState(() => isLoading = true);
                                final navigator = Navigator.of(context);
                                await viewModelUtente.login(email, password);
                                hasAttemptedLogin = true;
                                if (viewModelUtente.loginSuccessful) {
                                  if (viewModelUtente.firstLogin) {
                                    navigator.pushReplacementNamed(Schermate.benvenuto);
                                  } else {
                                    navigator.pushReplacementNamed(Schermate.ituoiProgetti);
                                  }
                                }
                                setState(() => isLoading = false);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: Red70,
                                minimumSize:  Size((screenWidth*0.5),(screenHeight*0.2)),
                                maximumSize: Size((screenWidth*0.5),(screenHeight*0.2))
                              ),
                              child: const Text('Accedi'),
                            )
                        ],
                      ),
                    ),
                    SizedBox(height: (screenHeight*0.02)),
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
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
