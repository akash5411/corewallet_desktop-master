import 'dart:convert';
import 'dart:io';
import 'package:corewallet_desktop/Models/AccountTokenModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBTokenProvider{

  static final _databaseName = Platform.isMacOS ? "token_manager.db" : "/CoreWallet/path/Files/token_manager.db";
  static final DBTokenProvider dbTokenProvider = DBTokenProvider._();

  DBTokenProvider._();
  var databaseFactory = databaseFactoryFfi;


  var db ;
  initDB() async {
    sqfliteFfiInit();

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    db = await databaseFactory.openDatabase(
        path, options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db,version) async {
          await db.execute('CREATE TABLE Token('
              'id INTEGER,'
              'token_id INTEGER,'
              'acc_address TEXT,'
              'network_id INTEGER,'
              'market_id INTEGER,'
              'name TEXT,'
              'type TEXT,'
              'address TEXT,'
              'symbol TEXT,'
              'decimals INTEGER,'
              'logo TEXT,'
              'balance TEXT,'
              'network_name TEXT,'
              'price REAL,'
              'percent_change_24h REAL,'
              'accountId TEXT,'
              'explorer_url TEXT'
              ')');

        }
    )

    );
    return db;

  }

  createToken(AccountTokenList newToken) async{
    // final db= await database;
    final res = await db!.insert('Token', newToken.toJson());
    return res;
  }


  Future<int> deleteAllToken() async {
    // final db = await database;
    final res = await db.rawDelete('DELETE FROM Token');
    return res;
  }

  Future<int> deleteToken(String id) async {

    final res = await db.rawDelete("DELETE FROM Token Where id = $id");
    return res;
  }

  Future<int> deleteAccountToken(String accountId) async {
    // final db = await database;
    final res = await db.rawDelete("DELETE FROM Token Where accountId = '$accountId'");
    return res;
  }

  List<AccountTokenList> tokenList = [];
  List<AccountTokenList> searchTokenList = [];

  getAccountToken(String accountId,String searchController,String filter) async {
    // final db = await database;
    final res = await db.rawQuery("SELECT * FROM Token Where accountId = '$accountId'");
    // print("tokenlist Res::${res}");

    List<dynamic> list = res.map((c) => AccountTokenList.fromJson(c,accountId)).toList();
    tokenList = list.map((e) =>e as AccountTokenList).toList();
    // print("tokenid ::${DBTokenProvider.dbTokenProvider.tokenList.map((e) => e.token_id)}");


    if(filter == "Balance"){
      tokenList.sort((a, b) {
        return b.balance.compareTo(a.balance);
      });

    }else if(filter == "24H"){
      tokenList.sort((a, b) {
        return b.percentChange24H.compareTo(a.percentChange24H);
      });

    }else if(filter == "Name"){
      tokenList.sort((a, b) {
        return a.name.compareTo(b.name);
      });

    }else {
      tokenList.sort((a, b) {
        double aValue = (double.parse(a.balance) * double.parse("${a.price}"));
        double bValue = (double.parse(b.balance) * double.parse("${b.price}"));
        return aValue.compareTo(bValue);
      });
    }

    if(searchController != ""){
      searchTokenList = DBTokenProvider.dbTokenProvider.tokenList.where((element) => element.name.toLowerCase() == searchController).toList();
    }else{
      searchTokenList = tokenList;
    }

    return list;
  }

  updateTokenPrice(double live_price,double gain_loss,int id) async {

    // print("$live_price,$gain_loss,$symbol");

    List<AccountTokenList> list;

    // final db = await database;
    final res = await db.rawUpdate("UPDATE Token SET price = $live_price, percent_change_24h = $gain_loss WHERE market_id = '$id'");


    return res;
  }




  updateToken(AccountTokenList newToken,tokenId,id) async{
    // final db= await database;
    Map<String, dynamic> data = {
      "id": newToken.id,
      "token_id": newToken.token_id,
      "acc_address": newToken.accAddress,
      "network_id": newToken.networkId,
      "market_id": newToken.marketId,
      "name": newToken.name,
      "type": newToken.type,
      "address": newToken.address,
      "symbol": newToken.symbol,
      "price":newToken.price,
      "decimals": newToken.decimals,
      "logo": newToken.logo,
      "network_name": newToken.networkName,
      "explorer_url": newToken.explorer_url,
      "accountId": newToken.accountId,
    };

    final res = await db!.update('Token', data, where: "id = ? AND accountId = ? ",whereArgs: [tokenId,id],/* conflictAlgorithm: ConflictAlgorithm.replace,*/);
    getAccountToken(id,"","");
    return res;
  }

  updateTokenBalance(String balance,String id) async {

    // final db = await database;
    final res = await db.rawUpdate("UPDATE Token SET balance = $balance WHERE id = '$id'");


    return res;
  }

  getTokenUsdPrice (id) async{
    // final db = await database;
    final res = await db.rawQuery("SELECT price FROM Token Where token_id = '$id'");
    return res;
  }
}