import 'package:boodbank/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';

class RequestBlood extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const RequestBlood({Key? key, this.latitude, this.longitude})
      : super(key: key);

  double? get _latitude => latitude;
  double? get _longitude => longitude;

  @override
  State<RequestBlood> createState() => _RequestBloodState();
}

class _RequestBloodState extends State<RequestBlood> {
  final formkey = GlobalKey<FormState>();
  final List<String> _bloodGroup = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];
  String _selected = '';
  String? _qty;
  String? _phone;
  String? _address;
  bool _categorySelected = false;
  DateTime selectedDate = DateTime.now();
  var formattedDate;
  int flag = 0;
  User? currentUser;
  late List<Placemark> placemark;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    getAddress();
  }

  bool isLoggedIn() {
    if (FirebaseAuth.instance.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> addData(user) async {
    if (isLoggedIn()) {
      FirebaseFirestore.instance
          .collection('Blood Request Details')
          .doc(user['uid'])
          .set(user)
          .catchError((e) {
        print(e);
      });
    } else {
      print('You need to be logged In');
    }
  }

  Future<void> _loadCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUser = user;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: selectedDate,
      lastDate: DateTime(2023),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        flag = 1;
      });
    }
    var date = DateTime.parse(selectedDate.toString());
    formattedDate = "${date.day}-${date.month}-${date.year}";
  }

  Future<void> dialogTrigger(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Blood Request Submitted'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                formkey.currentState?.reset();
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const HomePage()));
              },
              child: const Icon(
                Icons.arrow_forward,
                color: Color.fromARGB(1000, 221, 46, 68),
              ),
            ),
          ],
        );
      },
    );
  }

  void getAddress() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      widget.latitude!,
      widget.longitude!,
    );

    Placemark firstPlacemark = placemarks.first;

    String address =
        '${firstPlacemark.name}, ${firstPlacemark.locality}, Postal Code: ${firstPlacemark.postalCode}';

    setState(() {
      _address = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(1000, 221, 46, 68),
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Request Blood",
          style: TextStyle(
            fontSize: 40.0,
            fontFamily: "Raleway",
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            FontAwesomeIcons.reply,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0)),
        child: Container(
          height: 800.0,
          width: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Form(
                  key: formkey,
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: DropdownButton(
                                hint: const Text(
                                  'Please choose a Blood Group',
                                  style: TextStyle(
                                    color: Color.fromARGB(1000, 221, 46, 68),
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
                              height: 10.0,
                            ),
                            Text(
                              _selected,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Color.fromARGB(1000, 221, 46, 68),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Quantity(L)',
                            icon: Icon(
                              FontAwesomeIcons.prescriptionBottle,
                              color: Color.fromARGB(1000, 221, 46, 68),
                            ),
                          ),
                          validator: (value) => value!.isEmpty
                              ? "Quantity field can't be empty"
                              : null,
                          onSaved: (value) => _qty = value,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              onPressed: () => _selectDate(context),
                              icon: const Icon(FontAwesomeIcons.calendar),
                              color: const Color.fromARGB(1000, 221, 46, 68),
                            ),
                            flag == 0
                                ? const Text(
                                    "<< Pick up a Due Date",
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 15.0),
                                  )
                                : Text(formattedDate),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Phone Number',
                            icon: Icon(
                              FontAwesomeIcons.mobile,
                              color: Color.fromARGB(1000, 221, 46, 68),
                            ),
                          ),
                          validator: (value) => value!.isEmpty
                              ? "Phone Number field can't be empty"
                              : null,
                          onSaved: (value) => _phone = value,
                          maxLength: 10,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (!formkey.currentState!.validate()) return;
                          formkey.currentState!.save();
                          final Map<String, dynamic> BloodRequestDetails = {
                            'uid': currentUser!.uid,
                            'bloodGroup': _selected,
                            'quantity': _qty,
                            'dueDate': formattedDate,
                            'phone': _phone,
                            'location': GeoPoint(
                                widget._latitude ?? 0, widget._longitude ?? 0),
                            'address': _address,
                          };
                          addData(BloodRequestDetails).then((result) {
                            dialogTrigger(context);
                          }).catchError((e) {
                            print(e);
                          });
                        },
                        child: const Text("Done"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
