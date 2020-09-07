import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mechapp/libraries/custom_button.dart';

class NotiAndCategory extends StatefulWidget {
  TextEditingController controller;
  List boolList, valueList;
  final String type;

  NotiAndCategory(this.controller, this.boolList, this.type, this.valueList);

  @override
  _NotiAndCategoryState createState() => _NotiAndCategoryState();
}

class _NotiAndCategoryState extends State<NotiAndCategory> {
  List<bool> tempBoolList = List();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                  labelText: widget.type,
                  hintText: "Choose " + widget.type,
                  labelStyle: TextStyle(color: Colors.blue)),
              style: TextStyle(fontSize: 18),
              readOnly: true,
              controller: widget.controller,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                    title: Text(
                      "Choose " + widget.type,
                      style: TextStyle(fontSize: 20),
                    ),
                    content: Container(
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: ListView.builder(
                        itemCount: widget.valueList.length,
                        itemBuilder: (context, index) {
                          tempBoolList = widget.boolList;
                          return Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Material(
                              child: StatefulBuilder(
                                builder: (context, _setState) =>
                                    CheckboxListTile(
                                  title: Text(
                                    widget.valueList[index],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  value: widget.boolList[index],
                                  onChanged: (e) {
                                    _setState(
                                      () {
                                        if (widget.boolList[index]) {
                                          widget.boolList[index] =
                                              !widget.boolList[index];
                                        } else {
                                          widget.boolList[index] =
                                              !widget.boolList[index];
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
                                setState(() {
                                  widget.boolList = tempBoolList;
                                });
                                Navigator.of(context).pop();
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Cancel",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      CustomButton(
                        title: "OK",
                        onPress: () {
                          setState(() {
                            List<String> aTempList = [];
                            int intI = 0;
                            for (bool item in widget.boolList) {
                              if (item == true) {
                                aTempList.add(widget.valueList[intI]);
                              }
                              intI++;
                            }
                            widget.controller.text = aTempList
                                .toString()
                                .substring(1, aTempList.toString().length - 1);
                          });
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.done,
                          color: Colors.white,
                        ),
                        iconLeft: false,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Icon(
            Icons.unfold_more,
            color: Colors.deepPurple,
          ),
        ],
      ),
    );
  }
}
