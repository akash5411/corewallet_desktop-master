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
import 'package:corewallet_desktop/Values/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';



class WatchListMarket extends StatefulWidget {
  const WatchListMarket({Key? key}) : super(key: key);

  @override
  State<WatchListMarket> createState() => _WatchListMarketState();
}

class _WatchListMarketState extends State<WatchListMarket> {

  final _debouncer = Debouncer(milliseconds: 500);

  TextEditingController searchController = TextEditingController();
  late WalletProvider walletProvider;
  bool  isLoading = false;
  late ExchangeProvider exchangeProvider;
  late MarketProvider marketProvider;

  var crySymbol = "";

  @override
  void initState() {
    super.initState();
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);
    marketProvider = Provider.of<MarketProvider>(context, listen: false);
    Future.delayed(Duration.zero,(){
      getWatchList();
    });
  }


  var currency = "";
  getWatchList() async {


    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(mounted) {
      setState(() {
        currency = sharedPreferences.getString("currency") ?? "USD";
        crySymbol = sharedPreferences.getString("crySymbol") ?? "\$";
        isLoading = true;
      });
    }
    await DBWatchListProvider.dbWatchListProvider.getWatchList();

    int i = 0;

    do{
      if(DBWatchListProvider.dbWatchListProvider.watchList.isNotEmpty || i < DBWatchListProvider.dbWatchListProvider.watchList.length) {
        if(mounted) {
          setState(() {
            Utils.MarketId = int.parse(
                DBWatchListProvider.dbWatchListProvider.watchList[i].marketId
            );
            // print("  Utils.MarketId ==> ${ Utils.MarketId}");
          });
        }

        var data = {
          "id": DBWatchListProvider.dbWatchListProvider.watchList[i].marketId,
          "convert": currency,
        };
        //print(data);
        await marketProvider.getCoinData("/cmc/quotesLatest", data);

        if(mounted) {
          setState(() {
            i += 1;
          });
        }else{
          break;
        }
      }
    }
    while(i < DBWatchListProvider.dbWatchListProvider.watchList.length);

    await DBWatchListProvider.dbWatchListProvider.getWatchList();

    if(mounted) {
      setState(() {
        isLoading = false;
      });
    }
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // App Bar

            Row(
              children: [

             /*   InkWell(
                  onTap: (){
                    marketProvider.changeListnerMarket("Market");
                  },
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: Boxdec.BackButtonGradient,
                      child: Center(
                        child:Image.asset("assets/icons/backarrow.png",height: 24),)),
                ),*/

                const Expanded(child: SizedBox(width: 1)),

                const Padding(
                  padding: EdgeInsets.only(left: 140),
                  child: Text(
                      "Watchlist",
                      style: TextStyle(
                          color: AppColors.White,
                          fontFamily: "Sf-SemiBold",
                          fontSize: 20
                      )
                  ),
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
                              const SizedBox(width: 20,),

                              const Padding(
                                padding: EdgeInsets.only(right: 28),
                                child: Text(
                                    "Balance:",
                                    style:TextStyle(
                                      color:AppColors.greydark,
                                      fontSize: 12,
                                      fontFamily: 'Sf-SemiBold',
                                    )
                                ),
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
                                      style:const TextStyle(color: Colors.grey,fontSize: 16,   fontFamily: 'Sf-Regular',)),
                                  const SizedBox(width: 15,),

                                ],),
                            ),
                          ),  ),
                      ],
                    )
                ),

              ],
            ),
            const SizedBox(height: 20,),

            //  search text filed
            Row(
              children: [
                const Expanded(child: SizedBox(width: 1,)),
                SizedBox(
                  width: MediaQuery.of(context).size.width/3.5,
                  height: MediaQuery.of(context).size.height/22 ,
                  child: TextField(
                    cursorColor: AppColors.white,
                    controller: searchController,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontFamily: "Sf-Regular",
                        fontSize: 16
                    ),
                    onChanged: (value){
                      // FocusScope.of(context).requestFocus(new FocusNode());

                      _debouncer.run(() {
                        setState(() {
                          DBWatchListProvider.dbWatchListProvider.watchList = DBWatchListProvider.dbWatchListProvider.SearchwatchList  .where((u) {
                            return (u.name.toLowerCase().contains(value.toLowerCase()));
                          }).toList();
                          marketProvider.allCoinGet == false;
                          // getDistributorlist();
                        });
                      });

                      setState(() {});
                    },

                    onSubmitted: (value){
                      // FocusScope.of(context).requestFocus(new FocusNode());

                      _debouncer.run(() {
                        setState(() {
                          DBWatchListProvider.dbWatchListProvider.watchList = DBWatchListProvider.dbWatchListProvider.SearchwatchList   .where((u) {
                            return (u.name.toLowerCase().contains(value.toLowerCase()));
                          }).toList();
                          // marketProvider!.allCoinGet == false;
                        });
                      });

                      setState(() {});
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(top: 6),
                      fillColor: AppColors.ContainergreySearch,
                      filled: true,
                      isDense: true,
                      hintText: "Search",
                      hintStyle: const TextStyle(
                          color: AppColors.greydark,
                          fontFamily: "Sf-Regular",
                          fontSize: 16
                      ),
                      prefixIcon: Padding(
                        padding:const EdgeInsets.all(6),
                        child: SvgPicture.asset(
                            'assets/icons/wallet/search.svg',
                            width: 10
                        ),
                      ),

                      suffixIcon:searchController.text.isEmpty ? const SizedBox() : InkWell(
                        onTap: () {
                          setState(() {
                            FocusScope.of(context).unfocus();
                            searchController.clear();
                             DBWatchListProvider.dbWatchListProvider.watchList = DBWatchListProvider.dbWatchListProvider.SearchwatchList  ;
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
                const Expanded(child: SizedBox(width: 1,)),
              ],
            ),

            // token details heading
            Padding(
              padding:  EdgeInsets.only(top: 10,left: 5,right: 5),
              child: Container(
                height:MediaQuery.of(context).size.height/18 ,
                width: width,
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.darklightgrey,width: 0),
                    color: AppColors.HeaderdarkbluesColor,
                    borderRadius: BorderRadius.circular(15)
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                      const Text(
                        "#",
                        style:TextStyle(
                            color: AppColors.WhiteText,
                            fontFamily: "Sf-Regular",
                            fontSize: 15),),
                    SizedBox(width: 20),

                      // assets name title
                      SizedBox(
                        width: Responsive.isTablet(context) ? width * 0.17: width * 0.2,
                        child: const Text(
                          "Assets Name",
                          style:TextStyle(
                              color: AppColors.WhiteText,
                              fontFamily: "Sf-Regular",
                              fontSize: 15
                          ),
                        ),
                      ),

                    SizedBox(width: 20),

                      // price title
                      SizedBox(
                        width: Responsive.isDesktop(context) ? Responsive.isTablet(context) ? width * 0.09 : width * 0.12 : width * 0.10,
                        child: const Text(
                          "Price",
                          style:TextStyle(
                              color: AppColors.WhiteText,
                              fontFamily: "Sf-Regular",
                              fontSize: 15
                          ),
                        ),
                      ),
                    SizedBox(width: 20),

                    // 24H%
                    SizedBox(
                      width:Responsive.isDesktop(context) ? Responsive.isTablet(context) ? width * 0.06 : width * 0.12 : width * 0.08,
                        child: const Text(
                          "24H%",
                          style:TextStyle(
                              color: AppColors.WhiteText,fontFamily: "Sf-Regular",fontSize: 15
                          ),
                        ),
                      ),
                    SizedBox(width: 20),

                    SizedBox(
                      width: Responsive.isMobile(context) ? width * 0.13 : width * 0.15,
                        child: const Text(
                          "MarketCap",
                          style:TextStyle(
                              color: AppColors.WhiteText,
                              fontFamily: "Sf-Regular",
                              fontSize: 15
                          ),
                        ),
                      ),

                    const Expanded(
                        child: Text(
                          "Volume",
                          textAlign: TextAlign.start  ,
                          style:TextStyle(
                              color: AppColors.WhiteText,
                              fontFamily: "Sf-Regular",
                              fontSize: 15
                          ),
                        ),
                      ),


                    // Text("7Day Chart", style:TextStyle(color: AppColors.WhiteText,fontFamily: "Sf-Regular",fontSize: 15),),
                   ],
                ),
              ),
            ),
            const SizedBox(height: 10,),

            // watch list
            Expanded(
              child: isLoading
                  ?
              Helper.dialogCall.showLoader()
                  :
              DBWatchListProvider.dbWatchListProvider.watchList.isEmpty
                  ?
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                      "assets/icons/Exchange/error.svg",
                    width: width * 0.4,
                    height: height * 0.4,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "The watch list has been not created yet.",
                    style: TextStyle(
                        color: AppColors.white.withOpacity(0.4),
                        fontFamily: "Sf-Regular",
                        fontSize: 13
                    ),
                  )
                ],
              )
                  :
              ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: DBWatchListProvider.dbWatchListProvider.watchList.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index){
                    var list = DBWatchListProvider.dbWatchListProvider.watchList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 70,
                      decoration:Boxdec.ContainerRowBackgroundgradient,
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          Text(
                            "${index+1}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.white,
                                fontFamily: "Sf-Regular",
                                fontSize: 13
                            ),
                          ),
                          const SizedBox(width: 20),

                          // token image and name
                          SizedBox(
                            width: Responsive.isTablet(context) ? width * 0.18: width * 0.21,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration:Boxdec.Containercoinshadow,
                                  height:Responsive.isTablet(context)?40:50,
                                  width:Responsive.isTablet(context)?40: 50,
                                  child: Padding(
                                    padding: const EdgeInsets.all(13),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(
                                            color: Colors.black,
                                            blurRadius: 18.0,
                                          ),]
                                      ),
                                      width:Responsive.isTablet(context)?10: 20,
                                      height:Responsive.isTablet(context)?10: 20,
                                      child:CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        imageUrl: 'https://s2.coinmarketcap.com/static/img/coins/64x64/${list.marketId}.png',
                                        placeholder: (context, url) => const Center(child: SpinKitCircle(color: AppColors.white)),
                                        errorWidget: (context, url, error) =>
                                            SvgPicture.asset(
                                                'assets/icons/drawericon/colorlogoonly.svg',
                                                width: 22
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        list.name,
                                        textAlign: TextAlign.start,
                                        style:const TextStyle(
                                          color: AppColors.White,
                                          fontFamily: "Sf-SemiBold",
                                          fontSize:13,
                                        ),
                                      ),
                                      Text(
                                        list.symbol,
                                        textAlign: TextAlign.start,
                                        style:TextStyle(
                                          color: AppColors.WhiteText,
                                          fontFamily: "Sf-Regular",
                                          fontSize: Responsive.isTablet(context)|| Responsive.isMobile(context)? 11: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 20),

                          // price
                          SizedBox(
                            width: Responsive.isDesktop(context) ? Responsive.isTablet(context) ? width * 0.09 : width * 0.12 : width * 0.10,

                            child: Text(
                              "\$${ApiHandler.calculateLength3("${list.price}")}",
                              style: const TextStyle(
                                  color: AppColors.whiteColor,
                                  fontFamily: "Sf-Regular",
                                  fontSize: 13
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),

                          // 24H %
                          SizedBox(
                            width:Responsive.isDesktop(context) ? Responsive.isTablet(context) ? width * 0.06 : width * 0.12 : width * 0.08,
                            child: Text(
                              list.percent_change_24h > 0
                                  ?
                              list.percent_change_24h.toStringAsFixed(2)
                                  :
                              "${list.percent_change_24h.toStringAsFixed(2)}",
                              style:TextStyle(
                                  color: list.percent_change_24h > 0 ? AppColors.greenColor : AppColors.redColor,
                                  fontFamily: "Sf-Regular",
                                  fontSize: 13
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),

                          // marketCap
                          SizedBox(
                            width:  Responsive.isMobile(context) ? width * 0.11 : width * 0.13,
                            child: Text(
                              NumberFormat.compact().format(double.parse(list.marketCap)),
                              style: const TextStyle(
                                  color: AppColors.whiteColor,
                                  fontFamily: "Sf-Regular",
                                  fontSize: 13
                              ),
                            ),
                          ),

                          const SizedBox(width: 20),
                          // volume
                          Expanded(
                            child: Text(
                              NumberFormat.compact().format(double.parse(list.volume)),
                              style: const TextStyle(
                                  color: AppColors.whiteColor,
                                  fontFamily: "Sf-Regular",
                                  fontSize: 13
                              ),
                            ),
                          ),

                          const SizedBox(width: 20),

                          // bookmark icon
                          InkWell(
                              onTap: () async {
                                final value = await DBWatchListProvider.dbWatchListProvider.deleteWatchlist(list.marketId);
                                if(value != null){
                                  getWatchList();
                                }
                              },
                              child: Image.asset(
                                "assets/icons/yellowstar.png",
                                height: 15,
                              )
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

