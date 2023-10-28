import 'dart:convert';

import 'package:corewallet_desktop/Handlers/ApiHandle.dart';
import 'package:corewallet_desktop/Models/FiatModel.dart';
import 'package:flutter/cupertino.dart';

class SettingProvider with ChangeNotifier{


  var setting_PageName="Setting";

  changeListnerSetting( String value){
    setting_PageName = value;
    notifyListeners();

  }

  FiatModel? fiatModel;
  getCurrency(url)async{
    ApiHandler.getParams(url,{"limit":"40"}).then((responseData){
      var value = json.decode(responseData.body);
      // print(value);
      fiatModel = FiatModel.fromJson(value);
      notifyListeners();
    });
  }

}