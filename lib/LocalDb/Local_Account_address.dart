import 'dart:io';
import 'package:corewallet_desktop/Models/AccountAddress.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DbAccountAddress{

  static final _databaseName = Platform.isMacOS ? "account_address.db": "/CoreWallet/path/Files/account_address.db";
  static  DbAccountAddress dbAccountAddress = DbAccountAddress._();


  DbAccountAddress._();
  var databaseFactory = databaseFactoryFfi;


  var db ;
  initDB() async {
    sqfliteFfiInit();
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, _databaseName);

    db = await databaseFactory.openDatabase(
        path,options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db,version) async {
          await db.execute('CREATE TABLE AccountAddress('
              'accountId TEXT,'
              'publicAddress TEXT,'
              'privateAddress TEXT,'
              'publicKeyName TEXT,'
              'privateKeyName TEXT,'
              'networkId TEXT,'
              'networkName TEXT'
              ')');
        }
    ));

    return db;

  }

  Future<int?> deleteAllAccountAddress() async {
    final res = await db?.rawDelete('DELETE FROM AccountAddress');
    return res;
  }

  Future<int?> deleteAccountAddress(id) async {
    final res = await db?.rawDelete("DELETE FROM AccountAddress Where accountId = '$id'");
    return res;
  }



  createAccountAddress(accountId,publicAddress,privateAddress,publicKeyName,privateKeyName,networkId,networkName) async{
    final res= await db.insert('AccountAddress',<String, Object?> {'accountId': '$accountId','publicAddress': '$publicAddress','privateAddress': '$privateAddress','publicKeyName': '$publicKeyName','privateKeyName': '$privateKeyName','networkId': networkId,'networkName': '$networkName',});
    return res;
  }

  List<AccountAddress> allAccountAddress = [];

  getAccountAddress(accountId) async {
    final res = await db.rawQuery("SELECT * FROM AccountAddress Where accountId = '$accountId'");
    List<dynamic> list = res.map((c) => AccountAddress.fromJson(c)).toList();
    allAccountAddress = list.map((e) => e as AccountAddress).toList();

  }

  String selectAccountPublicAddress = "",selectAccountPrivateAddress = "";
  getPublicKey(accountId,networkId) async {
    final res = await db.rawQuery("SELECT publicAddress,privateAddress FROM AccountAddress Where accountId = '$accountId' AND networkId = '$networkId'");
    selectAccountPublicAddress = "${res[0]["publicAddress"]}";
    selectAccountPrivateAddress = "${res[0]["privateAddress"]}";
  }


}