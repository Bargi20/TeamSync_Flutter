import 'package:flutter/material.dart';
import 'package:teamsync_flutter/caratteristiche/login/viewModel/ViewModelUtente.dart';
import 'package:teamsync_flutter/navigation/schermate.dart';
import '../../../theme/color.dart';

class PasswordDimenticata extends StatefulWidget {
  final ViewModelUtente viewModelUtente;

  PasswordDimenticata(this.viewModelUtente);

  @override
  _PasswordDimenticataState createState() => _PasswordDimenticataState();
}

class _PasswordDimenticataState extends State<PasswordDimenticata> {
  final TextEditingController emailRecuperoPasswordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(30.0),
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
                const SizedBox(height: 16),
                Text(
                  'Non preoccuparti, inserisci la tua email e ti invieremo un link per reimpostare la tua password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 25),
                SizedBox(
                  width: 250,
                  height: 50, // Dimensione minima di altezza per il pulsante
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() => isLoading = true);
                      await widget.viewModelUtente.resetPassword(
                        emailRecuperoPasswordController.text,
                      );
                      if (widget.viewModelUtente.resetPasswordRiuscito) {
                        widget.viewModelUtente.resetPasswordRiuscito = false;
                        Navigator.pushReplacementNamed(
                          context, Schermate.login,
                        );
                      }
                      if (widget.viewModelUtente.erroreResetPassword != null) {
                        var errore = widget.viewModelUtente.erroreResetPassword;
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errore!),
                              duration: Duration(seconds: 1),),
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
