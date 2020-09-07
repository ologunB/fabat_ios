import 'dart:async';

import 'package:floor/floor.dart';
import 'package:mechapp/database/cart_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'cart_dao.dart';
import 'cart_model.dart';

part 'database.g.dart';

@Database(version: 1, entities: [CartModel])
abstract class AppDatabase extends FloorDatabase {
  MyCartDao get cartDao;
}
