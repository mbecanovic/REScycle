import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';

// Funkcija za učitavanje slike iz assets i konvertovanje u BitmapDescriptor
Future<BitmapDescriptor> createMarkerIcon() async {
  final ByteData byteData = await rootBundle.load('lib/data/icons/bin.png');
  final Uint8List imageBytes = byteData.buffer.asUint8List();
  return BitmapDescriptor.bytes(imageBytes);
}


Future<List<Marker>> createMarkers() async {
  final BitmapDescriptor icon = await createMarkerIcon();

  return [
    Marker(
      markerId: const MarkerId('Marker1'),
      position: const LatLng(44.01826, 20.90607),
      infoWindow: const InfoWindow(title: 'Kanta1', snippet: 'Veliki Park'),
      icon: icon,
      anchor: const Offset(0.5, 0.5),
    ),
    Marker(
      markerId: const MarkerId('Marker2'),
      position: const LatLng(44.011321, 20.916658),
      infoWindow: const InfoWindow(title: 'Kanta2', snippet: 'Radomir'),
      icon: icon,
      anchor: const Offset(0.5, 0.5),
    ),
    Marker(
      markerId: const MarkerId('Marker3'),
      position: const LatLng(44.005556, 20.889166),
      infoWindow: const InfoWindow(title: 'Kanta3', snippet: 'Bagremar, Centralna Radionica'),
      icon: icon,
      anchor: const Offset(0.5, 0.5),
    ),
     Marker(
      markerId: const MarkerId('Marker4'),
      position: const LatLng(44.030208, 20.874491),
      infoWindow: const InfoWindow(title: 'Kanta4', snippet: 'Sumaricko jezero'),
      icon: icon,
      anchor: const Offset(0.5, 0.5),
    ),
    Marker(
      markerId: const MarkerId('Marker5'),
      position: const LatLng(44.016490, 20.884795),
      infoWindow: const InfoWindow(title: 'Kanta5', snippet: 'Spomenik Sumarice'),
      icon: icon,
      anchor: const Offset(0.5, 0.5),
    ),
  ];
}
