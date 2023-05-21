import 'package:flutter/material.dart';

class IncrementalPage extends StatefulWidget {
  @override
  _IncrementalPageState createState() => _IncrementalPageState();
}

class _IncrementalPageState extends State<IncrementalPage> {
  int value = 1;
  String donorDonation = 'No donation yet';

  void incrementValue() {
    setState(() {
      value++;
      donorDonation = 'Donor Donation: \$${value.toString()}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Incremental Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Value: $value',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              donorDonation,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: incrementValue,
              child: Text('Increase Value'),
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
