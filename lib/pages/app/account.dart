import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../data/data.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  String? name;
  String? email;
  int? points;
  bool isLoading = true;
  String errorMessage = '';
  List yourList = [1, 3, 4, 4];
  List<dynamic> _databaseActive = [];
  final markets = marketList;
  int currentPoints = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    currentPoints == points;
  }

  Future<void> _fetchUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            name = userDoc.data()?['name'];
            email = userDoc.data()?['email'];
            points = userDoc.data()?['points'];
            _databaseActive = userDoc.data()?['activePromotion'] ?? [];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'User data not found.';
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Error fetching user data: $e';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        errorMessage = 'No user currently logged in.';
        isLoading = false;
      });
    }
  }

  Future<void> _cancelPromotion(String marketId) async {
    var newList = List<String>.from(_databaseActive);
    newList.remove(marketId);
    var newPoints = (points ?? 0) + 20;
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'activePromotion': newList,
          'points': newPoints,
        });
        setState(() {
          _fetchUserData();
        });
      } catch (e) {
        print("Failed to update promotion: $e");
      }
    }
  }




  void _editName() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final newName = await showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController(text: name);
          return AlertDialog(
            title: Text('Edit Name'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: 'Enter new name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(controller.text),
                child: Text('Save'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );

      if (newName != null && newName.isNotEmpty) {
        try {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'name': newName});
          setState(() {
            name = newName;
          });
        } catch (e) {
          print('Error updating name: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nalog'),
      ),
      body: isLoading
          ? Center(
              child: LoadingAnimationWidget.halfTriangleDot(
                color: Color.fromARGB(255, 109, 121, 109),
                size: 50,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: const Text('Ime i prezime'),
                      subtitle: Text(name ?? 'No name'),
                      leading: Icon(Icons.person),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _editName,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: const Text('Email'),
                      subtitle: Text(email ?? 'No email'),
                      leading: Icon(Icons.email),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: const Text('Ostvareni poeni'),
                      subtitle: Text(points?.toString() ?? 'No points'),
                      leading: Icon(Icons.star),
                    ),
                  ),
                  SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Aktivirani kuponi',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _databaseActive.isEmpty
                        ? Center(child: Text('Nemate aktiviranih kupona'))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _databaseActive.length,
                            itemBuilder: (context, index) {
                              final marketIndex = int.tryParse(_databaseActive[index].toString()) ?? -1;
                              final market = markets[marketIndex - 1];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
                                elevation: 3,
                                child: Container(
                                  width: 200,
                                  height: 300,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(height: 20),
                                      Image.asset(market.imgPath, width: 50, height: 50),
                                      SizedBox(height: 20),
                                      Text(market.name, style: TextStyle(fontWeight: FontWeight.bold)),
                                      SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(child: Text(market.currentPromotion)),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[400],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                        ),
                                        onPressed: () => _cancelPromotion(market.id),
                                        child: Text('Otkaži', style: TextStyle(color: Colors.black),),
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
