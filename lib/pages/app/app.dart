import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rescycling/pages/auth/auth.dart';
import 'package:rescycling/pages/app/list.dart'; 
import 'map.dart';
import 'qr_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  String? _userName;
  int _selectedIndex = 0; // Index for bottom navigation
  bool iconPressed = false;
  int currentPoints = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _userName = userDoc.data()?['name'];
            currentPoints = userDoc.data()?['points'];

          });
        }
      } catch (e){//komentar
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    // Define the pages
    List<Widget> pages = [
      ListPage(iconPressed: iconPressed, currentPoints: currentPoints), // Replace with your home page widget
      MapPage(), 
      QRPage(points: 0,), 
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
        'REScycle',
          style: TextStyle(
          fontWeight: FontWeight.bold,
        fontFamily: 'Montserrat', // Replace with your font name
        fontSize: 20, // You can adjust the size if needed
        ),
        ),
        actions: [
          if(_selectedIndex == 0 )
          IconButton(onPressed: (){
            setState(() {
                iconPressed = !iconPressed;
                //print(iconPressed);
              });
          }, icon: Icon(iconPressed ? Icons.grid_view : Icons.view_list),),
          
          //IconButton(onPressed: (){}, icon: const Icon(Icons.search),),
          //IconButton(onPressed: (){}, icon: const Icon(Icons.more_vert),),
        ],
        //centerTitle: true,
        bottom: PreferredSize(
        preferredSize: const Size.fromHeight(6.0),
          child: Container(
            color: Colors.grey,
            //height: 1.0,
          )
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_userName ?? 'Guest', style: TextStyle(fontSize: 30),),
              accountEmail: Text(user?.email ?? ''),
              decoration: BoxDecoration(color: Color.fromARGB(255, 109, 121, 109)),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Nalog'),
              onTap: () {
                // Handle account navigation
                Navigator.pushNamed(context, '/account');
              },
            ),
            ListTile(
              leading: const Icon(Icons.password),
              title: const Text('Promena lozinke'),
              onTap: () {
                // Handle settings navigation
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Noćni režim'),
              onTap: () {
                // Handle settings navigation
                Navigator.pushNamed(context, '/settings');
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('O aplikaciji'),
              onTap: () {
                // Handle settings navigation
                Navigator.pushNamed(context, '/settings');
              },
            ),
            
            /*ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Recycle Bins'),
              onTap: () {
                // Handle settings navigation
                Navigator.pushNamed(context, '/settings');
              },
            ), */
            SizedBox(height: 365,),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Odjavi se'),
              onTap: () async {
                await Auth().signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: pages[_selectedIndex], // Render the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.grey[800],
        unselectedItemColor: Colors.black38,
         selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400, // Slightly lighter bold
          fontSize: 14,
        ),
          unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600, // Slightly lighter bold
          fontSize: 11,
        ),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home,),
            
            label: 'Početna strana',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR kod',
          ),
        ],
        onTap: _onItemTapped, // Update the selected index
      ),
    );
  }
}

// Define your pages here

