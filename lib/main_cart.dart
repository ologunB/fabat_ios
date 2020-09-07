import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mechapp/cart_order_page.dart';
import 'package:mechapp/database/cart_model.dart';
import 'package:mechapp/libraries/toast.dart';
import 'package:mechapp/utils/type_constants.dart';

import 'cart_history_details.dart';
import 'database/database.dart';
import 'libraries/custom_button.dart';

class MainCart extends StatefulWidget {
  String main;

  MainCart({this.main = "true"});

  @override
  _MainCartState createState() => _MainCartState();
}

class _MainCartState extends State<MainCart>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: primaryColor,
          elevation: 0.0,
          title: TabBar(
              isScrollable: true,
              unselectedLabelColor: Colors.white70,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(50), color: Colors.blue),
              tabs: [
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "My Cart",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("Cart History",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
          leading: widget.main == "true"
              ? SizedBox()
              : IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
          centerTitle: true,
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: TabBarView(children: [MyCart(), CartHistory()]),
        ),
      ),
    );
  }
}

class MyCart extends StatefulWidget {
  int a;

  MyCart({this.a});

  @override
  _MyCartState createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<CartModel> cartItems, items;
  List<int> counters;

  @override
  void initState() {
    a = 0;
    counters = List();

    getData();
    super.initState();
  }

  double total =0;
  Future<List<CartModel>> getItems;

  void getData() async {
    final database =
        await $FloorAppDatabase.databaseBuilder('flutter_database.db').build();
    final dao = database.cartDao;
    getItems = dao.getItems();
    cartItems = await dao.getItems();

    total = 0;

    Future.delayed(Duration(milliseconds: 500)).then((a) {
      for (int i = 0; i < cartItems.length; i++) {
        total = total + double.parse(cartItems[i].price);
        setState(() {});
      }
    });

    setState(() {});
  }

  Future<List<CartModel>> getThem() async {
    return (await $FloorAppDatabase
            .databaseBuilder('flutter_database.db')
            .build())
        .cartDao
        .getItems();
  }

  void doDelete(int index, BuildContext context) async {
    final database =
        await $FloorAppDatabase.databaseBuilder('flutter_database.db').build();
    database.cartDao.deleteOneItem(items[index]).then((a) {
      showToast("Item Deleted", context);
      items.removeAt(index);
      cartItems.removeAt(index);
      counters.removeAt(index);
      total = 0;
      for (int i = 0; i < cartItems.length; i++) {
        total = total + double.parse(cartItems[i].price);
      }
      setState(() {});
    });
  }

  int a = 0;

  @override
  Widget build(BuildContext context) {
/*    if (a == 0) {
      getData();
      a++;
    }*/
    return Scaffold(
      body: Container(
        color: Colors.grey[200],
        child: FutureBuilder(
            future: getThem(),
            builder: (context, snaps) {
              if (snaps.connectionState == ConnectionState.done) {
                items = snaps.data;

                List.generate(items.length, (i) {
                  counters.add(1);
                });
                return items.isEmpty
                    ? Center(
                        child: Text(
                          "Cart is empty, Go and shop",
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: items.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Card(
                            child: Container(
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      items[index].name,
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
                                          imageUrl: items[index].image,
                                          height: 50,
                                          width: 50,
                                          placeholder: (context, url) =>
                                              CupertinoActivityIndicator(
                                            radius: 20,
                                          ),
                                          errorWidget: (context, url, error) =>
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
                                                "By: ${items[index].seller}",
                                                style: TextStyle(
                                                  fontSize: 17,
                                                ),
                                              ),
                                              Text(
                                                "\₦ ${items[index].price}",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w900,
                                                    color: primaryColor),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Align(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: IconButton(
                                                  onPressed: () async {
                                                    doDelete(index, context);
                                                  },
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  IconButton(
                                                    icon: Icon(
                                                        Icons.remove_circle,
                                                        color: Colors.black38),
                                                    onPressed: () {
                                                      if (counters[index] > 1) {
                                                        counters[index]--;

                                                        total = total -
                                                            double.parse(
                                                                items[index]
                                                                    .price);
                                                        setState(() {});
                                                      }
                                                    },
                                                  ),
                                                  Text(
                                                    counters[index].toString(),
                                                    style: TextStyle(
                                                        fontSize: 24,
                                                        color: Colors.black38),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.add_circle,
                                                        color:
                                                            Colors.deepPurple),
                                                    onPressed: () {
                                                      if (counters[index] <
                                                          10) {
                                                        counters[index]++;
                                                        total = total +
                                                            double.parse(
                                                                items[index]
                                                                    .price);
                                                        setState(() {});
                                                      }
                                                    },
                                                  ),
                                                ],
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
                        });
              }
              return CupertinoActivityIndicator(
                radius: 11,
              );
            }),
      ),
      bottomNavigationBar: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("All",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  Text("\₦ ${total.floor()}",
                      //widget.totalValue.toStringAsFixed(2),
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo)),
                ],
              ),
              Center(
                child: CustomButton(
                  title: "    ORDER NOW   ",
                  onPress: () {
                    if (items.isEmpty) {
                      Toast.show("Cart is empty, Go to Shop", context,
                          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
                      return;
                    }
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => OrderNowPage(
                                total: total,
                                items: items,
                                counters: counters)));
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
}

class CartHistoryModel {
  List itemNames, sellers, numbers, images;
  String price, address, id, city, status;

  CartHistoryModel(
      {this.itemNames,
      this.sellers,
      this.numbers,
      this.images,
      this.price,
      this.address,
      this.id,
      this.city,
      this.status});
}

class CartHistory extends StatefulWidget {
  @override
  _CartHistoryState createState() => _CartHistoryState();
}

class _CartHistoryState extends State<CartHistory>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<CartHistoryModel> list = [];

  Stream<List<CartHistoryModel>> getData() async* {
    DatabaseReference dataRef = FirebaseDatabase.instance
        .reference()
        .child("Cart Collection")
        .child(mUID);

    await dataRef.once().then((snapshot) {
      var KEYS = snapshot.value.keys;
      var DATA = snapshot.value;
      print(DATA);

      list.clear();
      for (var index in KEYS) {
        List t1 = DATA[index]["Product List"];
        List t2 = DATA[index]["Product Sellers"];
        List t3 = DATA[index]["Product Images"];
        List t4 = DATA[index]["Product Numbers"];

        String t5 = DATA[index]["Total Amount Paid"];
        String t6 = DATA[index]["Street Address"];
        String t7 = DATA[index]["Trans ID"];
        String t8 = DATA[index]["City"];
        String t9 = DATA[index]["Trans Status"];

        list.add(CartHistoryModel(
            itemNames: t1,
            sellers: t2,
            images: t3,
            numbers: t4,
            price: t5,
            address: t6,
            id: t7,
            city: t8,
            status: t9));
      }
    });
    yield list;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CartHistoryModel>>(
        stream: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return list.isEmpty
                ? Center(
                    child: Text(
                      "Order is empty, Go and shop",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => CartHistoryDetails(
                                        cartItem: list[index],
                                      )));
                        },
                        child: Card(
                          child: Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      list[index].itemNames[0],
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CachedNetworkImage(
                                            imageUrl: list[index].images[0],
                                            height: 50,
                                            width: 50,
                                            placeholder: (context, url) =>
                                                CupertinoActivityIndicator(
                                                    radius: 20),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 9),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                "By: ${list[index].sellers[0]}",
                                                style: TextStyle(
                                                  fontSize: 17,
                                                ),
                                              ),

                                              Text(
                                                "\₦ ${list[index].price}",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.deepPurple),
                                              )
                                              //CupertinoTextField()
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Align(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    "x ",
                                                    style: TextStyle(
                                                        fontSize: 28,
                                                        color: Colors.black38),
                                                  ),
                                                  Text(
                                                    list[index]
                                                        .images
                                                        .length
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 28,
                                                        color: Colors.black38),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              list[index].status,
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: list[index].status ==
                                                        "Delivered"
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
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
                        ),
                      );
                    });
          }
          return CupertinoActivityIndicator(radius: 20);
        });
  }
}
