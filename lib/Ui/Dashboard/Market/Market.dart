import 'package:cached_network_image/cached_network_image.dart';
import 'package:corewallet_desktop/Handlers/ApiHandle.dart';
import 'package:corewallet_desktop/LocalDb/Local_Watchlist_provider.dart';
import 'package:corewallet_desktop/Models/AllCoinModel.dart';
import 'package:corewallet_desktop/Provider/ExchangeProvider.dart';
import 'package:corewallet_desktop/Provider/MarketProvider.dart';
import 'package:corewallet_desktop/Provider/Wallet_Provider.dart';
import 'package:corewallet_desktop/Provider/uiProvider.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Wallet/Wallet.dart';
import 'package:corewallet_desktop/Values/Helper/helper.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:corewallet_desktop/Values/styleandborder.dart';
import 'package:corewallet_desktop/Values/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:corewallet_desktop/Values/clippercontainerrfile.dart'as clipp;
import 'package:shared_preferences/shared_preferences.dart';



class Market_Page extends StatefulWidget {


   Market_Page({Key? key,   }) : super(key: key);

  @override
  State<Market_Page> createState() => _Market_PageState();
}

class _Market_PageState extends State<Market_Page> {

  late WalletProvider walletProvider;
  late ExchangeProvider exchangeProvider;
  late MarketProvider marketProvider;
  late UiProvider uiProvider;
  bool changewatchlistColor=false;

  final _debouncer = Debouncer(milliseconds: 500);
  TextEditingController searchController = TextEditingController();

  List<bool>bookmarkList = [];

  @override
  void initState() {
    super.initState();
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);
    marketProvider = Provider.of<MarketProvider>(context, listen: false);
    uiProvider = Provider.of<UiProvider>(context, listen: false);

    marketProvider.topCoinGet = false;
    marketProvider.marketData == null;
    marketProvider.topGainerList == null;
    marketProvider.topLoserList == null;

    Future.delayed(
        Duration.zero, (){
          getWatchList();
          getAllCoin();
          getTopCoin();
          getTopGainer();
          getCoinMarketData();
          getTopLoser();
    });

  }

  getWatchList() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      crySymbol = sharedPreferences.getString("crySymbol") ?? "\$";
      currency = sharedPreferences.getString("currency") ?? "USD";
    });

    await DBWatchListProvider.dbWatchListProvider.getWatchList();
    Future.delayed(const Duration(milliseconds: 300),(){
      setState(() {
        DBWatchListProvider.dbWatchListProvider.watchList;
      });
    });
  }

  var selectType = "News";

  getTopCoin()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      currency = sharedPreferences.getString("currency") ?? "USD";
      crySymbol = sharedPreferences.getString("crySymbol") ?? "\$";
      Utils.convertType = currency;
    });
    var data = {
      "start":"1",
      "limit":"5",
      "convert":currency,
    };

    await marketProvider.topCoin("/cmc/listingsLatest",data);
  }

  int page = 1;
  bool allCoinLoading = false;
  getAllCoin()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      currency = sharedPreferences.getString("currency") ?? "USD";
      crySymbol = sharedPreferences.getString("crySymbol") ?? "\$";
      Utils.convertType = currency;
    });

    setState(() {
      allCoinLoading = true;
    });
    var data = {
      "start":"$page",
      "limit":"20",
      "sort":"market_cap",
      "sort_dir":"desc",
      "convert":currency,
    };
    await marketProvider.getAllCoin("/cmc/listingsLatest",data);

    if(mounted) {
      setState(() {
        bookmarkList = [];
        bookmarkList = List.filled(marketProvider.allCoinList.length,false);
        allCoinLoading = false;
      });
    }
  }

  var currency = "",crySymbol = "";

  getCoinMarketData()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      currency = sharedPreferences.getString("currency") ?? "USD";
      crySymbol = sharedPreferences.getString("crySymbol") ?? "\$";
      Utils.convertType = currency;
    });
    await marketProvider.getMarketData("/cmc/globalQuotesLatest");

  }

  getTopGainer()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      currency = sharedPreferences.getString("currency") ?? "USD";
      crySymbol = sharedPreferences.getString("crySymbol") ?? "\$";
      Utils.convertType = currency;
    });
    var data = {
      "sort_dir":"desc",
      "start":"1",
      "limit":"5",
      "convert":currency,
    };

    await marketProvider.getTopGainer("/cmc/gainersLosers",data);
  }

  getTopLoser()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      currency = sharedPreferences.getString("currency") ?? "USD";
      crySymbol = sharedPreferences.getString("crySymbol") ?? "\$";
      Utils.convertType = currency;
    });
    var data = {
      "sort_dir":"asc",
      "start":"1",
      "limit":"5",
      "convert":currency,
    };

    //print("get Top Loser => $data");

    await marketProvider.getTopLoser("/cmc/gainersLosers",data);
  }

  var width =0.0,height =0.0;

  @override
  Widget build(BuildContext context) {

    width=MediaQuery.of(context).size.width;
    height=MediaQuery.of(context).size.height;

    walletProvider = Provider.of<WalletProvider>(context, listen: true);
    exchangeProvider = Provider.of<ExchangeProvider>(context, listen: true);
    marketProvider = Provider.of<MarketProvider>(context, listen: true);
    uiProvider = Provider.of<UiProvider>(context, listen: true);

    return Scaffold(
      body: Padding(
        padding:  const EdgeInsets.only(top: 20,right: 20,left: 20),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // App Bar
            Row(
              children: [
                InkWell(
                  onTap: (){
                    uiProvider.DashBoardpage("WatchList");
                    if(uiProvider.myBoolValue==true){}

                  },
                  child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: Boxdec.BackButtonGradient,
                      child: Center(
                        child:
                        SvgPicture.asset(
                            'assets/icons/Market/star-1 1.svg',
                            width: 22
                        ),)),
                ),

                const Expanded(child: SizedBox(width: 1,)),

                const Padding(
                  padding: EdgeInsets.only(left: 140),
                  child: Text("Market",style: TextStyle(color: AppColors.White,fontFamily: "Sf-SemiBold",fontSize: 20)),
                ),

                const Expanded(child: SizedBox(width: 1,)),

                Container(
                    height: 55,
                    //    padding: EdgeInsets.only(left: width/15),
                    decoration: Boxdec.ContainerBalancegradientLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:  [

                              const  SizedBox(width: 20,),

                              const Padding(
                                padding: EdgeInsets.only(right: 28),
                                child: Text("Balance:",style:TextStyle(color:AppColors.greydark, fontSize: 12,    fontFamily: 'Sf-SemiBold',)),
                              ),

                              const SizedBox(width: 0,),

                              Padding(
                                padding:const EdgeInsets.only(right: 20),
                                child: Text(
                                    "$crySymbol ${walletProvider.showTotalValue.toStringAsFixed(2)}",
                                    style:const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Sf-SemiBold',
                                    )
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          decoration: Boxdec.ContainerBalancegradientRight,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 5,),
                                  SvgPicture.asset(
                                      'assets/icons/wallet/Vector.svg',
                                      width: 22
                                  ),
                                  // Image.asset("assets/images/Vector (2).png",width: 20),
                                  const SizedBox(width: 5,),
                                  Text(
                                      "$crySymbol ${walletProvider.cmcxBalance.toStringAsFixed(2)}",
                                      style:const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontFamily: 'Sf-Regular',
                                      )
                                  ),
                                  const SizedBox(width: 15,),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                ),
              ],
            ),
            const SizedBox(height: 20),

            // main ui
            Expanded(
                child:!marketProvider.topCoinGet ||
                    marketProvider.marketData == null ||
                    marketProvider.topGainerList == null ||
                    marketProvider.topLoserList == null
                    ?
                Helper.dialogCall.showLoader()
                    :
                SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      // CMCX Market details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(child: SizedBox(width: 20,height: 20,)),

                          const SizedBox(height: 10,),

                          Padding(
                            padding: const EdgeInsets.only(left: 80,bottom: 0,top: 0),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(top: 10,bottom: 10),
                                  margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 40),
                                  alignment: Alignment.center,
                                  width: Responsive.isMobile(context)? width/2.5:width/3,
                                  decoration: BoxDecoration(
                                      color: AppColors.ContainerblackColor,
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Expanded(child: SizedBox(width: 30,)),

                                      //Market Cap
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Market Cap",
                                            style:TextStyle(
                                                color: AppColors.greyColor,
                                                fontFamily: "Sf-SemiBold",
                                                fontSize: 12
                                            ),
                                          ),
                                          const SizedBox(height: 4,),
                                          Text(
                                            "$crySymbol ${NumberFormat.compact().format(marketProvider.marketData['quote']['USD']['total_market_cap'])}",
                                            style:const TextStyle(
                                                color: AppColors.White,
                                                fontFamily: "Sf-Regular",
                                                fontSize: 15
                                            ),
                                          ),
                                          const SizedBox(height: 4,),
                                          Text(
                                            marketProvider.marketData['quote']['USD']['total_market_cap_yesterday_percentage_change'] == null
                                                ?
                                            "0%"
                                                :
                                            "${double.parse("${marketProvider.marketData['quote']['USD']['total_market_cap_yesterday_percentage_change']}").toStringAsFixed(3)}%",
                                            style:TextStyle(
                                                color:marketProvider.marketData['quote']['USD']['total_market_cap_yesterday_percentage_change'] > 0
                                                    || marketProvider.marketData['quote']['USD']['total_market_cap_yesterday_percentage_change'] == null
                                                ?
                                                AppColors.greenColor
                                                    :
                                                AppColors.redColor,
                                                fontFamily: "Sf-SemiBold",
                                                fontSize: 13
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Expanded(child: SizedBox(width: 30,)),

                                      // divider
                                      Container(
                                        alignment: Alignment.center,
                                        height: height*0.04,
                                        width:width*0.0002,
                                        color: AppColors.greyColor,

                                      ),
                                      const Expanded(child: SizedBox(width: 30,)),

                                      //24H Volume
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "24H Volume",
                                            style:TextStyle(color: AppColors.greyColor,fontFamily: "Sf-SemiBold",fontSize: 12),),
                                          const SizedBox(height: 4,),
                                          Text(
                                            "$crySymbol ${NumberFormat.compact().format(marketProvider.marketData['quote']['USD']['total_volume_24h'])}",
                                            style:const TextStyle(
                                                color: AppColors.White,
                                                fontFamily: "Sf-Regular",
                                                fontSize: 15
                                            ),
                                          ),
                                          const SizedBox(height: 4,),
                                          Text(
                                            marketProvider.marketData['quote']['USD']['total_volume_24h_yesterday_percentage_change'] == null
                                                ?
                                            "0%"
                                                :
                                            "${double.parse("${marketProvider.marketData['quote']['USD']['total_volume_24h_yesterday_percentage_change']}").toStringAsFixed(3)}%",
                                            style:TextStyle(
                                              color:marketProvider.marketData['quote']['USD']['total_volume_24h_yesterday_percentage_change'] > 0
                                                  || marketProvider.marketData['quote']['USD']['total_volume_24h_yesterday_percentage_change'] == null
                                                  ?
                                              AppColors.greyColor : AppColors.redColor,
                                              fontFamily: "Sf-SemiBold",
                                              fontSize: 13
                                          ),
                                          ),
                                        ],
                                      ),
                                      const Expanded(child: SizedBox(width: 30,)),

                                      // divider
                                      Container(
                                        alignment: Alignment.center,
                                        height: height*0.04,
                                        width:width*0.0002,
                                        color: AppColors.greyColor,
                                      ),
                                      const Expanded(child: SizedBox(width: 30,)),

                                      // Dominance
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Dominance",
                                            style:TextStyle(
                                                color: AppColors.greyColor,
                                                fontFamily: "Sf-SemiBold",
                                                fontSize: 12
                                            ),
                                          ),
                                          const SizedBox(height: 4,),
                                          Text(
                                            "${double.parse("${marketProvider.marketData['btc_dominance']}").toStringAsFixed(2)}%",
                                            style:const TextStyle(
                                                color: AppColors.White,
                                                fontFamily: "Sf-Regular",
                                                fontSize: 15
                                            ),
                                          ),
                                          const SizedBox(height: 4,),
                                          Text(
                                            marketProvider.marketData['btc_dominance_24h_percentage_change'] == null
                                                ?
                                            "0%"
                                                :
                                            "${double.parse("${marketProvider.marketData['btc_dominance_24h_percentage_change']}").toStringAsFixed(2)}%",
                                            style:TextStyle(
                                                color: marketProvider.marketData['btc_dominance_24h_percentage_change'] == null
                                                    || marketProvider.marketData['btc_dominance_24h_percentage_change'] > 0
                                                    ?
                                                AppColors.greenColor
                                                    :
                                                AppColors.redColor,
                                                fontFamily: "Sf-SemiBold",
                                                fontSize: 13
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Expanded(child: SizedBox(width: 30,)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),

                          const Expanded(child: SizedBox(width: 20,height: 20,)),
                          const SizedBox(width: 40,height: 20,),
                        ],
                      ),

                      // top/Gained/Loser Coin
                      SizedBox(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const SizedBox(width: 10),

                              //Top Coins List
                              Container(
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.darklightgrey,width: 1.5),
                                  color: AppColors.containerbackgroundgrey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                height: 180,
                                width: 350,
                                child: Padding(
                                  padding:  const EdgeInsets.only(top:10,left: 20,right: 20),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Expanded(
                                            child: Text(
                                                "Top Coins",
                                                style: TextStyle(
                                                    color: AppColors.White,
                                                    fontFamily: "Sf-SemiBold",
                                                    fontSize: 14
                                                )
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              marketProvider.changeMorePageName("top");
                                              marketProvider.changeListnerMarket("Coins");
                                            },
                                            child: Container(
                                                alignment: AlignmentDirectional.topEnd,
                                                child: const Text(
                                                    "More",
                                                    style: TextStyle(
                                                        color: AppColors.blueColor2,
                                                        fontFamily: "Sf-SemiBold",
                                                        fontSize: 14
                                                    )
                                                )
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height:10),
                                      Expanded(
                                        child: ListView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: marketProvider.topCoinList.length > 5 ? 5 :marketProvider.topCoinList.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              var list = marketProvider.topCoinList[index];
                                              return  Padding(
                                                padding: const EdgeInsets.only(bottom: 8.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                        "${index + 1}. ",
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(
                                                            color: AppColors.greyColor,
                                                            fontFamily: "Sf-Regular",
                                                            fontSize: 13
                                                        )
                                                    ),
                                                    const SizedBox(width: 5),

                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(400),
                                                      child: CachedNetworkImage(
                                                        fit: BoxFit.fill,
                                                        imageUrl: 'https://s2.coinmarketcap.com/static/img/coins/64x64/${list.id}.png',
                                                        height: 20,
                                                        width: 20,
                                                        placeholder: (context, url) => Helper.dialogCall.showLoader(),
                                                        errorWidget: (context, url, error) =>
                                                            SvgPicture.asset(
                                                              'assets/icons/drawericon/colorlogoonly.svg',
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                        list.name,
                                                        style: const TextStyle(
                                                            color: AppColors.whiteColor,
                                                            fontFamily: "Sf-Regular",
                                                            fontSize: 13
                                                        ),
                                                        textAlign: TextAlign.center
                                                    ),
                                                    const SizedBox(width: 3,),
                                                    Text(
                                                        list.symbol,
                                                        style: const TextStyle(
                                                            color: AppColors.greyColor,
                                                            fontFamily: "Sf-Regular",
                                                            fontSize: 10
                                                        ),
                                                        textAlign: TextAlign.center
                                                    ),
                                                    const Expanded(child: SizedBox(width:1)),
                                                    Text(
                                                        "${list.quote.usd.percentChange24H.toStringAsFixed(2)}%",
                                                        style: TextStyle(
                                                            color: list.quote.usd.percentChange24H > 0  ? AppColors.greenColor : AppColors.redColor,
                                                            fontFamily: "Sf-Regular",
                                                            fontSize: 13
                                                        ),
                                                        textAlign: TextAlign.end
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                      )

                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Top gainer List
                              Container(
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.darklightgrey,width: 1.5),
                                  color: AppColors.containerbackgroundgrey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                // color: AppColors.containerbackgroundgrey,
                                height: 180,
                                width: 350,
                                child: Padding(
                                  padding:  EdgeInsets.only(top:10,left: 20,right: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                              "Top Gainer",
                                              style: TextStyle(
                                                  color: AppColors.White,
                                                  fontFamily: "Sf-SemiBold",
                                                  fontSize: 14
                                              )
                                          ),
                                          const Expanded(child: SizedBox(width:10)),
                                          InkWell(
                                            onTap: (){
                                              marketProvider.changeMorePageName("top");
                                              marketProvider.changeListnerMarket("Gainer");
                                            },
                                            child: Container(
                                                alignment: AlignmentDirectional.topEnd,
                                                child: const Text(
                                                    "More",
                                                    style: TextStyle(
                                                        color: AppColors.blueColor2,
                                                        fontFamily: "Sf-SemiBold",
                                                        fontSize: 14
                                                    )
                                                )
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height:10),
                                      Expanded(
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: marketProvider.topGainerList!.data.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              var list = marketProvider.topGainerList!.data[index];
                                              return  Padding(
                                                padding: const EdgeInsets.only(bottom: 8.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                        "${index+1}. ",
                                                        style: const TextStyle(
                                                            color: AppColors.greyColor,
                                                            fontFamily: "Sf-Regular",
                                                            fontSize: 13
                                                        ),
                                                        textAlign: TextAlign.center
                                                    ),
                                                    const SizedBox(width: 5),
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(400),
                                                      child: CachedNetworkImage(
                                                        fit: BoxFit.fill,
                                                        height: 20,
                                                        width: 20,
                                                        imageUrl: 'https://s2.coinmarketcap.com/static/img/coins/64x64/${list.id}.png',
                                                        placeholder: (context, url) => Helper.dialogCall.showLoader(),
                                                        errorWidget: (context, url, error) =>
                                                            SvgPicture.asset(
                                                              'assets/icons/drawericon/colorlogoonly.svg',
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),

                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 0),
                                                      child: SizedBox(
                                                        width: width/18,
                                                        child: Text(
                                                            "${list.name}",
                                                            style: const TextStyle(
                                                                color: AppColors.whiteColor,
                                                                fontFamily: "Sf-Regular",
                                                                fontSize: 13
                                                            ),
                                                            textAlign: TextAlign.start,
                                                          maxLines: 1,overflow: TextOverflow.ellipsis,
                                                          softWrap: false,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 3,),
                                                    Text(
                                                        list.symbol != null ?  "${list.symbol}" : "--",
                                                        style: const TextStyle(
                                                            color: AppColors.greyColor,
                                                            fontFamily: "Sf-Regular",
                                                            fontSize: 10
                                                        ),
                                                        textAlign: TextAlign.center
                                                    ),
                                                    const Expanded(child: SizedBox(width:1)),
                                                    Text(
                                                        "${list.quote.usd.percentChange24H.toStringAsFixed(2)}%",
                                                        style: TextStyle(
                                                            color: list.quote.usd.percentChange24H > 0  ? AppColors.greenColor : AppColors.redColor,
                                                            fontFamily: "Sf-Regular",
                                                            fontSize: 13
                                                        ),
                                                        textAlign: TextAlign.end
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Top Losers List
                              Container(
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.darklightgrey,width: 1.5),

                                  color: AppColors.containerbackgroundgrey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                // color: AppColors.containerbackgroundgrey,
                                height: 180,
                                width: 350,
                                child: Padding(
                                  padding:  const EdgeInsets.only(top:10,left: 20,right: 20),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                              "Top Losers",
                                              style: TextStyle(
                                                  color: AppColors.White,
                                                  fontFamily: "Sf-SemiBold",
                                                  fontSize: 14
                                              )
                                          ),
                                          const Expanded(child: SizedBox(width:10)),
                                          InkWell(
                                            onTap: () {
                                              marketProvider.changeMorePageName("loser");
                                              marketProvider.changeListnerMarket("Loser");
                                            },
                                            child: Container(
                                                alignment: AlignmentDirectional.topEnd,
                                                child: const Text(
                                                    "More",
                                                    style: TextStyle(
                                                        color: AppColors.blueColor2,
                                                        fontFamily: "Sf-SemiBold",
                                                        fontSize: 14
                                                    )
                                                )
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height:10),
                                      Expanded(
                                        child: ListView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: marketProvider.topLoserList!.data.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              var list = marketProvider.topLoserList!.data[index];
                                              return  Padding(
                                                padding: const EdgeInsets.only(bottom: 8.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "${index+1}. ",
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                          color: AppColors.greyColor,
                                                          fontFamily: "Sf-Regular",
                                                          fontSize: 13
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(400),
                                                      child: CachedNetworkImage(
                                                        fit: BoxFit.fill,
                                                        height: 20,
                                                        width: 20,
                                                        imageUrl: 'https://s2.coinmarketcap.com/static/img/coins/64x64/${list.id}.png',
                                                        placeholder: (context, url) => Helper.dialogCall.showLoader(),
                                                        errorWidget: (context, url, error) =>
                                                            SvgPicture.asset(
                                                              'assets/icons/drawericon/colorlogoonly.svg',
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      list.name,
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                          color: AppColors.whiteColor,
                                                          fontFamily: "Sf-Regular",
                                                          fontSize: 13
                                                      ),
                                                    ),
                                                    const SizedBox(width: 3,),
                                                    Text(
                                                      list.symbol != null ? "${list.symbol}" : "--",
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                          color: AppColors.greyColor,
                                                          fontFamily: "Sf-Regular",
                                                          fontSize: 10
                                                      ),
                                                    ),
                                                    const Expanded(child: SizedBox(width:1)),
                                                    Text(
                                                      "${list.quote.usd.percentChange24H.toStringAsFixed(2)}%",
                                                      style: TextStyle(
                                                          color:list.quote.usd.percentChange24H > 0 ? AppColors.greenColor : AppColors.redColor,
                                                          fontFamily: "Sf-Regular",
                                                          fontSize: 13
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),


                      // search filed
                      SizedBox(
                        width:Responsive.isMobile(context)?MediaQuery.of(context).size.width/2.5: MediaQuery.of(context).size.width/3.5,
                        height: MediaQuery.of(context).size.height/24,
                        child: TextField(
                          controller: searchController,
                          style: const TextStyle(
                              color: AppColors.greyColor,
                              fontFamily: "Sf-Regular",
                              fontSize: 14
                          ),
                          onChanged: (value){
                            // FocusScope.of(context).requestFocus(new FocusNode());

                            _debouncer.run(() {
                              setState(() {
                                marketProvider.allCoinList =  marketProvider.SearchallCoinList.where((u) {
                                  return (u.name.toLowerCase().contains(value.toLowerCase()));
                                }).toList();
                                marketProvider.allCoinGet == false;
                              });
                            });

                            setState(() {});
                          },

                          onSubmitted: (value){
                            // FocusScope.of(context).requestFocus(new FocusNode());

                            _debouncer.run(() {
                              setState(() {
                                marketProvider.allCoinList = marketProvider.SearchallCoinList.where((u) {
                                  return (u.name.toLowerCase().contains(value.toLowerCase()));
                                }).toList();
                                marketProvider.allCoinGet == false;
                              });
                            });

                            setState(() {});
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            fillColor: AppColors.ContainergreySearch,
                            filled: true,
                            isDense: true,
                            hintText: "Search",
                            hintStyle: const TextStyle(
                                color: AppColors.greydark,
                                fontFamily: "Sf-Regular",
                                fontSize: 14
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(6),
                              child:  SvgPicture.asset(
                                  'assets/icons/wallet/search.svg',
                                  width: 22
                              ),
                            ),

                            suffixIcon:searchController.text.isEmpty ? const SizedBox() : InkWell(
                              onTap: () {
                                setState(() {
                                  FocusScope.of(context).unfocus();
                                  searchController.clear();
                                  marketProvider.allCoinList = marketProvider.SearchallCoinList;
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.clear),
                              ),
                            ),


                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0)
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.transparent),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.transparent, width: 2),
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),

                      ),

                      const SizedBox(height: 20),

                      // market coin list titles
                      Container(
                        height:MediaQuery.of(context).size.height/18 ,
                        width: width,
                        decoration: BoxDecoration(
                            border: Border.all(color: AppColors.darklightgrey,width: 0),
                            color: AppColors.HeaderdarkbluesColor,
                            borderRadius: BorderRadius.circular(15)
                        ),
                        child: Row(children: [
                          const SizedBox(width: 20,),
                          const Text(
                            "#",
                            style:TextStyle(
                                color: AppColors.WhiteText,
                                fontFamily: "Sf-Regular",
                                fontSize: 15
                            ),
                          ),

                          SizedBox(
                              width: width*0.19,
                              child: const Text(
                                "Assets Name",
                                style:TextStyle(
                                    color: AppColors.WhiteText,
                                    fontFamily: "Sf-Regular",
                                    fontSize: 15
                                ),
                              )
                          ),


                          SizedBox(
                              width: width*0.13,
                              child: const Text(
                                "Price",
                                style:TextStyle(
                                    color: AppColors.WhiteText,
                                    fontFamily: "Sf-Regular",
                                    fontSize: 15
                                ),
                              )
                          ),


                          SizedBox(
                              width: width*0.09,
                              child: const Text(
                                "24H%",
                                style:TextStyle(
                                    color: AppColors.WhiteText,
                                    fontFamily: "Sf-Regular",
                                    fontSize: 15
                                ),
                              )
                          ),


                          SizedBox(
                              width: width*0.19,
                              child: const Text(
                                "MarketCap",
                                style:TextStyle(
                                    color: AppColors.WhiteText,
                                    fontFamily: "Sf-Regular",
                                    fontSize: 15
                                ),
                              )
                          ),
                          //   SizedBox(width: 15,),

                          SizedBox(
                              width: width*0.1,

                              child: const Text(
                                "Volume",
                                style:TextStyle(
                                    color: AppColors.WhiteText,
                                    fontFamily: "Sf-Regular",
                                    fontSize: 15
                                ),
                              )
                          ),
                          // SizedBox(width:   Responsive.isTablet(context)?20:25,),

                          //Text(
                           // "7Day Chart",
                            // style:TextStyle(
                              // color: AppColors.WhiteText,
                              // fontFamily: "Sf-Regular",
                              // fontSize: 15
                            // ),
                          // ),
                          // Spacer(),
                          // Spacer(),
                          // SizedBox(width: 15,),
                        ],),
                      ),
                      const SizedBox(height: 10),


                      marketProvider.allCoinGet || allCoinLoading
                          ?
                      Helper.dialogCall.showLoader()
                          :
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: marketProvider.allCoinList.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index){
                          var list = marketProvider.allCoinList[index];

                          final bookmarkCheck = DBWatchListProvider.dbWatchListProvider.watchList.where((element) => element.marketId == "${list.id}").toList();
                          if(bookmarkCheck.isEmpty){
                            bookmarkList[index] = false;
                          }else{
                            bookmarkList[index] = true;
                          }

                          return Container(
                            height:MediaQuery.of(context).size.height/10 ,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration:Boxdec.ContainerRowBackgroundgradient,

                            child: Row(
                              children: [
                                Responsive.isDesktop(context)?const SizedBox(width: 15,)
                                    :
                                const SizedBox(width: 10,),
                                Text(
                                  "${page+index}. ",
                                  style: const TextStyle(
                                      color: AppColors.white,
                                      fontFamily: "Sf-Regular",
                                      fontSize: 13
                                  ),
                                ),

                                const SizedBox(width: 1,),
                                // token image and name
                                SizedBox(
                                  width: MediaQuery.of(context).size.width*0.18,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 5,),
                                      Container(
                                        decoration:Boxdec.Containercoinshadow,
                                        height:50,
                                        width: 50,
                                        child:
                                        Padding(
                                          padding: const EdgeInsets.all(13),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black,
                                                    blurRadius: 18.0,
                                                  ),
                                                ]
                                            ),
                                            width: 20,
                                            height: 20,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(400),
                                              child: CachedNetworkImage(
                                                fit: BoxFit.fill,
                                                imageUrl: 'https://s2.coinmarketcap.com/static/img/coins/64x64/${list.id}.png',
                                                placeholder: (context, url) => Helper.dialogCall.showLoader(),
                                                errorWidget: (context, url, error) =>
                                                    SvgPicture.asset(
                                                      'assets/icons/drawericon/colorlogoonly.svg',
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width*0.09,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${list.name}",
                                              maxLines: 2,
                                              style:TextStyle(color: AppColors.White,fontFamily: "Sf-SemiBold",fontSize:Responsive.isTablet(context)|| Responsive.isMobile(context)? 13: 13),),
                                            Text(
                                              "${list.symbol}",
                                              textAlign: TextAlign.start,
                                              style:TextStyle(color: AppColors.WhiteText,fontFamily: "Sf-Regular",fontSize: Responsive.isTablet(context)|| Responsive.isMobile(context)? 11: 13),),
                                          ],),
                                      ),
                                    ],
                                  ),
                                ),


                                // price and marketCap
                                SizedBox(
                                    width: width*0.14,
                                    child: Text(
                                      "$crySymbol ${ApiHandler.calculateLength3("${list.quote.usd.price}")}",
                                      style: const TextStyle(
                                          color: AppColors.whiteColor,
                                          fontFamily: "Sf-Regular",
                                          fontSize: 13
                                      ),
                                    )
                                ),
                                SizedBox(
                                    width: width*0.10,
                                    child: Text(
                                      list.quote.usd.percentChange24H.toStringAsFixed(2),
                                      style: TextStyle(
                                          color: list.quote.usd.percentChange24H > 0 ? AppColors.greenColor : AppColors.redColor,
                                          fontFamily: "Sf-Regular",
                                          fontSize: 13
                                      ),
                                    )
                                ),
                                SizedBox(
                                    width: width*0.18,
                                    child: Text(
                                      "${NumberFormat.compact().format(list.quote.usd.marketCap)}",
                                      style: const TextStyle(
                                          color: AppColors.whiteColor,
                                          fontFamily: "Sf-Regular",
                                          fontSize: 13
                                      ),
                                    )
                                ),

                                //volume
                                Expanded(
                                  child: SizedBox(
                                    width: width*0.14,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                            width: width*0.9  ,
                                            child: Text(
                                              "$crySymbol ${NumberFormat.compact().format(list.quote.usd.volume24H)}",
                                              style: const TextStyle(
                                                  color: AppColors.whiteColor,
                                                  fontFamily: "Sf-Regular",
                                                  fontSize: 13
                                              ),
                                            )
                                        ),
                                       /* Row(
                                          children: [
                                            Text(
                                              "\$${list.quote.usd.volume24H}",
                                              style: const TextStyle(
                                                  color: AppColors.whiteColor,
                                                  fontFamily: "Sf-Regular",
                                                  fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                                list.symbol,
                                                style: const TextStyle(
                                                    color: AppColors.greyColor,
                                                    fontFamily: "Sf-Regular",
                                                    fontSize: 10
                                                )
                                            ),
                                          ],
                                        ),*/
                                      ],
                                    ),
                                  ),
                                ),
                                // Spacer(),


                                InkWell(
                                    onTap: () async {
                                      if(bookmarkList[index] == false) {
                                        await DBWatchListProvider.dbWatchListProvider.createWatchList(
                                          "${list.id}",
                                          list.name,
                                          list.symbol,
                                          "${list.quote.usd.marketCap}",
                                          "${list.quote.usd.volume24H}",
                                          list.quote.usd.price,
                                          list.quote.usd.percentChange24H,
                                        );
                                        await DBWatchListProvider.dbWatchListProvider.getWatchList();
                                        setState(() {
                                          bookmarkList[index] = true;
                                          // print(bookmarkList[index]);
                                        });
                                      }else{
                                        await DBWatchListProvider.dbWatchListProvider.deleteWatchlist("${list.id}");
                                        await DBWatchListProvider.dbWatchListProvider.getWatchList();

                                        setState(() {
                                          bookmarkList[index] = false;
                                        });
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: SizedBox(
                                        width: width*0.02,
                                        child: bookmarkList[index]
                                            ?
                                        Image.asset("assets/icons/yellowstar.png",height:20,)
                                            :
                                        Image.asset("assets/icons/star.png",height:20,color: AppColors.greydark,),
                                      ),
                                    )),
                                SizedBox(width:0),

                                //    SizedBox(width:Responsive.isTablet(context)?10: 30,),
                              ],),
                          );
                        },
                      ),


                    ],
                  ),
                ),
            ),


            // pagination ui
            !marketProvider.topCoinGet ||
                marketProvider.marketData == null ||
                marketProvider.topGainerList == null ||
                marketProvider.topLoserList == null
                ?
            const SizedBox()
                :
            Column(
              children: [
                const SizedBox(height: 10,),

                SizedBox(
                  width: width * 0.8,
                  child: NumberPaginator(
                    config: const NumberPaginatorUIConfig(
                      buttonUnselectedBackgroundColor: AppColors.Containerbluestatic,
                      buttonSelectedBackgroundColor: AppColors.darkblue,
                      buttonSelectedForegroundColor: AppColors.white,
                      buttonUnselectedForegroundColor: AppColors.greyColor,
                      mode: ContentDisplayMode.numbers,
                      buttonShape: CircleBorder(
                          side: BorderSide(
                              width: 0 ,
                              color: Colors.transparent
                          )
                      ),

                    ),

                    numberPages: 100,

                    onPageChange: (int index) {
                      setState(() {
                        page = (((index + 1) - 1) * 20) + 1;
                      });

                      getAllCoin();
                    },
                  ),
                ),
                const SizedBox(height: 10,),
              ],
            )

          ],
        ),
      ),
    );
  }

}



