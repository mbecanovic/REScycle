import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 170, 190, 170),
        elevation: 0,
        title: Center(
          child: const Text(
          'REScycle',
            style: TextStyle(
            fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat', // Replace with your font name
          fontSize: 20, // You can adjust the size if needed
          ),
          ),
        ),
      ),
      body: Container(
  decoration: const BoxDecoration(
    color: Color.fromARGB(255, 170, 190, 170),
  ),
  child: Column(
    children: <Widget>[
      SizedBox(height: 100,),
      Image.asset(
                'lib/data/icons/logo.png', 
                height: 150,
                width: 150,
              ),
      const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Dobrodošli na REScycle',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Recikliraj pametno',
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 109, 121, 109), // Transparent background
                    side: BorderSide(color: Color.fromARGB(255, 109, 121, 109), width: 2), // Blue border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded shape
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Padding around text
                  ),
              child: Text(
                'Registruj se',
                style: TextStyle(color: Colors.white)
              ),
            ),
            SizedBox(width: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 109, 121, 109), // Transparent background
                    side: BorderSide(color: Color.fromARGB(255, 109, 121, 109), width: 2), // Blue border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded shape
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Padding around text
                  ),
              child: Text(
                'Uloguj se',
                style: TextStyle(color: Colors.white)
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

    );
  }
}