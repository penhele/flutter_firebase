import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Flutter Firebase'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseAuth auth;
  String _email = 'stephenhelk1@gmail.com';
  String _password = 'stephen1234';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    auth = FirebaseAuth.instance;

    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                createUserEmailAndPassWord();
              }, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade300),
              child: Text('Email/Password Create', style: TextStyle(fontSize: 25, color: Colors.white),),
            ),
            ElevatedButton(
              onPressed: () {
                signUserEmailAndPassWord();
              }, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade300),
              child: Text('Email/Password Sign', style: TextStyle(fontSize: 25, color: Colors.white),),
            ),
            ElevatedButton(
              onPressed: () {
                signOut();
              }, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade300),
              child: Text('Sign Out', style: TextStyle(fontSize: 25, color: Colors.white),),
            ),
            ElevatedButton(
              onPressed: () {
                deleteIUser();
              }, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow.shade300),
              child: Text('Delete User', style: TextStyle(fontSize: 25, color: Colors.black),),
            ),
            ElevatedButton(
              onPressed: () {
                updatePassword();
              }, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade300),
              child: Text('Update Password', style: TextStyle(fontSize: 25, color: Colors.white),),
            ),
            ElevatedButton(
              onPressed: () {
                signGoogle();
              }, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade300),
              child: Text('Google Sign', style: TextStyle(fontSize: 25, color: Colors.white),),
            ),
            ElevatedButton(
              onPressed: () {
                logInWithPhone();
              }, 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade300),
              child: Text('Phone Number Sign', style: TextStyle(fontSize: 25, color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
  
  createUserEmailAndPassWord() async {
    try {
      var _userCredential =  await auth.createUserWithEmailAndPassword(
        email: _email, 
        password: _password
      );

      var _myUser = _userCredential.user;
      if (!_myUser!.emailVerified) {
        await _myUser.sendEmailVerification();
      } else {
        debugPrint('User mail is confirmed');
      }

      print(_userCredential.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  
  void signUserEmailAndPassWord() async {
    try {
      var _userCredential = await auth.signInWithEmailAndPassword(
        email: _email, 
        password: _password
      );

      print(_userCredential.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  
  void signOut() async {
    var googleUser = GoogleSignIn().currentUser;
    if (googleUser != null) {
      await GoogleSignIn().signOut();
    }

    await auth.signOut();
  }
  
  void deleteIUser() async {
    if (auth.currentUser != null) {
      await auth.currentUser!.delete();
    } else {
      debugPrint('User is not logged in');
    }
  }
  
  void updatePassword() async {
    try {
      await auth.currentUser!.updatePassword('newPassword');
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        var credential = EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);
        await auth.currentUser!.updatePassword('password');
        await auth.signOut();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  
  void signGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void logInWithPhone()  async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+62818355788',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        debugPrint(credential.toString());
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint(e.toString());
      },
      codeSent: (String verificationId, int? resendToken) async {
        var smsCode = '123456';
        var credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint('code Auto Retrieval Timeout');
      },
    );
  }
}