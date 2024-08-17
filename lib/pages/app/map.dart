import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../data/bins.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  Set<Marker> markers = {};
  late GoogleMapController mapController;
  loc.LocationData? currentLocation;
  final LatLng custom = const LatLng(44.014167, 20.911667);

  @override
  void initState() {
    super.initState();
    _getLocation();
    _loadMarkers();
    createBins();
  }

   //final Set<Marker> _markers = createMarkers(binList);

  Future<void> _getLocation() async {
    try {
      loc.Location location = loc.Location();
      loc.LocationData locationData = await location.getLocation();
      setState(() {
        currentLocation = locationData;
      });
    } catch (e) {//
    }
  }

  Future<void> _loadMarkers() async {
    final List<Marker> markerList = await createMarkers();
    setState(() {
      markers.addAll(markerList.toSet());
    });
  }

  Map<String, dynamic> markerToMap(Marker marker) {
  return {
    'markerId': marker.markerId.value,
    'latitude': marker.position.latitude,
    'longitude': marker.position.longitude,
    'title': marker.infoWindow.title,
    'snippet': marker.infoWindow.snippet,
    'increment': 0,
  };
}
Future<bool> markerExists(String markerId) async {
  final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('bins')
      .where('markerId', isEqualTo: markerId)
      .limit(1)
      .get();

  return querySnapshot.docs.isNotEmpty;
}
  Future<void> createBins() async {
    final List<Marker> markers = await createMarkers();
    //final List<Map<String, dynamic>> markerMaps = markers.map(markerToMap).toList();

    for (Marker marker in markers) {
    final markerId = marker.markerId.value;
    final markerData = markerToMap(marker);
    
    await FirebaseFirestore.instance.collection('bins').doc(markerId).set(markerData, SetOptions(merge: true),);
    
  }
  }

  

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation == null
          ?  Center(child: LoadingAnimationWidget.halfTriangleDot(color: const Color.fromARGB(255, 109, 121, 109), size: 50))
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                        currentLocation!.latitude!, currentLocation!.longitude!),
                    zoom: 15.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: markers,
                  /*markers: {
                    Marker(
                      markerId: const MarkerId("custom"),
                      position: custom,
                    ),
                  },*/
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(26.0),
                    child: FloatingActionButton(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      onPressed: _getLocation,
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

Future<BitmapDescriptor> createMarkerIcon() async {
  return BitmapDescriptor.asset(
    const ImageConfiguration(size: Size(48, 48)),
    'assets/data/icons/bin.png',
  );
}
