import 'package:boodbank/camp.dart';
import 'package:boodbank/donors.dart';
import 'package:boodbank/login.dart';
import 'package:boodbank/map.dart';
import 'package:boodbank/requestblood.dart';
import 'package:boodbank/waveindicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'reporst.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? currentUser;
  String? _name = '', _bloodgroup = '', _email = '';
  late Widget _child;

  Future<void> _fetchUserInfo() async {
    Map<String, dynamic> userInfo;
    User currentUser = FirebaseAuth.instance.currentUser!;

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("User Details")
        .doc(currentUser.uid)
        .get();

    userInfo = snapshot.data() as Map<String, dynamic>;

    setState(() {
      _name = userInfo['name'];
      _email = userInfo['email'];
      _bloodgroup = userInfo['Blood Group'];
      //  _child = _myWidget();
    });
  }

  Future<void> _loadCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUser = user;
      });
    }

    // print me current user
  }

  @override
  void initState() {
    _child = const WaveIndicator();
    _loadCurrentUser();
    _fetchUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: const Color.fromARGB(1000, 221, 46, 68),
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Home",
          style: TextStyle(
            fontSize: 60,
            fontFamily: "Raleway",
            color: Colors.white,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0.0),
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(1000, 221, 46, 68),
              ),
              accountName: Text(
                currentUser == null ? "" : _name!,
                style: const TextStyle(
                  fontSize: 22.0,
                ),
              ),
              accountEmail: Text(
                currentUser == null ? "" : _email!,
                style: TextStyle(fontSize: 22),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  currentUser == null ? "" : _bloodgroup!,
                  style: const TextStyle(
                    fontSize: 30.0,
                    color: Colors.black54,
                    fontFamily: 'Raleway',
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text("Home"),
              leading: const Icon(
                FontAwesomeIcons.home,
                color: Color.fromARGB(1000, 221, 46, 68),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                              user: widget.user,
                            )));
              },
            ),
            ListTile(
              title: const Text("Map "),
              leading: const Icon(
                FontAwesomeIcons.mapLocation,
                color: Color.fromARGB(1000, 221, 46, 68),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MapView(
                              user: widget.user,
                            )));
              },
            ),
            ListTile(
              title: const Text("Blood Donors"),
              leading: const Icon(
                FontAwesomeIcons.handshake,
                color: Color.fromARGB(1000, 221, 46, 68),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const DonorPage()));
              },
            ),
            ListTile(
              title: const Text("Blood Request"),
              leading: const Icon(
                FontAwesomeIcons.burn,
                color: Color.fromARGB(1000, 221, 46, 68),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RequestBlood(
                              user: widget.user,
                            )));
              },
            ),
            ListTile(
              title: const Text("Donor-Report"),
              leading: const Icon(
                Icons.report,
                color: Color.fromARGB(1000, 221, 46, 68),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => IncrementalPage()));
              },
            ),
            ListTile(
              title: const Text("Campaigns"),
              leading: const Icon(
                FontAwesomeIcons.ribbon,
                color: Color.fromARGB(1000, 221, 46, 68),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CampPage(
                              user: widget.user,
                            )));
              },
            ),
            ListTile(
              title: const Text("Log-Out"),
              leading: const Icon(
                FontAwesomeIcons.signOutAlt,
                color: Color.fromARGB(1000, 221, 46, 68),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Loginpage()));
              },
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
          child: Container(
            height: 800,
            width: double.infinity,
            color: Colors.white,
            //  child: const MapView(),
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/hello.jpg"),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: Column(
                children: [
                  Padding(
                      padding:
                          EdgeInsets.only(left: 25, right: 25, bottom: 180)),
                  Container(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DonorPage()));
                      },
                      child: Text(
                        "Donor",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontFamily: "Raleway"),
                      ),
                      style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(Size(130, 50))),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                  ),
                  Container(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RequestBlood(
                                      user: widget.user,
                                    )));
                      },
                      child: Text(
                        "Request",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontFamily: "Raleway"),
                      ),
                      style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(Size(130, 50))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

//   Widget _myWidget() {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(1000, 221, 46, 68),
//       appBar: AppBar(
//         elevation: 0.0,
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         title: const Text(
//           "Home",
//           style: TextStyle(
//             fontSize: 60,
//             fontFamily: "Raleway",
//             color: Colors.white,
//           ),
//         ),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: const EdgeInsets.all(0.0),
//           children: [
//             UserAccountsDrawerHeader(
//               decoration: const BoxDecoration(
//                 color: Color.fromARGB(1000, 221, 46, 68),
//               ),
//               accountName: Text(
//                 currentUser == null ? "" : _name!,
//                 style: const TextStyle(
//                   fontSize: 22.0,
//                 ),
//               ),
//               accountEmail: Text(
//                 currentUser == null ? "" : _email ?? "",
//                 style: TextStyle(fontSize: 22),
//               ),
//               currentAccountPicture: CircleAvatar(
//                 backgroundColor: Colors.white,
//                 child: Text(
//                   currentUser == null ? "" : _bloodgroup ?? "",
//                   style: const TextStyle(
//                     fontSize: 30.0,
//                     color: Colors.black54,
//                     fontFamily: 'Raleway',
//                   ),
//                 ),
//               ),
//             ),
//             ListTile(
//               title: const Text("Home"),
//               leading: const Icon(
//                 FontAwesomeIcons.home,
//                 color: Color.fromARGB(1000, 221, 46, 68),
//               ),
//               onTap: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => const HomePage()));
//               },
//             ),
//             ListTile(
//               title: const Text("Blood Donors"),
//               leading: const Icon(
//                 FontAwesomeIcons.handshake,
//                 color: Color.fromARGB(1000, 221, 46, 68),
//               ),
//               onTap: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => const DonorPage()));
//               },
//             ),
//             ListTile(
//               title: const Text("Blood Request"),
//               leading: const Icon(
//                 FontAwesomeIcons.burn,
//                 color: Color.fromARGB(1000, 221, 46, 68),
//               ),
//               onTap: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const RequestBlood()));
//               },
//             ),
//             // ListTile(
//             //   title: const Text("Campaigns"),
//             //   leading: const Icon(
//             //     FontAwesomeIcons.ribbon,
//             //     color: Color.fromARGB(1000, 221, 46, 68),
//             //   ),
//             //   onTap: () {
//             //     Navigator.push(context,
//             //         MaterialPageRoute(builder: (context) => const CampPage()));
//             //   },
//             // ),
//             ListTile(
//               title: const Text("Log-Out"),
//               leading: const Icon(
//                 FontAwesomeIcons.signOutAlt,
//                 color: Color.fromARGB(1000, 221, 46, 68),
//               ),
//               onTap: () async {
//                 await FirebaseAuth.instance.signOut();
//                 Navigator.pushReplacement(context,
//                     MaterialPageRoute(builder: (context) => const Loginpage()));
//               },
//             )
//           ],
//         ),
//       ),
//       body: ClipRRect(
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(35),
//           topRight: Radius.circular(35),
//         ),
//         child: Container(
//           height: 800,
//           width: double.infinity,
//           color: Colors.white,
//           child: const MapView(),
//           // child: Container(
//           //   decoration: BoxDecoration(
//           //       image: DecorationImage(image: AssetImage("images/hello.jpg"))),
//           // ),
//         ),
//       ),
//     );
//   }
// }
}
