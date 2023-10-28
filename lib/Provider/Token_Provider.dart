import 'dart:convert';

import 'package:flutter/material.dart';

import '../Handlers/ApiHandle.dart';
import '../LocalDb/Local_Token_provider.dart';
import '../Models/AccountTokenModel.dart';
import '../Models/AllTokenModel.dart';
import '../Models/NetworkModel.dart';
import '../Models/SwapProviders.dart';
import '../Models/TokenDetailsModel.dart';

class TokenProvider with ChangeNotifier {

  bool isLoading = true;
  bool isSuccess = false;

  List<NetworkList> networkList = [];
  var netWorkData;
  bool networkLoad = false;
  List<NetworkList> newNetworkList = [];
  getNetworks(url) async {
    isLoading = true;
    networkLoad = false;
    notifyListeners();

      await ApiHandler.get(url).then((responseData) {

        var value = json.decode(responseData.body);

        // print("get network");

        if(responseData.statusCode == 200 && value["status"] == true){
          // isSuccess = true;
          netWorkData = value;

          final items = netWorkData["data"].cast<Map<String, dynamic>>();
          List<NetworkList> list = items.map<NetworkList>((val) {
            return NetworkList.fromJson(val);
          }).toList();

          networkList = list;
          int bnbIndex = networkList.indexWhere((e) => e.id == 2);
          int ethIndex = networkList.indexWhere((e) => e.id == 1);
          newNetworkList.add(networkList[bnbIndex]);
          newNetworkList.add(networkList[ethIndex]);
          for(int i = 0; i< networkList.length; i++){
            int dubIndex = newNetworkList.indexWhere((element) => element.id == networkList[i].id);
            if(dubIndex == -1) {
              newNetworkList.add(networkList[i]);
            }
          }

          networkLoad = true;
          isLoading = false;
          notifyListeners();
        }
        else {
          // isSuccess = false;
          isLoading = false;
          networkLoad = false;

          notifyListeners();

          print("=========== Get Network Api Error ==========");

        }

      });

  }


  bool isProviderLoading = false;
  List<SwapProviders> providersList = [];
  getSwapProviders(data,url) async {
    isProviderLoading = true;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData) {

      var value = json.decode(responseData.body);

      // print("Provider Value: ${value}");
      if(responseData.statusCode == 200 && value["status"] == true){
        isSuccess = true;
        final items = value["data"].cast<Map<String, dynamic>>();
        List<SwapProviders> list = items.map<SwapProviders>((val) {
          return SwapProviders.fromJson(val);
        }).toList();

        providersList = list;
        //print("providerList -${providersList.length}");
        isProviderLoading = false;
        notifyListeners();
      }
      else {
        isSuccess = false;
        isProviderLoading = false;
        notifyListeners();

        print("=========== Get Providers Api Error ==========");

      }

    });

  }



  bool isAddTokenDone = false;
  var allToken;
  getAccountToken(data, url,id) async {
    isLoading = true;
    notifyListeners();

    await ApiHandler.post(data, url).then((responseData) async {

        var value = json.decode(responseData.body);
        // print("get Token api :- $value");
        if(responseData.statusCode == 200 && value["status"] == true){

          allToken = value;

          // await DBTokenProvider.dbTokenProvider.deleteAccountToken(id);


            await DBTokenProvider.dbTokenProvider.getAccountToken(id,"","");

            (allToken["data"] as List).map((token) async {
              var index = DBTokenProvider.dbTokenProvider.tokenList.indexWhere((element) {
                return "${element.id}"== "${token["id"]}";
              });
              // print(index);
              if(index != -1){
                await DBTokenProvider.dbTokenProvider.updateToken(AccountTokenList.fromJson(token,id), token["id"],id);
              }else{
                await DBTokenProvider.dbTokenProvider.createToken(AccountTokenList.fromJson(token,id));
              }
            }).toList();

          // print(tokenNote);

          isSuccess = true;
          isLoading = false;
          notifyListeners();

        }
        else {
          isSuccess = false;
          isLoading = false;
          notifyListeners();

          print("=========== Get Account Token Api Error ==========");

        }

      });

  }


  var deleteData;
  deleteToken(data,url) async {
    isLoading = true;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData){

        var value = json.decode(responseData.body);
        // print(value);
        if(responseData.statusCode == 200 && value["status"] == true)
        {
          isSuccess = true;
          deleteData = value;
          isLoading = false;
          notifyListeners();
        }
        else
        {
          isLoading = false;
          isSuccess = false;
          notifyListeners();

          print("=========== Delete Token Api Error ==========");

        }

      });

  }


  var tokenData;
  getCustomToken(data,url) async {
    isLoading = true;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData){

      var value = json.decode(responseData.body);
      //print(value);
      if(responseData.statusCode == 200 && value["status"] == true)
      {
        isSuccess = true;
        tokenData = value;
        notifyListeners();
      }
      else
      {
        tokenData = null;
        isSuccess = false;
        isLoading = false;
        notifyListeners();

        print("=========== Get Custom Token Api Error ==========");

      }

    });

  }


  bool isTokenLoading = false;
  bool isTokenAdded = false;
  var tokenDetail;
  addCustomToken(data,url,id) async {
    isTokenLoading = true;
    isTokenAdded = false;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData){

      var value = json.decode(responseData.body);
      // print("add token response ===> $value");
      if(responseData.statusCode == 200 && value["status"] == true)
      {
        tokenDetail = value;

        // (tokenDetail["data"] as List).map((token){
        //   DBTokenProvider.dbTokenProvider.createToken(AccountTokenList.fromJson(token,id));
        // }).toList();

        isTokenAdded = true;
        isTokenLoading = false;
        notifyListeners();
      }
      else
      {
        isTokenAdded = false;
        isTokenLoading = false;
        notifyListeners();

        print("=========== Add Custom Token Api Error ==========");

      }

    });
  }


  List<SearchtokenList> searchTokenList = [];
  List<SearchtokenList> allTokenList = [];
  List<Map<String,dynamic>> selectTokenBool = [];
  List<Map<String,dynamic>> searchSelectTokenBool = [];

  bool isSearch = false;

  getSearchToken(data,url) async {
    isLoading = true;
    notifyListeners();



    await ApiHandler.post(data,url).then((responseData){

      List<SearchtokenList> list;

      var value = json.decode(responseData.body);

      if(responseData.statusCode == 200 && value["status"] == true) {
        searchTokenList.clear();
        selectTokenBool = [];

        var items = value["data"];

        List client = items as List;

        list = client.map<SearchtokenList>((json) {
          return SearchtokenList.fromJson(json);
        }).toList();

        searchTokenList.addAll(list);

        for (int i = 0; i < searchTokenList.length; i ++) {
          selectTokenBool.add({
            "tokenName": searchTokenList[i].name,
            "tokenId": searchTokenList[i].id,
            "isSelected": false
          });
        }


        // selectTokenBool = List.filled(searchTokenList.length, false);


        for (int i = 0; i < DBTokenProvider.dbTokenProvider.tokenList.length; i++) {
          var index = searchTokenList.indexWhere((element) {
            return "${element.id}" ==
                "${DBTokenProvider.dbTokenProvider.tokenList[i].token_id}";
          });
          if (index != -1) {
            selectTokenBool[index]['isSelected'] = true;
          }
        }

        allTokenList = searchTokenList;
        searchSelectTokenBool = selectTokenBool;


        isSearch = true;
        isLoading = false;
        notifyListeners();

      } else {
        isSearch = true;
        isLoading = false;
        notifyListeners();

        print("=========== Search Token List Api Error ==========");

      }

    });

  }


  List<SearchtokenList> searchNetWorkTokenTokenList = [];
  getSearchNetWorkToken(data,url) async {
    isLoading = true;
    searchNetWorkTokenTokenList.clear();
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData){

      List<SearchtokenList> list;

      var value = json.decode(responseData.body);
      // print("get token ai  => $value");

      if(responseData.statusCode == 200 && value["status"] == true) {
        // allTokenDetails = value;

        var items = value["data"];

        List client = items as List;
        list  = client.map<SearchtokenList>((json) => SearchtokenList.fromJson(json)).toList();
        searchNetWorkTokenTokenList.addAll(list);

        isLoading = false;
        notifyListeners();

      } else {
        isLoading = false;
        notifyListeners();

        print("=========== Search Network Token List Api Error ==========");

      }

    });

  }



  bool isEstimate = false;
  var estimateData = null;
  getEstimate(data,url) async{

    isLoading = true;
    isEstimate = false;
    notifyListeners();

    //print(data);
    await ApiHandler.testPost(data,url).then((responseData){

      var value = json.decode(responseData.body);
      // print(" ====> $value");

      if(responseData.statusCode == 200 && value["status"] == true) {
        isLoading = false;
        isEstimate = true;
        estimateData = value;
        notifyListeners();
      } else {
        estimateData = null;
        isEstimate = false;
        isLoading = false;

        print("=========== Get Estimate Api Error ==========");

      }

    });

  }



  bool isChartToken = false;
  List<TokenDataList> tokenDetailsChart = [];
  getChartTokenInfo(url,params) async {
    isChartToken = true;
    notifyListeners();

    tokenDetailsChart.clear();
    await ApiHandler.getParams(url,params).then((responseData){

      List<TokenDataList> list;
      var value = json.decode(responseData.body);
      //print(value);

      if(responseData.statusCode == 200 && value["status"] == true) {

        var items = value["data"];

        List client = items as List;
        list  = client.map<TokenDataList>((json) => TokenDataList.fromJson(json)).toList();
        tokenDetailsChart.addAll(list);

        isChartToken = false;
        notifyListeners();
      }
      else {
        isChartToken = false;
        notifyListeners();

        print("=========== Get Chart Token Info Api Error ==========");

      }

    });

  }

  var pairDetails;
  getPairPrice(url,params) async {
    isLoading = true;
    notifyListeners();

    await ApiHandler.getParams(url,params).then((responseData){

      var value = json.decode(responseData.body);
      //print(value);

      if(responseData.statusCode == 200 && value["status"] == true) {
        pairDetails = value;

        isSuccess = true;
        isLoading = false;
        notifyListeners();
      }
      else {
        isSuccess = false;
        isLoading = false;
        notifyListeners();

        print("=========== Get Pair Price Api Error ==========");

      }

    });
  }


  var tokenBalance;
  bool isBalance = false;
  getTokenBalance(data,url) async {
    isLoading = true;
    tokenBalance = null;
    notifyListeners();

    // print(data);

      await ApiHandler.post(data,url).then((responseData){

        var value = json.decode(responseData.body);
        print(value);

        if(responseData.statusCode == 200 && value["status"] == true) {
          tokenBalance = value;

          isBalance = true;
          isLoading = false;
          notifyListeners();
        }
        else {
          tokenBalance = null;

          isLoading = false;
          isBalance = false;
          notifyListeners();

          print("=========== get Token Balance Api Error ==========");

        }

      });

  }

}