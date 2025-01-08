import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meteo_fabien/models/weather.dart';

class WeatherService{
  String baseURL = "https://api.openweathermap.org/data/2.5/";
  String apiKey = "959d1296a89c3365a20b001a440c4eb3";

  Future<Weather?> getCurrentWeather({required double latitude, required double longitude}) async{

    String completeUrl = "${baseURL}weather?units=metric&lat=${latitude}&lon=${longitude}&appid=${apiKey}";
    final response = await http.get(
        Uri.parse(completeUrl),
        headers: {
          'Content-Type':'application/json'
        }
    );

    if(response.statusCode == 200){
      Map<String,dynamic> json = jsonDecode(response.body);
      return Weather.fromJson(json);
    }
    return null;
  }

}
