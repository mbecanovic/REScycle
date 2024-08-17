import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
  bool _isObscured = true;

  void _signUp() async {
    String email = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String repeatPassword = _repeatPasswordController.text.trim();
    int points = 0;
    List<dynamic> _databaseActive = [];
    

    if (password != repeatPassword) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Passwords do not match'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Dodajte korisničke informacije u Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': email,
        'uid': userCredential.user!.uid,
        'points': points,
        'activePromotion': _databaseActive,
      });

      // Navigate to another screen or show success message
      Navigator.pushReplacementNamed(context, '/login'); // Adjust route name as needed
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Signup failed'),
          content: Text(e.message ?? 'Unknown error occurred'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                SizedBox(height: 30),
                Text(
                'Registruj se',
                style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
               ),
              ),
              SizedBox(height: 80),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  //icon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0)
                  ),
                  hintText: 'Ime i prezime',
                ),
              ),
              
              SizedBox(height: 10),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  //icon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0)
                  ),
                  hintText: 'Email adresa',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: _isObscured,
                decoration: InputDecoration(
                  //icon: Icon(Icons.password),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0)
                  ),
                  hintText: 'Šifra',
                  suffixIcon: IconButton(
                    icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                    onPressed: (){
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _repeatPasswordController,
                obscureText: _isObscured,
                decoration: InputDecoration(
                  //icon: Icon(Icons.password),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0)
                  ),
                  hintText: 'Ponovi šifru',
                  suffixIcon: IconButton(
                    icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                    onPressed: (){
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
                ),
              ),
              SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signUp,
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
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Color.fromARGB(255, 109, 121, 109), width: 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Rounded shape
                      ),
                  ),
                  onPressed: (){Navigator.pushNamed(context, '/login');},
                  child: Text('Imas nalog? Uloguj se', style: TextStyle(color: Colors.black),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
