import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_address.dart';
import 'package:corewallet_desktop/LocalDb/Local_Token_provider.dart';
import 'package:corewallet_desktop/Provider/Token_Provider.dart';
import 'package:corewallet_desktop/Provider/Wallet_Provider.dart';
import 'package:corewallet_desktop/Values/Helper/helper.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:corewallet_desktop/Values/styleandborder.dart';
import 'package:corewallet_desktop/Values/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Debouncer {
  final int milliseconds;
  late VoidCallback action;
  Timer? timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (null != timer) {
      timer!.cancel();
    }
    timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}


class Wallets_Add_assets extends StatefulWidget {
  const Wallets_Add_assets({Key? key}) : super(key: key);

  @override
  State<Wallets_Add_assets> createState() => _Wallets_Add_assetsState();
}

class _Wallets_Add_assetsState extends State<Wallets_Add_assets> {

  final _debouncer = Debouncer(milliseconds: 500);

  late TokenProvider tokenProvider;
  late WalletProvider walletProvider;

  TextEditingController searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    Future.delayed(Duration.zero,(){
      selectedAccount();
    });
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

    for(int i=0; i< DbAccountAddress.dbAccountAddress.allAccountAddress.length; i ++){

      if(DbAccountAddress.dbAccountAddress.allAccountAddress[i].publicKeyName == "address"){
        selectedAccountAddress = DbAccountAddress.dbAccountAddress.allAccountAddress[i].publicAddress;
        selectedAccountPrivateAddress = DbAccountAddress.dbAccountAddress.allAccountAddress[i].privateAddress;
      }
    }

    getSearchToken();
  }


  getSearchToken() async {

    setState(() {
      isLoaded = false;
    });
    var data = {
      "search_term": "",
      "network_id":0,
      "type":"ALL"
    };
    await tokenProvider.getSearchToken(data,'/getTokensByNetwork');
    setState(() {
      isLoaded = true;
    });
  }

  String selectedTokenType='',token_normal_id = "",network_id = "",
      tokenId = "",tokenAddress="",tokan_name = "",token_symbol = "",tokan_decimals = "";


  deleteToken(String tokenId,int index) async {
    Helper.dialogCall.showAlertDialog(context);
    setState(() {
      isLoaded = false;
    });

    var data = {
      "token_id": tokenId,
      "address": ""
    };

    await tokenProvider.deleteToken(data,'/deleteAccountToken');

    setState((){
      DBTokenProvider.dbTokenProvider.deleteToken(tokenId);

      DBTokenProvider.dbTokenProvider.tokenList.removeAt(index);

      isLoaded = true;
    });

    await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId,"","");
    setState(() {});

    Navigator.pop(context,"refresh");
  }

  addCustomToken(index) async {
    Helper.dialogCall.showAlertDialog(context);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    currency = sharedPreferences.getString("currency") ?? "USD";



    var data = {
      "network_id": "$network_id",
      "tokenAddress": "${tokenAddress}",
      "type":"$selectedTokenType",
      "name":"${tokan_name}",
      "symbol":"${token_symbol}",
      "decimals":"${tokan_decimals}",
      "address":  "$selectedAccountAddress",
    };

    // print(json.encode(data));

    await tokenProvider.addCustomToken(data,'/addToken',selectedAccountId);
    if(tokenProvider.isTokenAdded == false){

      Helper.dialogCall.showToast(context, "Token Already Added on This Account");

      setState(() {
        network_id = "";
        tokenAddress = "";
        selectedTokenType = "";
        token_symbol = "";
        tokan_name = "";
        tokan_decimals = "";

      });
      Navigator.pop(context);

    }
    else{

      network_id = "";
      selectedTokenType = "";
      token_symbol = "";
      tokan_name = "";
      tokan_decimals = "";


      await DbAccountAddress.dbAccountAddress.getAccountAddress(selectedAccountId);

      var data = {};

      for (int j = 0; j < DbAccountAddress.dbAccountAddress.allAccountAddress.length; j++) {
        data[DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicKeyName] = DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicAddress;
      }

      data["convert"] = currency;

      await tokenProvider.getAccountToken(data, '/getAccountTokens', selectedAccountId);

      await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId,"","");
      walletProvider.changeListnerWallet("Wallet");
      Navigator.pop(context);

    }
  }


  Widget build(BuildContext context)  {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    walletProvider = Provider.of<WalletProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);

    return  Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10,right: 10,top: 20),
        child: Column(
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
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border.all(color:AppColors.greydark),
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              AppColors.greyColor2,
                              AppColors.BlackgroundBlue,

                            ],)),
                      child: Center(
                        child:Image.asset("assets/icons/backarrow.png",height: 24),)),
                ),
                const Spacer(),
                SizedBox(width:Responsive.isMobile(context)?width/8: width/11,),
                Text("Add Assets",style: TextStyle(color: AppColors.White,fontFamily: "Sf-SemiBold",fontSize:Responsive.isMobile(context)?16: 18)),
                Spacer(),
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
                              const SizedBox(width: 20,),

                              const Padding(
                                padding: EdgeInsets.only(right: 28),
                                child: Text("Balance:",style:TextStyle(color:AppColors.greydark, fontSize: 12,    fontFamily: 'Sf-SemiBold',)),
                              ),
                              Padding(
                                padding:  EdgeInsets.only(right: 20),
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
            const SizedBox(height: 0,),

            // top title
            Center(child: Padding(
              padding: const EdgeInsets.only(top: 10,bottom: 30,left: 0,right: 0),
              child: Container(
                width: width/3.5,
                  alignment: Alignment.center,
                  child: const Text("Enable assets to your home page.", style:TextStyle(color: AppColors.greyColor,fontFamily: "Sf-Regular",fontSize: 12),textAlign: TextAlign.center,)),
            )),

            // search filed
            Row(
              children: [
                const Expanded(child: SizedBox()),
                SizedBox(
                  width: MediaQuery.of(context).size.width/3,
                  height: MediaQuery.of(context).size.height/24,

                  child: TextField(
                    cursorColor: AppColors.white,
                    controller: searchController,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontFamily: "Sf-Regular",
                        fontSize: 16
                    ),
                    onChanged: (value){
                      _debouncer.run(() {
                        setState(() {

                          tokenProvider.searchTokenList = tokenProvider.allTokenList.where((u) {
                            return (u.name.toLowerCase().contains(value.toLowerCase()));
                          }).toList();

                          tokenProvider.selectTokenBool = tokenProvider.searchSelectTokenBool.where((u) {
                            return (u['tokenName'].toLowerCase().contains(value.toLowerCase()));
                            // print("token${u['tokenName']}");
                          }).toList();
                          // print("token${tokenProvider.selectTokenBool}");


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
                          fontSize: 16
                      ),

                      prefixIcon: Padding(
                        padding:const EdgeInsets.all(6),
                        child:
                        SvgPicture.asset(
                            'assets/icons/wallet/search.svg',
                            width: 10
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
                const Expanded(child: SizedBox()),
              ],
            ),

            // Token list Heading title
            Padding(
              padding:  EdgeInsets.only(top: 20,left: 5,right: 5,bottom: 5),
              child: Column(
                children: [
                  Container(
                    height:MediaQuery.of(context).size.height/18 ,
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.darklightgrey,width: 0),
                        color: AppColors.HeaderdarkbluesColor,
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Row(children: [
                      SizedBox(width:Responsive.isMobile(context)?10: 20,),
                      const Text("Assets Name", style:TextStyle(color: AppColors.WhiteText,fontFamily: "Sf-Regular",fontSize: 13),),

                     /* SizedBox(width:Responsive.isMobile(context)?10: 55,),

                     Spacer(),
                      Row(
                        children: const [
                          Text("Balance", style:TextStyle(color: AppColors.WhiteText,fontFamily: "Sf-Regular",fontSize: 13),),
                          Icon(Icons.arrow_drop_down,color: AppColors.greyColor ,size: 15,)

                        ],
                      ),
                      // Expanded(child: SizedBox(width: 30,)),
                      // SizedBox(width: width/19,),
                      Spacer(),

                      Row(
                        children: const [
                          Text("Price", style:TextStyle(color: AppColors.WhiteText,fontFamily: "Sf-Regular",fontSize: 13),),
                          Icon(Icons.arrow_drop_down,color: AppColors.greyColor,size: 15,)

                        ],
                      ),

                      Spacer(),
                      // SizedBox(width: width/19,),
                      // Expanded(child: SizedBox(width:Responsive.isMobile(context)?10: 0,)),
                      Row(
                        children: const [
                          Text("24H Change", style:TextStyle(color: AppColors.WhiteText,fontFamily: "Sf-Regular",fontSize:13),),
                          Icon(Icons.arrow_drop_down,color: AppColors.greyColor ,size: 15,)

                        ],
                      ),
                      // Expanded(child: SizedBox(width: 0,)),
                      // SizedBox(width: width/20,),
                      const SizedBox(width: 25,),
                      const Spacer(),*/


                    ],),
                  ),
                ],
              ),
            ),


            // token list
            Expanded(
              child: !isLoaded
                  ?
              Helper.dialogCall.showLoader()
                  :
              ListView.builder(
                itemCount: tokenProvider.searchTokenList.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index){
                  var list = tokenProvider.searchTokenList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    height:MediaQuery.of(context).size.height/10 ,
                    decoration:Boxdec.ContainerRowBackgroundgradient,
                    child: Row(

                      children: [
                        Expanded(
                          child: SizedBox(
                            width:Responsive.isTablet(context)|| Responsive.isMobile(context)? MediaQuery.of(context).size.width/6: MediaQuery.of(context).size.width/8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 10),
                                Container(
                                  decoration:Boxdec.Containercoinshadow,
                                  height:50,
                                  width: 50,
                                  child: Padding(
                                    padding: const EdgeInsets.all(13),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle, // BoxShape.circle or BoxShape.retangle
                                          //color: const Color(0xFF66BB6A),
                                          boxShadow: [BoxShadow(
                                            color: Colors.black,
                                            blurRadius: 18.0,
                                          ),]
                                      ),
                                      width: 20,
                                      height: 20,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(400),
                                        child: CachedNetworkImage(
                                          fit: BoxFit.fill,
                                          imageUrl: list.logo,
                                          placeholder: (context, url) => Helper.dialogCall.showLoader(),
                                          errorWidget: (context, url, error) =>
                                              SvgPicture.asset(
                                                  'assets/icons/drawericon/colorlogoonly.svg',
                                                  width: 22
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${list.name}",
                                        //textAlign: TextAlign.start,
                                        style:TextStyle(color: AppColors.White,fontFamily: "Sf-SemiBold",fontSize:Responsive.isTablet(context)|| Responsive.isMobile(context)? 13: 13),),
                                      Row(
                                        children: [
                                          Text(
                                            "${list.type}",
                                            textAlign: TextAlign.start,
                                            style:TextStyle(
                                                color: AppColors.WhiteText,
                                                fontFamily: "Sf-Regular",
                                                fontSize: Responsive.isTablet(context)|| Responsive.isMobile(context)? 11: 13
                                            ),
                                          ),

                                          SizedBox(width: list.type == "" ? 0:4),
                                          Text("${list.symbol}",
                                            textAlign: TextAlign.start,
                                            style:TextStyle(
                                                color: AppColors.WhiteText,
                                                fontFamily: "Sf-Regular",
                                                fontSize: Responsive.isTablet(context)|| Responsive.isMobile(context)? 11: 13
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                           padding: const EdgeInsets.only(right: 20),
                           child: FlutterSwitch(
                             width: 40.0,
                             height: 20.0,
                             activeColor:AppColors.redColor,
                             valueFontSize: 20.0,
                             toggleSize: 20.0,
                             value: tokenProvider.selectTokenBool[index]["isSelected"],
                             borderRadius: 30.0,
                             padding: 1.0,
                             showOnOff: false,
                             onToggle: (val) async {
                               if(val) {
                                 await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId, tokenProvider.searchTokenList[index].networkId);

                                 setState(() {
                                   selectedAccountAddress = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
                                   tokenProvider.isSearch = false;
                                   //print("${tokenProvider.searchTokenList[index].address}");
                                   network_id = "${tokenProvider.searchTokenList[index].networkId}";
                                   token_normal_id = "${tokenProvider.searchTokenList[index].id}";
                                   tokenId = "${tokenProvider.searchTokenList[index].marketId}";
                                   tokan_name = "${tokenProvider.searchTokenList[index].name}";
                                   tokenAddress = "${tokenProvider.searchTokenList[index].address}";
                                   selectedTokenType = "${tokenProvider.searchTokenList[index].type}";
                                   token_symbol = "${tokenProvider.searchTokenList[index].symbol}";
                                   tokan_decimals = "${tokenProvider.searchTokenList[index].decimals}";
                                 });

                                 addCustomToken(index);
                                 setState(() {
                                   tokenProvider.selectTokenBool[index]["isSelected"] = val;
                                 });
                               }
                               else {
                                 var index2 = DBTokenProvider.dbTokenProvider.tokenList.indexWhere((element) =>
                                 "${element.marketId}" == "${tokenProvider.searchTokenList[index].marketId}");
                                 deleteToken("${DBTokenProvider.dbTokenProvider.tokenList[index2].id}", index2);
                                 setState(() {
                                   tokenProvider.selectTokenBool[index]["isSelected"] = val;
                                 });
                               }
                             },
                           ),
                         ),
                      ],
                    ),
                  );},
              ),
            ),


            SizedBox(height: 10,),
          ],),
      ),
    );
  }
}


final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final  divider = Divider(color: AppColors.whiteColor.withOpacity(0), height: 0);


