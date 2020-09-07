import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mechapp/utils/type_constants.dart';

import 'libraries/custom_button.dart';
import 'libraries/show_exception_alert_dialog.dart';
import 'libraries/toast.dart';

class ChangePasswordF extends StatefulWidget {
  @override
  _ChangePasswordFState createState() => _ChangePasswordFState();
}

class _ChangePasswordFState extends State<ChangePasswordF> {
  bool isLoading = false;
  TextEditingController oldPass = TextEditingController();
  TextEditingController new1Pass = TextEditingController();
  TextEditingController new2Pass = TextEditingController();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future _changePassword(String password) async {
    setState(() {
      isLoading = true;
    });

    _firebaseAuth
        .signInWithEmailAndPassword(email: mEmail, password: oldPass.text)
        .then((a) {
      a.user.updatePassword(password).then((_) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                content: Text(
                  "Password successfully changed. Don't forget your password!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              );
            });
        oldPass.clear();
        new1Pass.clear();
        new2Pass.clear();
        FocusScope.of(context).unfocus();

        setState(() {
          isLoading = false;
        });
        return true;
      }).catchError((e) {
        showExceptionAlertDialog(
            context: context, exception: e, title: "Error");
        setState(() {
          isLoading = false;
        });

        return true;
      });
    }).catchError((e) {
      showExceptionAlertDialog(context: context, exception: e, title: "Error");
      setState(() {
        isLoading = false;
      });
    });
  }

  String theText = mEmail;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text(
          "Change Password",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.white, size: 28),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                "assets/images/bg_image.jpg",
              ),
              fit: BoxFit.fill),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Center(
            child: Card(
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(25.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(theText),
                    TextField(
                      readOnly: isLoading,
                      obscureText: true,
                      decoration: InputDecoration(hintText: "Old Password"),
                      style: TextStyle(fontSize: 20),
                      controller: oldPass,
                    ),
                    TextField(
                      readOnly: isLoading,
                      obscureText: true,
                      decoration: InputDecoration(hintText: "New Password"),
                      style: TextStyle(fontSize: 20),
                      controller: new1Pass,
                    ),
                    TextField(
                      // readOnly: isLoading,
                      obscureText: true,
                      decoration:
                          InputDecoration(hintText: "Retype New Password"),
                      style: TextStyle(fontSize: 20),
                      controller: new2Pass,
                    ),
                    CustomButton(
                      title: isLoading ? "" : "Change Password",
                      onPress: isLoading
                          ? null
                          : () async {
                              if (oldPass.text.toString().isEmpty) {
                                showEmptyToast("Old Password", context);
                                return;
                              } else if (new1Pass.text.toString().isEmpty) {
                                showEmptyToast("New Password", context);
                                return;
                              } else if (new1Pass.text.toString().length < 8) {
                                Toast.show(
                                    "Password must be at least 8 characters  ",
                                    context,
                                    duration: Toast.LENGTH_SHORT,
                                    gravity: Toast.BOTTOM);
                                return;
                              } else if (new2Pass.text.toString().isEmpty) {
                                showEmptyToast("New Password", context);
                                return;
                              } else if (new1Pass.text.toString() !=
                                  new2Pass.text.toString()) {
                                Toast.show(
                                    "The two new passwords must match", context,
                                    duration: Toast.LENGTH_LONG,
                                    gravity: Toast.BOTTOM);
                                return;
                              }
                              _changePassword(new1Pass.text.toString());
                              CupertinoActivityIndicator(radius: 20);
                            },
                      icon: isLoading
                          ? CupertinoActivityIndicator(radius: 20)
                          : Icon(
                              Icons.done,
                              color: Colors.white,
                            ),
                      iconLeft: false,
                      hasColor: isLoading ? true : false,
                      bgColor: Colors.blueGrey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
