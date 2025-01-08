import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:meteo_fabien/models/device_info.dart';
import 'package:meteo_fabien/pages/home_page.dart';
import 'package:meteo_fabien/services/geocoder_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }

  _locationData = await location.getLocation();
  DeviceInfo.longitude = _locationData.longitude;
  DeviceInfo.latitude = _locationData.latitude;
  print("Position = ${DeviceInfo.latitude},${DeviceInfo.longitude}");
  DeviceInfo.ville = await GeoCoderService.getCityFromCoordinates(latitude:DeviceInfo.latitude!, longitude:DeviceInfo.longitude!  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
