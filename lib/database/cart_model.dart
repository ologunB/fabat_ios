import 'package:floor/floor.dart';

@Entity(tableName: "CartItems")
class CartModel {
  @primaryKey
  String productId;

  String name, price, seller, image, status;
/*
  String get name => _name;
  String get price => _price;
  String get seller => _seller;
  String get image => _image;
  String get status => _status;
  String get productID => _productId;*/
  CartModel(this.productId, this.name, this.status, this.image, this.price,
      this.seller);
}
