import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mechapp/database/cart_model.dart';
import 'package:mechapp/utils/my_models.dart';

import 'database/database.dart';
import 'libraries/carousel_slider.dart';
import 'libraries/custom_button.dart';
import 'main_cart.dart';

class EachProduct extends StatefulWidget {
  final ShopItem shopItem;
  EachProduct({Key key, @required this.shopItem}) : super(key: key);
  @override
  _EachProductState createState() => _EachProductState();
}

class _EachProductState extends State<EachProduct> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    var size = MediaQuery.of(context).size;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Product Item"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 8, left: 8.0, right: 8.0),
                child: CarouselSlider(
                  height: MediaQuery.of(context).size.height / 3,
                  autoPlay: true,
                  enableInfiniteScroll: true,
                  enlargeCenterPage: true,
                  pauseAutoPlayOnTouch: Duration(seconds: 5),
                  items: widget.shopItem.images.map((i) {
                    return Builder(
                      builder: (context) {
                        return Container(
                          width: size.width,
                          height: size.height / 2.5,
                          child: CachedNetworkImage(
                            imageUrl: i.toString(),
                            height: 100,
                            width: 100,
                            placeholder: (context, url) =>
                                CupertinoActivityIndicator(
                              radius: 20,
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Name:  ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.w700),
                    ),
                    Flexible(
                      child: Text(
                        widget.shopItem.name,
                        style: TextStyle(
                            fontSize: 18,
                            color: primaryColor,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Description: ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.w700),
                    ),
                    Flexible(
                      child: Text(
                        widget.shopItem.desc,
                        style: TextStyle(
                            fontSize: 18,
                            color: primaryColor,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Price:   ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                          fontWeight: FontWeight.w700),
                    ),
                    Flexible(
                      child: Text(
                        "\₦ " + widget.shopItem.price,
                        style: TextStyle(
                            fontSize: 25,
                            color: primaryColor,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Sold By:   ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                          fontWeight: FontWeight.w700),
                    ),
                    Flexible(
                      child: Text(
                        widget.shopItem.soldBy,
                        style: TextStyle(
                            fontSize: 24,
                            color: primaryColor,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              CustomButton(
                title: "   ADD TO CART   ",
                onPress: () async {
                  final database = await $FloorAppDatabase
                      .databaseBuilder('flutter_database.db')
                      .build();
                  database.cartDao.insertItem(CartModel(
                      widget.shopItem.itemID,
                      widget.shopItem.name,
                      widget.shopItem.desc,
                      widget.shopItem.images[0],
                      widget.shopItem.price,
                      widget.shopItem.soldBy));

                  scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      duration: Duration(milliseconds: 5000),
                      backgroundColor: primaryColor,
                      content: Text(
                        "Added to cart",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                      ),
                      action: SnackBarAction(
                        label: "CHECKOUT",
                        textColor: Colors.red,
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                               builder: (context) {
                                 return MainCart(main: "cart",);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.add_shopping_cart,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
