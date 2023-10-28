import 'dart:io';
import 'package:corewallet_desktop/Models/newAccountModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBAccountProvider {
  static final _databaseName = Platform.isMacOS ? "account.db" : "/CoreWallet/path/Files/account.db";

  static final DBAccountProvider dbAccountProvider = DBAccountProvider._();


  DBAccountProvider._();
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
           await  db.execute('CREATE TABLE Account('
               'id INTEGER,'
               'device_id TEXT,'
               'name TEXT,'
               'mnemonic TEXT'
               ')');
         })
     );


    return db;
   }

  List<NewAccountList> newAccountList = [];
  getAllAccount() async {
    newAccountList.clear();
    final db = await initDB();
    var res = await db.query('Account');
    // print("get account ==>  $res");
    List<NewAccountList> list = res.map<NewAccountList>((json) => NewAccountList.fromJson(json)).toList();
    newAccountList.addAll(list);
  }

  List<NewAccountList> account = [];
  getAccountById(int id) async {
    newAccountList.clear();
    final db = await initDB();
    var res = await db.query('Account',where: "id = ?", whereArgs:['$id']);

    print("get account ==>  $res");
    List<NewAccountList> list = res.map<NewAccountList>((json) => NewAccountList.fromJson(json)).toList();
    account.addAll(list);
  }

  createAccount(String id,String deviceId,String name,String mnemonic) async{

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    var db = await databaseFactory.openDatabase(path);
    final res= await db.insert('Account', <String, Object?>{'id': '$id','device_id': '$deviceId','name': '$name','mnemonic': '$mnemonic',});

    return res;
  }

  Future<int> deleteAllAccount() async {
    final res = await db!.rawDelete('DELETE FROM Account');
    return res;
  }

  Future<int> deleteAccount(String id) async {

    final res = await db!.rawDelete("DELETE FROM Account Where id = '$id'");
    return res;
  }

}
