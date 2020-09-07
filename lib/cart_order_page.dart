import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mechapp/database/cart_model.dart';
import 'package:mechapp/utils/type_constants.dart';
import 'package:rave_flutter/rave_flutter.dart';

import 'database/database.dart';
import 'libraries/custom_button.dart';
import 'libraries/order_confirmed.dart';

class OrderNowPage extends StatefulWidget {
  double total;
  List<CartModel> items;
  List<int> counters;
  OrderNowPage({this.total, this.items, this.counters});
  @override
  _OrderNowPageState createState() => _OrderNowPageState();
}

class _OrderNowPageState extends State<OrderNowPage>
    with AutomaticKeepAliveClientMixin {
  List<Item> _data = [Item(isExpanded: true)];
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController streetController = TextEditingController();
  TextEditingController zipController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
        elevation: 0.0,
        title: Text(
          "Preview Order",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Local Address",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CupertinoTextField(
                      padding: EdgeInsets.all(8),
                      placeholder: "Street Address",
                      controller: streetController,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CupertinoTextField(
                            padding: EdgeInsets.all(8),
                            controller: phoneNumberController,
                            placeholder: "Phone Number",
                            style: TextStyle(fontSize: 20),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CupertinoTextField(
                            padding: EdgeInsets.all(8),
                            controller: zipController,
                            placeholder: "City/Town",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _data[index].isExpanded = !isExpanded;
                  });
                },
                children: _data.map<ExpansionPanel>((Item item) {
                  return ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          title: Text(
                            "Cart Items",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                      body: ListView.builder(
                          itemCount: widget.items.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            double val =
                                double.parse(widget.items[index].price) *
                                    widget.counters[index];
                            String val1 = widget.items[index].price +
                                " x " +
                                widget.counters[index].toString() +
                                " = " +
                                val.toString();
                            return Card(
                              child: Container(
                                width: double.infinity,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        widget.items[index].name,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CachedNetworkImage(
                                            imageUrl: widget.items[index].image,
                                            height: 50,
                                            width: 50,
                                            placeholder: (context, url) =>
                                                CupertinoActivityIndicator(
                                              radius: 20,
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 9),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  "By: ${widget.items[index].seller}",
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                  ),
                                                ),
                                                Text(
                                                  "\₦$val1",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: primaryColor),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                      isExpanded: item.isExpanded,
                      canTapOnHeader: true);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Goods",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Text(
                  "\₦ ${commaFormat.format(widget.total)}", //widget.totalValue.toStringAsFixed(2),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo)),
              Text("Charge and Delivery",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              Text(
                  "\₦ ${commaFormat.format((widget.total * 0.1).floor())}", //widget.totalValue.toStringAsFixed(2),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo)),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Total",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  Text(
                      "\₦ ${(commaFormat.format(widget.total * 1.1))}", //widget.totalValue.toStringAsFixed(2),
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo)),
                ],
              ),
              Center(
                child: CustomButton(
                  title: "   PLACE TO ORDER   ",
                  onPress: () {
                    if (streetController.text.isEmpty ||
                        phoneNumberController.text.isEmpty ||
                        zipController.text.isEmpty) {
                      showCenterToast("Fill in correct Address", context);
                      return;
                    }
                    processOrder(context);
                  },
                  icon: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                  iconLeft: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void processOrder(context) async {
    var initializer = RavePayInitializer(
        amount: widget.total * 1.1,
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
                  "An error has occured, Try again ",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              );
            });
      }

      print(result);
    });
  }

  void doAfterSuccess(String serverData) async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

    String payTransactID = randomString();
    List productListName = List();
    List productListImages = List();
    List productListSellers = List();
    List numberOfCartItems = List();

    for (int i = 0; i < widget.items.length; i++) {
      productListName
          .add(widget.items[i].name + "_" + widget.counters[i].toString());
      productListImages.add(widget.items[i].image);
      productListSellers.add(widget.items[i].seller);
      numberOfCartItems.add(widget.counters[i]);
    }

    final String uid = mUID;

    final Map<String, Object> valuesToCustomer = Map();
    valuesToCustomer.putIfAbsent("Customer Name", () => mName);
    valuesToCustomer.putIfAbsent(
        "Customer Number", () => phoneNumberController.text);
    valuesToCustomer.putIfAbsent("Customer Email", () => mEmail);
    valuesToCustomer.putIfAbsent("Customer Uid", () => uid);
    valuesToCustomer.putIfAbsent("Product List", () => productListName);
    valuesToCustomer.putIfAbsent("Product Sellers", () => productListSellers);
    valuesToCustomer.putIfAbsent("Product Numbers", () => numberOfCartItems);
    valuesToCustomer.putIfAbsent("Product Images", () => productListImages);
    valuesToCustomer.putIfAbsent(
        "Total Amount Paid", () => (widget.total * 1.1).floor().toString());
    valuesToCustomer.putIfAbsent("Street Address", () => streetController.text);
    valuesToCustomer.putIfAbsent("City", () => zipController.text);
    valuesToCustomer.putIfAbsent("Trans Time", () => thePresentTime());
    valuesToCustomer.putIfAbsent("Server Confirmation", () => serverData);
    valuesToCustomer.putIfAbsent(
        "Trans Description", () => "Payment for Items");
    valuesToCustomer.putIfAbsent("Trans ID", () => payTransactID);
    valuesToCustomer.putIfAbsent("Trans Status", () => "Processing");
    valuesToCustomer.putIfAbsent(
        "Timestamp", () => DateTime.now().millisecondsSinceEpoch);

    String made = "You have made a payment of ₦ " +
        (widget.total * 1.1).floor().toString() +
        " and has been withdrawn from your Card. Thanks for using FABAT";

    final Map<String, Object> sentMessage = Map();
    sentMessage.putIfAbsent("notification_message", () => made);
    sentMessage.putIfAbsent("notification_time", () => thePresentTime());
    sentMessage.putIfAbsent(
        "Timestamp", () => DateTime.now().millisecondsSinceEpoch);

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
    databaseReference
        .child("Cart Collection")
        .child(uid)
        .child(payTransactID)
        .set(valuesToCustomer)
        .then((a) {
      databaseReference
          .child("Notification Collection")
          .child("Customer")
          .child(uid)
          .push()
          .set(sentMessage)
          .then((a) {
        databaseReference
            .child("Cart Transactions")
            .child("Ordered Items")
            .child(uid)
            .child(payTransactID)
            .set(valuesToCustomer)
            .then((a) {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                  builder: (context) => OrderConfirmedDone(from: "Cart"),
                  fullscreenDialog: true));
        });
      });
    });
    final database =
        await $FloorAppDatabase.databaseBuilder('flutter_database.db').build();
    database.cartDao.deleteAllItems();
  }
}

class Item {
  Item({this.isExpanded = false});

  bool isExpanded;
}
