import 'package:boodbank/home.dart';
import 'package:boodbank/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'Customdialog.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({
    super.key,
  });

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final _formkey = GlobalKey<FormState>();
  late String _email;
  late String _password;
  late FirebaseAuth auth;

  bool validate_save() {
    final form = _formkey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
  }

  void _submit() async {
    if (validate_save()) {
      try {
        CustomDialogs.progressDialog(context: context, message: 'Signing In');
        print("============================");
        print(auth);
        print("============================");

        User user = (await auth.signInWithEmailAndPassword(
                email: _email, password: _password))
            .user!;
        Navigator.pop(context);
        print('Signed in: ${user.uid}');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      user: user,
                    )));
      } catch (e) {
        print('Errr : $e');
        showDialog(
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('User Sign-In Failed !'),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('OK'),
                    onPressed: () {
                      _formkey.currentState?.reset();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            },
            context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 2.5,
              child: const Center(
                child: Text(
                  "Blood Alert",
                  style: TextStyle(
                      fontFamily: "Raleway",
                      fontSize: 60,
                      color: Colors.white70),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
              ),
              child: Container(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).size.height / 2.5,
                width: double.infinity,
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Form(
                            key: _formkey,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      hintText: 'Email ID',
                                      icon: Icon(
                                        FontAwesomeIcons.envelope,
                                        color:
                                            Color.fromARGB(1000, 221, 46, 68),
                                      ),
                                    ),
                                    obscureText: false,
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
                                        color:
                                            Color.fromARGB(1000, 221, 46, 68),
                                      ),
                                    ),
                                    obscureText: true,
                                    validator: (value) => value!.isEmpty
                                        ? "Password can't be empty"
                                        : null,
                                    onSaved: (value) => _password = value!,
                                  ),
                                ),
                                const SizedBox(
                                  height: 30.0,
                                ),
                                ElevatedButton(
                                  onPressed: _submit,
                                  child: const Text("Login"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("New User? "),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const RegisterPage()));
                                        },
                                        child: const Text(
                                          "Click Here",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
