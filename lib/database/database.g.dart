// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? join(await sqflite.getDatabasesPath(), name)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  MyCartDao _cartDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    return sqflite.openDatabase(
      path,
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `CartItems` (`productId` TEXT, `name` TEXT, `price` TEXT, `seller` TEXT, `image` TEXT, `status` TEXT, PRIMARY KEY (`productId`))');

        await callback?.onCreate?.call(database, version);
      },
    );
  }

  @override
  MyCartDao get cartDao {
    return _cartDaoInstance ??= _$MyCartDao(database, changeListener);
  }
}

class _$MyCartDao extends MyCartDao {
  _$MyCartDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _cartModelInsertionAdapter = InsertionAdapter(
            database,
            'CartItems',
            (CartModel item) => <String, dynamic>{
                  'productId': item.productId,
                  'name': item.name,
                  'price': item.price,
                  'seller': item.seller,
                  'image': item.image,
                  'status': item.status
                }),
        _cartModelDeletionAdapter = DeletionAdapter(
            database,
            'CartItems',
            ['productId'],
            (CartModel item) => <String, dynamic>{
                  'productId': item.productId,
                  'name': item.name,
                  'price': item.price,
                  'seller': item.seller,
                  'image': item.image,
                  'status': item.status
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _cartItemsMapper = (Map<String, dynamic> row) => CartModel(
      row['productId'] as String,
      row['name'] as String,
      row['status'] as String,
      row['image'] as String,
      row['price'] as String,
      row['seller'] as String);

  final InsertionAdapter<CartModel> _cartModelInsertionAdapter;

  final DeletionAdapter<CartModel> _cartModelDeletionAdapter;

  @override
  Future<List<CartModel>> getItems() async {
    return _queryAdapter.queryList('SELECT * FROM CartItems',
        mapper: _cartItemsMapper);
  }

  @override
  Future<void> deleteAllItems() async {
    await _queryAdapter.queryNoReturn('DELETE FROM CartItems');
  }

  @override
  Future<void> insertItem(CartModel cartModel) async {
    await _cartModelInsertionAdapter.insert(
        cartModel, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> deleteOneItem(CartModel cartModel) async {
    await _cartModelDeletionAdapter.delete(cartModel);
  }
}
