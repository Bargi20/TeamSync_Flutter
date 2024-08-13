import 'package:flutter/material.dart';
import 'package:teamsync_flutter/caratteristiche/login/viewModel/view_model_utente.dart';
import 'package:teamsync_flutter/navigation/Schermate.dart';
import '../../../theme/color.dart';
import '../Model/user_class.dart';
import 'package:intl/intl.dart';



class Registrazione extends StatefulWidget {

  final ViewModelUtente viewModelUtente;
  const Registrazione(this.viewModelUtente, {super.key});

  @override
  RegistrazioneState createState() => RegistrazioneState();
}

class RegistrazioneState extends State<Registrazione> {

  String matricola = "";
  String email = "";
  String nome = "";
  String cognome = "";
  String password = "";
  String confermaPassword = "";
  DateTime dataDiNascita = DateTime.now();
  SessoUtente sesso = SessoUtente.UOMO;
  bool passwordVisibile = false;
  bool confermaPasswordVisibile = false;


  @override
  void initState() {
    super.initState();
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: dataDiNascita,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        setState(() {
          dataDiNascita = date;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
            const Image(
              image: AssetImage('assets/registrazione.png'),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          SingleChildScrollView(
            child:Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child:  Column(
                  children: [
                    SizedBox(height: screenHeight*0.06),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Image.asset('assets/icon.png', width: 70, height: 70),
                      ],
                    ),
                    SizedBox(height: screenHeight*0.05),
                    const Text(
                      "Iscriviti",
                      style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: screenHeight*0.03),
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth*0.05),
                          child: Column(
                            children: [
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Matricola',
                                  prefixIcon: Icon(Icons.badge),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                                onChanged: (value) => setState(() => matricola = value),
                              ),
                              SizedBox(height: screenHeight*0.01),
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.mail),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) => setState(() => email = value),
                              ),
                              SizedBox(height: screenHeight*0.01),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        labelText: 'Nome',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                        ),
                                      ),
                                      onChanged: (value) => setState(() => nome = value),
                                    ),
                                  ),
                                  SizedBox(width: screenWidth*0.01),
                                  Expanded(
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        labelText: 'Cognome',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                        ),
                                      ),
                                      onChanged: (value) => setState(() => cognome = value),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight*0.01),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Data di Nascita',
                                        border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.calendar_today),
                                          onPressed: _showDatePicker,
                                        ),
                                      ),
                                      readOnly: true,
                                      controller: TextEditingController(text: DateFormat('dd/MM/yyyy').format(dataDiNascita)),
                                    ),
                                  ),
                                  SizedBox(width: screenWidth*0.01),
                                  Expanded(
                                    child: _buildDropdownField(),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight*0.01),
                              TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(passwordVisibile ? Icons.visibility : Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {
                                          passwordVisibile = !passwordVisibile;
                                        });
                                      },
                                    ),
                                  ),
                                obscureText: !passwordVisibile,
                                onChanged: (value) => setState(() => password = value),
                              ),
                              SizedBox(height: screenHeight*0.01),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Conferma Password',
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(confermaPasswordVisibile ? Icons.visibility : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        confermaPasswordVisibile = !confermaPasswordVisibile;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: !confermaPasswordVisibile,
                                onChanged: (value) => setState(() => confermaPassword = value),
                              ),
                            ],
                          ),
                        ),


                        SizedBox(height: screenHeight*0.02),
                        ElevatedButton(
                          onPressed:   () async {
                            final navigator = Navigator.of(context);
                            final scaffoldMessanger = ScaffoldMessenger.of(context);
                            await widget.viewModelUtente.signUp(matricola, nome, cognome, email, dataDiNascita, sesso, password, confermaPassword);
                            if (widget.viewModelUtente.registrazioneRiuscita) {
                              widget.viewModelUtente.registrazioneRiuscita = false;
                              navigator.pushReplacementNamed(Schermate.verificaEmail);
                            }
                            else {
                              if (widget.viewModelUtente.erroreRegistrazione != null) {
                                scaffoldMessanger.hideCurrentSnackBar();

                            scaffoldMessanger.showSnackBar(
                              SnackBar(
                                  content: Text(widget.viewModelUtente.erroreRegistrazione!),
                                  duration: const Duration(seconds: 1),
                                  action: SnackBarAction(
                                    label: 'Chiudi',
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    },
                                  )
                              ),
                          );
                          }
                          }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Red70,
                            padding:  EdgeInsets.symmetric(vertical: screenHeight*0.02, horizontal: screenWidth*0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text("Next"),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight*0.03),
                    Column(
                      children: [
                        const Text(
                          "Hai già un account?",
                          style: TextStyle(color: Colors.black),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, Schermate.login);
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(color:  Red70, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<SessoUtente>(
      value: sesso,
      onChanged: (value) {
        setState(() {
          sesso = value!;
        });
      },
      decoration: InputDecoration(
        labelText: "Sesso",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      items: SessoUtente.values.map((s) {
        return DropdownMenuItem(
          value: s,
          child: Text(s.toString().split('.').last),
        );
      }).toList(),
    );
  }
}
