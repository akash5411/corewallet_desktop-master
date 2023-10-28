import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:corewallet_desktop/Handlers/ApiHandle.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_address.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_provider.dart';
import 'package:corewallet_desktop/LocalDb/Local_Token_provider.dart';
import 'package:corewallet_desktop/Models/AccountTokenModel.dart';
import 'package:corewallet_desktop/Provider/Account_Provider.dart';
import 'package:corewallet_desktop/Provider/Token_Provider.dart';
import 'package:corewallet_desktop/Provider/Wallet_Provider.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Wallet/PriceChart.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:corewallet_desktop/Values/styleandborder.dart';
import 'package:corewallet_desktop/Values/utils.dart';
import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../values/Helper/helper.dart';


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


class Wallet extends StatefulWidget {

  const Wallet({Key? key}) : super(key: key);

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {

  final _debouncer = Debouncer(milliseconds: 500);

  late AccountProvider accountProvider;
  late TokenProvider tokenProvider;

  final GlobalKey _key = GlobalKey();

  var height = 0.0,width = 0.0;
  late WalletProvider walletProvider;

  TextEditingController searchController = TextEditingController();


  final border = const OutlineInputBorder(
      borderRadius: BorderRadius.horizontal(left: Radius.circular(5))
  );

  @override
  void initState() {
    super.initState();

    accountProvider = Provider.of<AccountProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    walletProvider = Provider.of<WalletProvider>(context, listen: false);

    Future.delayed(Duration.zero,(){
      selectedAccount();
    });

  }


  late String deviceId;
  String selectedAccountId = "",
      selectedAccountName = "",
      selectedAccountAddress = "",
      selectedAccountPrivateAddress = "",cryChange = "";

  bool isLoaded = false,isNeeded = false,_showRefresh = false;

  var trxPrivateKey ="", currency = "",crySymbol = "";
  var filerValue = "";

  selectedAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      isLoaded = false;
      cryChange = sharedPreferences.getString('cryChange') ?? "";
      selectedAccountId = sharedPreferences.getString('accountId') ?? "";
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";
      selectedAccountAddress = sharedPreferences.getString('accountAddress') ?? "";
      selectedAccountPrivateAddress = sharedPreferences.getString('accountPrivateAddress') ?? "";

      currency = sharedPreferences.getString("currency") ?? "USD";
      crySymbol = sharedPreferences.getString("crySymbol") ?? "\$";
      filerValue = sharedPreferences.getString("filerValue") ?? "Balance";
    });

    if(cryChange != ""){
      setState(() {
        isNeeded = true;
        sharedPreferences.setString('cryChange',"");
      });
    }

    if(selectedAccountId == "") {
      setState(() {
        selectedAccountId = "${DBAccountProvider.dbAccountProvider.newAccountList[0].id}";
        selectedAccountName = "${DBAccountProvider.dbAccountProvider.newAccountList[0].name}";

        sharedPreferences.setString('accountId', selectedAccountId);
        sharedPreferences.setString('accountName', selectedAccountName);

      });
    }


    await DbAccountAddress.dbAccountAddress.getAccountAddress(selectedAccountId);
    for(int i=0; i< DbAccountAddress.dbAccountAddress.allAccountAddress.length; i ++){

      if(DbAccountAddress.dbAccountAddress.allAccountAddress[i].publicKeyName == "address"){

        setState((){
          selectedAccountAddress = DbAccountAddress.dbAccountAddress.allAccountAddress[i].publicAddress;
          selectedAccountPrivateAddress = DbAccountAddress.dbAccountAddress.allAccountAddress[i].privateAddress;
          // print("selectedAccountAddress ====>  ${Helper.dialogCall.decryptAddressColumn(selectedAccountAddress)}");
          sharedPreferences.setString('accountAddress', selectedAccountAddress);
          sharedPreferences.setString('accountPrivateAddress', selectedAccountPrivateAddress);
        });

      }
    }

    await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId,9);


    if(mounted){
      setState((){
        trxPrivateKey = Helper.dialogCall.decryptAddressColumn(DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress) ;

      });
    }

    // setState(() {
    //   trxPrivateKey = Helper.dialogCall.decryptAddressColumn(DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress) ;
    // });

    getToken();
  }

  getToken() async {
    if (isNeeded == true) {
      await DbAccountAddress.dbAccountAddress.getAccountAddress(selectedAccountId);

      var data = {};

      for (int j = 0; j < DbAccountAddress.dbAccountAddress.allAccountAddress.length; j++) {
        data[DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicKeyName] = DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicAddress;
      }

      data["convert"] = currency;

      await tokenProvider.getAccountToken(data, '/getAccountTokens', selectedAccountId);

      setState(() {
        isNeeded = false;
      });
    }

    await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId,searchController.text,filerValue);

    getSocketData();

    setState(() {
      _showRefresh = false;
      isLoaded = true;
    });
  }

  IO.Socket? socket;
  getSocketData() async {
    // print("Connecting socket");
    socket = IO.io('http://${Utils.url}/', <String, dynamic>{
      "secure": true,
      "path":"/api/socket.io",
      "rejectUnauthorized": false,
      "transports":["websocket", "polling"],
      "upgrade": false,
    });

    socket!.connect();

    socket!.onConnect((_) {

      socket!.on("getTokenBalance", (response) async {
        // print(json.encode(response));

        if (response["status"] == true) {

          if("${response["data"]["balance"]}" != "0" ) {
            if (response["data"]["balance"] != "null") {
              await DBTokenProvider.dbTokenProvider.updateTokenBalance(
                '${response["data"]["balance"]}',
                '${response["data"]["id"]}',
              );
            }
          }
        }

        await  DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId,searchController.text,filerValue);

        getAccountTotal();

      });
    });



    for (int i = 0; i <
        DBTokenProvider.dbTokenProvider.tokenList.length; i++) {
      var data = {
        "id": "${DBTokenProvider.dbTokenProvider.tokenList[i].id}",
        "network_id": "${DBTokenProvider.dbTokenProvider.tokenList[i].networkId}",
        "tokenAddress": DBTokenProvider.dbTokenProvider.tokenList[i].address,
        "address": DBTokenProvider.dbTokenProvider. tokenList[i].accAddress,
        "trxPrivateKey": "$trxPrivateKey"
      };

      // print("socket emit ==>  $data");
      socket!.emit("getTokenBalance", jsonEncode(data));
    }

  }

  double showTotalValue = 0.0;
  getAccountTotal() async {
    if(mounted) {
      setState(() {
        showTotalValue = 0.0;
      });
    }
    double valueUsd = 0.0;
    for(int i =0; i<DBTokenProvider.dbTokenProvider.tokenList.length; i++){


      if (DBTokenProvider.dbTokenProvider.tokenList[i].balance == "" ||
          DBTokenProvider.dbTokenProvider.tokenList[i].balance == "0" ||
          DBTokenProvider.dbTokenProvider.tokenList[i].balance == null ||
          DBTokenProvider.dbTokenProvider.tokenList[i].price == 0.0
      ) {
        valueUsd += 0;
      }
      else {
        valueUsd += double.parse(DBTokenProvider.dbTokenProvider.tokenList[i].balance) * DBTokenProvider.dbTokenProvider.tokenList[i].price;
      }

    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if(mounted) {
      setState(() {
        List list = DBTokenProvider.dbTokenProvider.tokenList.where((
            element) => "${element.token_id}" == "3").toList();
        if (list.isNotEmpty) {
          walletProvider.cmcxBalance =
          (double.parse(list.first.balance) * list.first.price);
        }
        showTotalValue = valueUsd;
        walletProvider.showTotalValue = showTotalValue;
        sharedPreferences.setDouble("myBalance", showTotalValue);
      });
    }
    // print("show Total Value === > $showTotalValue");
  }

  // delete coin dialog
  deleteAlert(String tokenId,int index) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darklightgrey,
        actionsPadding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
        contentPadding: const EdgeInsets.fromLTRB(18, 30, 10, 10),
        content: const Text(
            'Do you want to Delete Your Token',
            style: TextStyle(
                fontSize: 14,
                color:AppColors.white ,
                fontFamily: "Sf-SemiBold"
            )
        ),
        actions: <Widget>[
          MaterialButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
                "No",
                style: TextStyle(
                    fontSize: 14,
                    color:AppColors.white ,
                    fontFamily: "Sf-SemiBold"
                )
            ),
          ),
          MaterialButton(
            onPressed: () {

              Navigator.pop(context,"Refresh");
              deleteToken(tokenId,index);

            },
            child: const Text(
                "Yes",
                style: TextStyle(
                    fontSize: 14,
                    color:AppColors.white ,
                    fontFamily: "Sf-SemiBold"
                )
            ),
          ),
        ],
      ),
    );
  }

  // Delete Token api
  deleteToken(String tokenId,int index) async {

    setState(() {
      isLoaded = false;
    });

    var data = {
      "token_id": tokenId,
      "address": ""
    };

    // print(data);
    await tokenProvider.deleteToken(data,'/deleteAccountToken');


    setState((){
      DBTokenProvider.dbTokenProvider.deleteToken(tokenId);
      DBTokenProvider.dbTokenProvider.tokenList.removeAt(index);
      isLoaded = true;
    });

    getToken();

  }

  Future<void> _getData() async {

    socket!.close();
    socket!.destroy();
    socket!.dispose();

    setState(() {

      _showRefresh = true;
      isNeeded = true;
      getToken();
    });
  }

  donothing() async{}



  @override
  void dispose() {
    socket!.disconnect();
    socket!.destroy();
    socket!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)  {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    walletProvider = Provider.of<WalletProvider>(context, listen: true);

    return  Scaffold(
      key: _key,
      body: DeclarativeRefreshIndicator(
        color:  AppColors.blueColor,
        backgroundColor:AppColors.whiteColor,
        onRefresh: _showRefresh == true ? donothing : _getData,
        refreshing: _showRefresh,
        child: GestureDetector(
          onTap: () {
            setState(() {
              FocusScope.of(context).unfocus();
              searchController.clear();
              DBTokenProvider.dbTokenProvider.searchTokenList = DBTokenProvider.dbTokenProvider.tokenList;
            });
          },
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/icons/wallet/backimg.png"
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10,right: 10,top: 20),
              child: Column(
                children: [

                  // app bar
                  Row(
                    children: [
                    /*  Container(
                          padding: const EdgeInsets.all(8),
                          decoration: Boxdec.BackButtonGradient,
                          child: Center(
                            child:Image.asset(
                                "assets/images/status.png",
                                height: 24
                            ),
                          ),
                      ),*/



                      const Spacer(),
                      SizedBox(width:Responsive.isMobile(context)?width/6: width/9,),

                      const Text(
                          "Wallet",
                          style: TextStyle(
                              color: AppColors.White,
                              fontFamily: "Sf-SemiBold",
                              fontSize: 20
                          )
                      ),


                      const Spacer(),


                      const SizedBox(width: 20,),
                      //stack
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
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Text(
                                          "$crySymbol ${walletProvider.showTotalValue.toStringAsFixed(2)}",
                                          style:const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'Sf-SemiBold',
                                          ),
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
                                        SizedBox(width: 5,),
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

                                      ],),
                                  ),
                                ),  ),
                            ],
                          )
                      ),
                    ],
                  ),

                  const SizedBox(height: 20,),

                  // search and add asset button
                  Row(
                    children: [

                      InkWell(
                        onTap: (){
                          walletProvider.changeListnerWallet("AddAssets");
                        },
                        child: Container(
                          child:Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: const [

                                Icon(Icons.add,color: AppColors.darkblue,size: 20),

                                Text("Add Assets", style:TextStyle(color: AppColors.darkblue,fontFamily: "Sf-Medium",fontSize: 13 ),),
                              ],),
                          ) ,),
                      ),
                      const Expanded(child: SizedBox(width: 1,)),
                      Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: SizedBox(
                          width:Responsive.isMobile(context)?MediaQuery.of(context).size.width/2.5: MediaQuery.of(context).size.width/3.4,
                          height: MediaQuery.of(context).size.height/24,
                          child: TextField(
                            cursorColor: AppColors.white,
                            controller: searchController,
                            style: const TextStyle(
                                color: AppColors.white,
                                fontFamily: "Sf-Regular",
                                fontSize: 16
                            ),
                            onSubmitted: (value) {
                              if(value.isEmpty || value == "") {
                                DBTokenProvider.dbTokenProvider.searchTokenList = DBTokenProvider.dbTokenProvider.tokenList;
                                // print("DBTokenProvider.dbTokenProvider.searchTokenList of wallet${DBTokenProvider.dbTokenProvider.searchTokenList}");
                              }
                              else{
                                _debouncer.run(() {
                                  setState(() {
                                    DBTokenProvider.dbTokenProvider.searchTokenList = DBTokenProvider.dbTokenProvider.searchTokenList.where((u) {
                                      return (u.name.toLowerCase().contains(
                                          value.toLowerCase()));
                                    }).toList();
                                  });
                                });
                              }
                              setState(() {});
                            },
                            onChanged: (value) async {
                              if(value.isEmpty || value == "") {
                                setState(() {
                                  // print(DBTokenProvider.dbTokenProvider.searchTokenList);
                                  // print("hi");
                                  DBTokenProvider.dbTokenProvider.searchTokenList = DBTokenProvider.dbTokenProvider.tokenList;
                                  //print("DBTokenProvider.dbTokenProvider.searchTokenList of wallet${DBTokenProvider.dbTokenProvider.searchTokenList}");
                                });
                              }
                              else{
                                _debouncer.run(() {
                                  setState(() {
                                    DBTokenProvider.dbTokenProvider.searchTokenList = DBTokenProvider.dbTokenProvider.searchTokenList.where((u) {
                                      return (u.name.toLowerCase().contains(
                                          value.toLowerCase()));
                                    }).toList();
                                    // print("DBTokenProvider.dbTokenProvider.searchTokenList of wallet${DBTokenProvider.dbTokenProvider.searchTokenList}");

                                  });
                                });
                              }
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
                                      DBTokenProvider.dbTokenProvider.searchTokenList = DBTokenProvider.dbTokenProvider.tokenList;
                                    });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.clear,color: AppColors.whiteColor,),
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
                      ),
                      const Expanded(child: SizedBox(width: 1,)),
                    ],
                  ),

                  // coins detail title assets,balance,price,24chnege
                  Padding(
                    padding:  EdgeInsets.only(top: 10,left: 5,right: 5),
                    child: Container(

                      height:MediaQuery.of(context).size.height/18 ,
                      decoration: BoxDecoration(
                          border:const GradientBoxBorder(
                            gradient: LinearGradient(colors: [ AppColors.darklightgrey,AppColors.darkblueContainer,]),
                            width: 0.2,
                          ),
                          color: AppColors.HeaderdarkbluesColor,
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: Row(
                        children: [
                        const SizedBox(width: 25,),
                          InkWell(
                            onTap: () async {
                              SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                              setState(() {
                                sharedPreferences.setString("filerValue", "Name");
                                filerValue = "Name";
                              });
                              await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId, searchController.text, filerValue);
                              setState(() {});
                            },
                          child: SizedBox(
                            width:
                            MediaQuery.of(context).size.width*0.26,
                            child: const Text(
                              "Assets Name",
                              style:TextStyle(
                                  color: AppColors.greyColor,
                                  fontFamily: "Sf-Regular",
                                  fontSize: 13
                              ),
                            ),
                          ),
                        ),


                          //balance
                        InkWell(
                          onTap: () async {
                            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                            setState(() {
                              sharedPreferences.setString("filerValue", "Balance");
                              filerValue = "Balance";
                            });
                            await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId, searchController.text, filerValue);
                            setState(() {});
                         },
                          child: SizedBox(
                            width: width*0.19,
                            child: Row(
                              children:  const [
                                Text(
                                  "Balance",
                                  style:TextStyle(
                                      color: AppColors.greyColor,
                                      fontFamily: "Sf-Regular",
                                      fontSize: 13,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.greyColor,
                                  size: 15,
                                )
                              ],
                            ),
                          ),
                        ),
                          // SizedBox(
                          //   width:
                          //   width/6.6,
                          // ),


                          InkWell(
                            onTap: () async {
                              SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                              setState(() {
                                sharedPreferences.setString("filerValue", "Price");
                                filerValue = "Price";
                              });
                              await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId, searchController.text, filerValue);
                              setState(() {});

                            },
                            child: SizedBox(
                              width:Responsive.isTablet(context) || Responsive.isMobile(context)? width*0.15:width*0.23,
                              child: Row(
                                children: const [
                                  Text(
                                    "Price",
                                    style:TextStyle(
                                        color: AppColors.greyColor,
                                        fontFamily: "Sf-Regular",
                                        fontSize: 13
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.greyColor,
                                    size: 15,
                                  )
                                ],
                              ),
                            ),
                          ),

                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                              setState(() {
                                sharedPreferences.setString("filerValue", "24H");
                                filerValue = "24H";
                              });
                              await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId, searchController.text, filerValue);
                              setState(() {});

                            },
                            child: SizedBox(
                              width: width*0.03,
                              child: Row(
                                children:  const [
                                  Text(
                                    "24H Change",
                                    style:TextStyle(
                                        color: AppColors.greyColor,
                                        fontFamily: "Sf-Regular",
                                        fontSize: 13
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.greyColor,
                                    size: 15,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                         const SizedBox(width: 10,),
                        ],
                      ),
                    ),
                  ),

                  // coin list
                  DBTokenProvider.dbTokenProvider.searchTokenList.isEmpty
                      ?
                  Expanded(
                    child: Column(
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
                          "The assets list has been not created yet.",
                          style: TextStyle(
                              color: AppColors.white.withOpacity(0.4),
                              fontFamily: "Sf-Regular",
                              fontSize: 13
                          ),
                        )
                      ],
                    ),
                  )
                      :
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                      child: ListView.builder(
                        clipBehavior: Clip.antiAlias,
                          itemCount: DBTokenProvider.dbTokenProvider.searchTokenList.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index){
                            var list =  DBTokenProvider.dbTokenProvider.searchTokenList[index];
                            // print(list.toJson());
                            // print("olla ${DBTokenProvider.dbTokenProvider.searchTokenList.length}");
                            // print("olla ${list}");
                            return
                              Slidable(
                              endActionPane: ActionPane(
                                extentRatio: 0.08,
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context){
                                      deleteAlert(
                                          "${list.id}",
                                          index
                                      );

                                    },
                                    backgroundColor: AppColors.darkRedColor,
                                    foregroundColor: AppColors.white,
                                    icon: Icons.delete,
                                    borderRadius: BorderRadius.circular(15),
                                    spacing: 40,
                                  ),
                                ],
                              ),
                              child: InkWell(
                                  onTap: (){
                                    walletProvider.changeListnerWallet("PriceChart");
                                    walletProvider.addTokenDetails(list);
                                  },
                                  child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5,left: 5,right: 5),
                                          child: Container(
                                            height:MediaQuery.of(context).size.height/10 ,
                                            decoration:Boxdec.ContainerRowBackgroundgradient,
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 15),
                                                // coin image name and symbol
                                                SizedBox(
                                                    width:MediaQuery.of(context).size.width*0.27,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      //   here decoration background and images
                                                      Container(
                                                        decoration:Boxdec.Containercoinshadow,
                                                        height:50,
                                                        width: 50,
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(13),
                                                          child: Container(
                                                            decoration: const BoxDecoration(
                                                                shape: BoxShape.circle, // BoxShape.circle or BoxShape.retangle
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
                                                                imageUrl: list.logo,
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
                                                      const SizedBox(width: 10),


                                                      Expanded(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              list.name,
                                                              style:TextStyle(
                                                                  color: AppColors.White,
                                                                  fontFamily: "Sf-SemiBold",
                                                                  fontSize:Responsive.isTablet(context)|| Responsive.isMobile(context)? 13: 13
                                                              ),
                                                            ),

                                                            Row(
                                                              children: [

                                                                Text(
                                                                  list.type,
                                                                  textAlign: TextAlign.start,
                                                                  style:TextStyle(
                                                                      color: AppColors.WhiteText,
                                                                      fontFamily: "Sf-Regular",
                                                                      fontSize: Responsive.isTablet(context)|| Responsive.isMobile(context)? 11: 14
                                                                  ),
                                                                ),
                                                                SizedBox(width: list.type == "" ? 0:4),
                                                                Text(list.symbol,
                                                                  textAlign: TextAlign.start,
                                                                  style:TextStyle(color: AppColors.WhiteText,fontFamily: "Sf-Regular",fontSize: Responsive.isTablet(context)|| Responsive.isMobile(context)? 11: 14),),

                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5,)
                                                    ],
                                                  ),
                                                ),



                                               // SizedBox(width: MediaQuery.of(context).size.width/35,),

                                                // balance and usd value
                                                SizedBox(
                                                  width: width*0.18,

                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        list.balance == "0"
                                                            ?
                                                        double.parse(list.balance).toStringAsFixed(2)
                                                            :
                                                        ApiHandler.calculateLength3(list.balance== "0" ?"0.0" : list.balance),

                                                        style:const TextStyle(
                                                            color: AppColors.White,
                                                            fontFamily: "Sf-Regular",
                                                            fontSize: 14
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2,),
                                                      Text(
                                                        "$crySymbol ${(double.parse(list.balance) * list.price).toDouble().toStringAsFixed(2)}",
                                                        style:const TextStyle(
                                                            color: AppColors.WhiteText,
                                                            fontFamily: "Sf-Regular",
                                                            fontSize: 14
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // SizedBox(width: 20,),


                                                // Token price
                                                SizedBox(
                                                  width:Responsive.isTablet(context) || Responsive.isMobile(context)? width*0.19:width*0.26 ,
                                                  child: Text(
                                                    "$crySymbol ${ApiHandler.calculateLength3("${list.price}")}",
                                                    style:const TextStyle(
                                                        color: AppColors.WhiteText,
                                                        fontFamily: "Sf-Regular",
                                                        fontSize: 14
                                                    ),
                                                  ),
                                                ),
                                                 // Spacer(),

                                                SizedBox(
                                                  width: width * 0.05,
                                                  child: Text(
                                                    list.percentChange24H.toDouble().toStringAsFixed(2),
                                                    style:TextStyle(
                                                        color: list.percentChange24H > 0 ? AppColors.Textgreen : AppColors.redColor,
                                                        fontFamily: "Sf-Regular",
                                                        fontSize: 14
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 0,),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ]
                                  ),
                                ),
                            );
                          }),
                    ),
                  ),
                  const SizedBox(height: 10,),

                  // bottom Add Assets butoon
                  Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10,bottom: 20),
                    child: InkWell(
                      onTap: (){
                        walletProvider.changeListnerWallet("AddAssets");

                      },
                      child: DottedBorder(

                        padding: EdgeInsets.only(top: 0,bottom: 0,),
                        borderType: BorderType.RRect,
                        radius: Radius.circular(10),
                        dashPattern: [3, 3],
                        color:AppColors.greydark,
                        strokeWidth: 1,
                        child: Container(
                          height: MediaQuery.of(context).size.height/13,
                          decoration: BoxDecoration(
                            color: Color(0xFF222831),

                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: ShaderMask(

                            blendMode: BlendMode.srcIn,
                            shaderCallback: (Rect bounds) {
                              return AppColors.buttonGradient.createShader(
                                  Offset.zero & bounds.size);
                            },
                            child: const Text(
                              "Add More Assets",
                              style: TextStyle(
                                  fontFamily: 'Sf-SemiBold',
                                  fontSize: 14
                              ),
                            ),
                          ),),
                        ),),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class GradientBoxBorder extends BoxBorder {
  const GradientBoxBorder({required this.gradient, this.width = 1.0});

  final Gradient gradient;

  final double width;

  @override
  BorderSide get bottom => BorderSide.none;

  @override
  BorderSide get top => BorderSide.none;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  void paint(
      Canvas canvas,
      Rect rect, {
        TextDirection? textDirection,
        BoxShape shape = BoxShape.rectangle,
        BorderRadius? borderRadius,
      }) {
    switch (shape) {
      case BoxShape.circle:
        assert(
        borderRadius == null,
        'A borderRadius can only be given for rectangular boxes.',
        );
        _paintCircle(canvas, rect);
        break;
      case BoxShape.rectangle:
        if (borderRadius != null) {
          _paintRRect(canvas, rect, borderRadius);
          return;
        }
        _paintRect(canvas, rect);
        break;
    }
  }

  void _paintRect(Canvas canvas, Rect rect) {
    canvas.drawRect(rect.deflate(width / 2), _getPaint(rect));
  }

  void _paintRRect(Canvas canvas, Rect rect, BorderRadius borderRadius) {
    final rrect = borderRadius.toRRect(rect).deflate(width / 2);
    canvas.drawRRect(rrect, _getPaint(rect));
  }

  void _paintCircle(Canvas canvas, Rect rect) {
    final paint = _getPaint(rect);
    final radius = (rect.shortestSide - width) / 2.0;
    canvas.drawCircle(rect.center, radius, paint);
  }

  @override
  ShapeBorder scale(double t) {
    return this;
  }

  Paint _getPaint(Rect rect) {
    return Paint()
      ..strokeWidth = width
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke;
  }
}
