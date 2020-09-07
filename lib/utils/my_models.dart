import 'package:firebase_database/firebase_database.dart';

class Car {
  String _id;
  String _brand;
  String _model;
  String _date;
  String _regNo;
  String _img;

  Car(this._id, this._brand, this._model, this._date, this._regNo, this._img);

  String get brand => _brand;

  String get model => _model;

  String get date => _date;

  String get regNo => _regNo;

  String get id => _id;
  String get img => _img;

  Car.fromSnapshot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _brand = snapshot.value['car_brand'];
    _model = snapshot.value['car_model'];
    _date = snapshot.value['car_date'];
    _regNo = snapshot.value['car_num'];
    _img = snapshot.value['car_image'];
  }

  Car.map(dynamic obj) {
    this._brand = obj['car_brand'];
    this._model = obj['car_model'];
    this._date = obj['car_date'];
    this._regNo = obj['car_num'];
    this._img = obj['car_image'];
  }
}

class EachMechanic {
  final String uid,
      name,
      locality,
      descrpt,
      email,
      phoneNumber,
      image,
      jobsDone,
      city,
      rating,
      dBtwn,
      streetName;
  List categories, specs;
  var mLat, mLong;

  EachMechanic(
      {this.uid,
      this.name,
      this.locality,
      this.categories,
      this.specs,
      this.descrpt,
      this.email,
      this.phoneNumber,
      this.image,
      this.jobsDone,
      this.mLat,
      this.city,
      this.mLong,
      this.dBtwn,
      this.rating,
      this.streetName});
}

class EachJob {
  String id;
  String _jobsDone;

  EachJob(this._jobsDone);

  String get jobsDone => _jobsDone;

  EachJob.fromSnapshot(DataSnapshot snapshot) {
    _jobsDone = snapshot.key;
  }
}

class ShopItem {
  String name, price, soldBy, desc, email, number, itemID, type;
  List images;

  ShopItem(
      {this.name,
      this.price,
      this.soldBy,
      this.desc,
      this.images,
      this.email,
      this.number,
      this.itemID,
      type});
}
