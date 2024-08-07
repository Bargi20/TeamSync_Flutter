import 'package:flutter/material.dart';
import 'package:teamsync_flutter/caratteristiche/login/viewModel/ViewModelUtente.dart';

import 'package:teamsync_flutter/navigation/Schermate.dart';
import '../../../theme/color.dart';
import '../Model/UserClass.dart';
import 'package:intl/intl.dart';



class Registrazione extends StatefulWidget {

  ViewModelUtente viewModelUtente;
  Registrazione(this.viewModelUtente);

  @override
  _RegistrazioneState createState() => _RegistrazioneState();
}

class _RegistrazioneState extends State<Registrazione> {

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
  String? erroreRegistrazione;
  bool registrazioneRiuscita = false;
  bool expanded = false;


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
    return Scaffold(
      body: Stack(
        children: [
            const Image(
              image: AssetImage('assets/registrazione.png'),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child:  Column(
            children: [
              SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Image.asset('assets/icon.png', width: 70, height: 70),
                ],
              ),
              SizedBox(height: 50),
              const Text(
                "Iscriviti",
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 30),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        SizedBox(height: 10),
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

                        SizedBox(height: 10),
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
                            const SizedBox(width: 8),
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
                        SizedBox(height: 10),
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
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildDropdownField(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
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
                        SizedBox(height: 10),
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
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:   () async {
                    await widget.viewModelUtente.signUp(matricola, nome, cognome, email, dataDiNascita, sesso, password, confermaPassword);
                    if (widget.viewModelUtente.registrazioneRiuscita) {
                      widget.viewModelUtente.registrazioneRiuscita = false;
                     Navigator.pushReplacementNamed(context, Schermate.verificaEmail);
                    } else {
                    if (widget.viewModelUtente.erroreRegistrazione != null) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();

                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(widget.viewModelUtente.erroreRegistrazione!),
                            duration: Duration(seconds: 1), // Durata del SnackBar
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
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text("Next"),
                  ),
                ],
              ),
              SizedBox(height: 30),
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
