import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:meteo_fabien/models/city.dart';
import 'package:meteo_fabien/models/device_info.dart';
import 'package:meteo_fabien/models/weather.dart';
import 'package:meteo_fabien/services/geocoder_service.dart';
import 'package:meteo_fabien/services/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<City> villes = [];
  Weather? weather;
  City? villeChoisie;
  City maPosition = City(
    name: DeviceInfo.ville!,
    latitude: DeviceInfo.latitude!,
    longitude: DeviceInfo.longitude!,
  );



  @override
  void initState() {
    getVilles();
    super.initState();
    getMeteo(maPosition);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Météo"),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.blue,
          child: Column(
            children: [
              DrawerHeader(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Villes", style: TextStyle(fontSize:  30, color: Colors.white),),
                      ElevatedButton(
                        onPressed: ajoutVille,
                        child: Text(
                          "Ajouter une ville",
                          style: TextStyle(color: Colors.blue),
                        ),
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white)),
                      ),
                    ],
                  )
              ),

              ListTile(
                onTap: (){
                  getMeteo(maPosition);
                  Navigator.pop(context);

                },
                title: Text(DeviceInfo.ville ?? "Position Inconnue", style: TextStyle(color: Colors.white),textAlign: TextAlign.center,),

              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: villes.length,
                      itemBuilder: (BuildContext context, int index) {
                        City ville = villes[index];
                        return ListTile(
                          trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.white,),
                              onPressed: (){
                                deleteVille(ville.name);
                              }
                          ),
                          onTap: (){
                            getMeteo(ville);
                            Navigator.pop(context);

                          },
                          title: Text(ville.name, style: TextStyle(color: Colors.white),textAlign: TextAlign.center,),
                        );
                      })),
            ],
          ),
        ),
      ),
    body: (weather == null)
      ? Center(
      child: Text('Pas de météo dispo'),
    )
      
      :Container(
      width: size.width ,
      height: size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(weather!.backgroundPicture()),
          fit: BoxFit.cover
            )
        ),
      ),
    );
  }

  Future<void> getVilles() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonVilles = prefs.getString("villes");
    if(jsonVilles != null){
      List<dynamic> jsonList = jsonDecode(jsonVilles);
      List<City> v = [];
      jsonList.forEach((jsonVille){
        City ville = City.fromMap(jsonVille);
        v.add(ville);
      });
      setState(() {
        villes = v;
      });
    }
  }

  Future<void> addVille(String nom, double latitude, double longitude) async{
    // La ville existe-t-elle déjà ?
    bool existVille = villes.any((ville) => ville.name == nom);
    if(existVille){
      return;
    }

    City villeNouvelle = City(
        name: nom,
        latitude: latitude,
        longitude: longitude
    );

    villes.add(villeNouvelle);
    List<dynamic> v = [];
    villes.forEach((ville){
      v.add(ville.toMap());
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("villes", jsonEncode(v));
    await getVilles();
  }

  Future<void> deleteVille(String nom) async{
    int indexVille = villes.indexWhere((ville) => ville.name == nom);
    if(indexVille != -1){
      villes.removeAt(indexVille);

      List<dynamic> v = [];
      villes.forEach((ville){
        v.add(ville.toMap());
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("villes", jsonEncode(v));
      await getVilles();
    }
  }

  Future<void> ajoutVille() {
    City? villeSaisie;

    return showDialog(
        context: context,
        builder: (BuildContext contextDialog) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(20),
            title: Text("Ajoutez une ville"),
            children: [
              TypeAheadField<City>(
                builder: (context, controller, focusNode) {
                  return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Saisir une ville',
                      )
                  );
                },
                suggestionsCallback: (pattern) async{
                  if(pattern.isNotEmpty){
                    return await GeoCoderService.searchCity(pattern);
                  }else{
                    return [];
                  }
                },
                itemBuilder: (context, citySuggestion) {
                  return ListTile(
                    title: Text(citySuggestion.display_name ?? "no display name"),
                  );
                },
                onSelected: (citySelected) {
                  villeSaisie = citySelected;
                  print(citySelected.toString());
                },
              ),
              ElevatedButton(
                  onPressed: () {
                    if(villeSaisie != null){

                      addVille(villeSaisie!.name,villeSaisie!.latitude,villeSaisie!.longitude);
                      Navigator.pop(contextDialog);
                    }
                  },
                  child: Text("Valider")),
            ],
          );
        });
  }

  Future<void> getMeteo(City ville) async{
    WeatherService weatherService = WeatherService();
    Weather? w = await weatherService.getCurrentWeather(latitude: ville.latitude, longitude: ville.longitude);
    print(w);
    if(w != null){
      setState(() {
        weather = w;
        villeChoisie = ville;
      });
    }
  }




}
