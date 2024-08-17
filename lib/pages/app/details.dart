import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../data/data.dart';

class Details extends StatefulWidget {
  final int index;
  final int currentPoints;
  final Market market;

  const Details({
    required this.index,
    required this.market,
    required this.currentPoints,
  });

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  List<dynamic> _databaseActive = [];
  late List<dynamic> activePromotionId;
  bool isCouponDownloaded = false;
  bool isLoading = true;
  int points = 0;
  late int selectedMarketIndex = widget.index;


  @override
  void initState() {
    super.initState();
    activePromotionId = [widget.market.id];
    _getActivePromotions();
  }

  void _getActivePromotions() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _databaseActive = userDoc.data()?['activePromotion'] ?? [];
          points = userDoc.data()?['points'] ?? 0;
          if (_databaseActive.contains(widget.market.id)) {
            isCouponDownloaded = true;
          }
          isLoading = false;
        });
      }
    }
  }

  void _activePromotion() async {
    var newList = [..._databaseActive, ...activePromotionId];
    var newPoints = points - 20;
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'activePromotion': newList, 'points': newPoints,});
        setState(() {
          isCouponDownloaded = true;
        });
      } catch (e) {
        print("Failed to update promotion: $e");
      }
    }
  }

  void _cancelPromotion() async {
    final User? user = FirebaseAuth.instance.currentUser;
    var newList = List.from(_databaseActive);
    newList.remove(widget.market.id);
    var newPoints = points + 20;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'activePromotion': newList,'points': newPoints,});
        setState(() {
          isCouponDownloaded = false;
        });
      } catch (e) {
        print("Failed to update promotion: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? Center(child: LoadingAnimationWidget.halfTriangleDot(color: Color.fromARGB(255, 109, 121, 109), size: 50))
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    widget.market.name,
                    style: TextStyle(
                      fontSize: 40,
                      height: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        image: DecorationImage(
                          image: AssetImage(widget.market.imgPath),
                          fit: BoxFit.cover,
                        ),
                      ),
                      width: 150,
                      height: 150,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(80.0),
                    child: !widget.market.active ? Text('Trenutno ne postoji ni jedna akcija')
                    : Text(
                      '${widget.market.name} nudi ${widget.market.currentPromotion}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        !widget.market.active ? Colors.grey
                        :isCouponDownloaded ? Colors.red : Colors.green,
                      ),
                    ),
                    onPressed: !widget.market.active ? null : () {
                      if (points < 20 && isCouponDownloaded == false) {
                        _dialogBuilder(context);
                      } else {
                        setState(() {
                          if (isCouponDownloaded) {
                            _cancelPromotion();
                          } else {
                            _activePromotion();
                          }
                        });
                      }
                    },
                    child: Text(
                      isCouponDownloaded ? 'Otkaži kupon' : 'Preuzmi kupon',
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Greska prilikom preuzimanja'),
          content: const Text(
            'Potrebno je 20 poena kako biste preuzeli ovaj kupon.',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
