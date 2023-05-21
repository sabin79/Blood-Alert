import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IncrementalPage extends StatefulWidget {
  @override
  _IncrementalPageState createState() => _IncrementalPageState();
}

class _IncrementalPageState extends State<IncrementalPage> {
  int value = 1;
  String donorDonation = 'No donation yet';
  late User? _user;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
      if (_user != null) {
        retrieveDonation();
      }
    });
  }

  void retrieveDonation() async {
    final userDoc =
        FirebaseFirestore.instance.collection('donors').doc(_user!.uid);
    final docSnapshot = await userDoc.get();
    if (docSnapshot.exists) {
      setState(() {
        value = docSnapshot.data()!['donation'] ?? 1;
        donorDonation = 'Donor Donation: ${value.toString()}';
      });
    }
  }

  void incrementValue() async {
    if (_user != null) {
      setState(() {
        value++;
        donorDonation = 'Donor Donation: ${value.toString()}';
      });
      final userDoc =
          FirebaseFirestore.instance.collection('donors').doc(_user!.uid);
      await userDoc.set({'donation': value});
    }
  }

  void decrementValue() async {
    if (_user != null) {
      setState(() {
        if (value > 1) {
          value--;
          donorDonation = 'Donor Donation: ${value.toString()}';
        }
      });
      final userDoc =
          FirebaseFirestore.instance.collection('donors').doc(_user!.uid);
      await userDoc.set({'donation': value});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Donor-Report',
            style: TextStyle(fontFamily: "Raleway", fontSize: 35),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              FontAwesomeIcons.reply,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          )),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              donorDonation,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: incrementValue,
              child: Text(
                'Increase',
                style: TextStyle(fontSize: 25),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: decrementValue,
              child: Text(
                'Decrease',
                style: TextStyle(fontSize: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: IncrementalPage(),
  ));
}
