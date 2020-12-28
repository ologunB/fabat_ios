import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mechapp/utils/type_constants.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import 'libraries/custom_dialog.dart';

class JobModel {
  String otherPersonName,
      phoneNumber,
      amount,
      time,
      image,
      cusStatus,
      mechStatus,
      transactID,
      otherPersonUID,
      hasReviewed,
      carType;
  JobModel(
      {this.otherPersonName,
      this.phoneNumber,
      this.amount,
      this.time,
      this.image,
      this.cusStatus,
      this.hasReviewed,
      this.mechStatus,
      this.otherPersonUID,
      this.transactID,
      this.carType});
}

List<JobModel> list = [];
String selectedUID, preRating, preReview;
var rootRef = FirebaseDatabase.instance.reference();

class MyJobsF extends StatefulWidget {
  @override
  _MyJobsFState createState() => _MyJobsFState();
}

class _MyJobsFState extends State<MyJobsF> {
  Stream<List<JobModel>> _getJobs() async* {
    DatabaseReference dataRef =
        rootRef.child("Jobs Collection").child(userType).child(mUID);

    await dataRef.once().then((snapshot) {
      var kEYS = snapshot.value.keys;
      var dATA = snapshot.value;

      list.clear();
      for (var index in kEYS) {
        String tempName = dATA[index]['Mech Name'];
        String tempPrice = dATA[index]['Trans Amount'];
        String tempCusStatus = dATA[index]['Trans Confirmation'];
        String tempImage = dATA[index]['Mech Image'];
        String tempHasReviewed = dATA[index]['hasReviewed'];
        String tempNumber = dATA[index]['Mech Number'];
        String tempTime = dATA[index]['Trans Time'];
        String tempMechStatus = dATA[index]['Mech Confirmation'];
        String tempMechUID = dATA[index]['Mech UID'];
        String tempTransID = dATA[index]['Trans ID'];
        String tempCarType = dATA[index]['Car Type'];

        list.add(
          JobModel(
              otherPersonName: tempName,
              amount: tempPrice,
              phoneNumber: tempNumber,
              image: tempImage,
              cusStatus: tempCusStatus,
              time: tempTime,
              hasReviewed: tempHasReviewed,
              mechStatus: tempMechStatus,
              otherPersonUID: tempMechUID,
              transactID: tempTransID,
              carType: tempCarType),
        );
      }
    });
    yield list;
  }

  Widget _buildFutureBuilder() {
    return Center(
      child: StreamBuilder<List<JobModel>>(
        stream: _getJobs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return list.length == 0
                ? emptyList("Jobs")
                : Container(
                    color: Color(0xb090A1AE),
                    height: double.infinity,
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return Center(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: CachedNetworkImage(
                                      imageUrl: list[index].image ?? "ki",
                                      height: 70,
                                      width: 70,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        height: 70,
                                        width: 70,
                                        decoration: new BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: new DecorationImage(
                                            fit: BoxFit.fill,
                                            image: AssetImage(
                                                "assets/images/engineer.png"),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    list[index].otherPersonName ?? "ki",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 22, color: Colors.deepPurple),
                                  ),
                                  Text(
                                    list[index].phoneNumber ?? "ki",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w900),
                                  ),
                                  Text(
                                    "₦" + list[index].amount?? "ki",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Center(
                                    child: Text(
                                      list[index].time?? "ki",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 22, color: Colors.black),
                                    ),
                                  ),
                                  ConfirmButton(index: index),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, childAspectRatio: 0.6),
                    ),
                  );
          }
          return CupertinoActivityIndicator(radius: 20);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      color: Color(0xb090A1AE),
      child: _buildFutureBuilder(),
    );
  }
}

class ConfirmButton extends StatefulWidget {
  final int index;
  ConfirmButton({this.index});
  @override
  _ConfirmButtonState createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<ConfirmButton> {
  String status = "Confirm Job?";
  Color statusColor = Colors.blue;

  void confirmJob(int index, aSetState, context) async {
    String otherUID = list[index].otherPersonUID;
    String transactID = list[index].transactID;
    String amount = list[index].amount;
    String carType = list[index].carType;
    String nameOfMech = list[index].otherPersonName;

    String made = "Your payment of ₦" +
        amount +
        " to " +
        nameOfMech +
        " for " +
        carType +
        " has been confirmed by you. Thanks for using FABAT";

    String received = "You have a confirmed payment of ₦" +
        amount +
        " by " +
        mName +
        " and shall be available soonest. Thanks for using FABAT";

    final Map<String, Object> sentMessage = Map();
    sentMessage.putIfAbsent("notification_message", () => made);
    sentMessage.putIfAbsent("notification_time", () => thePresentTime());
    sentMessage.putIfAbsent(
        "Timestamp", () => DateTime.now().millisecondsSinceEpoch);

    final Map<String, Object> receivedMessage = Map();
    receivedMessage.putIfAbsent("notification_message", () => received);
    receivedMessage.putIfAbsent("notification_time", () => thePresentTime());
    receivedMessage.putIfAbsent(
        "Timestamp", () => DateTime.now().millisecondsSinceEpoch);

    Map<String, Object> valuesToMech = Map();
    valuesToMech.putIfAbsent("Trans Confirmation", () => "Confirmed");

    final Map<String, Object> valuesToCustomer = Map();
    valuesToCustomer.putIfAbsent("Trans Confirmation", () => "Confirmed");

    rootRef
        .child("Jobs Collection")
        .child("Mechanic")
        .child(otherUID)
        .child(transactID)
        .update(valuesToMech);

    rootRef
        .child("Notification Collection")
        .child("Mechanic")
        .child(otherUID)
        .child(transactID)
        .set(receivedMessage);

    rootRef
        .child("Jobs Collection")
        .child("Customer")
        .child(mUID)
        .child(transactID)
        .update(valuesToCustomer);
    rootRef
        .child("Notification Collection")
        .child("Customer")
        .child(mUID)
        .push()
        .set(sentMessage);
    aSetState(() {
      bool isConfirmed = list[widget.index].mechStatus == "Confirmed";
      status = isConfirmed ? "RATE MECH." : "PENDING!";
      statusColor = isConfirmed ? Colors.teal : Colors.red;
    });
    Navigator.pop(context);
    showToast("Confirmed", context);
  }

  void rateMechanic(
      int index, String reviewMessage, double givenRate, aSetState) async {
    final Map<String, Object> review = Map();
    review.putIfAbsent("review_message", () => reviewMessage);
    review.putIfAbsent("review_time", () => thePresentTime());
    review.putIfAbsent(
        "Timestamp", () => DateTime.now().millisecondsSinceEpoch);

    final Map<String, Object> cusVal = Map();
    cusVal.putIfAbsent("hasReviewed", () => "True");

    try {
      double _rate = double.parse(preRating);
      int _review = int.parse(preReview);

      int presentReview = _review + 1;
      String presentRate =
          (((_rate * _review) + givenRate) / presentReview).toString();
      final Map<String, Object> updateMech = Map();
      updateMech.putIfAbsent("Rating", () => presentRate.substring(0, 3));
      updateMech.putIfAbsent("Reviews", () => presentReview.toString());

      await rootRef
          .child("Mechanic Collection")
          .child(selectedUID)
          .update(updateMech);

      await rootRef
          .child("Mechanic Reviews")
          .child("Mechanic")
          .child(selectedUID)
          .child(randomString())
          .set(review);
      await rootRef
          .child("Jobs Collection")
          .child("Customer")
          .child(mUID)
          .child(list[index].transactID)
          .update(cusVal);
      aSetState(() {
        status = "CONFIRMED!";
        statusColor = Colors.black12;
      });

      Navigator.pop(context);
      showToast("Review Submitted", context);
    } catch (exp) {
      showToast("Getting data, Try again", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _messageController = TextEditingController();
    double ratingNum = 3;
    if (list[widget.index].cusStatus == "Confirmed" &&
        list[widget.index].mechStatus == "Confirmed") {
      if (list[widget.index].hasReviewed == "True") {
        status = "COMPLETED!";
        statusColor = Colors.black12;
      } else {
        status = "RATE MECH.";
        statusColor = Colors.teal;
      }
    } else if (list[widget.index].cusStatus == "Confirmed") {
      status = "PENDING!";
      statusColor = Colors.red;
    } else {
      status = "Confirm Job?";
      statusColor = Colors.blue;
    }
    return StatefulBuilder(
      builder: (context, _setState) => Center(
        child: RaisedButton(
          color: statusColor,
          onPressed: () async {
            selectedUID = list[widget.index].otherPersonUID;

            switch (status) {
              case "Confirm Job?":
                {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => CustomDialog(
                      title: "Are you sure you want to confirm the Mechanic?",
                      onClicked: () {
                        confirmJob(widget.index, _setState, context);
                      },
                      includeHeader: true,
                    ),
                  );

                  break;
                }
              case "RATE MECH.":
                {
                  await rootRef
                      .child("Mechanic Collection")
                      .child(selectedUID)
                      .once()
                      .then((snapshot) {
                    preRating = snapshot.value["Rating"];
                    preReview = snapshot.value["Reviews"];
                  });
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => CupertinoAlertDialog(
                      title: Text("Rate your dealing with " +
                          list[widget.index].otherPersonName),
                      content: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 10),
                          Text(
                            "Please select some stars and give some feedback",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          SizedBox(height: 10),
                          StatefulBuilder(
                            builder: (context, _setState) => SmoothStarRating(
                                allowHalfRating: true,
                                onRated: (val) {
                                  _setState(() {
                                    ratingNum = val;
                                  });
                                },
                                starCount: 5,
                                rating: ratingNum,
                                size: 40.0,
                                filledIconData: Icons.star,
                                halfFilledIconData: Icons.star_half,
                                color: Colors.blue,
                                borderColor: Colors.blue,
                                spacing: 0.0),
                          ),
                          SizedBox(height: 10),
                          CupertinoTextField(
                            placeholder: "Type something here...",
                            placeholderStyle:
                                TextStyle(fontWeight: FontWeight.w400),
                            padding: EdgeInsets.all(10),
                            maxLines: 7,
                            onChanged: (e) {
                              setState(() {});
                            },
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            controller: _messageController,
                          ),
                        ],
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
                                },
                                child: Text(
                                  "CANCEL",
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
                                  rateMechanic(
                                      widget.index,
                                      _messageController.text == null
                                          ? "No review"
                                          : _messageController.text,
                                      ratingNum,
                                      _setState);
                                },
                                child: Text(
                                  "  RATE   ",
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
                    ),
                  );
                  break;
                }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(
              status,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
