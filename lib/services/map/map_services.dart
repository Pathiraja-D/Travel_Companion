import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MapServices {
  String convertedAddress = "";
  String coordinatesFromAddress = "";

  //conversion of coordinates to address
  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0];
    convertedAddress =
        "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    return convertedAddress;
  }

  Future<String> getCityFromCoordinates(
      double latitude, double longitude) async {
    String cityName = "";
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0];
    cityName = "${place.administrativeArea}";
    
    return cityName;
  }

  //conversion of address to coordinates
  Future<List<Location>> getCoordinatesFromAddress(String address) async {
    List<Location> locations = await locationFromAddress(address);
    coordinatesFromAddress = locations.toString();
    return locations;
  }

  //get user access to allow location
  Future<Position> getUserLocationAccess() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print('error $error');
    });

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
