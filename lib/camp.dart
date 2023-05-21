import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Customdialog.dart';
import 'dart:io';

class CampPage extends StatefulWidget {
  const CampPage({Key? key}) : super(key: key);

  @override
  State<CampPage> createState() => _CampPageState();
}

class _CampPageState extends State<CampPage> {
  User? currentUser;
  final formKey = GlobalKey<FormState>();
  late String _text, _name;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  bool isLoggedIn() {
    return currentUser != null;
  }

  Future<void> addData(Map<String, dynamic> user) async {
    if (isLoggedIn()) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference collection =
          firestore.collection('Campaign Details');

      await collection.add(user).catchError((e) {
        print(e);
      });
    } else {
      print('You need to be logged in');
    }
  }

  Future<void> _loadCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUser = user;
      });
    }
  }

  Future<bool> dialogTrigger(
      BuildContext context, GlobalKey<FormState> formKey) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Post Submitted'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                formKey.currentState!.reset();
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const CampPage()),
                );
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
    return true;
  }

  File? _image;
  late String path;

  Future<void> getImage(bool isCamera) async {
    File? image;
    String path;
    if (isCamera) {
      final xfile = await ImagePicker().pickImage(source: ImageSource.camera);
      image = xfile != null ? File(xfile.path) : null;
      path = image?.path ?? '';
    } else {
      final xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
      image = xfile != null ? File(xfile.path) : null;
      path = image?.path ?? '';
    }
    setState(() {
      _image = image;
      path = path;
    });
  }

  Future<String> uploadImage() async {
    if (currentUser != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentUser!.providerData[0].providerId,
      );

      await currentUser!.reauthenticateWithCredential(credential);

      if (_image != null) {
        File imageFile = File(_image!.path);
        firebase_storage.Reference storageReference = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('campaignposters/${currentUser!.uid}/$_name.jpg');
        firebase_storage.UploadTask uploadTask =
            storageReference.put
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  } else {
    throw Exception('Image file is null');
  }
} else {
  throw Exception('User not authenticated');
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
resizeToAvoidBottomInset: false,
backgroundColor: const Color.fromARGB(1000, 221, 46, 68),
appBar: AppBar(
elevation: 0.0,
centerTitle: true,
backgroundColor: Colors.transparent,
title: const Text(
"Campaigns",
style: TextStyle(
fontSize: 50.0,
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
topLeft: Radius.circular(35),
topRight: Radius.circular(35),
),
child: Container(
height: 800,
width: double.infinity,
color: Colors.white,
),
),
floatingActionButton: Align(
alignment: Alignment.bottomRight,
child: Padding(
padding: const EdgeInsets.all(10.0),
child: FloatingActionButton(
backgroundColor: const Color.fromARGB(1000, 221, 46, 68),
onPressed: () {
showDialog(
context: context,
builder: (_) => AlertDialog(
title: const Text("Make a post about your Campaign"),
content: Form(
key: formKey,
child: SingleChildScrollView(
child: Column(
mainAxisAlignment: MainAxisAlignment.start,
children: [
Padding(
padding: const EdgeInsets.all(7),
child: TextFormField(
decoration: const InputDecoration(
hintText: "Organisation Name",
icon: Icon(
FontAwesomeIcons.user,
color: Color.fromARGB(1000, 221, 46, 68),
),
),
validator: (value) =>
value!.isEmpty ? "This can't be empty" : null,
onSaved: (value) => _name = value!,
keyboardType: TextInputType.multiline,
),
),
Padding(
padding: const EdgeInsets.all(7),
child: TextFormField(
decoration: const InputDecoration(
hintText: "Write Something Here.",
icon: Icon(FontAwesomeIcons.pen,
color: Color.fromARGB(1000, 221, 46, 68),
),
),
validator: (value) =>
value!.isEmpty ? "This can't be empty" : null,
onSaved: (value) => _text = value!,
keyboardType: TextInputType.multiline,
),
),
Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
IconButton(
onPressed: () {
getImage(true);
},
icon:  Icon(Icons.camera_alt),
),
IconButton(
onPressed: () {
getImage(false);
},
icon:  Icon(Icons.filter),
),
],
),
_image == null
? Container()
: Image.file(
_image!,
height: 150,
width: 150





User
continue
ChatGPT
,
),
),
],
),
const SizedBox(height: 20.0),
ElevatedButton(
onPressed: () async {
if (formKey.currentState!.validate()) {
formKey.currentState!.save();
String imageUrl = await uploadImage();
Map<String, dynamic> user = {
'name': _name,
'text': _text,
'image': imageUrl,
'timestamp': DateTime.now(),
};
await addData(user);
bool response = await dialogTrigger(
context, formKey);
if (response) {
setState(() {
_image = null;
});
}
}
},
child: const Text("Post"),
style: ElevatedButton.styleFrom(
primary: Colors.redAccent,
textStyle: const TextStyle(
color: Colors.white,
fontSize: 20,
),
padding: const EdgeInsets.symmetric(
horizontal: 30,
vertical: 15,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(30),
),
),
),))
],
),
),
),
),
);
},
child: const Icon(Icons.add),
),
),
),
);
}
}





