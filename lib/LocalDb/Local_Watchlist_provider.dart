import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../Models/WatchlistModel.dart';

class DBWatchListProvider {

  static final _databaseName = Platform.isMacOS ? "watchlist_manager.db" : "/CoreWallet/path/Files/watchlist_manager.db";

  static final DBWatchListProvider dbWatchListProvider = DBWatchListProvider._();

  DBWatchListProvider._();
  var databaseFactory = databaseFactoryFfi;


  var db ;
  initDB() async {
    // print("checkone${DBWatchListProvider.dbWatchListProvider.watchList.length}");
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    db = await databaseFactory.openDatabase(
        path, options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db,version) async {
          await db.execute(
              'CREATE TABLE WatchList('
              'market_id TEXT,'
              'name TEXT,'
              'symbol TEXT,'
              'marketCap TEXT,'
              'volume TEXT,'
              'price REAL,'
              'percent_change_24h REAL'
              ')');
        }
    ));
    return db;

  }

  List<WatchListModel> watchList = [];
  List<WatchListModel> SearchwatchList = [];
  getWatchList() async {
    watchList = [];
    SearchwatchList = [];
    final res = await db!.rawQuery("SELECT * FROM WatchList");
    // print("getWatchList ===> $res");
    List<WatchListModel> list = res.map<WatchListModel>((json) => WatchListModel.fromJson(json)).toList();
    watchList.addAll(list);
    SearchwatchList= watchList;


  }

  createWatchList(String marketID,String name,String symbol,String marketCap,String volume,double price,double percent_change_24h) async{
    final res= await db.insert(
        'WatchList',
        <String, Object?>{
          'market_id': '$marketID',
          'name': '$name',
          'symbol': '$symbol',
          'marketCap': '$marketCap',
          'volume': '$volume',
          'price': '$price',
          'percent_change_24h': '$percent_change_24h',
        }
    );
    // print("create watchList => $res");
    return res;
  }

  updateWatchList(String marketID,String name,String symbol,String marketCap,String volume,double price,double percent_change_24h) async{
    final res= await db.rawUpdate (
      "UPDATE WatchList SET market_id ='$marketID',name = '$name', symbol ='$symbol',marketCap = '$marketCap', volume = '$volume',price = '$price',percent_change_24h = '$percent_change_24h' WHERE market_id = '$marketID' "
    );
    // print("update watchList => $res");
    return res;
  }


  Future<int> deleteWatchlist(String id) async {
    final res = await db!.rawDelete("DELETE FROM WatchList Where market_id = '$id'");
    // print("print delete coin print");

    return res;
  }


  String coinName = "";
  getCoinById(marketId) async {
    coinName = "";
    final res = await db!.rawQuery("SELECT name FROM WatchList Where market_id = '$marketId'");
    if(res.isNotEmpty){
      coinName = "${res[0]['name']}";
    }else{
      coinName = "";
    }
  }

}
