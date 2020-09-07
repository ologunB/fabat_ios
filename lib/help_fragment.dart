import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mechapp/utils/type_constants.dart';

class HelpF extends StatefulWidget {
  @override
  _HelpFState createState() => _HelpFState();
}

class _HelpFState extends State<HelpF> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<String> list = [];

  Future<List<String>> _getHelps() async {
    DatabaseReference dataRef = FirebaseDatabase.instance
        .reference()
        .child("Help Collection")
        .child(userType);

    await dataRef.once().then((snapshot) {
      var kEYS = snapshot.value.keys;
      var dATA = snapshot.value;

      list.clear();
      for (var index in kEYS) {
        String tempString = dATA[index]['help_message'];
        list.add(tempString);
      }
    });
    return list;
  }

  Widget _buildFutureBuilder() {
    return Center(
      child: FutureBuilder<List<String>>(
        future: _getHelps(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: Container(
                color: Color(0xb090A1AE),
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, int index) {
                    return GestureDetector(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [BoxShadow(color: Colors.black12)],
                              borderRadius: BorderRadius.circular(18)),
                          child: Center(
                            child: ListTile(
                                title: Text(
                                  list[index],
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                leading: Icon(
                                  Icons.check_circle,
                                  size: 30,
                                  color: Theme.of(context).primaryColor,
                                )),
                          ),
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
