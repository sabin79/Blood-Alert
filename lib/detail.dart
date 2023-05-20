import 'package:flutter/material.dart';
import 'requestblood.dart';

class BloodRequestDetailsPage extends StatelessWidget {
  final Map<String, dynamic> bloodRequestDetails;

  BloodRequestDetailsPage({required this.bloodRequestDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Request Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UID: ${bloodRequestDetails['uid']}'),
            Text('Blood Group: ${bloodRequestDetails['bloodGroup']}'),
            Text('Quantity: ${bloodRequestDetails['quantity']}'),
            Text('Due Date: ${bloodRequestDetails['dueDate']}'),
            Text('Phone: ${bloodRequestDetails['phone']}'),
            Text('Location: ${bloodRequestDetails['location']}'),
            Text('Address: ${bloodRequestDetails['address']}'),
          ],
        ),
      ),
    );
  }
}
