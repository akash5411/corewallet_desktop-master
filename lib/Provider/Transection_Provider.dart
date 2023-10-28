import 'dart:convert';

import 'package:corewallet_desktop/values/Helper/helper.dart';
import 'package:flutter/material.dart';

import '../Handlers/ApiHandle.dart';
import '../Models/TransectionModel.dart';
import '../Models/onlineTransection.dart';

class TransectionProvider with ChangeNotifier{

  var message="";
  var body;
  bool isLoading = false;
  bool isSuccess = false;

  var networkData;
  getNetworkFees(data,url,context) async {
    isLoading = true;
    isSuccess = false;
    notifyListeners();

    try {
      await ApiHandler.post(data, url).then((responseData) {
        var value = json.decode(responseData.body);
        // print("getNetrowkFees => $value");

        if (responseData.statusCode == 200 && value["status"] == true) {
          networkData = value;
          isSuccess = true;
          isLoading = false;
          notifyListeners();
        }
        else {
          isSuccess = false;
          isLoading = false;
          notifyListeners();

          print("=========== Get Network Fees Api Error ==========");
        }
      });
    }catch(e){
      Helper.dialogCall.showToast(context, "Ops something is wrong try again letter");
      isSuccess = true;
      isLoading = false;
      notifyListeners();
    }
  }


  bool isSend = false;
  var sendTokenData;
  sendToken(data,url) async {
    isLoading = true;
    isSend = false;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData){

      var value = json.decode(responseData.body);
      // print("Send Token => $value");
      sendTokenData = value;

      if(responseData.statusCode == 200 && value["status"] == true) {
        isSend = true;
        isLoading = false;
        notifyListeners();
      }
      else {
        isSend = false;
        isLoading = false;
        notifyListeners();

        print("=========== Send Token Api Error ==========");
      }

    });

  }


  var validAddressResponse;
  bool isValidation = false;
  validateAddress(data,url)async{

    // print(data);
    // print(url);

    isValidation = true;
    notifyListeners();

    /*try {*/
      await ApiHandler.post(data, url).then((responseData) {
        var value = json.decode(responseData.body);
        // print("validateAddress $value");
        validAddressResponse = value;

        if (responseData.statusCode == 200 && value["status"] == true) {
          isValidation = false;
          notifyListeners();
        }
        else {
          isValidation = false;
          notifyListeners();

          print("=========== Send Token Api Error ==========");
        }
      });
    /*}catch(e){
      isValidation = false;
      notifyListeners();
    }*/
  }

  List<TransectionList> transectionList = [];
  getTransection(data,url) async {
    isLoading = true;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData){

      List<TransectionList> list;

      var value = json.decode(responseData.body);
      // print("value getTransection === > $value");

      if(responseData.statusCode == 200 && value["status"] == true) {
        body = value;
        var items = value["data"];
        transectionList.clear();
        // print(items as List);
        List client = items as List;
        list  = client.map<TransectionList>((json) => TransectionList.fromJson(json)).toList();

        transectionList.addAll(list);

        isSuccess = true;
        isLoading = false;
        notifyListeners();
      }
      else {
        isSuccess = false;
        isLoading = false;
        notifyListeners();

        print("=========== Get Transactions Api Error ==========");

      }

    });

  }






  List<TransectionModel> allTransectionList = [];
  getAllTransection(data,url) async {

    isLoading = true;
    notifyListeners();

    var baseUrl = url.split("/");
    //print(baseUrl);
    String api;
    if(baseUrl.length == 3){
      url = "${baseUrl[0]}";
      api = "/${baseUrl[1]}/${baseUrl[2]}/api";
    }
    else{
      url = baseUrl[0];
      api = "/api";
    }

    await ApiHandler.getOnlineTrasection("$url","$api",data).then((responseData){

      List<TransectionModel> list;
      var value = json.decode(responseData.body);

      //print(value);
      if(responseData.statusCode == 200 && value["status"]=="1") {
        body = value;

        var items = value["result"];

        List client = items as List;
        list  = client.map<TransectionModel>((json) => TransectionModel.fromJson(json)).toList();

        allTransectionList.addAll(list);

        isSuccess = true;
        isLoading = false;
        notifyListeners();
      }
      else {
        isSuccess = false;
        isLoading = false;
        notifyListeners();

        print("=========== Get All Transactions Api Error ==========");

      }

    });

  }
}