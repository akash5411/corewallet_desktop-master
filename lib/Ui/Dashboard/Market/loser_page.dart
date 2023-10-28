import 'package:cached_network_image/cached_network_image.dart';
import 'package:corewallet_desktop/Handlers/ApiHandle.dart';
import 'package:corewallet_desktop/LocalDb/Local_Watchlist_provider.dart';
import 'package:corewallet_desktop/Provider/ExchangeProvider.dart';
import 'package:corewallet_desktop/Provider/MarketProvider.dart';
import 'package:corewallet_desktop/Provider/Wallet_Provider.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Wallet/Wallet_Add_Assets.dart';
import 'package:corewallet_desktop/Values/Helper/helper.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:corewallet_desktop/Values/styleandborder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Values/utils.dart';

class MarketLoserPage extends StatefulWidget {
  const MarketLoserPage({Key? key}) : super(key: key);

  @override
  State<MarketLoserPage> createState() => _MarketLoserPageState();
}

class _MarketLoserPageState extends State<MarketLoserPage> {
  late WalletProvider walletProvider;
  late ExchangeProvider exchangeProvider;
  late MarketProvider marketProvider;
  NumberPaginatorController controller = NumberPaginatorController();
  final _debouncer = Debouncer(milliseconds: 500);
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);
    marketProvider = Provider.of<MarketProvider>(context, listen: false);

    getWatchList();
    // getTopLoser();


  }



  var currency = "",crySymbol = "";
  int page = 1;
  bool allCoinLoading = false;
  List<bool>bookmarkList = [];

  getWatchList() async {
    setState(() {
      allCoinLoading = true;
    });
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      crySymbol = sharedPreferences.getString("crySymbol") ?? "\$";
      currency = sharedPreferences.getString("currency") ?? "USD";
      Utils.convertType = currency;
    });
    await DBWatchListProvider.dbWatchListProvider.getWatchList();
    Future.delayed(const Duration(milliseconds: 300),(){
      setState(() {
        DBWatchListProvider.dbWatchListProvider.watchList;
      });
    });
    getTopLoser();


  }


  getTopLoser()async{
    var data = {
      "sort_dir":"asc",
      "start":"$page",
      "limit":"20",
      "convert":currency,
    };

    //print("get Top Loser => $data");

    await marketProvider.getTopLoser("/cmc/gainersLosers",data);

    setState(() {
      bookmarkList = [];
      bookmarkList = List.filled(marketProvider.topLoseList.length,false);
      allCoinLoading = false;
    });
  }

  var width = 0.0,height = 0.0;

  @override
  Widget build(BuildContext context) {

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    walletProvider = Provider.of<WalletProvider>(context, listen: true);
    exchangeProvider = Provider.of<ExchangeProvider>(context, listen: true);
    marketProvider = Provider.of<MarketProvider>(context, listen: true);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20,right: 20,left: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [

                InkWell(
                  onTap: (){

                    marketProvider.changeListnerMarket("Market");

                    // Navigator.pop(context);
                  },
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: Boxdec.BackButtonGradient,
                      child: Center(
                        child:Image.asset("assets/icons/backarrow.png",height: 24),)),
                ),

                const Expanded(child: SizedBox(width: 1,)),

                const Padding(
                  padding: EdgeInsets.only(left: 140),
                  child: Text("Top Losers",style: TextStyle(color: AppColors.White,fontFamily: "Sf-SemiBold",fontSize: 20)),
                ),
                Expanded(child: SizedBox(width: 1,)),

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
                            children: [
                              SizedBox(width: 20,),

                              Padding(
                                padding: const EdgeInsets.only(right: 28),
                                child: Text("Balance:",style:TextStyle(color:AppColors.greydark, fontSize: 12,    fontFamily: 'Sf-SemiBold',)),
                              ),
                              SizedBox(width: 0,),
                              Padding(
                                padding:  EdgeInsets.only(right: 20),
                                child: Text(
                                    "$crySymbol ${walletProvider.showTotalValue.toStringAsFixed(2)}",
                                    style:TextStyle(
                                      color: Colors.white,
                                      fontSize: 16  ,
                                      fontFamily: 'Sf-SemiBold',
                                    )
                                ),
                              ),
                            ],),
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

            Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20,bottom: 10,left: 0,right: 0),
                  child: Container(
                      width: width/3.5,
                      alignment: Alignment.center,
                      child: Text(
                        "Top losers is substract them to your assets. Assets with balances can’t be disabled.",
                        textAlign: TextAlign.center,
                        style:TextStyle(
                            color:  AppColors.white.withOpacity(0.6),
                            fontFamily: "Sf-Regular",
                            fontSize: 12
                        ),
                      )
                  ),
                )
            ),


            const SizedBox(height: 20,),

            SizedBox(
              width: width/2,
              child: TextField(
                controller: searchController,
                cursorColor: AppColors.white,
                style: const TextStyle(
                    color: AppColors.white,
                    fontFamily: "Sf-Regular",
                    fontSize: 14
                ),
                onChanged: (value){
                  // FocusScope.of(context).requestFocus(new FocusNode());

                  _debouncer.run(() {
                    setState(() {
                      marketProvider.topLoseList =  marketProvider.searchLoseList.where((u) {
                        return (u.name.toLowerCase().contains(value.toLowerCase()));
                      }).toList();
                      marketProvider.getLoser == false;
                    });
                  });

                  setState(() {});
                },
                onSubmitted: (value){
                  // FocusScope.of(context).requestFocus(new FocusNode());


                  _debouncer.run(() {
                    setState(() {
                      marketProvider.topLoseList =  marketProvider.searchLoseList.where((u) {
                        return (u.name.toLowerCase().contains(value.toLowerCase()));
                      }).toList();
                      marketProvider.getLoser == false;
                    });
                  });

                  setState(() {});
                },



                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(0),
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
                    padding: const EdgeInsets.all(8),
                    child:  SvgPicture.asset(
                        'assets/icons/wallet/search.svg',
                        width: 20
                    ),
                  ),

                  suffixIcon:searchController.text.isEmpty ? const SizedBox() : InkWell(
                    onTap: () {
                      setState(() {
                        FocusScope.of(context).unfocus();
                        searchController.clear();
                        marketProvider.topLoseList = marketProvider.searchLoseList;
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.clear),
                    ),
                  ),

                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(25.0))),
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

            // list heading titles
            Padding(
              padding:  EdgeInsets.only(top: 10,left: 5,right: 5),
              child: Container(
                height:MediaQuery.of(context).size.height/18 ,
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.darklightgrey,width: 0),
                    color: AppColors.HeaderdarkbluesColor,
                    borderRadius: BorderRadius.circular(15)
                ),
                child: Row(
                  children: [
                    SizedBox(width: 20,),
                    Text(
                      "#",
                      style:TextStyle(
                          color: AppColors.WhiteText,
                          fontFamily: "Sf-Regular",
                          fontSize: 15
                      ),
                    ),

                    SizedBox(
                        width: width*0.19,
                        child: Text(
                          "Assets Name",
                          style:TextStyle(
                              color: AppColors.WhiteText,
                              fontFamily: "Sf-Regular",
                              fontSize: 15
                          ),
                        )
                    ),


                    SizedBox(
                        width: width*0.14,
                        child: Text(
                          "Price",
                          style:TextStyle(
                              color: AppColors.WhiteText,
                              fontFamily: "Sf-Regular",
                              fontSize: 15
                          ),
                        )
                    ),


                    SizedBox(
                        width: Responsive.isDesktop(context)?width*0.12:width*0.10,
                        child: Text(
                          "24H%",
                          style:TextStyle(
                              color: AppColors.WhiteText,
                              fontFamily: "Sf-Regular",
                              fontSize: 15
                          ),
                        )
                    ),



                    SizedBox(
                        width: width*0.15,
                        child: Text(
                          "MarketCap",
                          style:TextStyle(
                              color: AppColors.WhiteText,
                              fontFamily: "Sf-Regular",
                              fontSize: 15
                          ),
                        )
                    ),
                    //   SizedBox(width: 15,),

                    Expanded(
                      child: SizedBox(
                          width: width*0.1,

                          child: Text("Volume", style:TextStyle(color: AppColors.WhiteText,fontFamily: "Sf-Regular",fontSize: 15),)),
                    ),
                    // SizedBox(width:   Responsive.isTablet(context)?20:25,),

                    /*     Text("7Day Chart", style:TextStyle(color: AppColors.WhiteText,fontFamily: "Sf-Regular",fontSize: 15),),
                        Spacer(),*/
                    // Spacer(),
                    // SizedBox(width: 15,),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10,),

            // list and pagination ui
            Expanded(
              child: Column(
                children: [
                  !marketProvider.getLoser || allCoinLoading
                      ?
                  Helper.dialogCall.showLoader()
                      :
                  Expanded(
                    child: ListView.builder(
                      itemCount: marketProvider.topLoseList.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index){
                        var list = marketProvider.topLoseList[index];

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
                                  width: width*0.15,
                                  child: Text(
                                    "\$ ${ApiHandler.calculateLength3("${list.quote.usd.price}")}",
                                    style: const TextStyle(
                                        color: AppColors.whiteColor,
                                        fontFamily: "Sf-Regular",
                                        fontSize: 13
                                    ),
                                  )
                              ),
                              SizedBox(
                                  width: width*0.14,
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
                                  width: width*0.14,
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
                                            "\$ ${NumberFormat.compact().format(list.quote.usd.volume24H)}",
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
                                        print(bookmarkList[index]);
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
                  ),


                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar:SizedBox(
        height: 50,
        width: width * 0.8,
        child: NumberPaginator(
          controller: controller,
          initialPage: 0,
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

            getTopLoser();
          },
        ),
      ),
    );
  }
}
