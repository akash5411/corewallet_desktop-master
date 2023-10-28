import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class WatchListProvider with ChangeNotifier{
  bool open=false;



  String watchListPage = "WatchList";

  DashBoardpage(String value){
    watchListPage = value;
    notifyListeners();
  }














}