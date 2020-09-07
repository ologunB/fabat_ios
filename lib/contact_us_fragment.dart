import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mechapp/utils/type_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import 'libraries/custom_button.dart';
import 'libraries/toast.dart';

class ContactUsF extends StatefulWidget {
  @override
  _ContactUsFState createState() => _ContactUsFState();
}

class _ContactUsFState extends State<ContactUsF> {
  TextEditingController _messageController = TextEditingController();

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
          color: Color(0xb090A1AE),
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Write your Message",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height / 4,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: CupertinoTextField(
                      placeholder: "Type something here...",
                      placeholderStyle: TextStyle(
                          fontWeight: FontWeight.w300, color: Colors.black38),
                      padding: EdgeInsets.all(10),
                      maxLines: 10,
                      onChanged: (e) {
                        setState(() {});
                      },
                      style: TextStyle(fontSize: 20, color: Colors.black),
                      controller: _messageController,
                    ),
                  ),
                ),
                CustomButton(
                  title: "   SEND   ",
                  onPress: () async {
                    if (_messageController.text.toString().isEmpty) {
                      return showCenterToast("Message", context);
                    }
                    String _messageTitle = "Messsage To FABAT";
                    String _messageBody = _messageController.text.toString();
                    String _url =
                        "mailto:info@fabat.com.ng?subject=$_messageTitle&body=$_messageBody%20";

                    if (await canLaunch(_url)) {
                     // await launch(_url);
                    } else {
                      Toast.show(" Could not launch $_url", context,
                          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                      throw 'Could not launch $_url';
                    }
                  },
                  icon: Icon(
                    Icons.done,
                    color: Colors.white,
                  ),
                  iconLeft: false,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(18.0),
                      child: InkWell(
                        child: Image(
                          image: AssetImage("assets/images/instagram.png"),
                          height: 40,
                          width: 40,
                        ),
                        onTap: () async {
                          String _url1 =
                              "http://instagram.com/_u/officialfabatmngt";
                          String _url2 =
                              "http://instagram.com/officialfabatmngt";

                          if (await canLaunch(_url1)) {
                            await launch(_url1);
                          } else {
                            await launch(_url2);
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(18.0),
                      child: InkWell(
                        child: Image(
                          image: AssetImage("assets/images/facebook.png"),
                          height: 40,
                          width: 40,
                        ),
                        onTap: () async {
                          String _url1 = "fb://profile/100039244757529";
                          String _url2 =
                              "https://www.facebook.com/fabat.mngt.1";

                          if (await canLaunch(_url1)) {
                            await launch(_url1);
                          } else {
                            await launch(_url2);
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(18.0),
                      child: InkWell(
                        child: Image(
                          image: AssetImage("assets/images/twitter.png"),
                          height: 40,
                          width: 40,
                        ),
                        onTap: () async {
                          String _url1 =
                              "twitter://user?screen_name=fabatmanagement";
                          String _url2 =
                              "https://twitter.com/fabatmanagement?s=09";

                          if (await canLaunch(_url1)) {
                            await launch(_url1);
                          } else {
                            await launch(_url2);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Divider(
                    color: Colors.black.withAlpha(200),
                    height: 16,
                  ),
                ),
                Text(
                  "Reach Us Through",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
