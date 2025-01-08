
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meteo_fabien/models/city.dart';

class GeoCoderService{
  Timer? _debounce;


  //Fonction qui retourne la ville par rapport à des coordonnées GPS
  static Future<String> getCityFromCoordinates({required double latitude, required double longitude}) async{
      String url = "https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&accept-language=fr";
      final http.Response resp = await http.get(
        Uri.parse(url)
      );

      if(resp.statusCode == 200){
        Map<String,dynamic> json = jsonDecode(resp.body);
        String? ville;
        if(json["address"]["town"] != null){
          ville = json["address"]["town"];
        }else if(json["address"]["city"] != null){
          ville = json["address"]["city"];
        }else{
          ville = json["address"]["village"];
        }
        return ville!;
      }else{
        throw Exception("API OpenStreetMap error");
      }
  }

  /// Nouvelle méthode à appeler pour chaque appui de touche
  void onQueryChanged(String query, Function(List<City>) onResult) {
    const int debounceDuration = 2; // Temporisation de 2 secondes

    // Annulez le timer précédent si une nouvelle touche est pressée
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Lancez un nouveau timer
    _debounce = Timer(Duration(seconds: debounceDuration), () async {
      if (query.isNotEmpty) {
        try {
          // Appeler l'API après la temporisation
          final List<City> cities = await searchCity(query);
          onResult(cities); // Retourne les résultats à la vue
        } catch (e) {
          print("Erreur lors de l'appel API : $e");
        }
      }
    });
  }


  static Future<List<City>> searchCity(String query) async {
    String url = "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&accept-language=fr";
    final http.Response resp = await http.get(
        Uri.parse(url)
    );

    if (resp.statusCode == 200) {
      List<dynamic> json = jsonDecode(resp.body);
      /* Je veux renvoyer à la vue une list de map :
      [
        {name: Lyon, latitude: 414564, longitude: 456464, display_name: Lyo Métropole},
        {name: Lyon, latitude: 414564, longitude: 456464, display_name: Lyo Métropole},
      ]
       */
      return json.map((mapCity){
        return City(
          name: mapCity["name"],
          latitude: double.parse(mapCity["lat"]),
          longitude: double.parse(mapCity["lon"]),
          display_name: mapCity["display_name"]
        );
      }).toList();

    }else{
      throw Exception("API OpenStreetMap error");
    }
  }

}