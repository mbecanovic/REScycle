import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rescycling/pages/app/qr_page.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  List<dynamic> markerIds = []; // Changed to List<String> for clarity
  List<dynamic> increment = [];
  int pointsToAddPublic = 0;
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    super.initState();
    loadBins();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  } 

  @override
  void reassemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR skener'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          buildQRView(context),
          Positioned(child: buildResult(), bottom: 10,)
        ],
      ),
    );
  }

  Widget buildResult() {
    if (result != null && markerIds.contains(result!.code)) {
      return Text(
        'Uspesan: ${result!.code}',
        maxLines: 3,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
        ),
      );
    }
    return Container(); // Return an empty container if no match
  }

  Widget buildQRView(BuildContext context) => QRView(
    key: qrKey,
    onQRViewCreated: onQRViewCreated,
    overlay: QrScannerOverlayShape(
      cutOutSize: MediaQuery.of(context).size.width * 0.8,
      borderWidth: 10,
      borderLength: 20,
      borderRadius: 20,
      borderColor: Color.fromARGB(255, 109, 121, 109)),
  );

  void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((result) {
      if (!mounted) return;
      setState(() {
        this.result = result;
      });
      print('Scanned result: ${result.code}');
      if (markerIds.contains(result.code)) {
        addPoints();
        print('Prebaceni poeni: $pointsToAdd');
        controller.pauseCamera();
        Navigator.pop(context, pointsToAddPublic); 
      }
    });
  }

  Future<void> loadBins() async {
    final bins = await FirebaseFirestore.instance.collection('bins').get();
    setState(() {
      markerIds.clear(); // Clear the list to avoid duplication
      increment.clear();
      for (var bin in bins.docs) {
        var data = bin.data();

        // Handle markerId
        var markerIdData = data['markerId'];
        if (markerIdData is List) {
          markerIds.addAll(
            (markerIdData as List<dynamic>).map((e) => e.toString()).toList()
          );
        } else if (markerIdData is String) {
          markerIds.add(markerIdData); // Add single string value
        } else {
          print("Expected markerId to be a List or String but got: $markerIdData");
        }

        // Handle increment
        var incrementData = data['increment'];
        if (incrementData is List) {
          increment.addAll(incrementData as List<dynamic>);
        } else if (incrementData is int) {
          increment.add(incrementData);
        } else {
          print("Expected increment to be a List or int but got: $incrementData");
        }

        print(markerIds);
      }
    });
  }

void addPoints() async {
  final User? user = FirebaseAuth.instance.currentUser;

  // Check if user is authenticated
  if (user == null) {
    print('No user is logged in.');
    return;
  }

  // Check if result is not null
  if (result == null) {
    print('No result to add points for.');
    return;
  }

  // Find the index of the scanned markerId
  int index = markerIds.indexOf(result!.code);

  // Check if the markerId exists in the list
  if (index == -1) {
    print('Scanned markerId not found in markerIds list.');
    return;
  }

  // Get the corresponding increment value
  int pointsToAdd = increment[index];

  try {
    // Reference to the user document
    DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    DocumentReference binDoc = FirebaseFirestore.instance.collection('bins').doc(result!.code);

    WriteBatch batch = FirebaseFirestore.instance.batch();

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Read operations
      DocumentSnapshot userSnapshot = await transaction.get(userDoc);
      DocumentSnapshot binSnapshot = await transaction.get(binDoc);

      if (!userSnapshot.exists) {
        print('User does not exist.');
        return;
      }

      if (!binSnapshot.exists) {
        print('Bin document not found for markerId: ${result!.code}');
        return;
      }

      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      int currentPoints = userData['points'] ?? 0;
      int updatedPoints = currentPoints + pointsToAdd;
      pointsToAddPublic = pointsToAdd;

      // Perform all writes
      batch.update(userDoc, {'points': updatedPoints});
      batch.update(binDoc, {'increment': 0});
    });

    // Commit the batch write outside the transaction
    await batch.commit();

    /*if(mounted){
      setState(() {
        pointsToAddPublic = pointsToAdd;
      });
    }*/
    

    print('Points updated successfully. Points added: $pointsToAddPublic');
    
  } catch (e) {
    print('Error updating points: $e');
  }
}


}