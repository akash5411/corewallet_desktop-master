import 'dart:convert';

import 'package:corewallet_desktop/Handlers/ApiHandle.dart';
import 'package:corewallet_desktop/LocalDb/Local_Watchlist_provider.dart';
import 'package:corewallet_desktop/Models/AllCoinModel.dart';
import 'package:corewallet_desktop/Models/CoinGainerModel.dart';
import 'package:corewallet_desktop/Models/CoinGraphModel.dart';
import 'package:corewallet_desktop/Models/CoindetailModel.dart';
import 'package:corewallet_desktop/Models/GraphModel.dart';
import 'package:flutter/cupertino.dart';

class MarketProvider with ChangeNotifier{


  var market_PageName="Market";

  String morePageName = "";
  changeMorePageName(var name){
    morePageName = name;
    notifyListeners();
  }

  changeListnerMarket( String value){
    market_PageName= value;
    notifyListeners();

  }


  bool isLoading = true;
  bool isSuccess = false;



  CoinData? coinData;
  getCoinData(url,data) async {
    isLoading = true;
    coinData = null;
    notifyListeners();

    try {
      await ApiHandler.getParams(url, data).then((responseData) {
        var value = json.decode(responseData.body);


        if (responseData.statusCode == 200) {
          // print("First Token details  => $value");
          coinData = CoinData.fromJson(value["data"]);

          DBWatchListProvider.dbWatchListProvider.updateWatchList(
              "${coinData!.coinID.id}",
              coinData!.coinID.name,
              coinData!.coinID.symbol,
              "${coinData!.coinID.quote.usd.marketCap}",
              "${coinData!.coinID.quote.usd.volume24H}",
              coinData!.coinID.quote.usd.price,
              coinData!.coinID.quote.usd.percentChange24H
          );

          isSuccess = true;
          isLoading = false;
          notifyListeners();
        } else {
          isSuccess = false;
          isLoading = false;
          notifyListeners();

          print("===========get First Coin Data  Api Error ==========");
        }
      });
    }catch(e){}
  }

  var marketData;
  getMarketData(url) async {
    isLoading = true;
    marketData = null;
    notifyListeners();

    await ApiHandler.get(url).then((responseData){


      var value = json.decode(responseData.body);

      //print(value);
      if(responseData.statusCode == 200) {

        //print("market details  => $value");
        marketData = value["data"];

        isSuccess = true;
        isLoading = false;
        notifyListeners();

      } else {
        isSuccess = false;
        isLoading = false;
        notifyListeners();

        print("=========== market data Api Error ==========");

      }

    });

  }



  CoinGraphModel? firstCoinGraph;
  List<PriceModel> priceGraphList = [];

  getFirstCoinGraph(url,data) async {
    isLoading = true;

    priceGraphList.clear();

    firstCoinGraph = null;
    notifyListeners();

    await ApiHandler.getParams(url,data).then((responseData){


      var value = json.decode(responseData.body);

      if(responseData.statusCode == 200 && value["status"]) {

        firstCoinGraph = CoinGraphModel.fromJson(value["data"]);

        //print(double.parse(firstCoinGraph!.quotes[0].quote.usd.price.toStringAsFixed(15)).toStringAsFixed(10));
        //print("First graph data  => $value");

        for(int i = 0; i < firstCoinGraph!.quotes.length; i ++){
          priceGraphList.add(
              PriceModel(
                "${i}",
                double.parse(double.parse(firstCoinGraph!.quotes[i].quote.usd.price.toStringAsFixed(15)).toStringAsFixed(10)),
              )
          );
        }

        //print("priceGraphList =====> ");
        //print(priceGraphList[0].price);
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

  CoinGraphModel? coinGraph;
  List<PriceModel> GraphList = [];
  getCoinGraph(url,data,reload) async {
    isLoading = true;
    coinGraph = null;
    GraphList.clear();
    notifyListeners();

    await ApiHandler.getParams(url,data).then((responseData){


      var value = json.decode(responseData.body);

      if(responseData.statusCode == 200 && value["status"] == true ) {

        // print(value["data"]);
        coinGraph = CoinGraphModel.fromJson(value["data"]);

        // print(double.parse(coinGraph!.quotes[0].quote.usd.price.toStringAsFixed(15)).toStringAsFixed(10));
        //print("First graph data  => $value");

        for(int i = 0; i < coinGraph!.quotes.length; i ++){
          if(reload == true){
            GraphList.clear();
            reload = false;
            notifyListeners();
          }

          GraphList.add(
              PriceModel(
                "${i}",
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



  CoinGraphModel? secondCoinGraph;
  List<PriceModel> priceGraphList2 = [];
  getSecondCoinGraph(url,data) async {
    priceGraphList2.clear();

    secondCoinGraph = null;
    isLoading = true;
    notifyListeners();

    await ApiHandler.getParams(url,data).then((responseData){


      var value = json.decode(responseData.body);
      //print("get sec graph data  => $value");

      if(responseData.statusCode == 200 && value["status"]) {
        priceGraphList2.clear();

        secondCoinGraph = CoinGraphModel.fromJson(value["data"]);

        for(int i = 0; i<secondCoinGraph!.quotes.length; i ++){
          priceGraphList2.add(
              PriceModel(
                "${i}",
                double.parse(secondCoinGraph!.quotes[i].quote.usd.price.toStringAsFixed(15)),
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

        print("=========== get Second Coin graph Api Error ==========");

      }

    });

  }



  CoinGainerModel? topGainerList;
  List<TopGainModel> topGainList = [];
  List<TopGainModel> searchTopGainList = [];
  bool topGian = false;
  getTopGainer(url,data) async {

    isLoading = true;
    topGian = false;
    notifyListeners();

    await ApiHandler.getParams(url,data).then((responseData){


      var value = json.decode(responseData.body);
      List<TopGainModel> list = [];

      if(responseData.statusCode == 200 && value["status"]) {
        topGainList.clear();
        searchTopGainList.clear();
        topGainerList = CoinGainerModel.fromJson(value);
        //print("Gainer Token ===> $value");

        final items = value["data"].cast<Map<String, dynamic>>();
        list = items.map<TopGainModel>((val) {
          return TopGainModel.fromJson(val);
        }).toList();

        topGainList.addAll(list);
        searchTopGainList = topGainList;
        topGian = true;
        isLoading = false;
        notifyListeners();

      } else {
        topGian = true;
        isLoading = false;
        notifyListeners();

        print("=========== get top gainer Api Error ==========");

      }

    });
  }


  CoinGainerModel? topLoserList;
  List<TopGainModel> topLoseList = [];
  List<TopGainModel> searchLoseList = [];

  bool getLoser = false;
  getTopLoser(url,data) async {
    isLoading = true;
    getLoser = false;

    notifyListeners();

    await ApiHandler.getParams(url,data).then((responseData){


      var value = json.decode(responseData.body);
      List<TopGainModel> list = [];

      if(responseData.statusCode == 200 && value["status"]) {
        topLoseList.clear();
        searchLoseList.clear();


        topLoserList = CoinGainerModel.fromJson(value);
        //print("Loser Token ====> $value");

        final items = value["data"].cast<Map<String, dynamic>>();
        list = items.map<TopGainModel>((val) {
          return TopGainModel.fromJson(val);
        }).toList();

        topLoseList.addAll(list);
        searchLoseList = topLoseList;
        getLoser = true;
        isLoading = false;
        notifyListeners();

      } else {
        getLoser = true;
        isLoading = false;
        notifyListeners();

        print("===========get top Loser Api Error ==========");

      }

    });
  }


  List<TopGainModel> recentList = [];
  bool isRecentLoad = false;

  getRecent(url,data) async {

    isLoading = true;
    notifyListeners();

    await ApiHandler.getParams(url,data).then((responseData){


      var value = json.decode(responseData.body);
      List<TopGainModel> list = [];
      if(responseData.statusCode == 200) {
        //print("recent data");
        //print(value);


        final items = value["data"].cast<Map<String, dynamic>>();
        list = items.map<TopGainModel>((val) {
          return TopGainModel.fromJson(val);
        }).toList();

        recentList.addAll(list);

        isRecentLoad = true;
        isLoading = false;
        notifyListeners();

      } else {
        isRecentLoad = true;
        isLoading = false;
        notifyListeners();

        print("=========== get recent added coin Api Error ==========");

      }

    });
  }

  List<AllCoinModel> allCoinList = [];
  List<AllCoinModel> SearchallCoinList = [];
  bool allCoinGet = false;
  getAllCoin(url,data) async {

    isLoading = true;
    allCoinGet = true;

    notifyListeners();

    await ApiHandler.getParams(url,data).then((responseData){


      var value = json.decode(responseData.body);
      List<AllCoinModel> list = [];

      // print(value);
      if(responseData.statusCode == 200) {
        allCoinList = [];
        SearchallCoinList = [];
        notifyListeners();

        final items = value["data"].cast<Map<String, dynamic>>();
        list = items.map<AllCoinModel>((val) {
          return AllCoinModel.fromJson(val);
        }).toList();

        allCoinList.addAll(list);

       /* final Map<String, AllCoinModel> profileMap = new Map();
        allCoinList.forEach((item) {
          profileMap[item.name] = item;
        });
        allCoinList = profileMap.values.toList();*/

        /*print("allCoinList ${allCoinList.length}");
        allCoinList.addAll(allCoinList.toSet().toList());
        print("newAllCoinList ${newAllCoinList.length}");*/
        SearchallCoinList=allCoinList;
        // print("data add ");
        allCoinGet = false;
        isLoading = false;
        notifyListeners();

      } else {
        allCoinGet = false;
        isLoading = false;
        notifyListeners();

        print("=========== get top gainer Api Error ==========");

      }

    });
  }


  List<AllCoinModel> topCoinList = [];
  bool topCoinGet = false;
  topCoin(url,data) async {

    topCoinGet = false;
    isLoading = true;

    notifyListeners();

    await ApiHandler.getParams(url,data).then((responseData){


      var value = json.decode(responseData.body);
      List<AllCoinModel> list = [];

      //print(value);
      if(responseData.statusCode == 200) {

        final items = value["data"].cast<Map<String, dynamic>>();
        list = items.map<AllCoinModel>((val) {
          return AllCoinModel.fromJson(val);
        }).toList();

        topCoinList.addAll(list);

        final Map<String, AllCoinModel> profileMap = {};
        topCoinList.forEach((item) {
          profileMap[item.name] = item;
        });
        topCoinList = profileMap.values.toList();


        topCoinGet = true;
        isLoading = false;
        notifyListeners();

      } else {
        topCoinGet = true;
        isLoading = false;
        notifyListeners();

        print("=========== get top gainer Api Error ==========");

      }

    });
  }

  applyFilter(String type){
    if(type == "%_Change"){
      allCoinList.sort((a, b) {
        return a.quote.usd.percentChange24H.compareTo(b.quote.usd.percentChange24H);
      });
    }else if(type == "Rank"){
      allCoinList.sort((a, b) {
        return a.cmcRank.compareTo(b.cmcRank);
      });
    }else if(type == "Market_Cap"){
      allCoinList.sort((a, b) {
        return a.quote.usd.marketCap.compareTo(b.quote.usd.marketCap);
      });
    }else if(type == "Volume_24h"){
      allCoinList.sort((a, b) {
        return a.quote.usd.volume24H.compareTo(b.quote.usd.volume24H);
      });
    }else if(type == "Circulating_Supply"){
      allCoinList.sort((a, b) {
        return a.circulatingSupply.compareTo(b.circulatingSupply);
      });
    }else if(type == "Price"){
      allCoinList.sort((a, b) {
        return a.quote.usd.price.compareTo(b.quote.usd.price);
      });

    }else if(type == "Name"){
      allCoinList.sort((a, b) {
        return a.name.compareTo(b.name);
      });
    }

  }


  updateWatchList(){

  }


}