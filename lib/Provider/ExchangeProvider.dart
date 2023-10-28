import 'package:flutter/cupertino.dart';

class ExchangeProvider with ChangeNotifier{


  var exchange_PageName="Exchange";

  changeListnerExchange( String value){
    // print("s 0");
    exchange_PageName= value;
    notifyListeners();

  }

}