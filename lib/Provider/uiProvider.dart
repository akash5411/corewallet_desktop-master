import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class UiProvider with ChangeNotifier{


  bool open=false;

  bool _changewatchlistColor = false;

  bool get myBoolValue => _changewatchlistColor;

  void setMyBoolValue(bool value) {
    _changewatchlistColor = value;
    notifyListeners();
  }






  String dashboardPage = "corewallet_dashboard";

  DashBoardpage(String value){
    dashboardPage = value;
    notifyListeners();
  }














}