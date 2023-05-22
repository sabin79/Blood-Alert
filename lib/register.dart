import 'package:boodbank/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Customdialog.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formkey = GlobalKey<FormState>();
  late String _email = "";
  late String _password = "";
  late String _name = "";
  late FirebaseAuth login;
  final List<String> _bloodGroup = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    "AB+",
    "AB-"
  ];
  String _selected = '';

  bool _categorySelected = false;
  bool isLoggedIn() {
    if (FirebaseAuth.instance.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    login = FirebaseAuth.instance;
  }

  Future<void> addData(user) async {
    if (isLoggedIn()) {
      FirebaseFirestore.instance
          .collection('User Details')
          .doc(user['uid'])
          .set(user)
          .catchError((e) {
        print(e);
      });
    } else {
      print('You need to be logged In');
    }
  }

  bool validate_save() {
    final form = formkey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validate_submit(BuildContext context) async {
    if (validate_save()) {
      try {
        CustomDialogs.progressDialog(
            context: context, message: 'Registration under process');
        User user = (await login.createUserWithEmailAndPassword(
                email: _email, password: _password))
            .user!;
        Navigator.pop(context);
        print("Registered User: ${user.uid}");
        final Map<String, dynamic> UserDetails = {
          'uid': user.uid,
          'name': _name,
          'email': _email,
          'Blood Group': _selected,
        };
        addData(UserDetails).then((result) {
          print("User Added");
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        user: user,
                      )));
        }).catchError((e) {
          print(e);
        });
      } catch (e) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: const Text('Registration Failed'),
                content: Text('Error : $e'),
                actions: <Widget>[
                  TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      })
                ],
              );
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, //top bar color
      systemNavigationBarColor: Colors.black, //bottom bar color
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
        backgroundColor: Colors.redAccent,
        appBar: AppBar(
          elevation: 0.0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: const Text(
            'Register',
            style: TextStyle(
                fontSize: 40, fontFamily: "Raleway", color: Colors.white),
          ),
        ),
        body: ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(35.0),
              topRight: Radius.circular(35),
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35)),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).size.height / 6,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(50),
                    child: Form(
                        key: formkey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  hintText: 'name',
                                  icon: Icon(
                                    FontAwesomeIcons.envelope,
                                    color: Color.fromARGB(1000, 221, 46, 68),
                                  ),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? "name can't be empty"
                                    : null,
                                onSaved: (value) => _name = value!,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  hintText: 'Email ID',
                                  icon: Icon(
                                    FontAwesomeIcons.envelope,
                                    color: Color.fromARGB(1000, 221, 46, 68),
                                  ),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? "Email ID  can't be empty"
                                    : null,
                                onSaved: (value) => _email = value!,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  hintText: "Password",
                                  icon: Icon(
                                    FontAwesomeIcons.userLock,
                                    color: Colors.red,
                                  ),
                                ),
                                obscureText: true,
                                validator: (value) => value!.isEmpty
                                    ? "Password  can't be empty"
                                    : null,
                                onSaved: (value) => _password = value!,
                              ),
                            ),
                            Container(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: DropdownButton(
                                      hint: const Text(
                                        "Please choose a blood Group",
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(1000, 221, 46, 68),
                                        ),
                                      ),
                                      iconSize: 40.0,
                                      items: _bloodGroup.map((val) {
                                        return DropdownMenuItem<String>(
                                          value: val,
                                          child: Text(val),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selected = newValue!;
                                          _categorySelected = true;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 13,
                                  ),
                                  Text(
                                    _selected,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Color.fromARGB(1000, 221, 47, 68),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            ElevatedButton(
                              onPressed: () => validate_submit(context),
                              child: const Text("Register"),
                            )
                          ],
                        )),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
