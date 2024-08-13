import 'package:flutter/material.dart';
import 'package:teamsync_flutter/caratteristiche/login/viewModel/view_model_utente.dart';
import 'package:teamsync_flutter/navigation/schermate.dart';
import '../../../theme/color.dart';

class PasswordDimenticata extends StatefulWidget {
  final ViewModelUtente viewModelUtente;
  const PasswordDimenticata(this.viewModelUtente, {super.key});

  @override
  PasswordDimenticataState createState() => PasswordDimenticataState();
}

class PasswordDimenticataState extends State<PasswordDimenticata> {
  final TextEditingController emailRecuperoPasswordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth*0.1, vertical:  screenHeight*0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Password Dimenticata',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight*0.01),
                Text(
                  'Non preoccuparti, inserisci la tua email e ti invieremo un link per reimpostare la tua password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: screenHeight*0.03),
                TextField(
                  controller: emailRecuperoPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.mail),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Red70,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: screenHeight*0.03),
                SizedBox(
                  width: screenWidth*0.7,
                  height: screenHeight*0.07,
                  child: ElevatedButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final scaffoldmessenger = ScaffoldMessenger.of(context);
                      setState(() => isLoading = true);
                      await widget.viewModelUtente.resetPassword(
                        emailRecuperoPasswordController.text,
                      );
                      if (widget.viewModelUtente.resetPasswordRiuscito) {
                        widget.viewModelUtente.resetPasswordRiuscito = false;
                        navigator.pushReplacementNamed(
                          Schermate.login,);
                      }
                      if (widget.viewModelUtente.erroreResetPassword != null) {
                        var errore = widget.viewModelUtente.erroreResetPassword;
                        scaffoldmessenger.hideCurrentSnackBar();
                        scaffoldmessenger.showSnackBar(
                          SnackBar(content: Text(errore!),
                              duration: const Duration(seconds: 1),),
                        );
                      }
                      setState(() => isLoading = false);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Red70,
                      padding: const EdgeInsets.symmetric(horizontal: 70),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : const Text('Procedi'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
