import 'dart:ui' as ui;
import 'package:boodbank/requestblood.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:boodbank/Customdialog.dart';
import 'package:boodbank/RippleIndicator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _controller;
  bool isMapCreated = false;
  Position? position;
  Widget? _child;
  BitmapDescriptor? bitmapImage;
  Marker? marker;
  Uint8List? markerIcon;
  var lat = [];
  var lng = [];
  String? _name;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  void initState() {
    _child = RippleIndicator("Getting Location");
    getIcon();
    getCurrentLocation();
    populateClients();
    super.initState();
  }

  Future<void> _fetchRequestName(String requestId) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection("User Details")
        .doc(requestId)
        .get();

    if (snapshot.exists) {
      setState(() {
        _name = snapshot.data()!['name'];
      });
    }
  }

  populateClients() {
    FirebaseFirestore.instance
        .collection('Blood Request Details')
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        for (int i = 0; i < querySnapshot.docs.length; ++i) {
          initmarker(querySnapshot.docs[i].data(), querySnapshot.docs[i].id);
        }
      }
    });
  }

  void initmarker(request, requestId) {
    var markerIdVal = requestId;
    final MarkerId markedId = MarkerId(markerIdVal);

    final Marker marker = Marker(
        markerId: const MarkerId('home'),
        position:
            LatLng(request['location'].latitude, request['location'].longitude),
        onTap: () async {
          CustomDialogs.progressDialog(context: context, message: 'fetching');
          await _fetchRequestName(requestId);
          Navigator.pop(context);
          return showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (BuildContext context) {
                return Container(
                  margin: const EdgeInsets.all(10.0),
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(17),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor:
                                  const Color.fromARGB(1000, 221, 46, 68),
                              child: Text(
                                request['Blood-Group'],
                                style: const TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _name!,
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.black87),
                              ),
                              Text(
                                "${"Quantity :" + request['quantity']}L",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                "Due Date:" + request['dueDate'],
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 14, right: 14),
                        child: Text(
                          request['address'],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              urlLauncher.launch("tel:${request['phone']}");
                            },
                            child: const Text("Data"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              String message =
                                  "hello $_name, I am a potential blood donpr willing to donate blood in your need. Reply back if you need blood.";
                              urlLauncher.launch(
                                  "sms: ${request['phone']}?body=$message");
                            },
                            child: const Text(""),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              });
        });
    setState(() {
      markers[markedId] = marker;
      print(markedId);
    });
  }

  void getCurrentLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Position? res = await Geolocator.getCurrentPosition();
      setState(() {
        position = res;
        _child = mapWidget();
      });

      Position? currentPosition = position;
      if (currentPosition != null) {
        print(currentPosition.latitude);
        print(currentPosition.longitude);
      }
    } else {}
  }

  void getIcon() async {
    markerIcon = await getBytesFromAsset("images/mark.png", 120);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Set<Marker> _createMarker() {
    return <Marker>{
      Marker(
        markerId: const MarkerId("home"),
        position: LatLng(position!.latitude, position!.longitude),
        icon: BitmapDescriptor.fromBytes(markerIcon!),
      ),
    };
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void setmapstyle(String mapStyle) {
    _controller!.setMapStyle(mapStyle);
  }

  @override
  Widget build(BuildContext context) {
    if (isMapCreated) {
      getJsonFile('images/customStyle.json').then(setmapstyle);
    }
    return _child ?? Container();
  }

  Widget mapWidget() {
    return Stack(
      children: <Widget>[
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(position!.latitude, position!.longitude),
            zoom: 18.0,
          ),
          markers: Set<Marker>.of(markers.values),
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            isMapCreated = true;
            getJsonFile('assets/customStyle.json').then(setmapstyle);
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton.extended(
              backgroundColor: const Color.fromARGB(1000, 221, 46, 68),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestBlood(
                      latitude: position?.latitude,
                      longitude: position?.longitude,
                    ),
                  ),
                );
              },
              icon: const Icon(FontAwesomeIcons.burn),
              label: const Text("Request Blood"),
            ),
          ),
        )
      ],
    );
  }
}
