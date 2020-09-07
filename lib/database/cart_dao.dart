import 'package:floor/floor.dart';

import 'cart_model.dart';

@dao
abstract class MyCartDao {
  @Query('SELECT * FROM CartItems')
  Future<List<CartModel>> getItems();
/*
  @Query('SELECT * FROM CartItems')
  Stream<List<CartModel>> getItemsStream();
*/

  @insert
  Future<void> insertItem(CartModel cartModel);

  @Query('DELETE FROM CartItems')
  Future<void> deleteAllItems();

  @delete
  Future<void> deleteOneItem(CartModel cartModel);
}
