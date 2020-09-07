import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mechapp/libraries/custom_button.dart';
import 'package:mechapp/mechanic/mech_main.dart';
import 'package:mechapp/utils/type_constants.dart';
import 'package:rave_flutter/rave_flutter.dart';

class MechMakePayment extends StatefulWidget {
  @override
  _MechMakePaymentState createState() => _MechMakePaymentState();
}

class _MechMakePaymentState extends State<MechMakePayment> {
  String t5 = "--", t8 = "--";
  var rootRef = FirebaseDatabase.instance.reference();

  Future getJobs() async {
    DatabaseReference dataRef = FirebaseDatabase.instance
        .reference()
        .child("All Jobs Collection")
        .child(mUID);

    await dataRef.once().then((snapshot) {
      var dATA = snapshot.value;

      //  setState(() async {
      t5 = dATA['Cash Payment Debt'];
      t8 = dATA['Completed Amount'];
      // });
    });
  }

  Widget _buildFutureBuilder() {
    return Center(
      child: FutureBuilder(
        future: getJobs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.center,
              height: double.infinity,
              color: Color(0xb090A1AE),
              child: SingleChildScrollView(
                child: Center(
                  child: Column(children: <Widget>[
                    Text(
                      "Debt: ₦$t5",
                      style: TextStyle(
                          fontSize: 26,
                          color: primaryColor,
                          fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      onPress: () {
                        if (double.parse(t5) < 500) {
                          showCenterToast(
                              "You can't pay less than 500 naira", context);
                          return;
                        }
                        processOrder(context);
                      },
                      title: "PAY ADMIN   ",
                      iconLeft: false,
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
                    ),
                  ]),
                ),
              ),
            );
          }
          return CupertinoActivityIndicator(radius: 20);
        },
      ),
    );
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void processOrder(context) async {
    var initializer = RavePayInitializer(
        amount: double.parse(t5),
        publicKey: ravePublicKey,
        encryptionKey: raveEncryptKey)
      ..country = "NG"
      ..currency = "NGN"
      ..email = mEmail
      ..fName = mName
      ..lName = "lName"
      ..narration = "FABAT MANAGEMENT"
      ..txRef = "SCH${DateTime.now().millisecondsSinceEpoch}"
      ..acceptAccountPayments = false
      ..acceptCardPayments = true
      ..acceptAchPayments = false
      ..acceptGHMobileMoneyPayments = false
      ..acceptUgMobileMoneyPayments = false
      ..staging = true
      ..isPreAuth = true
      ..displayFee = true;

    RavePayManager()
        .prompt(context: context, initializer: initializer)
        .then((result) {
      if (result.status == RaveStatus.success) {
        doAfterSuccess(result.message);
      } else if (result.status == RaveStatus.cancelled) {
        if (mounted) {
          scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text(
                "Closed!",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              backgroundColor: primaryColor,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else if (result.status == RaveStatus.error) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(
                  "Error",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
                content: Text(
                  "An error has occured ",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              );
            });
      }

      print(result);
    });
  }

  void doAfterSuccess(String serverData) {
    final String ppA = "0";
    final String cA = ((double.parse(t8) * 5) + double.parse(t5)).toString();

    final Map<String, Object> allJobs = Map();
    allJobs.putIfAbsent("Cash Payment Debt", () => ppA);
    allJobs.putIfAbsent("Completed Amount", () => cA);

    String made =
        "You sent a payment of $t5 to the FABAT ADMIN, your debt has been cleared.";

    final Map<String, String> sentMessage = Map();
    sentMessage.putIfAbsent("notification_message", () => made);
    sentMessage.putIfAbsent("notification_time", () => thePresentTime());
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text(
              "Finishing processing",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 20),
            ),
            content: CupertinoActivityIndicator(radius: 20),
          );
        });
    rootRef
        .child("Notification Collection")
        .child("Mechanic")
        .child(mUID)
        .child(mUID)
        .set(sentMessage)
        .then((a) {
      rootRef
          .child("All Jobs Collection")
          .child(mUID)
          .update(allJobs)
          .then((a) {
        showToast("Payment Complete", context);
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (context) => MechMainPage()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(color: Color(0xb090A1AE), child: _buildFutureBuilder()),
    );
  }
}
