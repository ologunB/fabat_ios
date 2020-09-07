import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mechapp/change_password_fragment.dart';
import 'package:mechapp/contact_us_fragment.dart';
import 'package:mechapp/help_fragment.dart';
import 'package:mechapp/libraries/custom_dialog.dart';
import 'package:mechapp/log_in.dart';
import 'package:mechapp/mechanic/mech_make_payment.dart';
import 'package:mechapp/mechanic/mech_profile_fragment.dart';
import 'package:mechapp/mechanic/mech_request_payment.dart';
import 'package:mechapp/notifications_fragment.dart';
import 'package:mechapp/utils/type_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../libraries/drawerbehavior.dart';
import 'mech_home_fragment.dart';
import 'mech_jobs_fragment.dart';

class MechMainPage extends StatefulWidget {
  @override
  _MechMainPageState createState() => _MechMainPageState();
}

class _MechMainPageState extends State<MechMainPage> {
  final menu = new Menu(
    items: [
      new MenuItem(
        id: 'Home',
        title: 'Home',
        icon: IconData(0xe88a, fontFamily: 'MaterialIcons'),
      ),
      new MenuItem(
        id: 'Profile',
        title: 'My Profile',
        icon: IconData(0xe7fd, fontFamily: 'MaterialIcons'),
      ),
      new MenuItem(
        id: 'My Jobs',
        title: 'My Jobs',
        icon: IconData(0xe7ee, fontFamily: 'MaterialIcons'),
      ),
      new MenuItem(
        id: 'Notifications',
        title: 'Notifications',
        icon: IconData(0xe7f4, fontFamily: 'MaterialIcons'),
      ),
      new MenuItem(
        id: 'Help',
        title: 'Help',
        icon: IconData(0xe932, fontFamily: 'MaterialIcons'),
      ),
      new MenuItem(
        id: 'Make Payment',
        title: 'Make Payment',
        icon: Icons.payment,
      ),
      new MenuItem(
        id: 'Request Payment',
        title: 'Request Payment',
        icon: Icons.assignment_return,
      ),
      new MenuItem(
        id: 'Contact Us',
        title: 'Contact Us',
        icon: IconData(0xe0d0, fontFamily: 'MaterialIcons'),
      )
    ],
  );

  var title = 'Home';
  var selectedMenuItemId = 'Home';
  Widget currentWidget;
  final List<Widget> pages = [
    MechHomeFragment(),
    MechProfileFragment(),
    MechJobsF(),
    NotificationF(),
    HelpF(),
    MechMakePayment(),
    MechRequestPayment(),
    ContactUsF()
  ];
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future afterLogout() async {
    final SharedPreferences prefs = await _prefs;

    setState(() {
      prefs.setBool("isLoggedIn", false);
      prefs.remove("type");
      prefs.remove("uid");
      prefs.remove("email");
      prefs.remove("phone");
    });
  }

  Future<String> uid;
  Future<String> email;
  Future<String> name;
  Future<String> type, phone;

  @override
  void initState() {
    super.initState();

    uid = _prefs.then((prefs) {
      return (prefs.getString('uid') ?? "mechUID");
    });
    email = _prefs.then((prefs) {
      return (prefs.getString('email') ?? "mechEmail");
    });
    name = _prefs.then((prefs) {
      return (prefs.getString('name') ?? "mechName");
    });
    type = _prefs.then((prefs) {
      return (prefs.getString('type') ?? "mechName");
    });

    phone = _prefs.then((prefs) {
      return (prefs.getString('phone') ?? "mechName");
    });

    currentWidget = MechHomeFragment();

    setState(() {
      currentWidget = MechHomeFragment();
    });
    doAssign();
  }

  void doAssign() async {
    mName = await name;
    userType = await type;
    mEmail = await email;
    mPhone = await phone;
    mUID = await uid;
  }

  @override
  Widget build(BuildContext context) {
    Widget _headerView() {
      return Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: new BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: new DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage("assets/images/engineer.png"),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FutureBuilder<String>(
                        future: name,
                        builder: (context, snapshot) {
                          mName = snapshot.data;

                          return Text(
                            mName,
                            style: Theme.of(context)
                                .textTheme
                                .subhead
                                .copyWith(color: Colors.white),
                          );
                        },
                      ),
                      FutureBuilder<String>(
                        future: email,
                        builder: (context, snapshot) {
                          mEmail = snapshot.data;

                          return Text(
                            mEmail,
                            style:
                                Theme.of(context).textTheme.subtitle.copyWith(
                                      color: Colors.white.withAlpha(200),
                                    ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Divider(
            color: Colors.white.withAlpha(200),
            height: 16,
          )
        ],
      );
    }

    Widget _footerView() {
      return Column(
        children: <Widget>[
          Row(children: <Widget>[
            FutureBuilder<String>(
                future: type,
                builder: (context, snapshot) {
                  userType = snapshot.data;

                  return Center(
                      /* child: Text(
                      "$userType : ",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),*/
                      );
                }),
            FutureBuilder<String>(
                future: uid,
                builder: (context, snapshot) {
                  mUID = snapshot.data;

                  return new Flexible(
                    child: new Container(
                      padding: new EdgeInsets.only(right: 13.0),
                      /*child: Text(
                        mUID,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),*/
                    ),
                  );
                }),
          ]),
          Divider(
            color: Colors.white.withAlpha(200),
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FlatButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => CustomDialog(
                        title: "Are you sure you want to log out?",
                        onClicked: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushReplacement(
                            CupertinoPageRoute(
                              fullscreenDialog: true,
                              builder: (context) {
                                return LogOn();
                              },
                            ),
                          );
                          afterLogout();
                        },
                        includeHeader: true,
                      ),
                    );
                  },
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 0.0),
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          "Logout",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              VerticalDivider(
                width: 5,
                thickness: 5,
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      fullscreenDialog: true,
                      builder: (context) {
                        return ChangePasswordF();
                      },
                    ),
                  );
                },
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Change Password",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    return WillPopScope(
      onWillPop: () async {
        showDialog(
            context: context,
            builder: (_) {
              return CustomDialog(
                title: "Do you want to exit the app?",
                includeHeader: true,
                onClicked: () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
              );
            });
        return false;
      },
      child: DrawerScaffold(
        percentage: 0.7,
        contentShadow: [
          BoxShadow(
              color: const Color(0x44000000),
              offset: const Offset(0.0, 0.0),
              blurRadius: 50.0,
              spreadRadius: 5.0)
        ],
        cornerRadius: 50,
        appBar: AppBarProps(
          title: Text(title),
        ),
        menuView: MenuView(
          menu: menu,
          selectorColor: Colors.blue,
          headerView: _headerView(),
          footerView: _footerView(),
          animation: false,
          color: Theme.of(context).primaryColor,
          selectedItemId: selectedMenuItemId,
          onMenuItemSelected: (String itemId) {
            selectedMenuItemId = itemId;
            if (itemId == "Home") {
              setState(() {
                title = selectedMenuItemId;
                currentWidget = pages[0];
              });
            } else if (itemId == "Profile") {
              setState(() {
                title = selectedMenuItemId;
                currentWidget = pages[1];
              });
            } else if (itemId == "My Jobs") {
              setState(() {
                title = selectedMenuItemId;
                currentWidget = pages[2];
              });
            } else if (itemId == "Notifications") {
              setState(() {
                title = selectedMenuItemId;
                currentWidget = pages[3];
              });
            } else if (itemId == "Help") {
              setState(() {
                title = selectedMenuItemId;
                currentWidget = pages[4];
              });
            } else if (itemId == "Make Payment") {
              setState(() {
                title = selectedMenuItemId;
                currentWidget = pages[5];
              });
            } else if (itemId == "Request Payment") {
              setState(() {
                title = selectedMenuItemId;
                currentWidget = pages[6];
              });
            } else if (itemId == "Contact Us") {
              setState(() {
                title = selectedMenuItemId;
                currentWidget = pages[7];
              });
            }
          },
        ),
        contentView: Screen(
          contentBuilder: (context) => currentWidget,
          color: Colors.white,
        ),
      ),
    );
  }
}
