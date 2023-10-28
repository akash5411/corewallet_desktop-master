import 'dart:io';
import 'package:corewallet_desktop/Models/ExchangeModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../Models/WatchlistModel.dart';

class DBExchange {

  static final _databaseName = Platform.isMacOS ? "exchange_manager.db": "/CoreWallet/path/Files/exchange_manager.db";

  static final DBExchange exchangeDB = DBExchange._();

  DBExchange._();
  var databaseFactory = databaseFactoryFfi;


  var db ;
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    db = await databaseFactory.openDatabase(
        path, options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db,version) async {
          await db.execute(
              'CREATE TABLE Exchange('
              'id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
              'from_token_name TEXT,'
              'from_token_icon TEXT,'
              'from_symbol TEXT,'
              'to_token_name TEXT,'
              'to_token_icon TEXT,'
              'to_symbol TEXT,'
              'from_amount TEXT,'
              'to_amount TEXT,'
              'hex_link TEXT,'
              'dataTime TEXT'
              ')');
        }
    ));
    return db;

  }

  List<ExchangeModel> exchangeList = [];
  getExchangeList() async {
    final res = await db!.rawQuery("SELECT * FROM Exchange");
    List<ExchangeModel> list = res.map<ExchangeModel>((json) => ExchangeModel.fromJson(json)).toList();
    exchangeList = list;
  }

  createExchangeList(ExchangeModel exchangeModel) async{
    final res= await db.insert(
        'Exchange',
        exchangeModel.toJson()
    );
    // print("create watchList => $res");
    return res;
  }

  Future<int> deleteExchange(String id) async {
    final res = await db!.rawDelete("DELETE FROM Exchange");
    return res;
  }

}
