import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:corewallet_desktop/Handlers/ApiHandle.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_address.dart';
import 'package:corewallet_desktop/LocalDb/Local_Token_provider.dart';
import 'package:corewallet_desktop/LocalDb/Local_Watchlist_provider.dart';
import 'package:corewallet_desktop/Models/GraphModel.dart';
import 'package:corewallet_desktop/Models/TransectionModel.dart';
import 'package:corewallet_desktop/Provider/Transection_Provider.dart';
import 'package:corewallet_desktop/Provider/Wallet_Provider.dart';
import 'package:corewallet_desktop/Values/Helper/helper.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:corewallet_desktop/Values/styleandborder.dart';
import 'package:corewallet_desktop/Values/utils.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import  'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class Price_Chart extends StatefulWidget {
  const Price_Chart({Key? key}) : super(key: key);

  @override
  State<Price_Chart> createState() => _Price_ChartState();
}

class _Price_ChartState extends State<Price_Chart> {

  bool isWatchList=false;

  late WalletProvider walletProvider;
  late TransectionProvider transectionProvider;

  TextEditingController searchController = TextEditingController();


  bool click = true;
  bool dot = false;
  bool _showRefresh = false,showBalance = false, hideSmallTRX = false;
  var width,height;

  tokenDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context,) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor:AppColors.containerbackgroundgrey,
              contentPadding:  EdgeInsets.zero,
              alignment: Alignment.center,
              insetPadding: EdgeInsets.zero,
              content: SingleChildScrollView(
                child: Container(
                  decoration:  BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient:  const LinearGradient(
                          colors:[Color(0xFF222831),AppColors.blackColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                      )
                  ),

                  width:MediaQuery.of(context).size.width/8,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                       /* Padding(
                          padding: const EdgeInsets.only(top:20),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width/5,
                            height: MediaQuery.of(context).size.height/27,

                            child: TextField(
                              controller: searchController,
                              style: const TextStyle(color: AppColors.greyColor),
                              onChanged: (value) {
                                setState((){
                                  searchList = DBTokenProvider.dbTokenProvider.tokenList.where((element) => element.symbol.toLowerCase() == value.toLowerCase()).toList();
                                });
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(0),
                                fillColor: AppColors.ContainergreySearch,
                                filled: true,
                                isDense: true,
                                hintText: "Search",

                                hintStyle: const TextStyle(color: AppColors.greydark,fontFamily: "Sf-Regular",fontSize: 14),
                                prefixIcon: Padding(
                                  padding:  const EdgeInsets.all(6),
                                  child: Image.asset("assets/images/search.png",),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25)
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
                        ),*/
                        const SizedBox(height: 10),

                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.3,
                          ),
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: DBTokenProvider.dbTokenProvider.tokenList.length,
                              itemBuilder: (BuildContext context, int index) {
                                var list = DBTokenProvider.dbTokenProvider.tokenList[index];
                                return InkWell(
                                  onTap: () async {
                                    walletProvider.addTokenDetails(list);
                                    await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId,walletProvider.accountTokenList!.networkId);
                                    setState(() {
                                      selectedTime = "1h";
                                      selectedAccountAddress = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
                                      selectedAccountPrivateAddress = DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress;
                                    });
                                    getWatchListStatus();
                                    getTransection();
                                    getCoinGraph();
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween  ,
                                      children: [
                                       Expanded(
                                         child  : Row(
                                           children: [
                                             ClipRRect(
                                               borderRadius: BorderRadius.circular(400),
                                               child: CachedNetworkImage(
                                                 fit: BoxFit.fill,
                                                 imageUrl: list.logo,
                                                 width: 30,height: 30,
                                                 placeholder: (context, url) => Helper.dialogCall.showLoader(),
                                                 errorWidget: (context, url, error) =>
                                                     SvgPicture.asset(
                                                         'assets/icons/drawericon/colorlogoonly.svg',
                                                         width: 22
                                                     ),
                                               ),
                                             ),
                                             SizedBox(width: 4),
                                             Flexible(child: Text(list.name,style: TextStyle(color: Colors.white,fontFamily: "Sf-SemiBold",fontSize: 12),)),
                                             SizedBox(width: 4,),
                                             Text(list.symbol,style: TextStyle(color:AppColors.whiteEF,fontFamily: "Sf-Regular",fontSize: 12  ),),

                                           ],
                                         ),
                                       ),
                                        Icon(
                                          walletProvider.accountTokenList!.id == list.id ? Icons.radio_button_checked: Icons.radio_button_off,
                                          color:walletProvider.accountTokenList!.id  != list.id ? AppColors.white.withOpacity(0.1) : AppColors.darkblue,
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            );
          },

        );
      },
    );
  }


  List searchList = [];

  @override
  void initState() {
    super.initState();
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    transectionProvider = Provider.of<TransectionProvider>(context, listen: false);
    selectedAccount();
  }

  String selectedAccountId = "",
      selectedAccountName = "",
      selectedAccountAddress = "",
      selectedAccountPrivateAddress = "";
  bool isLoaded = false;



  var currency = "",crySymbol = "";

  selectedAccount() async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    currency = sharedPreferences.getString("currency") ?? "USD";
    crySymbol = sharedPreferences.getString("crySymbol") ?? "\$";

    setState((){
      isLoaded = true;
      selectedAccountId = sharedPreferences.getString('accountId') ?? "";
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";
    });

    await DbAccountAddress.dbAccountAddress.getAccountAddress(selectedAccountId);
    await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId,walletProvider.accountTokenList!.networkId);


    selectedAccountAddress = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
    selectedAccountPrivateAddress = DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress;



    getCoinGraph();
    setState(() {});
    getWatchListStatus();
    getTransection();
  }

  var selectedTime = "1h";
  getCoinGraph()async{
    setState(() {
      walletProvider.GraphList.clear();
      Utils.convertType = currency;
    });

    var data = {
      "id":"${walletProvider.accountTokenList!.marketId}",
      "convert":currency,
      "interval":selectedTime,
    };

    // print(jsonEncode(data));
    await walletProvider.getCoinGraph("/cmc/quotesHistorical",data);
  }

  getWatchListStatus() async {
    await DBWatchListProvider.dbWatchListProvider.getCoinById("${walletProvider.accountTokenList!.marketId}",);
    Future.delayed(Duration(milliseconds: 500),() {
      setState(() {
        if (DBWatchListProvider.dbWatchListProvider.coinName != "") {
          setState(() {
            isWatchList = true;
          });
        } else {
          setState(() {
            isWatchList = false;
          });
        }
      });
    });
  }

  getTransection() async {
    setState(() {
      isLoaded = true;
    });

    var data = {

      "network_id": "${walletProvider.accountTokenList!.networkId}",
      "token_id":"${walletProvider.accountTokenList!.token_id}",
      "tokenDecimal": "${walletProvider.accountTokenList!.decimals}",
      "tokenAddress":walletProvider.accountTokenList!.address,
      "address":selectedAccountAddress

    };

    // print("getTransactions => $data");

    await transectionProvider.getTransection(data,'/getTransactions');
    transactionFilter();

    if(mounted) {
      setState(() {
        _showRefresh = false;
        isLoaded = false;
      });
    }
  }

  var filterType = "All";
  List<TransectionList> transectionList = [];
  transactionFilter(){

    if(filterType == "All"){
      transectionList = transectionProvider.transectionList;
    }else if(filterType == "Send"){
      setState(() {
        transectionList =  transectionProvider.transectionList.where((a) {
          return a.from.toLowerCase() == selectedAccountAddress.toLowerCase();
        }).toList();
      });
    }else{
      setState(() {
        transectionList =  transectionProvider.transectionList.where((a) {
          return a.from.toLowerCase() != selectedAccountAddress.toLowerCase();
        }).toList();
      });
    }

  }

  @override
  Widget build(BuildContext context) {

   walletProvider = Provider.of<WalletProvider>(context, listen: true);
   transectionProvider = Provider.of<TransectionProvider>(context, listen: true);

   width= MediaQuery.of(context).size.width;
   height= MediaQuery.of(context).size.height;


   return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20,right: 20,left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // app bar
            Row(
              children: [
                InkWell(
                  onTap: (){
                    walletProvider.changeListnerWallet("Wallet");
                    // Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border.all(color:AppColors.greydark),
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              AppColors.greyColor2,
                              AppColors.BlackgroundBlue,

                            ],
                          )
                      ),
                      child: Center(
                        child:Image.asset(
                            "assets/icons/backarrow.png",
                            height: 24
                        ),
                      )
                  ),
                ),

                const Spacer(),
                SizedBox(width:Responsive.isMobile(context)?width/6: width/9,),
                 Padding(
                   padding: const EdgeInsets.only(left: 0),
                   child: Text(
                       "${walletProvider.accountTokenList!.name}",
                       style: TextStyle(
                           color: AppColors.White,
                           fontFamily: "Sf-SemiBold",
                           fontSize: Responsive.isMobile(context)?18:20
                       )
                   ),
                 ),
                const Spacer(),
                Container(
                    height: 55,
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

                              const Padding(
                                padding: EdgeInsets.only(right: 28),
                                child: Text("Balance:",style:TextStyle(color:AppColors.greydark, fontSize: 12,    fontFamily: 'Sf-SemiBold',)),
                              ),
                              SizedBox(width: 0,),
                              Padding(
                                padding:  EdgeInsets.only(right: 20),
                                child: Text(
                                    "$crySymbol ${walletProvider.showTotalValue.toStringAsFixed(2)}",
                                    style:const TextStyle(
                                      color: Colors.white,fontSize: 16,
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
            const SizedBox(height: 30),

            // token details
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.1),
                    blurRadius: 26,
                  )
                ],
              ),
              child: Column(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // SizedBox(width:Responsive.isMobile(context)?width/16: width/2,),
                      const Expanded(child: SizedBox(width: 20,height: 20,)),
                      Padding(
                        padding: const EdgeInsets.only(left: 28),
                        child: Container(
                          alignment: AlignmentDirectional.center,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.09),
                                  blurRadius: 40,
                                )
                              ],
                            ),
                            child:  ClipRRect(
                              borderRadius: BorderRadius.circular(400),
                              child: CachedNetworkImage(
                                fit: BoxFit.fill,
                                imageUrl: walletProvider.accountTokenList!.logo,
                                height: 45,
                                placeholder: (context, url) => Helper.dialogCall.showLoader(),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                      "assets/icons/wallet/catenabackgroundimg.png",
                                    ),
                              ),
                            ),
                        ),
                      ),
                      const Expanded(child: SizedBox(width: 20,height: 20,)),
                      // Star
                      InkWell(
                          onTap: (){
                            if(isWatchList == false) {
                              DBWatchListProvider.dbWatchListProvider.createWatchList(
                                  "${walletProvider.accountTokenList!.marketId}",
                                  "${walletProvider.accountTokenList!.name}",
                                  "${walletProvider.accountTokenList!.symbol}",
                                  "0.0",
                                  "0.0",
                                walletProvider.accountTokenList!.price,
                                walletProvider.accountTokenList!.percentChange24H,

                              );
                              setState(() {
                                isWatchList = true;
                              });
                            }else{
                              DBWatchListProvider.dbWatchListProvider.deleteWatchlist("${walletProvider.accountTokenList!.marketId}");
                              setState(() {
                                isWatchList = false;
                              });
                            }
                          },
                          child:
                          isWatchList==true
                              ?
                          Image.asset("assets/icons/yellowstar.png",height: 20,)
                              :
                          Image.asset(
                            "assets/icons/star.png",
                            height: 20,
                            color: AppColors.greydark,
                          )
                      ),

                      const SizedBox(width: 20,height: 20,),

                     /* PopupMenuButton(
                        splashRadius: 20,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12.0),
                          ),
                        ),
                        padding: EdgeInsets.zero,
                        initialValue: 2,
                        color: AppColors.containerbackgroundgrey,
                        offset: const Offset(0, 24),
                        child: Center(
                            child: Image.asset(
                              "assets/icons/dot.png",
                              height: 15,
                              color: AppColors.greyColor,
                            )
                        ),
                        itemBuilder: (context) {
                          return List.generate(1, (index) {
                            return PopupMenuItem(
                              onTap:() {
                                _showDialog(context);
                              },
                              height:height*0.030,
                              child: SizedBox(
                                height: height*0.030,
                                child: Row(
                                  children: const [
                                    Icon(Icons.not_interested,color: AppColors.white,),
                                    SizedBox(width: 5,),
                                    Text("Disable Asset",style: TextStyle(fontSize: 12,color: AppColors.whiteColor,fontFamily: 'Sf-Regular'),)],
                                ),
                              ),
                            );
                          });
                        },
                      ),

                      const SizedBox(width: 20),*/
                    ],
                  ),
                  const SizedBox(height: 10,),

                  GestureDetector(
                    onTap: () async {
                      await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId,"","");
                      setState(() {
                        searchList.clear();
                        searchList.addAll(DBTokenProvider.dbTokenProvider.tokenList);
                        dot=!dot;
                      });
                      tokenDialog(context);

                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            walletProvider.accountTokenList!.symbol,
                            style: const TextStyle(
                                color: AppColors.White,
                                fontFamily: "Sf-SemiBold",
                                fontSize: 14,
                            )
                        ),
                        const SizedBox(width: 4,),
                        Icon(dot==true?Icons.keyboard_arrow_up:Icons.keyboard_arrow_down_outlined,color: AppColors.greydark,size: 18,),

                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),

                  InkWell(
                      onTap: () async {
                        setState(() {
                          showBalance = !showBalance;
                        });

                      },
                      child: !showBalance ?
                      const Icon(
                        Icons.visibility,
                        color: AppColors.whiteColor,
                        size: 20,
                      )
                          :
                      const Icon(
                        Icons.visibility_off,
                        color: AppColors.whiteColor,
                        size: 20,
                      )
                  ),
                  const SizedBox(height: 10,),

                  Column(
                    children: [
                      Text(
                       showBalance
                           ?
                       "*****"
                           :
                       ApiHandler.calculateLength3(double.parse(walletProvider.accountTokenList!.balance).toString()),
                        style:const TextStyle(color: AppColors.whiteColor,fontFamily: "Sf-Medium",fontSize: 25),),
                     const SizedBox(height: 5,),
                      Text(
                        "$crySymbol ${(double.parse(walletProvider.accountTokenList!.balance) * walletProvider.accountTokenList!.price).toStringAsFixed(2)}",
                        style:const TextStyle(
                            color: AppColors.greyColor,
                            fontFamily: "Sf-Medium",
                            fontSize: 12
                        ),
                      ),

                    ],
                  ),

                ],
              ),
            ),

            const SizedBox(height: 20,),

            // send and receive button
            Row(
              children: [
                const Spacer(),
                InkWell(
                  onTap: (){
                    walletProvider.changeListnerWallet("SendTo");
                  },
                  child: Container(
                    decoration: Boxdec.ButtonDecorationGradientwithBorder,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height/18,
                      width: width * 0.2,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          SvgPicture.asset(
                            'assets/icons/wallet/receive.svg',
                            height: 20,alignment: Alignment.center,
                          ),
                          const SizedBox(width: 4,),

                          Center(
                            child: ShaderMask(

                            blendMode: BlendMode.srcIn,
                            shaderCallback: (Rect bounds) {
                              return AppColors.buttonGradient.createShader(
                                  Offset.zero & bounds.size);
                            },
                            child: const Text(
                              "Send",
                              style: TextStyle(
                                shadows: [],
                                fontFamily: 'Sf-SemiBold',
                                fontSize: 13,
                              ),
                            ),
                          ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20,),

                InkWell(
                  onTap: (){
                    walletProvider.changeListnerWallet("RecieveTo");
                  },
                  child: Container(
                    decoration:  Boxdec.ButtonDecorationGradientwithBorder,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height/18,
                      width: width * 0.2,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/wallet/Send.svg',
                            height: 20,alignment: Alignment.center,
                          ),

                          Center(
                            child: ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (Rect bounds) {
                                return AppColors.buttonGradient.createShader(
                                    Offset.zero & bounds.size);
                                },
                              child: const Text(
                                "Receive",
                                style: TextStyle(
                                  fontFamily: 'Sf-SemiBold',
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),),
                ),
                const Spacer(),
              ],
            ),


            const SizedBox(height: 20,),

            // toggle option price chart/transaction ui
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.darklightgrey),
                shape: BoxShape.rectangle,
                  color: AppColors.containerbackgroundgrey.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20)
              ),
              alignment: Alignment.topCenter,

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  // toggle option buttons for price chart/transaction
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      //price chart
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              click = true;
                            });
                          },
                          child: Container(

                            // height: 40,
                            width:Responsive.isTablet(context)|| Responsive.isMobile(context)? MediaQuery.of(context).size.width/3.5:MediaQuery.of(context).size.width / 2.5,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: click == true ? 1: 1,
                                  color: (click == true)
                                      ? AppColors.darkblue
                                      : AppColors.darklightgrey,
                                  //width: 3
                                ),
                              ),
                            ),
                            child: Center(
                              child: Padding(
                                padding:  EdgeInsets.only(bottom: 10,top: 10),
                                child: Text("Price Chart",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: click == true
                                            ? AppColors.darkblue
                                            : AppColors.greyColor,
                                        fontFamily: click == true
                                            ? "Sf-SemiBold"
                                            :"Sf-Regular",
                                        )),
                              ),
                            ),
                          ),
                        ),
                      ),

                     //transaction
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              click = false;
                            });
                          },
                          child: Container(
                            // height: 40,
                            width:Responsive.isTablet(context)|| Responsive.isMobile(context)? MediaQuery.of(context).size.width/3.5: MediaQuery.of(context).size.width / 3,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: click == false ? 1 : 1,
                                  color: (click == false)
                                      ? AppColors.darkblue
                                          :
                                    AppColors.darklightgrey
                                  //width: 3
                                ),
                              ),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10,top: 10),
                                child: Text("Transactions",
                                    style: TextStyle(
                                        fontSize:  14,
                                        fontFamily: click == false
                                            ? "Sf-SemiBold":"Sf-Regular",
                                        color: click == false
                                            ? AppColors.darkblue
                                            : AppColors.greyColor,
                                       )),
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),

                  click
                      ?
                  // price graph
                  SizedBox(
                    height: height - 414,
                    width: width,
                    child: Column(
                      children: [

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(width: 20),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Price",
                                    style:TextStyle(
                                        color: AppColors.white.withOpacity(0.6),
                                        fontFamily: "Sf-Regular",
                                        fontSize: 12
                                    ),
                                  ),

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [

                                      Text(
                                        "$crySymbol ${ApiHandler.calculateLength3("${walletProvider.accountTokenList!.price}")}",
                                        style:const TextStyle(
                                            color: AppColors.white,
                                            fontFamily: "Sf-Regular",
                                            fontSize: 22
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 3.0),
                                        child: Text(
                                          walletProvider.accountTokenList!.percentChange24H > 0
                                              ?
                                          "+${walletProvider.accountTokenList!.percentChange24H.toStringAsFixed(2)} %"
                                              :
                                          "${walletProvider.accountTokenList!.percentChange24H.toStringAsFixed(2)} %",
                                          style:TextStyle(
                                              color: walletProvider.accountTokenList!.percentChange24H > 0 ? AppColors.greenColor : AppColors.redColor,
                                              fontFamily: "Sf-Regular",
                                              fontSize: 12
                                          ),
                                        ),
                                      ),

                                    ],
                                  )
                                ],
                              ),
                            ),


                            InkWell(
                              onTap: (){
                                if(selectedTime != "1h") {
                                  setState(() {
                                    selectedTime = "1h";
                                  });
                                  getCoinGraph();
                                }
                              },
                              child: Container(
                                height: 28,
                                width: 45,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color:selectedTime == "1h"  ? AppColors.blueColor : Colors.transparent,
                                    border: Border.all(color: AppColors.whiteColor.withOpacity(0.1))
                                ),
                                child: const Text(
                                    "1h",
                                  style:TextStyle(
                                      color: AppColors.whiteEF,
                                      fontFamily: "Sf-Regular",
                                      fontSize: 12
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: (){
                                setState(() {
                                  selectedTime = "24h";
                                });
                                getCoinGraph();
                              },
                              child: Container(
                                height: 28,
                                width: 45,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color:selectedTime == "24h"  ? AppColors.blueColor : Colors.transparent,
                                    border: Border.all(color: AppColors.whiteColor.withOpacity(0.1))
                                ),
                                child: const Text(
                                    "24h",
                                  style:TextStyle(
                                      color: AppColors.whiteEF,
                                      fontFamily: "Sf-Regular",
                                      fontSize: 12
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            InkWell(
                              onTap: (){
                                setState(() {
                                  selectedTime = "7d";
                                });
                                getCoinGraph();
                              },
                              child: Container(
                                height: 28,
                                width: 45,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color:selectedTime == "7d"  ? AppColors.blueColor : Colors.transparent,
                                    border: Border.all(color: AppColors.whiteColor.withOpacity(0.1))
                                ),
                                child: const Text(
                                    "7d",
                                  style:TextStyle(
                                      color: AppColors.whiteEF,
                                      fontFamily: "Sf-Regular",
                                      fontSize: 12
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            InkWell(
                              onTap: (){
                                setState(() {
                                  selectedTime = "30d";
                                });

                                getCoinGraph();

                              },
                              child: Container(
                                height: 28,
                                width: 45,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color:selectedTime == "30d"  ? AppColors.blueColor : Colors.transparent,
                                    border: Border.all(color: AppColors.whiteColor.withOpacity(0.1))
                                ),
                                child: const Text(
                                    "30d",
                                  style:TextStyle(
                                      color: AppColors.whiteEF,
                                      fontFamily: "Sf-Regular",
                                      fontSize: 12
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            InkWell(
                              onTap: (){
                                setState(() {
                                  selectedTime = "90d";
                                });

                                getCoinGraph();

                              },
                              child: Container(
                                height: 28,
                                width: 45,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color:selectedTime == "90d"  ? AppColors.blueColor : Colors.transparent,
                                    border: Border.all(color: AppColors.whiteColor.withOpacity(0.1))
                                ),
                                child: const Text(
                                    "90d",
                                  style:TextStyle(
                                      color: AppColors.whiteEF,
                                      fontFamily: "Sf-Regular",
                                      fontSize: 12
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            InkWell(
                              onTap: (){
                                setState(() {
                                  selectedTime = "1y";
                                });
                                getCoinGraph();
                              },
                              child: Container(
                                height: 28,
                                width: 45,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color:selectedTime == "1y"  ? AppColors.blueColor : Colors.transparent,
                                    border: Border.all(color: AppColors.whiteColor.withOpacity(0.1))
                                ),
                                child: const Text(
                                    "1y",
                                  style:TextStyle(
                                      color: AppColors.whiteEF,
                                      fontFamily: "Sf-Regular",
                                      fontSize: 12
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),

                          ],
                        ),

                        const SizedBox(height: 30),

                        walletProvider.isLoading
                            ?
                        Expanded(
                          child: Helper.dialogCall.showLoader(),
                        )
                            :
                        Expanded(
                          child: SfCartesianChart(
                              plotAreaBorderWidth: 0,
                              primaryXAxis: CategoryAxis(
                                arrangeByIndex: true,
                                labelStyle: const TextStyle(
                                    color: AppColors.whiteColor,
                                    fontFamily: "Sf-Regular",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400
                                ),

                                majorGridLines: const MajorGridLines(width: 0),
                              ),

                              primaryYAxis: NumericAxis(
                                rangePadding: ChartRangePadding.additional,
                                isVisible: true,
                                labelStyle: const TextStyle(
                                    color: AppColors.whiteColor,
                                    fontFamily: "Sf-Regular",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400
                                ),

                                majorGridLines: MajorGridLines(width: 0.1),
                                axisLine: const AxisLine(width: 0),
                                majorTickLines: const MajorTickLines(width: 0),
                              ),

                              series: <SplineAreaSeries<PriceModel, String>>[

                                SplineAreaSeries<PriceModel, String>(
                                    animationDuration: 2,
                                    dataSource: walletProvider.GraphList,
                                    xValueMapper: (PriceModel sales, _) => sales.date,
                                    yValueMapper: (PriceModel sales, _) => double.parse(sales.price.toStringAsFixed(15)),
                                    markerSettings: const MarkerSettings(isVisible: false),
                                    borderColor: AppColors.Textgreen,
                                    borderWidth: 2,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.Textgreen.withOpacity(0.2),
                                        AppColors.Textgreen.withOpacity(0.16),
                                        AppColors.Textgreen.withOpacity(0.01),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,

                                    )
                                )

                              ]

                          ),
                        ),

                      ],
                    ),
                  )
                    :
                  // Transaction Page
                  SizedBox(
                    height: height-414,
                    child: isLoaded
                        ?
                    Helper.dialogCall.showLoader()
                        :
                    Column(
                      children: [

                        Align(
                            alignment: Alignment.centerRight,
                          child: PopupMenuButton<String>(
                            splashRadius: 20,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12.0),
                              ),
                            ),
                            padding: EdgeInsets.zero ,
                            // initialValue: 2,
                            color: AppColors.containerbackgroundgrey,
                            offset: const Offset(0, 24),
                             child: Padding(
                               padding: const EdgeInsets.only(top: 12.0,right: 20),
                               child: Image.asset(
                                 "assets/icons/alertbo.png",
                                 width: 20,
                                 color: AppColors.darkblue,
                               ),
                             ),
                            onSelected: (value) {
                              setState(() {
                                filterType = value;
                              });
                              transactionFilter();
                            },

                            itemBuilder: (BuildContext bc) {
                              return  [
                                PopupMenuItem<String>(
                                  value: 'All',
                                  child: SizedBox(
                                    width: 100.0,
                                    child: Row(
                                       children: [
                                         SvgPicture.asset(
                                           'assets/icons/wallet/blueticket.svg',
                                           height: 22,alignment: Alignment.center,
                                           color: filterType == "All" ? AppColors.blueColor2 : AppColors.greyColor,

                                         ),

                                         const SizedBox(width: 5,),
                                         Text(
                                             "All Type",
                                             style: TextStyle(
                                                 fontFamily: "Sf-Regular",
                                                 color: filterType == "All" ? AppColors.blueColor2 : AppColors.greyColor,
                                                 fontSize: 16
                                             ),
                                             textAlign: TextAlign.center
                                         ),
                                      ],
                                    ),
                                  ),
                                ),

                                PopupMenuItem<String>(
                                  value: 'Send',
                                  child: SizedBox(
                                    width: 100.0,
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/wallet/Send.svg',
                                          height: 22,alignment: Alignment.center,
                                          color: filterType == "Send" ? AppColors.blueColor2 : AppColors.greyColor,

                                        ),
                                        const SizedBox(width: 5,),
                                        Text(
                                            "Send",
                                            style: TextStyle(
                                                fontFamily: "Sf-Regular",
                                                color: filterType == "Send" ? AppColors.blueColor2 : AppColors.greyColor,
                                                fontSize: 16
                                            ),
                                            textAlign: TextAlign.center
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                PopupMenuItem<String>(
                                  value: 'Receive',
                                  child:SizedBox(
                                  width: 100.0,
                                  child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/wallet/receive.svg',
                                          height: 22,alignment: Alignment.center,
                                          color: filterType == "Receive" ? AppColors.blueColor2 : AppColors.greyColor,

                                        ),
                                        const SizedBox(width: 5,),
                                        Text(
                                            "Receive",
                                            style: TextStyle(
                                                fontFamily: "Sf-Regular",
                                                color: filterType == "Receive" ? AppColors.blueColor2 : AppColors.greyColor,
                                                fontSize: 16
                                            ),
                                            textAlign: TextAlign.center
                                        ),
                                      ],
                                    ),
                                ),
                                ),
                              ];
                            },
                           ),
                        ),

                        const SizedBox(height: 20),
                        Expanded(
                          child: transectionList.isEmpty
                              ?
                          Center(
                            child: Image.asset(
                              "assets/icons/notranaction.png",
                              width:  MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height*0.45,
                            )
                          )
                              :

                          ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                            child: GroupedListView(
                              groupHeaderBuilder: (element) {
                                return  Padding(
                                  padding: const EdgeInsets.only(left:5,bottom: 8.0),
                                  child: Text(
                                      DateFormat("MMM dd,yyyy").format(DateTime.fromMillisecondsSinceEpoch(int.parse(element.timeStamp) * 1000)),
                                      style: TextStyle(
                                          color: AppColors.white.withOpacity(0.6),
                                          fontFamily: "Sf-SemiBold",
                                          fontSize: 12
                                      )
                                  ),
                                );
                              },
                              elements: transectionList,
                              groupBy: (element) =>DateFormat("MMM dd,yyyy").format(DateTime.fromMillisecondsSinceEpoch(int.parse(element.timeStamp) * 1000)),
                              itemBuilder: (context, list) {

                                return Container(
                                  margin: const EdgeInsets.only(left:10,right:10,top: 0,bottom: 10),
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  alignment: Alignment.center,
                                  height:70,
                                  decoration: BoxDecoration(
                                    // border: Border.all(color: AppColors.darkblueContainer,width: 0),
                                      color: AppColors.ContainergreyhomeColor,
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,

                                    children: [
                                      const SizedBox(width: 10),
                                      // token name and image
                                      SizedBox(
                                        width: Responsive.isTablet(context) ? width * 0.19 :width * 0.2,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Token",
                                              style:TextStyle(
                                                  color: AppColors.white.withOpacity(0.6),
                                                  fontFamily: "Sf-SemiBold",
                                                  fontSize:Responsive.isTablet(context)|| Responsive.isMobile(context)? MediaQuery.of(context).size.width*0.012: 11
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(400),
                                                  child: CachedNetworkImage(
                                                    fit: BoxFit.fill,
                                                    imageUrl: walletProvider.accountTokenList!.logo,
                                                    height: 16,alignment: Alignment.center,
                                                    placeholder: (context, url) => Helper.dialogCall.showLoader(),
                                                    errorWidget: (context, url, error) =>
                                                        Image.asset(
                                                          "assets/icons/wallet/catenabackgroundimg.png",
                                                        ),
                                                  ),
                                                ),

                                                SizedBox(width: 5,),
                                                Text(
                                                  "${walletProvider.accountTokenList!.name}",
                                                  style:const TextStyle(
                                                      color: AppColors.whiteEF,
                                                      fontFamily: "Sf-Regular",
                                                      fontSize: 12
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      // form and to address
                                      SizedBox(
                                        width: Responsive.isDesktop(context)
                                            ? width * 0.22 :Responsive.isTablet(context)
                                            ? width * 0.23 : width * 0.25,
                                        child: Row(
                                          children: [
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "From",
                                                  style:TextStyle(
                                                      color: AppColors.white.withOpacity(0.6),
                                                      fontFamily: "Sf-SemiBold",
                                                      fontSize: 12
                                                  ),
                                                ),

                                                Text(
                                                  "${list.from.substring(0,4)}....${list.from.substring(list.from.length -4,list.from.length)}",
                                                  style:const TextStyle(
                                                      color: AppColors.whiteEF,
                                                      fontFamily: "Sf-Regular",
                                                      fontSize:12
                                                  ),
                                                ),

                                              ],
                                            ),
                                            const SizedBox(width: 8,),

                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: Container(
                                                alignment: Alignment.bottomCenter,
                                                child:
                                                SvgPicture.asset(
                                                  list.from.toLowerCase() != selectedAccountAddress.toLowerCase()
                                                      ?
                                                  'assets/icons/wallet/Send.svg'
                                                      :
                                                  'assets/icons/wallet/receive.svg',
                                                  height: 20,
                                                  alignment: Alignment.center,
                                                  color: list.from.toLowerCase() == selectedAccountAddress.toLowerCase() ? AppColors.darkRedColor : AppColors.greenColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),

                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "To",
                                                  style:TextStyle(
                                                      color:AppColors.white.withOpacity(0.6),
                                                      fontFamily: "Sf-SemiBold",
                                                      fontSize:12
                                                  ),
                                                ),

                                                Text(
                                                  "${list.to.substring(0,4)}....${list.to.substring(list.to.length -4,list.to.length)}",
                                                  style:const TextStyle(
                                                      color: AppColors.white,
                                                      fontFamily: "Sf-Regular",
                                                      fontSize:12
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 8),

                                          ],
                                        ),
                                      ),

                                      Spacer(),
                                      // values
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Value",
                                            style:TextStyle(
                                                color: AppColors.white.withOpacity(0.6),
                                                fontFamily: "Sf-Regular",
                                                fontSize: 12
                                            ),
                                          ),
                                          Text(
                                            "$crySymbol ${(list.value * walletProvider.accountTokenList!.price).toStringAsFixed(2)}",
                                            style:const TextStyle(
                                                color: AppColors.white,
                                                fontFamily: "Sf-Regular",
                                                fontSize:12
                                            ),
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      const SizedBox(width: 10),
                                      Spacer(),


                                      // amount
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Amount",
                                            style:TextStyle(
                                                color: AppColors.white.withOpacity(0.6),
                                                fontFamily: "Sf-SemiBold",
                                                fontSize: 11
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                ApiHandler.calculateLength("${list.value}"),
                                                style:const TextStyle(
                                                    color: AppColors.white,
                                                    fontFamily: "Sf-Regular",
                                                    fontSize:14
                                                ),
                                              ),
                                              Text(
                                                walletProvider.accountTokenList!.symbol,
                                                style:TextStyle(
                                                    color: AppColors.white.withOpacity(0.6),
                                                    fontFamily: "Sf-Regular",
                                                    fontSize:11
                                                ),
                                              ),

                                            ],
                                          ),
                                        ],
                                      ),


                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          /*ListView.builder(
                              itemCount: transectionList.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                var list = transectionList[index];
                                return Container(
                                  margin: const EdgeInsets.only(left:10,right:10,top: 0,bottom: 10),
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  alignment: Alignment.center,
                                  height:70,
                                  decoration: BoxDecoration(
                                    // border: Border.all(color: AppColors.darkblueContainer,width: 0),
                                      color: AppColors.ContainergreyhomeColor,
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,

                                    children: [
                                      const SizedBox(width: 10),
                                      // token name and image
                                      SizedBox(
                                        width: Responsive.isTablet(context) ? width * 0.19 :width * 0.2,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Token",
                                              style:TextStyle(
                                                  color: AppColors.white.withOpacity(0.6),
                                                  fontFamily: "Sf-SemiBold",
                                                  fontSize:Responsive.isTablet(context)|| Responsive.isMobile(context)? MediaQuery.of(context).size.width*0.012: 11
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(400),
                                                  child: CachedNetworkImage(
                                                    fit: BoxFit.fill,
                                                    imageUrl: walletProvider.accountTokenList!.logo,
                                                    height: 16,alignment: Alignment.center,
                                                    placeholder: (context, url) => Helper.dialogCall.showLoader(),
                                                    errorWidget: (context, url, error) =>
                                                        Image.asset(
                                                          "assets/icons/Core_Multichain.png",
                                                        ),
                                                  ),
                                                ),

                                                SizedBox(width: 5,),
                                                Text(
                                                  "${walletProvider.accountTokenList!.name}",
                                                  style:const TextStyle(
                                                      color: AppColors.whiteEF,
                                                      fontFamily: "Sf-Regular",
                                                      fontSize: 12
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      // form and to address
                                      SizedBox(
                                        width: Responsive.isDesktop(context)
                                            ? width * 0.22 :Responsive.isTablet(context)
                                            ? width * 0.23 : width * 0.25,
                                        child: Row(
                                          children: [
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "From",
                                                  style:TextStyle(
                                                      color: AppColors.white.withOpacity(0.6),
                                                      fontFamily: "Sf-SemiBold",
                                                      fontSize: 12
                                                  ),
                                                ),

                                                Text(
                                                  "${list.from.substring(0,4)}....${list.from.substring(list.from.length -4,list.from.length)}",
                                                  style:const TextStyle(
                                                      color: AppColors.whiteEF,
                                                      fontFamily: "Sf-Regular",
                                                      fontSize:12
                                                  ),
                                                ),

                                              ],
                                            ),
                                            const SizedBox(width: 8,),

                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: Container(
                                                alignment: Alignment.bottomCenter,
                                                child:
                                                SvgPicture.asset(
                                                  list.from.toLowerCase() != selectedAccountAddress.toLowerCase()
                                                      ?
                                                  'assets/icons/wallet/Send.svg'
                                                      :
                                                  'assets/icons/wallet/receive.svg',
                                                  height: 20,
                                                  alignment: Alignment.center,
                                                  color: list.from.toLowerCase() == selectedAccountAddress.toLowerCase() ? AppColors.darkRedColor : AppColors.greenColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),

                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "To",
                                                  style:TextStyle(
                                                      color:AppColors.white.withOpacity(0.6),
                                                      fontFamily: "Sf-SemiBold",
                                                      fontSize:12
                                                  ),
                                                ),

                                                Text(
                                                  "${list.to.substring(0,4)}....${list.to.substring(list.to.length -4,list.to.length)}",
                                                  style:const TextStyle(
                                                      color: AppColors.white,
                                                      fontFamily: "Sf-Regular",
                                                      fontSize:12
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 8),

                                          ],
                                        ),
                                      ),

                                      Spacer(),
                                      // values
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Value",
                                            style:TextStyle(
                                                color: AppColors.white.withOpacity(0.6),
                                                fontFamily: "Sf-Regular",
                                                fontSize: 12
                                            ),
                                          ),
                                          Text(
                                            "$crySymbol ${(list.value * walletProvider.accountTokenList!.price).toStringAsFixed(2)}",
                                            style:const TextStyle(
                                                color: AppColors.white,
                                                fontFamily: "Sf-Regular",
                                                fontSize:12
                                            ),
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      const SizedBox(width: 10),
                                      Spacer(),


                                      // amount
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Amount",
                                            style:TextStyle(
                                                color: AppColors.white.withOpacity(0.6),
                                                fontFamily: "Sf-SemiBold",
                                                fontSize: 11
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                ApiHandler.calculateLength("${list.value}"),
                                                style:const TextStyle(
                                                    color: AppColors.white,
                                                    fontFamily: "Sf-Regular",
                                                    fontSize:14
                                                ),
                                              ),
                                              Text(
                                                walletProvider.accountTokenList!.symbol,
                                                style:TextStyle(
                                                    color: AppColors.white.withOpacity(0.6),
                                                    fontFamily: "Sf-Regular",
                                                    fontSize:11
                                                ),
                                              ),

                                            ],
                                          ),
                                        ],
                                      ),


                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                );
                              }),*/
                        ),
                      ],
                    ),
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
