import 'package:flutter/material.dart';


import 'package:flutter/cupertino.dart';

class HistroyProvider with ChangeNotifier{


  var histroy_PageName="Histroy";

  changeListnerMarket( String value){
    histroy_PageName= value;
    notifyListeners();

  }

}