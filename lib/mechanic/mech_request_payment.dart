import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mechapp/utils/type_constants.dart';

import 'mech_main.dart';

var rootRef = FirebaseDatabase.instance.reference();
String t6 = "--", t7 = "--";

class MechRequestPayment extends StatefulWidget {
  @override
  _MechRequestPaymentState createState() => _MechRequestPaymentState();
}

class _MechRequestPaymentState extends State<MechRequestPayment> {
  Stream<String> getJobs() async* {
    DatabaseReference dataRef = FirebaseDatabase.instance
        .reference()
        .child("All Jobs Collection")
        .child(mUID);

    await dataRef.once().then((snapshot) {
      var dATA = snapshot.value;

      setState(() {
        t6 = dATA['Pay pending Amount'];
        t7 = dATA['Payment Request'];
      });
    });
    yield "the";
  }

  final _formKey = GlobalKey<FormState>();

  Widget _buildFutureBuilder() {
    return Center(
      child: StreamBuilder<String>(
        stream: getJobs(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.done) {
            return Text("evefgvegve");
          }
          return CupertinoActivityIndicator(radius: 20);
        },
      ),
    );
  }

  TextEditingController _amountC = TextEditingController();

  bool _autoValidate = false;
  bool isLoading = false;

  void processRequest(_setState) {
    String amount = _amountC.toString().trim();

    final String ppA = (double.parse(t6) - double.parse(amount)).toString();
    final String pR = (double.parse(t7) + double.parse(amount)).toString();

    final Map<String, Object> allJobs = Map();
    allJobs.putIfAbsent("Pay pending Amount", () => ppA);
    allJobs.putIfAbsent("Payment Request", () => pR);

    Map<String, String> pRequest = Map();
    allJobs.putIfAbsent("amount", () => amount);
    allJobs.putIfAbsent("uid", () => mUID);
    allJobs.putIfAbsent("date", () => thePresentTime());

    rootRef
        .child("Payment Request")
        .child("Pending")
        .child(mUID)
        .set(pRequest)
        .then((a) {
      rootRef
          .child("All Jobs Collection")
          .child(mUID)
          .update(allJobs)
          .then((a) {
        _setState(() {
          t6 = ppA;
          t7 = pR;
          isLoading = false;
          showCenterToast("Request Made", context);
          Navigator.pushReplacement(context,
              CupertinoPageRoute(builder: (context) => MechMainPage()));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Color(0xb090A1AE), child: _buildFutureBuilder());
  }
}
