import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rescycling/pages/auth/auth.dart'; // Ensure this path is correct

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? errorMessage;
  bool _isObscured = true;

  Future<void> signIn() async {
    if (_username.text.isEmpty || _password.text.isEmpty) {
      setState(() {
        errorMessage = "Please enter both username and password";
      });
      return;
    }
    
    showDialog(context: context, builder: (context){
      return Center(child: LoadingAnimationWidget.halfTriangleDot(color: Colors.white, size: 60));
    },);
    
    try {
      await Auth().signInWithEmailAndPassword(
        email: _username.text,
        password: _password.text,
      );
      // Ako je prijava uspešna, prebacite korisnika na '/app' stranicu
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/app');
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
      Navigator.pop(context);
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 30),
                Text(
                'Uloguj se',
                style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
               ),
              ),
              SizedBox(height: 80),
              TextField(
                controller: _username,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30)
                  ),
                  hintText: 'Username',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _password,
                obscureText: _isObscured, // Hide password text
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30)
                  ),
                  hintText: 'Password',
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
              SizedBox(height: 20),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    // Handle forgotten password logic here
                  },
                  child: Text(
                    'Zaboravljena sifra',
                    style: TextStyle(color: Color.fromARGB(255, 109, 121, 109)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 109, 121, 109),
                    side: BorderSide(color: Colors.white, width: 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Rounded shape
                      ),
                  ),
                  onPressed: signIn,
                  child: Text('Log In', style: TextStyle(color: Colors.white),),
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
                  onPressed: (){Navigator.pushNamed(context, '/signup');},
                  child: Text('Nemas nalog? Registruj se', style: TextStyle(color: Colors.black),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
