import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mechapp/utils/type_constants.dart';

class MechHomeFragment extends StatefulWidget {
  @override
  _MechHomeFragmentState createState() => _MechHomeFragmentState();
}

String t1 = "--",
    t2 = "--",
    t3 = "--",
    t4 = "--",
    t5 = "--",
    t6 = "--",
    t7 = "--",
    t8 = "--";

class _MechHomeFragmentState extends State<MechHomeFragment>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<List<String>> getJobs() async {
    DatabaseReference dataRef = FirebaseDatabase.instance
        .reference()
        .child("All Jobs Collection")
        .child(mUID);

    await dataRef.once().then((snapshot) {
      var dATA = snapshot.value;

      setState(() async {
        t1 = dATA['Total Job'];
        t2 = dATA['Total Amount'];
        t3 = dATA['Pending Job'];
        t4 = dATA['Pending Amount'];
        t5 = dATA['Cash Payment Debt'];
        t6 = dATA['Pay pending Amount'];
        t7 = dATA['Payment Request'];
        t8 = dATA['Completed Amount'];
      });
    });

    List<String> list = [];
    return list;
  }

  Widget _buildFutureBuilder() {
    return Center(
      child: FutureBuilder<List<String>>(
        future: getJobs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _eachItem1("Total Jobs", t1, t2, context),
                    _eachItem1("Pending Jobs", t3, t4, context),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _eachItem2(
                        "Cash Payment Pending", t5, "Pay Pending", t6, context),
                    _eachItem2(
                        "Payment Request", t7, "Pay Completed", t8, context),
                  ],
                ),
              ],
            );
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _eachItem1("Total Jobs", "--", "--", context),
                  _eachItem1("Pending Jobs", "--", "--", context),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _eachItem2("Cash Payment Pending", "--", "Pay Pending", "--",
                      context),
                  _eachItem2(
                      "Payment Request", "--", "Pay Completed", "--", context),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void initState() {
    getJobs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                "assets/images/bg_image.jpg",
              ),
              fit: BoxFit.fill),
        ),
        child: _buildFutureBuilder());
  }
}

Widget _eachItem1(
    String type, String noJobs, String amount, BuildContext context) {
  var height = MediaQuery.of(context).size.height / 3;
  var width = MediaQuery.of(context).size.width / 2.5;

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Card(
      elevation: 4,
      child: Container(
        height: height,
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              type,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                height: 8.0,
              ),
            ),
            Text(
              "Jobs",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            Text(
              noJobs,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
            ),
            Text(
              "Amount",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            Text(
              "₦" + " $amount",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _eachItem2(String type1, String amount1, String type2, String amount2,
    BuildContext context) {
  var height = MediaQuery.of(context).size.height / 3;
  var width = MediaQuery.of(context).size.width / 2.5;

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Card(
      elevation: 4,
      child: Container(
        height: height,
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              type1,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                height: 8.0,
              ),
            ),
            Text(
              "Amount",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            Text(
              "₦" + " $amount1",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
            ),
            Center(
              child: Text(
                type2,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                height: 8.0,
              ),
            ),
            Text(
              "Amount",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            Text(
              "₦" + " $amount2",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}
