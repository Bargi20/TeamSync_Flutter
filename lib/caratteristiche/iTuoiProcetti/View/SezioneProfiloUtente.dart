import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:teamsync_flutter/navigation/schermate.dart';
import 'package:teamsync_flutter/caratteristiche/login/Model/UserClass.dart';
import 'package:teamsync_flutter/caratteristiche/login/viewModel/ViewModelUtente.dart';

class SezioneProfiloUtente extends StatelessWidget {

  SezioneProfiloUtente();

  @override
  Widget build(BuildContext context) {
    final viewModelUtente = Provider.of<ViewModelUtente>(context);
    final ProfiloUtente? userProfile = viewModelUtente.utenteCorrente;

    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color:  Colors.red[700],
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(Schermate.profilo);
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (userProfile == null)
                      Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[50]!),
                          backgroundColor: Colors.red[700],
                        ),
                      )
                    else ...[
                      Text(
                        'Ciao',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        '${userProfile.nome}!', // Assicurati che userProfile sia di tipo ProfiloUtente
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (userProfile != null)
                CircleAvatar(
                  radius: 45,
                  backgroundImage: userProfile.immagine != null
                      ? CachedNetworkImageProvider(userProfile.immagine!)
                      : AssetImage("assets/logo_teamsync.png") as ImageProvider,
                ),

            ],
          ),
        ),
      ),
    );
  }
}
