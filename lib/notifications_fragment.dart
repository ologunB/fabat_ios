import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mechapp/utils/type_constants.dart';

class TheModel {
  String msg, time;
  TheModel({this.msg, this.time});
}

class NotificationF extends StatefulWidget {
  @override
  _NotificationFState createState() => _NotificationFState();
}

class _NotificationFState extends State<NotificationF> {
  List<TheModel> list = [];

  Stream<List<TheModel>> _getNotifications() async* {
    DatabaseReference dataRef = FirebaseDatabase.instance
        .reference()
        .child("Notification Collection")
        .child(userType)
        .child(mUID);

    await dataRef.once().then((snapshot) {
      var KEYS = snapshot.value.keys;
      var DATA = snapshot.value;
      print(DATA);

      list.clear();
      for (var index in KEYS) {
        String tempMsg = DATA[index]['notification_message'];
        String tempTime = DATA[index]['notification_time'];
        list.add(TheModel(msg: tempMsg, time: tempTime));
      }
    });
    yield list;
  }

  Widget _buildFutureBuilder() {
    return Center(
      child: StreamBuilder<List<TheModel>>(
        stream: _getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return list.length == 0
                ? emptyList("Notification")
                : Center(
                    child: Container(
                      color: Color(0xb090A1AE),
                      child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [BoxShadow(color: Colors.black12)],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: ListTile(
                                    title: Text(
                                      list[index].msg,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      list[index].time,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.red),
                                    ),
                                    leading: Icon(Icons.notifications,
                                        size: 30,
                                        color: Theme.of(context).primaryColor)),
                              ),
                            ),
                          );
                        },
                      ),
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
      color: primaryColor,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
            height: double.infinity,
            color: Color(0xb090A1AE),
            child: _buildFutureBuilder()),
      ),
    );
  }
}
