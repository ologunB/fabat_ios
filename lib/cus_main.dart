import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mechapp/change_password_fragment.dart';
import 'package:mechapp/contact_us_fragment.dart';
import 'package:mechapp/garage_fragment.dart';
import 'package:mechapp/help_fragment.dart';
import 'package:mechapp/home_fragment.dart';
import 'package:mechapp/jobs_fragment.dart';
import 'package:mechapp/libraries/custom_dialog.dart';
import 'package:mechapp/libraries/drawerbehavior.dart';
import 'package:mechapp/log_in.dart';
import 'package:mechapp/nearby_fragment.dart';
import 'package:mechapp/notifications_fragment.dart';
import 'package:mechapp/shop_fragment.dart';
import 'package:mechapp/utils/type_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database/database.dart';
import 'main_cart.dart';

class CusMainPage extends StatefulWidget {
  @override
  _CusMainPageState createState() => _CusMainPageState();
}

class _CusMainPageState extends State<CusMainPage> {
  final menu = new Menu(
    items: [
      MenuItem(
        id: 'Home',
        title: 'Home',
        icon: IconData(0xe88a, fontFamily: 'MaterialIcons'),
      ),
      MenuItem(
        id: 'My Garage',
        title: 'My Garage',
        icon: IconData(0xe531, fontFamily: 'MaterialIcons'),
      ),
      MenuItem(
        id: 'Nearby Services',
        title: 'Mechanic/Service Nearby',
        icon: IconData(0xe55e, fontFamily: 'MaterialIcons'),
      ),
      MenuItem(
        id: 'Shop',
        title: 'Shop',
        icon: IconData(0xeb3f, fontFamily: 'MaterialIcons'),
      ),
      MenuItem(
        id: 'Orders',
        title: 'Orders',
        icon: IconData(0xeb3f, fontFamily: 'MaterialIcons'),
      ),
      MenuItem(
        id: 'My Jobs',
        title: 'My Jobs',
        icon: IconData(0xe7ee, fontFamily: 'MaterialIcons'),
      ),
      MenuItem(
        id: 'Notifications',
        title: 'Notifications',
        icon: IconData(0xe7f4, fontFamily: 'MaterialIcons'),
      ),
      MenuItem(
        id: 'Help',
        title: 'Help',
        icon: IconData(0xe932, fontFamily: 'MaterialIcons'),
      ),
      MenuItem(
        id: 'Contact Us',
        title: 'Contact Us',
        icon: IconData(0xe0d0, fontFamily: 'MaterialIcons'),
      )
    ],
  );

  var title = 'Home';
  var selectedMenuItemId = 'Home';
  Widget currentWidget = HomeFragment();
  final List<Widget> pages = [
    HomeFragment(),
    MyGarage(),
    NearbyF(),
    ShopContainer("main"),
    MainCart(),
    MyJobsF(),
    NotificationF(),
    HelpF(),
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
      prefs.remove("name");
      prefs.remove("phone");
    });

    final database =
    await $FloorAppDatabase.databaseBuilder('flutter_database.db').build();
    database.cartDao.deleteAllItems();
  }

  Future<String> uid, email, name, type, phone;

  @override
  void initState() {
    super.initState();

    uid = _prefs.then((prefs) {
      return (prefs.getString('uid') ?? "customerUID");
    });
    email = _prefs.then((prefs) {
      return (prefs.getString('email') ?? "customerEmail");
    });
    name = _prefs.then((prefs) {
      return (prefs.getString('name') ?? "customerName");
    });
    type = _prefs.then((prefs) {
      return (prefs.getString('type') ?? "customerName");
    });
    phone = _prefs.then((prefs) {
      return (prefs.getString('phone') ?? "customerName");
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

  Widget _footerView() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            FutureBuilder<String>(
                future: type,
                builder: (context, snapshot) {
                  userType = snapshot.data;

                  return Center(
                    /*child: Text(
                        "$userType : ",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),*/
                  );
                }),
            FutureBuilder<String>(
                future: uid,
                builder: (context, snapshot) {
                  mUID = snapshot.data;

                  return Flexible(
                    child: Container(
                      padding: EdgeInsets.only(right: 13.0),
                      /*child: Text(
                          mUID,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),*/
                    ),
                  );
                }),
          ],
        ),
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
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CustomDialog(
                      title: "Are you sure you want to log out?",
                      onClicked: () async {
                        final database = await $FloorAppDatabase
                            .databaseBuilder('flutter_database.db')
                            .build();
                        database.cartDao.deleteAllItems();
                        FirebaseAuth.instance.signOut();
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
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage("assets/images/person.png"),
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
  bool isSearchingShop = false;
  @override
  Widget build(BuildContext context) {


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
                color: Color(0x44000000),
                offset: Offset(0.0, 0.0),
                blurRadius: 50.0,
                spreadRadius: 5.0)
          ],
          cornerRadius: 50,
          appBar: AppBarProps(title: Text(title), elevation: 0.0),
          menuView: MenuView(
            menu: menu,
            selectorColor: Colors.blue,
            headerView: _headerView(),
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
              } else if (itemId == "My Garage") {
                setState(() {
                  title = selectedMenuItemId;
                  currentWidget = pages[1];
                });
              } else if (itemId == "Nearby Services") {
                setState(() {
                  title = selectedMenuItemId;
                  currentWidget = pages[2];
                });
              } else if (itemId == "Shop") {
                setState(() {
                  title = selectedMenuItemId;
                  currentWidget = pages[3];
                });
              } else if (itemId == "Orders") {
                setState(() {
                  title = selectedMenuItemId;
                  currentWidget = pages[4];
                });
              } else if (itemId == "My Jobs") {
                setState(() {
                  title = selectedMenuItemId;
                  currentWidget = pages[5];
                });
              } else if (itemId == "Notifications") {
                setState(() {
                  title = selectedMenuItemId;
                  currentWidget = pages[6];
                });
              } else if (itemId == "Help") {
                setState(() {
                  title = selectedMenuItemId;
                  currentWidget = pages[7];
                });
              } else if (itemId == "Contact Us") {
                setState(() {
                  title = selectedMenuItemId;
                  currentWidget = pages[8];
                });
              }
            },
            footerView: _footerView(),
          ),
          contentView: Screen(
            contentBuilder: (context) => currentWidget,
            color: Colors.white,
          ),
        ));
  }
}
