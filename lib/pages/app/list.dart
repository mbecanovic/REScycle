import 'package:flutter/material.dart';
import 'package:rescycling/pages/app/details.dart';
import 'package:rescycling/pages/app/more.dart';
import '../../data/data.dart'; // Make sure marketList is correctly defined here
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListPage extends StatefulWidget {
  final bool iconPressed;
  final int currentPoints;
  const ListPage({required this.iconPressed, required this.currentPoints, Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListState();
}

class _ListState extends State<ListPage> {
  final List<Market> markets = marketList;
  int listUpdate = 2;
  List<String> _databaseActive = [];
  int points = 0;
  bool isLoading = true;
  Map<String, bool> _couponDownloadedMap = {};
  String _searchQuery = '';
  List<dynamic> dscList = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      dscList = markets.map((market) => market.description).toSet().toList();
    });
    _getActivePromotions();
  }

  Future<void> _refresh() async {
    await _getActivePromotions();
  }

  void updateList() {
    setState(() {
      listUpdate = widget.iconPressed ? 3 : 2;
    });
  }

  Future<void> _getActivePromotions() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _databaseActive = List<String>.from(userDoc.data()?['activePromotion'] ?? []);
          points = userDoc.data()?['points'] ?? 0;

          // Initialize coupon download status map
          _couponDownloadedMap = {for (var id in _databaseActive) id: true};
          for (var market in markets) {
            if (!_couponDownloadedMap.containsKey(market.id)) {
              _couponDownloadedMap[market.id] = false;
            }
          }

          isLoading = false;
        });
      }
    }
  }

  Future<void> _activePromotion(String marketId) async {
    var newList = [..._databaseActive, marketId];
    var newPoints = points - 20;
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'activePromotion': newList,
          'points': newPoints,
        });
        setState(() {
          _couponDownloadedMap[marketId] = true;
          _getActivePromotions();
        });
      } catch (e) {
        print("Failed to update promotion: $e");
      }
    }
  }

  Future<void> _cancelPromotion(String marketId) async {
    var newList = List<String>.from(_databaseActive);
    newList.remove(marketId);
    var newPoints = points + 20;
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'activePromotion': newList,
          'points': newPoints,
        });
        setState(() {
          _couponDownloadedMap[marketId] = false;
          _getActivePromotions();
        });
      } catch (e) {
        print("Failed to update promotion: $e");
      }
    }
  }

  @override
  void didUpdateWidget(covariant ListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.iconPressed != oldWidget.iconPressed) {
      updateList();
    }
  }

  void _filterMarkets(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            // Styled TabBar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0), // Add horizontal padding
              decoration: BoxDecoration(
                color: Colors.transparent, // Transparent background
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TabBar(
                  onTap: (index) {
                    // Handle tab change if needed
                  },
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 3.0))
                  ),
                  labelColor: Colors.black, // Color of the selected tab text
                  unselectedLabelColor: Colors.black38, // Color of the unselected tab text
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w800, // Slightly lighter bold
                    fontSize: 16,
                  ),
                  tabs: [
                    Tab(text: 'Kategorije'),
                    Tab(text: 'Promocije'),
                    Tab(text: 'Partneri'),
                  ],
                ),
              ),
            ),
            
            Expanded(
              child: TabBarView(
                children: [
                  _buildFirstPage(),
                  RefreshIndicator(
                    onRefresh: _refresh,
                    child: _buildListView(true),
                  ),
                  _buildGridView(), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(bool isActive) {
    final filteredMarkets = markets.where((market) => market.active == isActive).toList();

    return ListView.builder(
      itemCount: filteredMarkets.length,
      itemBuilder: (context, index) {
        final market = filteredMarkets[index];
        return Card(
          color: Colors.grey[350],
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 2,
          child: ListTile(
            contentPadding: EdgeInsets.all(8.0),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(market.imgPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(market.name, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(market.currentPromotion),
            trailing: SizedBox(
              width: 103,
              height: 35,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    !market.active ? Colors.grey
                    : _couponDownloadedMap[market.id] == true ? Color.fromARGB(255, 177, 177, 177) : Color.fromARGB(255, 109, 121, 109),
                  ),
                ),
                onPressed: !market.active ? null : () {
                  if (points < 20 && _couponDownloadedMap[market.id] == false) {
                    _dialogBuilder(context);
                  } else {
                    setState(() {
                      if (_couponDownloadedMap[market.id] == true) {
                        _cancelPromotion(market.id);
                      } else {
                        _activePromotion(market.id);
                      }
                    });
                  }
                },
                child: Text(
                  style: TextStyle(color: Colors.white),
                  _couponDownloadedMap[market.id] == true ? 'Otkaži' : 'Aktiviraj',
                ),
              ),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Details(
                  index: index,
                  market: market,
                  currentPoints: widget.currentPoints,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFirstPage() {
    return ListView.builder(
      itemCount: dscList.length,
      itemBuilder: (context, index) {
        final store = dscList[index];
        return Card(
          color: Colors.grey[400],
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
          elevation: 0,
          child: ListTile(
            leading: Icon(getIconForDescription(store), color: Color.fromARGB(255, 96, 107, 96)),
            contentPadding: EdgeInsets.all(15.0),
            title: Text(store, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MorePage(
                  index: index,
                  store: store,
                ),
              ),
            ), 
          ),
        );
      }
    );
  }

  Widget _buildGridView() {
    final filteredMarkets = markets
      .where((market) => market.name.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Pretraži',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0),),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: _filterMarkets,
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: listUpdate,
              crossAxisSpacing: 20,
              mainAxisSpacing: 30,
            ),
            itemCount: filteredMarkets.length,
            itemBuilder: (context, index) {
              final market = filteredMarkets[index];
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Details(
                        index: index,
                        market: market,
                        currentPoints: widget.currentPoints,
                      ),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.8),
                          offset: Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage(market.imgPath),
                        fit: BoxFit.cover,
                      ),
                    ),
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
