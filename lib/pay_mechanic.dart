import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mechapp/libraries/order_confirmed.dart';
import 'package:mechapp/utils/my_models.dart';
import 'package:mechapp/utils/type_constants.dart';
import 'package:rave_flutter/rave_flutter.dart';

import 'add_car_activity.dart';
import 'libraries/custom_button.dart';
import 'libraries/custom_dialog.dart';
import 'libraries/toast.dart';

class PayMechanicPage extends StatefulWidget {
  final EachMechanic mechanic;

  PayMechanicPage({Key key, @required this.mechanic}) : super(key: key);

  @override
  _PayMechanicPageState createState() => _PayMechanicPageState();
}

class _PayMechanicPageState extends State<PayMechanicPage> {
  String t3, t4, chosenImage = "em";

  final carsReference =
      FirebaseDatabase.instance.reference().child("Car Collection").child(mUID);

  List<Car> cars;
  StreamSubscription<Event> _onCarAddedSubscription;

  @override
  void initState() {
    super.initState();
    cars = new List();
    getJobs();
    _onCarAddedSubscription = carsReference.onChildAdded.listen(_onCarAdded);
  }

  @override
  void dispose() {
    _onCarAddedSubscription.cancel();
    super.dispose();
  }

  void _onCarAdded(Event event) {
    setState(() {
      cars.add(new Car.fromSnapshot(event.snapshot));
    });
  }

  Future<List<String>> getJobs() async {
    DatabaseReference dataRef = FirebaseDatabase.instance
        .reference()
        .child("All Jobs Collection")
        .child(widget.mechanic.uid);

    await dataRef.once().then((snapshot) {
      var dATA = snapshot.value;

      setState(() async {
        t3 = dATA['Pending Job'];
        t4 = dATA['Pending Amount'];
      });
    });

    List<String> list = [];
    return list;
  }

/*
  _payWithCard(BuildContext context) {
    final _rave = RaveCardPayment(
      isDemo: true,
      //        .setEncryptionKey("ab5cfe0059e5253250eb68a4")
      //       .setPublicKey("FLWPUBK-37eaceebb259b1537c67009339575c01-X")
      encKey: "FLWSECK_TEST3ba765b74b1f",
      publicKey: "FLWPUBK_TEST-9ba09916a6e4e8385b9fb2036439beac-X",
      transactionRef: "SCH${DateTime.now().millisecondsSinceEpoch}",
      amount: double.parse(amountController.text),
      email: mEmail,
      onSuccess: (response) {
        Toast.show("success", context,
            gravity: Toast.TOP, duration: Toast.LENGTH_LONG);

        doAfterSuccess(response);
      },
      onFailure: (err) {
        Toast.show("err", context,
            gravity: Toast.TOP, duration: Toast.LENGTH_LONG);

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
                  "An error has occured + $err",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              );
            });
      },
      onClosed: () {
        Toast.show("closed", context,
            gravity: Toast.TOP, duration: Toast.LENGTH_LONG);
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
      },
      context: context,
    );

    _rave.process();
  }
*/

  processTransaction(context) async {
    var initializer = RavePayInitializer(
        amount: double.parse(amountController.text),
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
      Toast.show("err", context,
          gravity: Toast.TOP, duration: Toast.LENGTH_LONG);

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

  bool isLoading = false;

  TextEditingController carController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  void doAfterSuccess(String serverData) async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    EachMechanic mech = widget.mechanic;
    String TransactionID = randomString();
    setState(() {
      isLoading = true;
    });

    // To get the current time
    String now = thePresentTime();
    String amount_ = amountController.text;

    //updates jobs on both side
    final Map<String, Object> valuesToCustomer = Map();
    valuesToCustomer.putIfAbsent("Mech Name", () => mech.name);
    valuesToCustomer.putIfAbsent("Customer Name", () => mName);
    valuesToCustomer.putIfAbsent("Mech UID", () => mech.uid);
    valuesToCustomer.putIfAbsent("Mech Number", () => mech.phoneNumber);
    valuesToCustomer.putIfAbsent("Mech Image", () => mech.image);
    valuesToCustomer.putIfAbsent("Trans Amount", () => amount_);
    valuesToCustomer.putIfAbsent("Trans Time", () => now);
    valuesToCustomer.putIfAbsent("Car Type", () => carController.text);
    valuesToCustomer.putIfAbsent("Server Confirmation", () => serverData);
    valuesToCustomer.putIfAbsent("Trans Description", () => "description_");
    valuesToCustomer.putIfAbsent("Trans ID", () => TransactionID.toString());
    valuesToCustomer.putIfAbsent("Trans Confirmation", () => "Unconfirmed");
    valuesToCustomer.putIfAbsent("Mech Confirmation", () => "Unconfirmed");
    valuesToCustomer.putIfAbsent("hasReviewed", () => "False");
    valuesToCustomer.putIfAbsent(
        "Timestamp", () => DateTime.now().millisecondsSinceEpoch);

    Map<String, Object> valuesToMech = Map();
    valuesToMech.putIfAbsent("Customer UID", () => mUID);
    valuesToMech.putIfAbsent("Customer Name", () => mName);
    valuesToMech.putIfAbsent("Customer Number", () => mPhone);
    valuesToMech.putIfAbsent("Trans Amount", () => amount_);
    valuesToMech.putIfAbsent("Trans Time", () => now);
    valuesToMech.putIfAbsent("Server Confirmation", () => serverData);
    valuesToMech.putIfAbsent("Car Type", () => carController.text);
    valuesToMech.putIfAbsent("Trans Description", () => "description_");
    valuesToMech.putIfAbsent("Trans ID", () => TransactionID.toString());
    valuesToMech.putIfAbsent("Trans Confirmation", () => "Unconfirmed");
    valuesToMech.putIfAbsent("Mech Confirmation", () => "Unconfirmed");
    valuesToMech.putIfAbsent(
        "Timestamp", () => DateTime.now().millisecondsSinceEpoch);

    int aa = int.parse(t3) + 1;
    int bb = int.parse(t4) + int.parse(amount_);

    final Map<String, String> updateJobs = Map();
    updateJobs.putIfAbsent("Pending Job", () => aa.toString());
    updateJobs.putIfAbsent("Pending Amount", () => bb.toString());

    String received = "You have a pending payment of ₦" +
        amount_ +
        " by " +
        mName +
        " and shall be available if confirmed by the customer. Thanks for using FABAT";

    String made = "You have made a payment of ₦" +
        amount_ +
        " to " +
        mech.name +
        " for " +
        carController.text +
        " and has been withdrawn from your Card. Thanks for using FABAT";

    final Map<String, Object> sentMessage = Map();
    sentMessage.putIfAbsent("notification_message", () => made);
    sentMessage.putIfAbsent("notification_time", () => now);
    sentMessage.putIfAbsent(
        "Timestamp", () => DateTime.now().millisecondsSinceEpoch);

    final Map<String, Object> receivedMessage = Map();
    receivedMessage.putIfAbsent("notification_message", () => received);
    receivedMessage.putIfAbsent("notification_time", () => now);
    receivedMessage.putIfAbsent(
        "Timestamp", () => DateTime.now().millisecondsSinceEpoch);

    showCupertinoDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              "Finishing processing",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 20),
            ),
            content: CupertinoActivityIndicator(radius: 20),
          );
        });
    databaseReference
        .child("Jobs Collection")
        .child("Mechanic")
        .child(mech.uid)
        .child(TransactionID)
        .set(valuesToMech)
        .then((a) {
      databaseReference
          .child("Jobs Collection")
          .child("Customer")
          .child(mUID)
          .child(TransactionID)
          .set(valuesToCustomer)
          .then((a) {
        databaseReference
            .child("All Jobs Collection")
            .child(mech.uid)
            .update(updateJobs)
            .then((a) {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                  builder: (context) => OrderConfirmedDone(
                        from: "Mech",
                      ),
                  fullscreenDialog: true));
        });
      });
    });
    databaseReference
        .child("Notification Collection")
        .child("Mechanic")
        .child(mech.uid)
        .push()
        .set(receivedMessage);

    databaseReference
        .child("Notification Collection")
        .child("Customer")
        .child(mUID)
        .push()
        .set(sentMessage);
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text("Pay Mechanic"),
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Color(0xb090A1AE)),
        child: ListView(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                imageUrl: widget.mechanic.image,
                height: 100,
                width: 100,
                placeholder: (context, url) => Image(
                  image: AssetImage("assets/images/person.png"),
                  height: 100,
                  width: 100,
                ),
                errorWidget: (context, url, error) => Image(
                  image: AssetImage("assets/images/person.png"),
                  height: 100,
                  width: 100,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                widget.mechanic.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontWeight: FontWeight.w900),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: RaisedButton(
                onPressed: () {
                  scaffoldKey.currentState.showBottomSheet(
                    (_) => Container(
                      height: MediaQuery.of(context).size.height / 3,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CustomButton(
                            title: "   Add Car   ",
                            onPress: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  fullscreenDialog: true,
                                  builder: (context) {
                                    return AddCarActivity();
                                  },
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                          Expanded(
                            child: MediaQuery.removePadding(
                              child: cars.length == 0
                                  ? emptyList("Cars")
                                  : ListView.builder(
                                      itemCount: cars.length,
                                      itemBuilder: (_, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                            carController.text =
                                                cars[index].brand +
                                                    " " +
                                                    cars[index].model +
                                                    ", " +
                                                    cars[index].date;
                                            chosenImage = cars[index].img;
                                            setState(() {});
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.black12)
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Center(
                                                child: ListTile(
                                                  title: Row(
                                                    children: <Widget>[
                                                      Text(
                                                        cars[index].brand,
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Text(
                                                        " - ${cars[index].date}",
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.black54),
                                                      )
                                                    ],
                                                  ),
                                                  subtitle: Text(
                                                    cars[index].model,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  leading: CachedNetworkImage(
                                                    imageUrl: cars[index].img,
                                                    height: 50,
                                                    width: 50,
                                                    placeholder: (context,
                                                            url) =>
                                                        CupertinoActivityIndicator(
                                                            radius: 10),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration:
                                                          new BoxDecoration(
                                                        image:
                                                            new DecorationImage(
                                                          fit: BoxFit.fill,
                                                          image: AssetImage(
                                                              "assets/images/car.png"),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  trailing: IconButton(
                                                      icon: Icon(
                                                        Icons.delete,
                                                        size: 30,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          barrierDismissible:
                                                              true,
                                                          builder: (_) =>
                                                              CustomDialog(
                                                            title:
                                                                "Are you sure you want to remove the car from garage?",
                                                            onClicked: () {
                                                              Navigator.pop(
                                                                  context);
                                                              carsReference
                                                                  .child(cars[
                                                                          index]
                                                                      .id)
                                                                  .remove();
                                                              setState(() {
                                                                cars.removeAt(
                                                                    index);
                                                              });
                                                            },
                                                            includeHeader: true,
                                                          ),
                                                        );
                                                      }),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              context: context,
                            ),
                          ),
                        ],
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                  );
                },
                child: TextField(
                  decoration: InputDecoration(
                    prefix: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CachedNetworkImage(
                        imageUrl: chosenImage,
                        height: 30,
                        width: 30,
                        placeholder: (_, url) =>
                            CupertinoActivityIndicator(radius: 10),
                        errorWidget: (_, url, error) => Container(
                          height: 30,
                          width: 30,
                          decoration: new BoxDecoration(
                            image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage("assets/images/car.png"),
                            ),
                          ),
                        ),
                      ),
                    ),
                    contentPadding: EdgeInsets.all(10),
                    labelText: "Add Car",
                  ),
                  enabled: false,
                  controller: carController,
                  style: TextStyle(fontSize: 22),
                  onTap: () {},
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: CupertinoTextField(
                prefix: Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: CachedNetworkImage(
                    imageUrl: chosenImage,
                    height: 30,
                    width: 30,
                    placeholder: (_, url) =>
                        CupertinoActivityIndicator(radius: 10),
                    errorWidget: (_, url, error) => Container(
                      height: 30,
                      width: 30,
                      decoration: new BoxDecoration(
                        image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage("assets/images/car.png"),
                        ),
                      ),
                    ),
                  ),
                ),
                placeholder: "Add Car",
                readOnly: true,
                onTap: (){
                  onAddCar(context);
                },

                enabled: false,
                placeholderStyle: TextStyle(),
                controller: amountController,
                padding: EdgeInsets.all(10),
                style: TextStyle(fontSize: 22),
                keyboardType: TextInputType.numberWithOptions(),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: CupertinoTextField(
                prefix: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image(
                    image: AssetImage("assets/images/naira_icon.png"),
                    height: 30,
                  ),
                ),
                placeholder: "Amount",
                controller: amountController,
                padding: EdgeInsets.all(10),
                style: TextStyle(fontSize: 22),
                keyboardType: TextInputType.numberWithOptions(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Ensure you have agreed on Job description and price with the mechanic before you proceed with payment",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                    fontWeight: FontWeight.w700),
              ),
            ),
            CustomButton(
              title: "   PROCEED   ",
              onPress: () {
                if (carController.text.isEmpty ||
                    amountController.text.isEmpty) {
                  showToast("Fill all fields", context);
                  return;
                }

                showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (_) => CupertinoAlertDialog(
                          title: Text("Confirmation!"),
                          content: Text(
                            "How do you want to pay the Mechanic?",
                            style: TextStyle(fontSize: 20),
                          ),
                          actions: <Widget>[
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.red),
                                  child: FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      showCupertinoDialog(
                                          context: context,
                                          builder: (_) {
                                            return CupertinoAlertDialog(
                                              title: Text(
                                                "Are you sure you want to pay by cash?",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20),
                                              ),
                                              actions: <Widget>[
                                                Center(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(5.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                          color: Colors.red),
                                                      child: FlatButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text(
                                                          "NO",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Center(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(5.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                        color: Color.fromARGB(
                                                            255, 22, 58, 78),
                                                      ),
                                                      child: FlatButton(
                                                        onPressed: () {
                                                          doAfterSuccess(
                                                              "By Cash");
                                                        },
                                                        child: Text(
                                                          "YES",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    child: Text(
                                      "With Cash",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Color.fromARGB(255, 22, 58, 78),
                                  ),
                                  child: FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      processTransaction(context);
                                    },
                                    child: Text(
                                      "With Card",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ));
              },
              icon: Icon(
                Icons.done,
                color: Colors.white,
              ),
              iconLeft: false,
            ),
          ],
        ),
      ),
    );
  }

 void onAddCar(context){
    scaffoldKey.currentState.showBottomSheet(
          (_) => Container(
        height: MediaQuery.of(context).size.height / 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CustomButton(
              title: "   Add Car   ",
              onPress: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    fullscreenDialog: true,
                    builder: (context) {
                      return AddCarActivity();
                    },
                  ),
                );
              },
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                child: cars.length == 0
                    ? emptyList("Cars")
                    : ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (_, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        carController.text =
                            cars[index].brand +
                                " " +
                                cars[index].model +
                                ", " +
                                cars[index].date;
                        chosenImage = cars[index].img;
                        setState(() {});
                      },
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12)
                            ],
                            borderRadius:
                            BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: ListTile(
                              title: Row(
                                children: <Widget>[
                                  Text(
                                    cars[index].brand,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight:
                                        FontWeight.w700,
                                        color:
                                        Colors.black),
                                  ),
                                  Text(
                                    " - ${cars[index].date}",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                        FontWeight.w400,
                                        color:
                                        Colors.black54),
                                  )
                                ],
                              ),
                              subtitle: Text(
                                cars[index].model,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                  FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              leading: CachedNetworkImage(
                                imageUrl: cars[index].img,
                                height: 50,
                                width: 50,
                                placeholder: (context,
                                    url) =>
                                    CupertinoActivityIndicator(
                                        radius: 10),
                                errorWidget:
                                    (context, url, error) =>
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration:
                                      new BoxDecoration(
                                        image:
                                        new DecorationImage(
                                          fit: BoxFit.fill,
                                          image: AssetImage(
                                              "assets/images/car.png"),
                                        ),
                                      ),
                                    ),
                              ),
                              trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    size: 30,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible:
                                      true,
                                      builder: (_) =>
                                          CustomDialog(
                                            title:
                                            "Are you sure you want to remove the car from garage?",
                                            onClicked: () {
                                              Navigator.pop(
                                                  context);
                                              carsReference
                                                  .child(cars[
                                              index]
                                                  .id)
                                                  .remove();
                                              setState(() {
                                                cars.removeAt(
                                                    index);
                                              });
                                            },
                                            includeHeader: true,
                                          ),
                                    );
                                  }),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                context: context,
              ),
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
    );
  }
}
