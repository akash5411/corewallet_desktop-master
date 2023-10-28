import 'dart:convert';

import 'package:corewallet_desktop/Handlers/ApiHandle.dart';
import 'package:corewallet_desktop/Models/AccountTokenModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../Models/CoinGraphModel.dart';
import '../Models/GraphModel.dart';

class WalletProvider with ChangeNotifier{

  var showTotalValue = 0.0;
  var cmcxBalance = 0.0;
  AccountTokenList? accountTokenList;

  addTokenDetails(AccountTokenList details){
    accountTokenList = details;
    notifyListeners();
  }

  // static late List walletNameTitle;
  var wallet_PageName = "Wallet";

  changeListnerWallet( String value){
       wallet_PageName= value;
       notifyListeners();

  }


  CoinGraphModel? coinGraph;
  bool isLoading = false, isSuccess = false;
  List<PriceModel> GraphList = [];

  getCoinGraph(url,data) async {
    // print("Coin ${data}");
    isLoading = true;
    coinGraph = null;
    GraphList.clear();
    notifyListeners();

    await ApiHandler.getParams(url,data).then((responseData){


      var value = json.decode(responseData.body);

      if(responseData.statusCode == 200 && value["status"] == true ) {

        coinGraph = CoinGraphModel.fromJson(value["data"]);

        // print(double.parse(coinGraph!.quotes[0].quote.usd.price.toStringAsFixed(15)).toStringAsFixed(10));
        //print("First graph data  => $value");

        for(int i = 0; i < coinGraph!.quotes.length; i ++){
          GraphList.add(
              PriceModel(
                  data['interval'] == "1h"
                      ?
                  DateFormat("hh:mm aa").format(coinGraph!.quotes[i].timestamp)
                      :
                  data['interval'] == "24h"
                      ?
                  DateFormat("dd-MM-yy").format(coinGraph!.quotes[i].timestamp)
                      :
                  data['interval'] == "1y"
                      ?
                  DateFormat("yyyy").format(coinGraph!.quotes[i].timestamp)
                      :
                  DateFormat("dd-MM-yy").format(coinGraph!.quotes[i].timestamp),
                double.parse(double.parse(coinGraph!.quotes[i].quote.usd.price.toStringAsFixed(15)).toStringAsFixed(10)),
              )
          );
        }


        isSuccess = true;
        isLoading = false;
        notifyListeners();

      } else {
        isSuccess = false;
        isLoading = false;
        notifyListeners();

        print("=========== get First Coin graph  Api Error ==========");

      }

    });

  }





}