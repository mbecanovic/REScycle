import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'qr_scanner.dart';

class QRPage extends StatefulWidget {
  final int points;

  const QRPage({
    super.key,
    required this.points,
  });

  @override
  State<QRPage> createState() => _QRPageState();
}

List<dynamic> _databaseActive = [];
bool isLoading = true;
final markets = marketList;
int pointsToAdd = 0;

class _QRPageState extends State<QRPage> {
  @override
  void initState() {
    super.initState();
    fetchPromotions();
    pointsToAdd = widget.points;
  }

  Future<void> fetchPromotions() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _databaseActive = userDoc.data()?['activePromotion'] ?? [];
            isLoading = false;
          });
        }
      } catch (e) {
        // Handle error
      }
    }
  }

  String getActivePromotionNames() {
    List<String> activePromotionDetails = [];
    for (var id in _databaseActive) {
      final marketId = id.toString();
      final market = markets.firstWhere(
        (market) => market.id == marketId,
      );
      activePromotionDetails.add('${market.name}: ${market.currentPromotion}');
    }
    return activePromotionDetails.join('\n');
  }

  void _scanQRCode() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const QrScanner()),
  );
  if (result != null && result is int) {
    pointsToAdd = widget.points;
    // Handle the scanned result (result is an int, representing points added)
    print('Scanned QR code, points added: $pointsToAdd');
    // Show Snackbar on successful points transfer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Uspešno skeniranje, proveri poene na nalog stranici',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }
}



  
  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        Center(
          child: isLoading
              ? LoadingAnimationWidget.halfTriangleDot(
                  color: Color.fromARGB(255, 109, 121, 109),
                  size: 50,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Proveravamo da li postoji aktivan kupon
                    _databaseActive.isEmpty
                        ? Text(
                            'Ni jedan kupon nije aktiviran.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 109, 121, 109),
                            ),
                          )
                        : Column(
                            children: [
                              // Tekst iznad QR koda
                              Text(
                                'Pokaži QR kod u radnji',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 109, 121, 109),
                                ),
                              ),
                              SizedBox(height: 80), // Razmak između teksta i QR koda
                              // QR kod
                              GestureDetector(
                                child: QrImageView(
                                  data: getActivePromotionNames(),
                                  version: QrVersions.auto,
                                  size: 250.0,
                                  /*embeddedImage: AssetImage('lib/data/icons/logo.png'), 
                                  embeddedImageStyle: QrEmbeddedImageStyle(),*/
                                ),
                              ),
                              SizedBox(height: 80), // Razmak između QR koda i teksta
                              // Tekst ispod QR koda
                              
                            ],
                          ),
                  ],
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _scanQRCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Color.fromARGB(255, 109, 121, 109), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Skeniraj QR kod na kanti',
                  style: TextStyle(
                    color: Color.fromARGB(255, 109, 121, 109),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

}
