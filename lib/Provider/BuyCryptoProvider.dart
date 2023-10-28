import 'package:flutter/cupertino.dart';

class BuyCryptoProvider with ChangeNotifier{


  var buyCrypto_PageName="BuyCrypto";

  changeListnerbuycrypto( String value){
    // print("s 0");
    buyCrypto_PageName= value;
    notifyListeners();

  }

}