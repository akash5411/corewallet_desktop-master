import 'package:cached_network_image/cached_network_image.dart';
import 'package:corewallet_desktop/Handlers/ApiHandle.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_address.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_provider.dart';
import 'package:corewallet_desktop/LocalDb/Local_Exchange_Provider.dart';
import 'package:corewallet_desktop/LocalDb/Local_Token_provider.dart';
import 'package:corewallet_desktop/Models/AccountTokenModel.dart';
import 'package:corewallet_desktop/Models/ExchangeModel.dart';
import 'package:corewallet_desktop/Provider/ExchangeProvider.dart';
import 'package:corewallet_desktop/Provider/Token_Provider.dart';
import 'package:corewallet_desktop/Provider/Wallet_Provider.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Wallet/Wallet.dart';
import 'package:corewallet_desktop/Values/Helper/helper.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:corewallet_desktop/Values/styleandborder.dart';
import 'package:corewallet_desktop/Values/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;



class Exchange_Page extends StatefulWidget {
  const Exchange_Page({Key? key}) : super(key: key);

  @override
  State<Exchange_Page> createState() => _Exchange_PageState();
}

class _Exchange_PageState extends State<Exchange_Page> {


  late WalletProvider walletProvider;
  late ExchangeProvider exchangeProvider;
  late TokenProvider tokenProvider;

  bool showLoader = false;

  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    showLoader = true;
    Future.delayed(Duration.zero,(){
      selectedAccount();
      tokenProvider.searchNetWorkTokenTokenList.clear();
      getSearchToken("");
      getProviders();
    });
  }


  bool isLoaded = false,isLoading = false;
  late String deviceId;
  String selectedAccountId = "",
      selectedAccountName = "",
      selectedAccountAddress = "",
      selectedAccountPrivateAddress = "" ,currency = "",crySymbol = "";

  selectedAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      isLoaded = false;
      selectedAccountId = sharedPreferences.getString('accountId') ?? "";
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";
      selectedAccountAddress = sharedPreferences.getString('accountAddress') ?? "";
      selectedAccountPrivateAddress = sharedPreferences.getString('accountPrivateAddress') ?? "";
      currency = sharedPreferences.getString("currency") ?? "USD";
      crySymbol = sharedPreferences.getString("crySymbol") ?? "\$";
    });

    if(selectedAccountId == "")
    {

      selectedAccountId = "${DBAccountProvider.dbAccountProvider.newAccountList[0].id}";
      selectedAccountName = "${DBAccountProvider.dbAccountProvider.newAccountList[0].name}";

      sharedPreferences.setString('accountId', selectedAccountId);
      sharedPreferences.setString('accountName', selectedAccountName);
    }

    await DbAccountAddress.dbAccountAddress.getAccountAddress(selectedAccountId);
    for(int i=0; i< DbAccountAddress.dbAccountAddress.allAccountAddress.length; i ++){

      if(DbAccountAddress.dbAccountAddress.allAccountAddress[i].publicKeyName == "address"){

        setState((){
          selectedAccountAddress = DbAccountAddress.dbAccountAddress.allAccountAddress[i].publicAddress;
          selectedAccountPrivateAddress = DbAccountAddress.dbAccountAddress.allAccountAddress[i].privateAddress;
        });

      }
    }

    getToken();

  }

  String providerName = "",
      providerImage = "",
      providerRouter = "";
  int? providerActive;

  getProviders() async {

    var data = {
      "network": network_id
    };
    await tokenProvider.getSwapProviders(data,'/getSwapProviders');

    if(tokenProvider.isProviderLoading == false) {
      if(tokenProvider.providersList.isNotEmpty) {
        if(mounted) {
          setState(() {
            providerName = tokenProvider.providersList[0].name;
            providerRouter = tokenProvider.providersList[0].router;
            providerImage = tokenProvider.providersList[0].logo;
            providerActive = tokenProvider.providersList[0].is_active;
          });
        }
      }
    }
  }

  getSearchToken(String search) async {
    var data = {
      "network_id":network_id,
      "search_term": "$search"
    };
    // print(data);
    await tokenProvider.getSearchNetWorkToken(data,'/getTokensByNetwork');
  }

  getToken() async {

    await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId,"","");
    //print(DBTokenProvider.dbTokenProvider.tokenList);
    getCustomTokenBalance();

    setState(() {
      isLoaded = true;
    });
  }

  // ===========================================================================

  // ========== Send Token Bottom =========

  String sendTokenAddress = "",
      sendTokenNetworkId = "2",
      sendTokenName = "Binance Smart Chain",
      sendTokenSymbol = "BNB",
      sendTokenMarketId = "1839",
      sendTokenImage = "http://${Utils.url}/api/img/binance_logo.png",
      sendTokenUsd = "0",
      sendTokenBalance = "0",
      sendTokenId = "2",
      sendTokenDes = "18";

  double sendAmountUsd = 0.0;

  sendBottomSheet(BuildContext context) {
    showDialog(
      context: context,

      builder: (BuildContext context,) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return Padding(
              padding:  EdgeInsets.only(right:Responsive.isDesktop(context)?0:  50,top: Responsive.isDesktop(context)?0:  100),
              child: AlertDialog(
                actionsPadding:const EdgeInsets.symmetric(vertical: 10,horizontal: 30),
                // contentPadding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),

                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.0),),),
                contentPadding: EdgeInsets.all(0.0),

                backgroundColor:AppColors.containerbackgroundgrey,
                alignment: Alignment.center,
                insetPadding:EdgeInsets.zero,
                content: SingleChildScrollView(
                  child: Container(
                    decoration:  BoxDecoration(
                        borderRadius: BorderRadius.circular(10),

                        gradient:  const LinearGradient(
                            colors:[Color(0xFF222831),AppColors.blackColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)),

                    width:Responsive.isMobile(context) ? MediaQuery.of(context).size.width / 2 : MediaQuery.of(context).size.width/2.3,

                    child: Padding(
                      padding: const EdgeInsets.only(top:20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,

                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left:20),
                                child: InkWell(
                                    onTap: (){
                                      Navigator.pop(context);
                                    },
                                    child: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        color: AppColors.whiteColor,
                                        size: 18
                                    )
                                ),
                              ),
                              SizedBox(width: width/50,),
                              const Text(
                                "My Tokens",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontFamily: 'Sf-SemiBold',
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.8,
                            ),
                            child: DBTokenProvider.dbTokenProvider.tokenList.where((element) => "${element.networkId}" == network_id).toList().isEmpty
                                ?
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/Exchange/error.svg",
                                  width: width * 0.4,
                                  height: height * 0.4,
                                ),
                                SizedBox(height: 20),

                                Text(
                                  "$network_name tokens are not available",
                                  style: TextStyle(
                                      color: AppColors.white.withOpacity(0.4),
                                      fontFamily: "Sf-Regular",
                                      fontSize: 13
                                  ),
                                ),
                                SizedBox(height: 30),
                              ],
                            )
                                :
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: DBTokenProvider.dbTokenProvider.tokenList.length,
                                itemBuilder: (BuildContext context, int index) {

                                  var list = DBTokenProvider.dbTokenProvider.tokenList[index];
                                  return "${list.networkId}" != network_id
                                      ?
                                  SizedBox()
                                      :
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20,right:20,bottom: 10),
                                    child: InkWell(
                                      onTap: () async {

                                        if("${DBTokenProvider.dbTokenProvider.tokenList[index].marketId}" == receiveTokenMarketId){

                                          Helper.dialogCall.showToast(context,"You Cant Select Both Same Token");

                                        }
                                        else{


                                          setState((){
                                            sendTokenAddress = DBTokenProvider.dbTokenProvider.tokenList[index].address;
                                            sendTokenId = "${DBTokenProvider.dbTokenProvider.tokenList[index].token_id}";
                                            sendTokenNetworkId = "${DBTokenProvider.dbTokenProvider.tokenList[index].networkId}";
                                            sendTokenName = DBTokenProvider.dbTokenProvider.tokenList[index].name;
                                            sendTokenSymbol = DBTokenProvider.dbTokenProvider.tokenList[index].symbol;
                                            sendTokenMarketId = "${DBTokenProvider.dbTokenProvider.tokenList[index].marketId}";
                                            sendTokenImage = DBTokenProvider.dbTokenProvider.tokenList[index].logo;
                                            sendTokenBalance = DBTokenProvider.dbTokenProvider.tokenList[index].balance;
                                            sendTokenUsd = "${DBTokenProvider.dbTokenProvider.tokenList[index].price}";
                                            sendTokenDes = "${DBTokenProvider.dbTokenProvider.tokenList[index].decimals}";
                                          });



                                          Navigator.pop(context);

                                        }

                                      },
                                      child:  Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(400),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              imageUrl: list.logo,
                                              width: 25,height: 25,
                                              placeholder: (context, url) => Helper.dialogCall.showLoader(),
                                              errorWidget: (context, url, error) =>
                                                  SvgPicture.asset(
                                                      'assets/icons/drawericon/colorlogoonly.svg',
                                                      width: 22
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),

                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  list.name,
                                                  style: const TextStyle(
                                                    color: AppColors.white,
                                                    fontFamily: 'Sf-SemiBold',
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                Text(
                                                  list.symbol,
                                                  style: const TextStyle(
                                                    color: AppColors.greyColor,
                                                    fontFamily: 'Sf-Regular',
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          Text(
                                            ApiHandler.calculateLength3(double.parse(list.balance).toString()),
                                            style: const TextStyle(
                                              color: AppColors.white,
                                              fontFamily: 'Sf-Regular',
                                              fontSize: 13,
                                            ),
                                          ),
                                          Column(
                                            children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 5),
                                              child: Text(
                                                list.symbol,
                                                style: const TextStyle(
                                                  color: AppColors.white,
                                                  fontFamily: 'Sf-SemiBold',
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            Text(
                                                "\$${(double.parse(list.balance) * list.price).toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  color: AppColors.greyColor,
                                                  fontFamily: 'Sf-Regular',
                                                  fontSize: 11,
                                                ),
                                                textAlign: TextAlign.end
                                            ),

                                          ],
                                          ),
                                          const SizedBox(width: 10),

                                          Icon(
                                            sendTokenId== "${list.token_id}"
                                                ?
                                            Icons.radio_button_checked: Icons.radio_button_off,
                                            color:sendTokenId != "${list.token_id}" ? AppColors.white.withOpacity(0.1) : AppColors.darkblue,
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
              ),
            );
          },

        );
      },
    ).whenComplete(() => setState((){}));
  }


  // ========== Receive Token Bottom =========
  String receiveTokenAddress = "",
      receiveTokenNetworkId = "",
      receiveTokenName = "",
      receiveTokenSymbol = "",
      receiveTokenMarketId = "",
      receiveTokenImage = "",
      receiveTokenBalance = "0",
      receiveTokenUsd = "0",
      receiveTokenId = "",
      receiveDes = "";

  double receiveAmountUsd = 0.0;

  receiveBottomSheet(BuildContext context) {
    showDialog(
      context: context,

      builder: (BuildContext context,) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            tokenProvider = Provider.of<TokenProvider>(context, listen: true);
            getSearchToken(String search) async {

              setState((){
                isLoading = true;
              });

              var data = {
                "network_id":network_id,
                "search_term": "$search"
              };
              await tokenProvider.getSearchNetWorkToken(data,'/getTokensByNetwork');

              setState((){
                isLoading = false;
              });

            }

            return Padding(
              padding:  EdgeInsets.only(right:Responsive.isDesktop(context)?0:  50,top: Responsive.isDesktop(context)?0:  100),
              child: AlertDialog(
                actionsPadding:const EdgeInsets.symmetric(vertical: 10,horizontal: 30),
                // contentPadding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),

                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.0),),),
                contentPadding: EdgeInsets.all(0.0),

                backgroundColor:AppColors.containerbackgroundgrey,
                alignment: Alignment.center,
                insetPadding:EdgeInsets.symmetric(vertical: 0,horizontal: 0),


                content: SingleChildScrollView(
                  child: Container(
                    decoration:  BoxDecoration(
                        borderRadius: BorderRadius.circular(10),

                        gradient:  const LinearGradient(
                            colors:[Color(0xFF222831),AppColors.blackColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)),

                    width:MediaQuery.of(context).size.width/2.3,

                    child: Padding(
                      padding: const EdgeInsets.only(top:20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,

                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left:20),
                                child: InkWell(
                                    onTap: (){
                                      Navigator.pop(context);
                                    },
                                    child: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        color: AppColors.whiteColor,
                                        size:18
                                    )
                                ),
                              ),
                              SizedBox(width: width/50,),
                              SizedBox(
                                width: MediaQuery.of(context).size.width/3,
                                height: MediaQuery.of(context).size.height/25,

                                child: TextField(
                                  style: const TextStyle(
                                    color: AppColors.greyColor,
                                    fontFamily: "Sf-Regular",
                                    fontSize: 14,
                                  ),

                                  onChanged: (value){
                                    if(value.isEmpty){
                                      getSearchToken("");
                                    }else {
                                      Future.delayed(Duration.zero, () async {
                                        getSearchToken(value);
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(0),
                                    fillColor: AppColors.searchbackground,
                                    filled: true,
                                    isDense: true,
                                    hintText: "Search",

                                    hintStyle: TextStyle(
                                        color: AppColors.greydark,
                                        fontFamily: "Sf-Regular",
                                        fontSize: 14,
                                    ),
                                    prefixIcon: Padding( padding:  EdgeInsets.all(6),
                                      child: Image.asset("assets/images/search.png",),
                                    ),
                                    border: OutlineInputBorder(
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
                            ],
                          ),
                          SizedBox(height: 20),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.8,
                            ),
                            child: isLoading == true
                                ?
                            Helper.dialogCall.showLoader()
                                :
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: tokenProvider.searchNetWorkTokenTokenList.length,
                                itemBuilder: (BuildContext context, int index) {

                                  var list = tokenProvider.searchNetWorkTokenTokenList[index];
                                  return  Padding(
                                    padding: const EdgeInsets.only(left: 20,right:20,bottom: 10),
                                    child: InkWell(
                                      onTap: (){

                                        if(sendTokenMarketId == "${tokenProvider.searchNetWorkTokenTokenList[index].marketId}"){
                                          Helper.dialogCall.showToast(context, "You Cant Select Both Same Token");
                                        }
                                        else{
                                          //print("receive token address $receiveTokenAddress");
                                          setState(() {

                                            receiveTokenAddress = tokenProvider.searchNetWorkTokenTokenList[index].address;
                                            receiveTokenId = "${tokenProvider.searchNetWorkTokenTokenList[index].id}";
                                            receiveTokenNetworkId = "${tokenProvider.searchNetWorkTokenTokenList[index].networkId}";
                                            receiveTokenName = tokenProvider.searchNetWorkTokenTokenList[index].name;
                                            receiveTokenSymbol = tokenProvider.searchNetWorkTokenTokenList[index].symbol;
                                            receiveTokenMarketId = "${tokenProvider.searchNetWorkTokenTokenList[index].marketId}";
                                            receiveTokenImage = tokenProvider.searchNetWorkTokenTokenList[index].logo;
                                            receiveDes = "${tokenProvider.searchNetWorkTokenTokenList[index].decimals}";
                                            toController = TextEditingController(text: "0.0");
                                          });
                                          Navigator.pop(context);

                                        }

                                      },
                                      child:  Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(400),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              imageUrl: list.logo,
                                              width: 25,height: 25,
                                              placeholder: (context, url) => SizedBox(
                                                  width: 25,height: 25,
                                                  child: Helper.dialogCall.showLoader()
                                              ),
                                              errorWidget: (context, url, error) =>
                                                  SvgPicture.asset(
                                                      'assets/icons/drawericon/colorlogoonly.svg',
                                                      width: 22
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),

                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  list.name,
                                                  style: const TextStyle(
                                                    color: AppColors.white,
                                                    fontFamily: 'Sf-SemiBold',
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  list.symbol,
                                                  style: const TextStyle(
                                                    color: AppColors.greyColor,
                                                    fontFamily: 'Sf-Regular',
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Expanded(child: SizedBox()),

                                          Icon(
                                            receiveTokenId == "${list.id}"
                                                ?
                                            Icons.radio_button_checked: Icons.radio_button_off,
                                            color:receiveTokenId != "${list.id}" ? AppColors.white.withOpacity(0.1) : AppColors.darkblue,
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
              ),
            );
          },

        );
      },
    ).whenComplete(() {

      getCustomTokenBalance();
      getSearchToken("");

      setState(() {
        FocusScope.of(context).unfocus();
      });

      // getEstimate();

    });
  }



  getCustomTokenBalance() async {

    var data = {
      "address": "$selectedAccountAddress",
      "tokenAddress": "$sendTokenAddress",
      "network_id":"$network_id"
    };

    // print(data);

    await tokenProvider.getTokenBalance(data,'/getTokenBalance');

    if(tokenProvider.tokenBalance != null){
      if(mounted) {
        setState(() {

          sendTokenBalance = tokenProvider.tokenBalance['data']['balance'];
          showLoader = false;

        });
      }
    }
  }

  // ========== Select Network ===========
  String network_id = "2",
      network_chain = "56",
      network_symbol = "BNB",
      network_weth = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c",
      network_name = "Binance Smart Chain",
      network_image = "http://${Utils.url}/api/img/binance_logo.png",
      network_url = "https://bsc-dataseed.binance.org/",
      netWorkType = "BEP20";

  netWorkBottomSheet(BuildContext context) {
    showDialog(
      context: context,

      builder: (BuildContext context,) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return Padding(
              padding:  EdgeInsets.only(right:Responsive.isDesktop(context)?0:  50,top: Responsive.isDesktop(context)?0:  100),
              child: AlertDialog(
                actionsPadding:const EdgeInsets.symmetric(vertical: 10,horizontal: 30),

                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.0),),),
                contentPadding: EdgeInsets.zero,

                backgroundColor:AppColors.containerbackgroundgrey,
                alignment: Alignment.center,
                insetPadding:EdgeInsets.zero,


                content: SingleChildScrollView(
                  child: Container(
                    decoration:  BoxDecoration(
                        borderRadius: BorderRadius.circular(10),

                        gradient:  const LinearGradient(
                            colors:[Color(0xFF222831),AppColors.blackColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)),

                    width:MediaQuery.of(context).size.width/2.3,

                    child: Padding(
                      padding: const EdgeInsets.only(top:20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              const SizedBox(width: 18),
                              InkWell(
                                  onTap: (){
                                    Navigator.pop(context);
                                  },
                                  child: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: AppColors.whiteColor,
                                      size: 20,
                                  )
                              ),

                              const SizedBox(width: 20),
                              const Text(
                                "Select Network",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontFamily: 'Sf-SemiBold',
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ConstrainedBox(
                            constraints: BoxConstraints(

                              maxHeight: MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.8,
                            ),
                            child: isLoading == true
                                ?
                            Helper.dialogCall.showLoader()
                                :
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: tokenProvider.networkList.length,
                                itemBuilder: (BuildContext context, int index) {

                                  var list = tokenProvider.networkList[index];
                                  return  list.swapEnable == 0
                                      ?
                                  SizedBox()
                                      :
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20,right:20,bottom: 10),
                                    child: InkWell(
                                      onTap: () async {
                                        setState((){
                                          network_id = "${tokenProvider.networkList[index].id}";
                                          network_symbol = "${tokenProvider.networkList[index].symbol}";
                                          network_weth = "${tokenProvider.networkList[index].weth}";
                                          network_chain = "${tokenProvider.networkList[index].chain}";
                                          network_image = "${tokenProvider.networkList[index].logo}";
                                          network_name = "${tokenProvider.networkList[index].name}";
                                          network_url = "${tokenProvider.networkList[index].url}";
                                          netWorkType = "${tokenProvider.networkList[index].tokenType}";

                                          fromController.text = "";
                                          toController = TextEditingController();

                                        });

                                        var data = {
                                          "network_id":network_id,
                                          "search_term": "$network_name"
                                        };
                                        await tokenProvider.getSearchNetWorkToken(data,'/getTokensByNetwork');

                                        // print(tokenProvider.searchNetWorkTokenTokenList);

                                        var geToken = tokenProvider.searchNetWorkTokenTokenList.where((element) {
                                          if(element.name == "Matic Mainnet" && "$network_id" == "3") {
                                            return "${element.name}" == "Matic Mainnet";
                                          }else{
                                            return "${element.name}" == network_name;
                                          }

                                        }).toList();

                                        // print(geToken);

                                        setState((){

                                          sendTokenAddress = "";
                                          sendTokenNetworkId = "$network_id";
                                          sendTokenName = "${geToken.first.name}";
                                          sendTokenSymbol = "${geToken.first.symbol}";
                                          sendTokenMarketId = "${geToken.first.marketId}";
                                          sendTokenImage = "${geToken.first.logo}";
                                          sendTokenUsd = "0";
                                          sendTokenBalance = "0";
                                          sendTokenId = "${geToken.first.id}";

                                          receiveTokenAddress = "";
                                          receiveTokenNetworkId = "";
                                          receiveTokenName = "";
                                          receiveTokenSymbol = "";
                                          receiveTokenMarketId = "";
                                          receiveTokenImage = "";
                                          receiveTokenBalance = "0";
                                          receiveTokenUsd = "0";

                                        });
                                        getCustomTokenBalance();
                                        Navigator.pop(context);

                                      },
                                      child:  Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(400),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              imageUrl: list.logo,
                                              width: 25,height: 25,
                                              placeholder: (context, url) => Helper.dialogCall.showLoader(),
                                              errorWidget: (context, url, error) =>
                                                  SvgPicture.asset(
                                                      'assets/icons/drawericon/colorlogoonly.svg',
                                                      width: 22
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),

                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                list.name,
                                                style: const TextStyle(
                                                  color: AppColors.white,
                                                  fontFamily: 'Sf-SemiBold',
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                list.symbol,
                                                style: const TextStyle(
                                                  color: AppColors.greyColor,
                                                  fontFamily: 'Sf-Regular',
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Expanded(child: SizedBox()),

                                          Icon(
                                            network_id == "${list.id}"
                                                ?
                                            Icons.radio_button_checked: Icons.radio_button_off,
                                            color:network_id != "${list.id}" ? AppColors.white.withOpacity(0.1) : AppColors.darkblue,
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
              ),
            );
          },

        );
      },
    ).whenComplete(() {
      getSearchToken("");
      getProviders();
      setState(() {
        FocusScope.of(context).unfocus();
      });

    });
  }

  providerBottomSheet(BuildContext context) {
    showDialog(
      context: context,

      builder: (BuildContext context,) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return Padding(
              padding:  EdgeInsets.only(right:Responsive.isDesktop(context)?0:  50,top: Responsive.isDesktop(context)?0:  100),
              child: AlertDialog(
                actionsPadding:const EdgeInsets.symmetric(vertical: 10,horizontal: 30),

                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.0),),),
                contentPadding: EdgeInsets.zero,

                backgroundColor:AppColors.containerbackgroundgrey,
                alignment: Alignment.center,
                insetPadding:EdgeInsets.zero,


                content: SingleChildScrollView(
                  child: Container(
                    decoration:  BoxDecoration(
                        borderRadius: BorderRadius.circular(10),

                        gradient:  const LinearGradient(
                            colors:[Color(0xFF222831),AppColors.blackColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)),

                    width:MediaQuery.of(context).size.width/2.3,

                    child: Padding(
                      padding: const EdgeInsets.only(top:20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              InkWell(
                                  onTap: (){
                                    Navigator.pop(context);
                                  },
                                  child: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: AppColors.whiteColor,
                                      size: 18,
                                  )
                              ),
                              const SizedBox(width: 20),

                              const Text(
                                "Select Provider",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontFamily: 'Sf-SemiBold',
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ConstrainedBox(
                            constraints: BoxConstraints(

                              maxHeight: MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.8,
                            ),
                            child: isLoading == true
                                ?
                            Helper.dialogCall.showLoader()
                                :
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: tokenProvider.providersList.length,
                                itemBuilder: (BuildContext context, int index) {

                                  var list = tokenProvider.providersList[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 20,right:20,bottom: 10),
                                    child: InkWell(
                                      onTap: () async {

                                        setState((){
                                          providerName = tokenProvider.providersList[index].name;
                                          providerImage = tokenProvider.providersList[index].logo;
                                          providerRouter = tokenProvider.providersList[index].router;
                                          providerActive = tokenProvider.providersList[index].is_active;

                                          // print("providerActive ===> $providerActive");

                                          receiveTokenAddress = "";
                                          receiveTokenNetworkId = "";
                                          receiveTokenId = "";
                                          receiveTokenName = "";
                                          receiveTokenSymbol = "";
                                          receiveTokenMarketId = "";
                                          receiveTokenImage = "";
                                          receiveTokenBalance = "0";
                                          receiveTokenUsd = "0";

                                          fromController = TextEditingController();
                                          toController = TextEditingController();

                                        });

                                        Navigator.pop(context);
                                      },
                                      child:  Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(400),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              imageUrl: list.logo,
                                              width: 25,height: 25,
                                              placeholder: (context, url) => Helper.dialogCall.showLoader(),
                                              errorWidget: (context, url, error) =>
                                                  SvgPicture.asset(
                                                      'assets/icons/drawericon/colorlogoonly.svg',
                                                      width: 22
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),

                                          Text(
                                            list.name,
                                            style: const TextStyle(
                                              color: AppColors.white,
                                              fontFamily: 'Sf-SemiBold',
                                              fontSize: 13,
                                            ),
                                          ),
                                          const Expanded(child: SizedBox()),

                                          Icon(
                                            providerName == tokenProvider.providersList[index].name
                                                ?
                                            Icons.radio_button_checked: Icons.radio_button_off,
                                            color:providerName != tokenProvider.providersList[index].name ? AppColors.white.withOpacity(0.1) : AppColors.darkblue,
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
              ),
            );
          },

        );
      },
    ).whenComplete(() {
      setState(() {
        FocusScope.of(context).unfocus();
      });
    });
  }

  Web3Client? _web3client;

  getWeb3NetWorkFees()async{


    setState((){
      isLoading = true;
    });


    _web3client = Web3Client(
      "${network_url}",
      http.Client(),
    );

    // print(rpcUrl);

    setState((){
      isLoading = true;
    });



    // print(EtherAmount.inWei(BigInt.from(1)));

    var estimateGas = 1000000;
    var getGasPrice = await _web3client!.getGasPrice();
    var value = BigInt.from(double.parse("$estimateGas") *  double.parse("${getGasPrice.getInWei}")) / BigInt.from(10).pow(18);
    // print(value);

    double tokenBalance = double.parse("${double.parse(sendTokenBalance).toStringAsFixed(5)}") - (value * 2);

    // print(tokenBalance);


    if(tokenBalance > 0){
      setState((){
        fromController = TextEditingController(
            text: "${tokenBalance}");
        isLoading = false;
      });

      getEstimate();

    }else{
     Helper.dialogCall.showToast(context, "Insufficient $network_symbol balance please deposit some $network_symbol");
    }



    setState((){
      isLoading = false;
    });

  }

  // ========== Estimate Token Allowance =========
  bool isAllowance = true;
  var pathEstimate;
  getEstimate() async {

    setState(() {
      isLoading = true;
    });

    var newSendAdress = "";
    var newReciveAddress = "";
    if(sendTokenAddress == ""){
      newSendAdress = network_weth;
    }else{
      newSendAdress = sendTokenAddress ;
    }
    if(receiveTokenAddress == ""){
      newReciveAddress = network_weth;
    }else{
      newReciveAddress = receiveTokenAddress;
    }

    var data = {
      "network_id":network_id,
      "router": providerRouter,
      "network_url" : network_url,
      "address" : selectedAccountAddress,
      "tokenIn" : {
        "address": "$newSendAdress",
        "symbol": "$sendTokenSymbol",
        "decimals": "$sendTokenDes",
        "isNative": sendTokenAddress == "" ? true : false
      },

      "tokenOut" : {
        "address": "$newReciveAddress",
        "symbol": "$receiveTokenSymbol",
        "decimals": "$receiveDes",
        "isNative": receiveTokenAddress == "" ? true : false
      },
      "amount" : fromController.text == "" ? 0.0 : double.parse(fromController.text).toStringAsFixed(15)
    };

    // print("this get estimate");
    // print(json.encode(data));

    await tokenProvider.getEstimate(data,'/estimateSwap');

    if(tokenProvider.isEstimate == true){

      var body = tokenProvider.estimateData;

      //print("this cxcx estimate value$body");
      setState((){
        pathEstimate = body['path'];
        toController = TextEditingController(text: "${body['outputAmount'].toStringAsFixed(6)}");
        isLoading = false;
      });
      //receiveAmountUsd = double.parse(toController.text) * double.parse(receiveTokenUsd);
      if(body['isAllowance'] == false){
        //print("isAllowance => ${body['isAllowance']}");
        setState(() {
          isAllowance = false;
        });
      }
      else{
        setState(() {
          isAllowance = true;
        });
      }


    }
    else{
      setState(() {
        isLoading = false;
      });
    }

  }
  // ===========================================================================


  // ========== Estimate Token Allowance Fees =========
  String ApproveFees = "",ApprovePrice = "",Approvegas = "";
  bool isApproveLoading = false;
  approveFees() async {

    setState((){
      isApproveLoading = true;
    });

    var data = {
      "privateKey":Helper.dialogCall.decryptAddressColumn(selectedAccountPrivateAddress),
      "Router": providerRouter,
      "network_url":network_url,
      "tokenAddress":sendTokenAddress,
    };

    await tokenProvider.getEstimate(data,'/approveFees');
    if(tokenProvider.isEstimate == true){

      var body = tokenProvider.estimateData;
      setState((){
        Approvegas = "${body['gasLimit']}";
        ApprovePrice = "${body['gasPrice']}";
        ApproveFees = "${body['approveFees']}";
      });

      verifyApproveSheet(context);

      setState((){
        isApproveLoading = false;
      });

    }
    else{
      setState((){
        isApproveLoading = false;
      });

      Helper.dialogCall.showToast(context, "Token Approve Fees Estimate Error");

    }

  }
  // ===========================================================================


  // ========== Token Allowance Fees Send =========

  verifyApproveSheet(BuildContext context) {

    bool isApprove = false;

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actionsPadding: EdgeInsets.zero,
            backgroundColor: AppColors.darklightgrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            content:  StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.27,
                    //height: MediaQuery.of(context).size.height-100,
                    padding: const EdgeInsets.only(left: 20,right: 20,top: 15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        Row(
                          children: [

                            InkWell(
                                onTap: (){
                                  Navigator.pop(context);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.arrow_back_ios_rounded,
                                    size: 20,
                                    color: AppColors.whiteColor,
                                  ),
                                )
                            ),

                            const Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: 25),
                                child: Center(
                                  child: Text(
                                      "Approve Fees",
                                    style: TextStyle(
                                      color: AppColors.whiteColor,
                                      fontSize: 16.0,
                                      fontFamily: "Sf-SemiBold",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [

                            ClipRRect(
                              borderRadius: BorderRadius.circular(300),
                              child: CachedNetworkImage(
                                height: 30,
                                width: 30,
                                fit: BoxFit.fill,
                                imageUrl: sendTokenImage,
                                placeholder: (context, url) => Helper.dialogCall.showLoader(),
                                errorWidget: (context, url, error) =>
                                    SvgPicture.asset(
                                        'assets/icons/drawericon/colorlogoonly.svg',
                                        width: 22
                                    ),
                              ),
                            ),

                            const SizedBox(width: 15,),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                const Text(
                                  "You Approve",
                                  style: TextStyle(
                                    color: AppColors.whiteColor,
                                    fontSize: 14.0,
                                    fontFamily: "Sf-SemiBold",
                                  ),
                                ),

                                Text(
                                  "$sendTokenSymbol Token",
                                  style: const TextStyle(
                                    color: AppColors.whiteColor,
                                    fontSize: 12.0,
                                    fontFamily: "Sf-Regular",
                                  ),
                                )

                              ],
                            )

                          ],
                        ),

                        SizedBox(height: 25),

                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            color: AppColors.darkBlack0A0.withOpacity(0.2),
                          ),
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [


                              Row(
                                children: [

                                  const Expanded(
                                      child: Text(
                                        "Gas Limit",
                                        style: TextStyle(
                                          color: AppColors.whiteColor,
                                          fontSize: 14.0,
                                          fontFamily: "Sf-SemiBold",
                                        ),
                                      )
                                  ),

                                  Text(
                                      "$Approvegas",
                                    style: const TextStyle(
                                      color: AppColors.whiteColor,
                                      fontSize: 12.0,
                                      fontFamily: "Sf-Regular",
                                    ),
                                  )

                                ],
                              ),

                              SizedBox(height: 10,),

                              Row(
                                children: [

                                  const Expanded(
                                    child: Text(
                                      "Gas_Price : ",
                                      style: TextStyle(
                                        color: AppColors.whiteColor,
                                        fontSize: 14.0,
                                        fontFamily: "Sf-SemiBold",
                                      ),
                                    ),
                                  ),

                                    Text(
                                      "$ApprovePrice wei",
                                      style: const TextStyle(
                                        color: AppColors.whiteColor,
                                        fontSize: 12.0,
                                        fontFamily: "Sf-Regular",
                                      ),
                                    )

                                ],
                              ),

                              SizedBox(height: 10,),

                              Row(
                                children: [

                                  const Expanded(
                                    child: Text(
                                      "Approve Fees : ",
                                      style: TextStyle(
                                        color: AppColors.whiteColor,
                                        fontSize: 14.0,
                                        fontFamily: "Sf-SemiBold",
                                      ),
                                    ),
                                  ),
                                  Text(
                                      "$ApproveFees $network_symbol",
                                    style: const TextStyle(
                                      color: AppColors.whiteColor,
                                      fontSize: 12.0,
                                      fontFamily: "Sf-Regular",
                                    ),
                                  )

                                ],
                              ),

                              const SizedBox(height: 10,),

                            ],
                          ),
                        ),


                        SizedBox(height: 50),

                        InkWell(
                          onTap: (){

                            Navigator.pop(context);
                            setState((){
                              isApprove = true;
                            });

                          },
                          child: Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width-180,
                              height: 45,
                              decoration: BoxDecoration(
                                gradient: AppColors.buttonGradient2,
                                  borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: const Center(
                                child: Text(
                                    'Confirm Approve',
                                  style: TextStyle(
                                    color: AppColors.whiteColor,
                                    fontSize: 16.0,
                                    fontFamily: "Roboto-Regular",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),


                      ],
                    ),
                  );
                }
            ),
          );
        }).whenComplete(() {

      if(isApprove == true){

        sendApproveFees();

      }

    });
  }
  bool isSendApprove = false;
  sendApproveFees() async {

    setState(() {
      isSendApprove = true;
    });

    var data = {

      "privateKey":"${Helper.dialogCall.decryptAddressColumn(selectedAccountPrivateAddress)}",
      "Router": providerRouter,
      "network_url":network_url,
      "tokenAddress":sendTokenAddress,
      "form_id":sendTokenId
    };

    await tokenProvider.getEstimate(data,'/approve');
    if(tokenProvider.isEstimate == true){

      var body = tokenProvider.estimateData;

      setState(() {
        isSendApprove = false;
      });

      getEstimate();
    }
    else{

      setState(() {
        isSendApprove = false;
      });

      Helper.dialogCall.showToast(context, "Insufficient $network_symbol For Cover Gas Fees",);

    }

  }

  // ===========================================================================

  // ========== Swap Fees Calculate =========

  String tradeType = "true";
  String networkFee = "";
  TextEditingController slippageController = TextEditingController();
  String gasPrice = "";
  String gas = "";
  var focusNode = FocusNode();

  String selected = "0.1",isSelected = "0.1";

  getSwapFees() async {

    setState(() {
      isLoading = true;
    });

    var newSendAdress = "";
    var newReciveAddress = "";
    if(sendTokenAddress == ""){
      newSendAdress = network_weth;
    }else{
      newSendAdress = sendTokenAddress ;
    }
    if(receiveTokenAddress == ""){
      newReciveAddress = network_weth;
    }else{
      newReciveAddress = receiveTokenAddress;
    }

    var data = {
      "privateKey" : Helper.dialogCall.decryptAddressColumn(selectedAccountPrivateAddress),
      "router": providerRouter,
      "network_url" : network_url,
      "address": selectedAccountAddress,
      "tokenIn" : {
        "address": "$newSendAdress",
        "symbol": "$sendTokenSymbol",
        "decimals": "$sendTokenDes",
        "isNative": sendTokenAddress == "" ? true : false
      },

      "tokenOut" : {
        "address": "$newReciveAddress",
        "symbol": "$receiveTokenSymbol",
        "decimals": "$receiveDes",
        "isNative": receiveTokenAddress == "" ? true : false
      },
      "amount": double.parse(fromController.text).toStringAsFixed(15),
      "path":pathEstimate,
      "slippage" : selected
    };

    // print(jsonEncode(data));
    await tokenProvider.getEstimate(data,'/swapFees');
    if(tokenProvider.isEstimate == true){

      var body = tokenProvider.estimateData;

      //print(body);
      setState(() {
        isLoading = false;

        gas ="${body['gasLimit']}";
        gasPrice = "${body['gasPrice']}";

/*
        double gasFinal = double.parse("${body['gasPrice']}.0") / 1000000000;
        gasPrice = "${gasFinal.toInt()}";
*/

        networkFee ="${body['fees']}";
        tradeType ="${body['tradeType']}";
      });

      sendVerifyApproveSheet(context);

    }
    else{

     Helper.dialogCall.showToast(context, "Increase slippage or Insufficient funds in liquidity pool");

      setState(() {
        isLoading = false;
      });

    }
  }
  // ===========================================================================

  // ========== Swap Token =========
  bool checkBox = false;
  sendVerifyApproveSheet(BuildContext context) {

    bool isloading = false;

    showDialog(
      context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.darklightgrey,
            actionsPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            content:  StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {

                  SwapExicute() async {

                    setState(() {
                      isloading = true;
                    });

                    var newSendAdress = "";
                    var newReciveAddress = "";

                    if(sendTokenAddress == ""){
                      newSendAdress = network_weth;
                    }
                    else{
                      newSendAdress = sendTokenAddress ;
                    }

                    if(receiveTokenAddress == ""){
                      newReciveAddress = network_weth;
                    }
                    else{
                      newReciveAddress = receiveTokenAddress;
                    }

                    var data = {
                      "privateKey":Helper.dialogCall.decryptAddressColumn(selectedAccountPrivateAddress),
                      "router": providerRouter,
                      "network_url" : network_url,
                      "address" : selectedAccountAddress,
                      "tokenIn" : {
                        "address": "$newSendAdress",
                        "symbol": "$sendTokenSymbol",
                        "decimals": "$sendTokenDes",
                        "isNative": sendTokenAddress == "" ? true : false
                      },

                      "tokenOut" : {
                        "address": "$newReciveAddress",
                        "symbol": "$receiveTokenSymbol",
                        "decimals": "$receiveDes",
                        "isNative": receiveTokenAddress == "" ? true : false
                      },
                      "amount" : fromController.text,
                      "slippage" : selected,
                      "tradeType": tradeType,
                      "from_id": sendTokenId,
                      "to_id": receiveTokenId,
                      "gasPrice": gasPrice,
                      "path":pathEstimate,
                      "gasLimit": gas
                    };

                    // print("swap send json data ===>  ${jsonEncode(data)}");
                    await tokenProvider.getEstimate(data,'/swapNew');
                    if(tokenProvider.isEstimate == true){

                      var body = tokenProvider.estimateData;
                      // print("print body ===> $body");
                      // print(body['tx']);

                      if(body['status'] == true){

                        Helper.dialogCall.showToast(context, "Transaction Successful");

                        ExchangeModel exchangeModel = ExchangeModel(
                            fromTokenName: sendTokenName,
                            fromTokenIcon: sendTokenImage,
                            fromSymbol: sendTokenSymbol,
                            toTokenName: receiveTokenName,
                            toTokenIcon: receiveTokenImage,
                            toSymbol: receiveTokenSymbol,
                            fromAmount: fromController.text,
                            toAmount: toController.text,
                            hexLink: body['tx']["hash"],
                            dataTime: DateTime.now().toString()
                        );
                        await DBExchange.exchangeDB.createExchangeList(exchangeModel);

                        setState(() {
                          isloading = false;

                          sendTokenAddress = "";
                          sendTokenNetworkId = "2";
                          sendTokenName = "Binance Smart Chain";
                          sendTokenSymbol = "BNB";
                          sendTokenMarketId = "1839";
                          sendTokenImage = "http://${Utils.url}/api/img/binance_logo.png";
                          sendTokenBalance = "0";
                          sendTokenUsd = "0";


                          receiveTokenAddress = "";
                          receiveTokenNetworkId = "";
                          receiveTokenName = "";
                          receiveTokenSymbol = "";
                          receiveTokenMarketId = "";
                          receiveTokenImage = "";
                          receiveTokenBalance = "0";
                          receiveTokenUsd = "0";


                          network_id = "2";
                          network_chain = "56";
                          network_symbol = "BNB";
                          network_weth = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";
                          network_name = "Binance Smart Chain";
                          network_image = "http://${Utils.url}/api/img/binance_logo.png";
                          network_url = "https://bsc-dataseed.binance.org/";



                          fromController.text = "";
                          toController.text = "";

                          selected = "0.1";

                        });

                        getCustomTokenBalance();

                        Navigator.pop(context,"Refresh");

                      }

                    }
                    else{

                      Helper.dialogCall.showToast(context, "Error In Swap Please Try Again Later");

                      setState(() {
                        isloading = false;
                      });

                    }

                  }

                  return Container(
                    width: MediaQuery.of(context).size.width/3,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          // confirm title
                          Row(
                            children: [

                              InkWell(
                                  onTap: (){
                                    Navigator.pop(context);
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.arrow_back_ios_rounded,
                                      size: 20,
                                      color: AppColors.whiteColor
                                    ),
                                  )
                              ),

                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 25),
                                  child: Center(
                                    child: Text(
                                        "Confirm Swap",
                                      style: TextStyle(
                                        color: AppColors.whiteColor,
                                        fontSize: 16.0,
                                        fontFamily: "Roboto-Regular",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // your address title
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                color: AppColors.darkBlack0A0.withOpacity(0.2),
                              ),
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  const Text(
                                      "Your Address",
                                      style:TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Sf-SemiBold',
                                      )
                                  ),

                                  SizedBox(height: 10),

                                  Text(
                                      selectedAccountAddress,
                                      style:const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Sf-Regular',
                                      )
                                  ),

                                ],
                              )
                          ),

                          SizedBox(height: 20),

                          // form coin details
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                              color: AppColors.darkBlack0A0.withOpacity(0.2),
                            ),
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              children: [

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(300),
                                  child: CachedNetworkImage(
                                    height: 30,
                                    width: 30,
                                    fit: BoxFit.fill,
                                    imageUrl: "${sendTokenImage}",
                                    placeholder: (context, url) => Helper.dialogCall.showLoader(),
                                    errorWidget: (context, url, error) =>
                                        SvgPicture.asset(
                                            'assets/icons/drawericon/colorlogoonly.svg',
                                            width: 22
                                        ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child:  Text(
                                      '$sendTokenSymbol',
                                      style:const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Sf-Regular',
                                      )
                                  ),
                                ),

                                Text(
                                    '${fromController.text} $sendTokenSymbol',
                                    textAlign: TextAlign.end,
                                    style:const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Sf-Regular',
                                    )
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 10),

                          // to coin details
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                              color: AppColors.darkBlack0A0.withOpacity(0.2),
                            ),
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              children: [

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(300),
                                  child: CachedNetworkImage(
                                    height: 30,
                                    width: 30,
                                    fit: BoxFit.fill,
                                    imageUrl: receiveTokenImage,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(color: AppColors.blueColor),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        SvgPicture.asset(
                                            'assets/icons/drawericon/colorlogoonly.svg',
                                            width: 22
                                        ),
                                  ),
                                ),
                                SizedBox(width: 10),

                                Expanded(
                                  child:  Text(
                                      receiveTokenSymbol,
                                      style:const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Sf-Regular',
                                      )
                                  ),
                                ),

                                Text(
                                    '${double.parse(toController.text.isEmpty ? "0.0": toController.text).toStringAsFixed(10)} $receiveTokenSymbol',
                                    style:const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Sf-Regular',
                                    )
                                ),
                              ],
                            ),
                          ),


                          SizedBox(height: 20),

                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: AppColors.darkBlack0A0.withOpacity(0.04)
                            ),
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                const Text(
                                   "Fees",
                                    style:TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Sf-SemiBold',
                                    )
                                ),

                                SizedBox(height: 10),

                                Row(
                                  children: [

                                    const Expanded(
                                      child: Text(
                                          'Gas Limit :',
                                          style:TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'Sf-SemiBold',
                                          )
                                      ),
                                    ),

                                    Text(
                                        '$gas',
                                        style:const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'Sf-Regular',
                                        )
                                    ),
                                  ],
                                ),

                                SizedBox(height: 5),

                                Row(
                                  children: [

                                    const Expanded(
                                      child: Text(
                                          'Gas Price:',
                                          style:TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'Sf-SemiBold',
                                          )
                                      ),
                                    ),

                                    Text(
                                        '$gasPrice wei',
                                        style:const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'Sf-Regular',
                                        )
                                    ),
                                  ],
                                ),

                                SizedBox(height: 5),

                                Row(
                                  children: [

                                    const Expanded(
                                      child: Text(
                                          'Approve Fees :',
                                          style:TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'Sf-SemiBold',
                                          )
                                      ),
                                    ),

                                    Text(
                                        '$networkFee $network_symbol',
                                        style:const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'Sf-Regular',
                                        )
                                    ),
                                  ],
                                ),


                              ],
                            ),
                          ),

                          SizedBox(height: 15),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              Theme(
                                data: Theme.of(context).copyWith(
                                  unselectedWidgetColor: AppColors.white.withOpacity(0.5),
                                ),
                                child: Checkbox(
                                  checkColor:AppColors.white,
                                  activeColor: AppColors.blueColor,
                                  value: checkBox,
                                  onChanged: (value) {
                                    setState(() {
                                      checkBox = value!;
                                    });
                                  },
                                ),
                              ),


                              Text(
                                  "I understand all of the risks.I agree to the Terms and Conditions.",
                                  style:TextStyle(
                                    color:AppColors.white.withOpacity(0.5),
                                    fontSize: 12,
                                    fontFamily: 'Sf-Regular',
                                  )
                              )

                            ],
                          ),

                          SizedBox(height: 10),

                          isloading == true
                              ?
                          Helper.dialogCall.showLoader()
                              :
                          checkBox == false
                              ?
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width-180,
                              height: 45,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  gradient: AppColors.buttonGradient2,
                                  color: AppColors.blueColor.withOpacity(0.4)
                              ),
                              child: Center(
                                child: Text(
                                    'Swap Now',
                                    style:TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 16,
                                      fontFamily: 'Sf-SemiBold',
                                    )
                                ),
                              ),
                            ),
                          )
                              :
                          InkWell(
                            onTap: (){
                              SwapExicute();
                            },
                            child: Center(
                              child: Container(
                                width: MediaQuery.of(context).size.width-180,
                                height: 45,
                                decoration: BoxDecoration(
                                    gradient: AppColors.buttonGradient2,
                                    borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Center(
                                  child: Text(
                                      'Swap Now',
                                      style:TextStyle(
                                        color: Colors.white,fontSize: 16,
                                        fontFamily: 'Sf-SemiBold',
                                      )
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                        ],
                      ),
                    ),
                  );
                }
            ),
          );
        }).whenComplete(() {

      setState(() {
        checkBox = false;
      });
    });
  }

  // ============================================

  var width,height;
  @override
  Widget build(BuildContext context) {

    width=MediaQuery.of(context).size.width;
    height=MediaQuery.of(context).size.height;

    walletProvider = Provider.of<WalletProvider>(context, listen: true);
    exchangeProvider = Provider.of<ExchangeProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);

    // print(tokenDetails.length);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20,right: 20,left: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // app bar
            Row(
              children: [

                InkWell(
                  onTap: (){
                    // walletProvider.changeListnerWallet("PriceChart");
                    exchangeProvider.changeListnerExchange("exchangehistroy");

                  },
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: Boxdec.BackButtonGradient,
                      child: Center(
                        child: SvgPicture.asset(
                            'assets/icons/drawericon/refreshwhite.svg',
                            width: 22
                        ),)),
                ),

                const Expanded(child: SizedBox(width: 1,)),

                const Padding(
                  padding: EdgeInsets.only(left: 140),
                  child: Text(
                      "Exchange",
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
                              SizedBox(width: 0,),
                              Padding(
                                padding:  const EdgeInsets.only(right: 20),
                                child: Text(
                                    "$crySymbol ${walletProvider.showTotalValue.toStringAsFixed(2)}",
                                    style:const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16 ,
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


            Expanded(
              child: showLoader
                  ?
              Helper.dialogCall.showLoader()
                  :
              Column(
                children: [

                  // top exchange show balance
                  Container(
                    padding: EdgeInsets.only(top: 10,bottom: 10),
                    margin: const EdgeInsets.fromLTRB(20,40,20,10),
                    alignment: Alignment.center,
                    width: Responsive.isDesktop(context) ? width /4 : width * 0.5 ,
                    decoration: const BoxDecoration(color: AppColors.ContainerblackColor,borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(child: SizedBox(width: 30,)),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Available",
                              style:TextStyle(
                                  color: AppColors.greyColor,
                                  fontFamily: "Sf-SemiBold",
                                  fontSize: 11
                              ),
                            ),
                            const SizedBox(height: 4,),
                            Text(
                              "${ApiHandler.calculateLength3("${double.parse(sendTokenBalance)}")} ${sendTokenSymbol}",
                              style:const TextStyle(
                                  color: AppColors.White,
                                  fontFamily: "Sf-Regular",
                                  fontSize: 12
                              ),
                            ),
                            // const SizedBox(height: 4,),
                            // Text("$crySymbol ${(double.parse(sendTokenBalance) * tokenDetails.first.price).toStringAsFixed(2)}", style:TextStyle(color: AppColors.greyColor,fontFamily: "Sf-SemiBold",fontSize: 11),),
                          ],
                        ),
                        const Expanded(child: SizedBox(width: 30,)),
/*
                    Container(
                      alignment: Alignment.center,
                      height: height*0.04,
                      width:width*0.0002,
                      color: AppColors.greyColor,

                    ),

                    Expanded(child: SizedBox(width: 30,)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Network Fee", style:TextStyle(color: AppColors.greyColor,fontFamily: "Sf-SemiBold",fontSize: 11),),
                        SizedBox(height: 4,),
                        Text("0.0343094 CMCMX", style:TextStyle(color: AppColors.White,fontFamily: "Sf-Regular",fontSize: 12),),
                        SizedBox(height: 4,),
                        Text("\$ 0.5", style:TextStyle(color: AppColors.greyColor,fontFamily: "Sf-SemiBold",fontSize: 11),),
                      ],
                    ),
                    Expanded(child: SizedBox(width: 30,)),*/
                      ],
                    ),
                  ),


                  // provider and network list
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.fromLTRB(20,0,20,10),
                    alignment: Alignment.center,
                    width: Responsive.isDesktop(context) ? width /3 : width * 0.6 ,
                    decoration: const BoxDecoration(
                        color: AppColors.ContainerblackColor,
                        borderRadius: BorderRadius.all(Radius.circular(20)
                        )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                tokenProvider.searchNetWorkTokenTokenList.clear();
                              });
                              getSearchToken("");

                              setState(() {
                                tokenProvider.searchNetWorkTokenTokenList = tokenProvider.searchNetWorkTokenTokenList.where((element) => "${element.networkId}" == network_id).toList();
                              });

                              netWorkBottomSheet(context);

                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: CachedNetworkImage(
                                    height: 34,
                                    width: 34,
                                    fit: BoxFit.fill,
                                    imageUrl: '${network_image}',
                                    placeholder: (context, url) =>Helper.dialogCall.showLoader(),
                                    errorWidget: (context, url, error) =>
                                        SvgPicture.asset(
                                            'assets/icons/drawericon/colorlogoonly.svg',
                                            width: 22
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    network_name,
                                    style:const TextStyle(
                                        color: AppColors.white,
                                        fontFamily: "Sf-SemiBold",
                                        fontSize: 11
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColors.whiteColor,
                                )

                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        tokenProvider.providersList.isEmpty ? const SizedBox() :
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                height: height*0.04,
                                width:width*0.0002,
                                color: AppColors.greyColor,
                              ),

                              const SizedBox(width: 20),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    getSearchToken("");

                                    setState(() {
                                      tokenProvider.searchNetWorkTokenTokenList = tokenProvider.searchNetWorkTokenTokenList.where((element) => "${element.networkId}" == network_id).toList();
                                    });
                                    providerBottomSheet(context);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(100),
                                        child: CachedNetworkImage(
                                          height: 34,
                                          width: 34,
                                          fit: BoxFit.fill,
                                          imageUrl: '${providerImage}',
                                          placeholder: (context, url) =>Helper.dialogCall.showLoader(),
                                          errorWidget: (context, url, error) =>
                                              SvgPicture.asset(
                                                  'assets/icons/drawericon/colorlogoonly.svg',
                                                  width: 22
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          providerName,
                                          style:const TextStyle(
                                              color: AppColors.white,
                                              fontFamily: "Sf-SemiBold",
                                              fontSize: 11
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: AppColors.whiteColor,
                                      )

                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )

                      ],
                    ),
                  ),

                  // form and to token ui
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // form token section


                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: height * 0.1,
                              alignment: Alignment.center,
                              width:Responsive.isMobile(context)?280:Responsive.isTablet(context)?270:390,
                              // width:Responsive.isTablet(context)?width/2.7:Responsive.isMobile(context)?width/2.7:width/4,
                              decoration: Boxdec.ContainerBalancegradientLeft.copyWith(border: GradientBoxBorder(
                                gradient: LinearGradient(
                                    begin : Alignment.topLeft,
                                    end : Alignment.bottomRight,
                                    colors: [
                                      AppColors.greydark.withOpacity(0.3),
                                      AppColors.darkblueContainer.withOpacity(0.3),
                                      AppColors.darkblueContainer.withOpacity(0.3),
                                      //  AppColors.darkblueContainer,
                                      //AppColors.darkblueContainer,
                                    ]),
                                width: 1,
                              ),
                              ),
                               /*const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/left.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),*/
                              child:Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [

                                  // token icon and form dialog box
                                  Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    decoration:Boxdec.Containercoinshadow,
                                    height:55,
                                    width: 55,
                                    child: Padding(
                                      padding: const EdgeInsets.all(13),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle, // BoxShape.circle or BoxShape.retangle
                                            boxShadow: [
                                              BoxShadow(
                                              color: Colors.black,
                                                blurRadius: 25.0,
                                              ),
                                            ]
                                        ),
                                        width: 50,
                                        height: 50,
                                        child: CachedNetworkImage(
                                          height: 30,
                                          width: 30,
                                          fit: BoxFit.fill,
                                          imageUrl: sendTokenImage,
                                          placeholder: (context, url) => const Center(
                                            child: CircularProgressIndicator(color: AppColors.blueColor),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              SvgPicture.asset(
                                                  'assets/icons/drawericon/colorlogoonly.svg',
                                                  width: 22
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5,),

                                  // form and symbol button
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: (){
                                        sendBottomSheet(context);
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Padding(
                                            padding: const EdgeInsets.all(0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("From", style:TextStyle(color:AppColors.white.withOpacity(0.6),fontFamily: "Sf-SemiBold",fontSize: 12),),

                                                Padding(
                                                  padding: const EdgeInsets.all(5.0),
                                                  child: SvgPicture.asset('assets/icons/Market/downarrow.svg',),
                                                ),

                                              ],
                                            ),
                                          ),
                                          Text("$sendTokenSymbol", style:TextStyle(color:AppColors.white,fontFamily: "Sf-Regular",fontSize: 12),),




                                        ],
                                      ),
                                    ),
                                  ),

                                  // max button and textfiled
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        // max button
                                        Padding(
                                          padding: const EdgeInsets.only(top: 0,bottom: 5,right: 30),
                                          child: InkWell(
                                            onTap: (){
                                              if(
                                              network_id == "1" ||
                                                  network_id == "2" ||
                                                  network_id == "3" ||
                                                  network_id == "4" ||
                                                  network_id == "5" ||
                                                  network_id == "6" ||
                                                  network_id == "11" ||
                                                  network_id == "12" ||
                                                  network_id== "13" ||
                                                  network_id == ""   ){

                                                if(receiveTokenName == ""){
                                                  Helper.dialogCall.showToast(context, "Please select receive token");
                                                }else {
                                                  getWeb3NetWorkFees();
                                                }
                                              }else {
                                                if (
                                                sendTokenSymbol == "BNB" ||
                                                    sendTokenSymbol == "ETH" ||
                                                    sendTokenSymbol == "MATIC" ||
                                                    sendTokenSymbol == "FTM" ||
                                                    sendTokenSymbol == "AVAX" ||
                                                    sendTokenSymbol == "ETH" ||
                                                    sendTokenSymbol == "ONE" ||
                                                    sendTokenSymbol == "ETH" ||
                                                    sendTokenSymbol == "XDAI"
                                                ) {
                                                  double tokenBalance = (double.parse(
                                                      sendTokenBalance) * 96) / 100;

                                                  setState(() {
                                                    fromController =
                                                        TextEditingController(text: "${tokenBalance.toStringAsFixed(3)}");
                                                  });

                                                  getEstimate();
                                                } else {
                                                  setState(() {
                                                    fromController =
                                                        TextEditingController(text: "${double.parse(sendTokenBalance).toStringAsFixed(3)}");
                                                  });
                                                  getEstimate();
                                                }
                                              }
                                            },
                                            child: ShaderMask(
                                              blendMode: BlendMode.srcIn,
                                              shaderCallback: (Rect bounds) {
                                                return AppColors.buttonGradient.createShader(
                                                    Offset.zero & bounds.size);
                                              },
                                              child: const Text(
                                                "Max",
                                                style: TextStyle(
                                                  fontFamily: 'Sf-SemiBold',
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // form coin text filed
                                        SizedBox(
                                          height:20,
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 30),
                                            child: TextField(
                                              textAlign: TextAlign.end,
                                              cursorColor: AppColors.whiteColor,
                                              controller: fromController,
                                              readOnly: receiveTokenName == ""  || tokenProvider.providersList.isEmpty || providerActive == 0 ? true : false,
                                              onTap: (){
                                                if(receiveTokenName == "" || tokenProvider.providersList.isEmpty){
                                                  Helper.dialogCall.showToast(context, tokenProvider.providersList.isEmpty ? "Swap is disable" : "Please select receive token");
                                                }
                                              },
                                              onChanged: (value){

                                                if(value == ""){
                                                  setState(() {
                                                    toController.clear();
                                                    sendAmountUsd = 0.0;
                                                  });
                                                }
                                                else{

                                                  setState(() {
                                                    sendAmountUsd = double.parse(value)*double.parse(sendTokenUsd);
                                                  });

                                                  getEstimate();

                                                }

                                              },
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                                              ],
                                              style: const TextStyle(
                                                  color: AppColors.White,
                                                  fontFamily: "Sf-SemiBold",
                                                  fontSize: 20
                                              ),
                                              decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.symmetric(vertical:1,),
                                                  border: InputBorder.none,
                                                  hintText: "0.00",
                                                  hintStyle: const TextStyle(
                                                      color: AppColors.greyColor2,
                                                      fontFamily: "Sf-SemiBold",
                                                      fontSize: 20
                                                  ),
                                                  labelStyle:  TextStyle(
                                                      color: AppColors.white.withOpacity(0.1)
                                                  )
                                              ),
                                            ),
                                          ),
                                        ),

                                        // usd price show

                                        /*Padding(
                                          padding: const EdgeInsets.only(right: 30.0,top: 5),
                                          child: Text(
                                              "$crySymbol ${(double.parse(fromController.text.isEmpty ? "0.0" :fromController.text) * tokenDetails.first.price).toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  color:AppColors.white.withOpacity(0.4),
                                                  fontFamily: "Sf-Regular",
                                                  fontSize: 12
                                              )
                                          ),
                                        ),*/
                                      ],),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width:width*0.01,),
                            Container(
                              height: height * 0.1,
                              width:Responsive.isMobile(context)?280:Responsive.isTablet(context)?270:400,
                              decoration: Boxdec.ContainerBalancegradientRight.copyWith(
                                gradient: LinearGradient(
                                  begin: Alignment.topRight,

                                  end: Alignment.bottomLeft,
                                  // tileMode: TileMode.,
                                  colors: [
                                    AppColors.darklightgrey.withOpacity(0.8),
                                    AppColors.darklightgrey.withOpacity(0.8),
                                    AppColors.Containerbluestatic.withOpacity(0.4),
                                    AppColors.Containerbluestatic.withOpacity(0.4),

                                    //  AppColors.darklightgrey,
                                  ],
                                ),
                                border: GradientBoxBorder(
                                gradient: LinearGradient(
                                    begin : Alignment.topLeft,
                                    end : Alignment.bottomRight,
                                    colors: [
                                      AppColors.greydark.withOpacity(0.3),
                                      AppColors.darkblueContainer.withOpacity(0.3),
                                      AppColors.darkblueContainer.withOpacity(0.3),

                                      //  AppColors.darkblueContainer,
                                      //AppColors.darkblueContainer,
                                    ]),
                                width: 0.5,
                              ),),


                                /*           const BoxDecoration(

                              */
                              /*  image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/right.png'),
                                  fit: BoxFit.fill,
                                ),*/
                              /*),*/

                              child:Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,

                                      children: [

                                        // To token text filed
                                        SizedBox(
                                          height: 20,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 34,top: 25),
                                            child: TextField(
                                              readOnly: true,
                                              cursorColor: AppColors.whiteColor,
                                              controller: toController,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                                              ],
                                              style: const TextStyle(
                                                  color: AppColors.White,
                                                  fontFamily: "Sf-SemiBold",
                                                  fontSize: 20
                                              ),
                                              decoration: InputDecoration(
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 1),
                                                  border: InputBorder.none,
                                                  hintText: "0.00",
                                                  hintStyle: const TextStyle(
                                                      color: AppColors.greyColor2,
                                                      fontFamily: "Sf-SemiBold",
                                                      fontSize: 20
                                                  ),
                                                  labelStyle:  TextStyle(
                                                      color: AppColors.white.withOpacity(0.1)
                                                  )
                                              ),
                                            ),
                                          ),
                                        ),

                                        // To token usd value
                                        /*Padding(
                                      padding: const EdgeInsets.only(left: 35.0,top: 25),
                                      child: Text(
                                          "\$0.0",
                                          style: TextStyle(
                                              color:AppColors.white.withOpacity(0.4),
                                              fontFamily: "Sf-Regular",
                                              fontSize: 12
                                          )
                                      ),
                                    ),*/
                                      ],
                                    ),
                                  ),

                                  receiveTokenName == ""
                                      ?
                                  InkWell(
                                    onTap: () {
                                      if(providerName != ""){
                                        setState(() {
                                          tokenProvider.searchNetWorkTokenTokenList = tokenProvider.searchNetWorkTokenTokenList.where((element) => "${element.networkId}" == network_id).toList();
                                        });
                                        receiveBottomSheet(context);
                                      }else{
                                        Helper.dialogCall.showToast(context, "Select Provider First");
                                      }
                                    },
                                    child: Container(
                                      width: Responsive.isMobile(context) ? width * 0.15 : width * 0.1,
                                      height: 50,
                                      margin:  EdgeInsets.only(right: 20),

                                      padding: EdgeInsets.fromLTRB(6,10,5,10),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: AppColors.BlackgroundBlue,
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Expanded(
                                            child: Text(
                                              "Select Token",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'Sf-SemiBold',
                                                  fontSize: 13,
                                                  color: AppColors.whiteColor
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            color: AppColors.whiteColor,

                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                      :
                                  Row(
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [

                                          Padding(
                                            padding:  const EdgeInsets.only(bottom: 2),
                                            child: InkWell(
                                              onTap: (){
                                                if(providerName != ""){
                                                  setState(() {
                                                    tokenProvider.searchNetWorkTokenTokenList = tokenProvider.searchNetWorkTokenTokenList.where((element) => "${element.networkId}" == network_id).toList();
                                                  });
                                                  receiveBottomSheet(context);
                                                }else{
                                                  Helper.dialogCall.showToast(context, "Select Provider First");
                                                }
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 5,),
                                                    child: SvgPicture.asset('assets/icons/Market/downarrow.svg',),
                                                  ),
                                                  Text(
                                                    "To",
                                                    style:TextStyle(
                                                        color:AppColors.white.withOpacity(0.6),
                                                        fontFamily: "Sf-SemiBold",
                                                        fontSize: 12
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "$receiveTokenSymbol",
                                            style:TextStyle(
                                                color:AppColors.white,
                                                fontFamily: "Sf-Regular",
                                                fontSize: 12
                                            ),
                                          ),




                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: Container(
                                          decoration:Boxdec.Containercoinshadow,
                                          height:50,
                                          width: 50,
                                          child:
                                          Padding(
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
                                                borderRadius: BorderRadius.circular(300),
                                                child: CachedNetworkImage(
                                                  width: 20,
                                                  height: 20,
                                                  fit: BoxFit.fill,
                                                  imageUrl: receiveTokenImage,
                                                  placeholder: (context, url) => const Center(
                                                    child: CircularProgressIndicator(color: AppColors.blueColor),
                                                  ),
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
                                      ),
                                    ],
                                  )

                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: InkWell(
                            onTap: (){

                              if(receiveTokenName != ""){
                                setState(() {
                                  fromController.text = "0.0";
                                  toController.clear();

                                  String EsendTokenAddress = sendTokenAddress;
                                  String EsendTokenNetworkId = sendTokenNetworkId;
                                  String EsendTokenName = sendTokenName;
                                  String EsendTokenSymbol = sendTokenSymbol;
                                  String EsendTokenImage = sendTokenImage;
                                  String EsendTokenMarketId = sendTokenMarketId;
                                  String EsendTokenDes = sendTokenDes;

                                  sendTokenAddress = receiveTokenAddress;
                                  sendTokenNetworkId = receiveTokenNetworkId;
                                  sendTokenName = receiveTokenName;
                                  sendTokenSymbol = receiveTokenSymbol;
                                  sendTokenImage = receiveTokenImage;
                                  sendTokenMarketId = receiveTokenMarketId;
                                  sendTokenDes = receiveDes;
                                  sendTokenBalance = "0.0";

                                  receiveTokenAddress = EsendTokenAddress;
                                  receiveTokenNetworkId = EsendTokenNetworkId;
                                  receiveTokenName = EsendTokenName;
                                  receiveTokenSymbol = EsendTokenSymbol;
                                  receiveTokenImage = EsendTokenImage;
                                  receiveTokenMarketId = EsendTokenMarketId;
                                  receiveDes = EsendTokenDes;
                                });
                              }else{
                                Helper.dialogCall.showToast(context, "Select both token first");
                              }
                              getCustomTokenBalance();
                            },
                            child: Container(
                              height:50,

                              width: 50,
                              alignment: Alignment.center,
                              decoration:Boxdec.ButtonDecorationGradientwithBorder.copyWith(color: AppColors.blueColor2,
                                boxShadow: [
                                  const BoxShadow(
                                  color: AppColors.blueColor2,
                                  blurRadius: 5.0,
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration:BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(400),),color: AppColors.blueColor2) ,
                                alignment: Alignment.center,
                              /*  decoration:Boxdec.Bluecoinshadow,*/
                                height:45,
                                width: 45,
                                child: Padding(
                                  padding: const EdgeInsets.all(13),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle, // BoxShape.circle or BoxShape.retangle
                                        //color: const Color(0xFF66BB6A),
                                        boxShadow: [BoxShadow(
                                          color: AppColors.darkblue,
                                          blurRadius: 18.0,
                                        ),]
                                    ),
                                    width: 20,
                                    height: 20,
                                    child: SvgPicture.asset(
                                        'assets/icons/Market/frame.svg'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // exchange icon


                        // to token section

                      ],
                    ),
                  ),
                  const SizedBox(height: 19),

                  // Slippage Tolerance text
                  SizedBox(
                    width: Responsive.isDesktop(context) ? width * 0.45 :Responsive.isTablet(context) ? width * 0.42 :  width * 0.5,
                    child: const Text(
                      "Slippage Tolerance",
                      style:TextStyle(
                          color: AppColors.white,
                          fontFamily: "Sf-SemiBold",
                          fontSize: 11
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  // Slippage Tolerance option
                  SizedBox(
                    width: Responsive.isDesktop(context) ? width * 0.45 :Responsive.isTablet(context) ? width * 0.42 :  width * 0.5,
                    height: 40,
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: (){
                              setState(() {
                                selected = "0.1";
                                isSelected = "0.1";
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: isSelected == "0.1" ? AppColors.blueColor.withOpacity(0.1) : AppColors.ContainerblackColor,
                                  border: Border.all(
                                      color: isSelected == "0.1" ? AppColors.blueColor.withOpacity(0.1) :AppColors.ContainerblackColor,
                                      width: 2
                                  )
                              ),
                              child: Center(
                                child: Text(
                                  "0.1%",
                                  style: TextStyle(
                                      fontFamily: 'Sf-SemiBold',
                                      fontSize: 13,
                                      color: isSelected != "0.1" ?  AppColors.whiteColor.withOpacity(0.35) : AppColors.white
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: (){
                              setState(() {
                                selected = "0.5";
                                isSelected = "0.5";
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: isSelected == "0.5" ? AppColors.blueColor.withOpacity(0.1) : AppColors.ContainerblackColor,
                                  border: Border.all(
                                      color: isSelected == "0.5" ? AppColors.blueColor.withOpacity(0.1) :AppColors.ContainerblackColor,
                                      width: 2
                                  )
                              ),
                              child: Center(
                                child: Text(
                                  "0.5%",
                                  style: TextStyle(
                                      fontFamily: 'Sf-SemiBold',
                                      fontSize: 13,
                                      color: isSelected != "0.5" ?  AppColors.whiteColor.withOpacity(0.35) : AppColors.white
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: (){
                              setState(() {
                                selected = "1";
                                isSelected = "1";
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: isSelected == "1" ? AppColors.blueColor.withOpacity(0.1) : AppColors.ContainerblackColor,
                                  border: Border.all(
                                      color: isSelected == "1" ? AppColors.blueColor.withOpacity(0.1) :AppColors.ContainerblackColor,
                                      width: 2

                                  )
                              ),
                              child: Center(
                                child: Text(
                                  "1%",
                                  style: TextStyle(
                                      fontFamily: 'Sf-SemiBold',
                                      fontSize: 13,
                                      color: isSelected != "1" ?  AppColors.whiteColor.withOpacity(0.35) : AppColors.white
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: isSelected == "custom" ? AppColors.blueColor.withOpacity(0.1) : AppColors.ContainerblackColor,
                                border: Border.all(
                                    color: isSelected == "custom" ? AppColors.blueColor.withOpacity(0.1) :AppColors.ContainerblackColor,
                                    width: 2
                                )
                            ),
                            child:TextFormField(
                              onTap: (){
                                setState(() {
                                  isSelected = "custom";
                                });
                              },
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.phone,
                              cursorColor:AppColors.whiteColor,
                              controller: slippageController,
                              style: const TextStyle(
                                  fontFamily: 'Sf-SemiBold',
                                  fontSize: 13,
                                  color:AppColors.white
                              ),
                              onChanged: (value){
                                setState(() {
                                  selected = value;
                                });
                              },
                              decoration:  InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  hintText: "Custom",
                                  hintStyle: const TextStyle(
                                      fontFamily: 'Sf-SemiBold',
                                      fontSize: 13,
                                      color:AppColors.white
                                  ),
                                  errorStyle: TextStyle(fontSize: 0,height: 0),
                                  isDense: true,
                                  filled: false,
                                  fillColor: AppColors.blueColor.withOpacity(0.1),
                                  focusColor: AppColors.backgroundColor,
                                  border: InputBorder.none
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: height*0.09),

                  // Exchange all Buttons
                  tokenProvider.providersList.isEmpty
                      ?
                  // Swap Disable button
                  Container(
                    height: MediaQuery.of(context).size.height/18,

                    width: width/7,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,

                          end: Alignment.bottomLeft,
                          // tileMode: TileMode.,
                          colors: [
                            // AppColors.darkblueContainer.withOpacity(0.1),
                            AppColors.darkblueContainer.withOpacity(0.1),


                            AppColors.pinkColor.withOpacity(0.1),
                            AppColors.darkblueContainer.withOpacity(0.2),
                            AppColors.darkblueContainer.withOpacity(0.1),
                            // AppColors.darkblueContainer.withOpacity(0.9),



                          ],
                        ),

                        border: Border.all(color: AppColors.bordergrey,width: 0),
                        color: AppColors.darkblueContainer,
                        borderRadius: BorderRadius.circular(25)
                    ),

                    child:   Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        SizedBox(width: 4,),
                        Center(child: ShaderMask(

                          blendMode: BlendMode.srcIn,
                          shaderCallback: (Rect bounds) {
                            return AppColors.buttonGradient.createShader(

                                Offset.zero & bounds.size);
                          },
                          child: const Text(
                            "Swap Disable",
                            style: TextStyle(
                              fontFamily: 'Sf-SemiBold',
                              fontSize: 13,

                            ),

                          ),
                        ),),
                      ],
                    ),)
                      :
                  isAllowance == false
                      ?
                  isLoading == true || isApproveLoading == true || isSendApprove == true
                      ?
                  Helper.dialogCall.showLoader()
                      :
                  fromController.text == "" || toController.text == "" || toController.text == "0.0" || fromController.text == "0.0" || providerActive == 0
                      ?
                  //Swap Disable  and Enable error button
                  Container(
                    height: MediaQuery.of(context).size.height/18,

                    width: width/7,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            AppColors.darkblueContainer.withOpacity(0.1),
                            AppColors.pinkColor.withOpacity(0.1),
                            AppColors.darkblueContainer.withOpacity(0.2),
                            AppColors.darkblueContainer.withOpacity(0.1),
                          ],
                        ),

                        border: Border.all(color: AppColors.bordergrey,width: 0),
                        color: AppColors.darkblueContainer,
                        borderRadius: BorderRadius.circular(25)
                    ),

                    child:Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        SizedBox(width: 4,),
                        Center(child: ShaderMask(

                          blendMode: BlendMode.srcIn,
                          shaderCallback: (Rect bounds) {
                            return AppColors.buttonGradient.createShader(

                                Offset.zero & bounds.size);
                          },
                          child: Text(
                            providerActive == 0 ?  "Swap Disable" : "Enable",
                            style: const TextStyle(
                              fontFamily: 'Sf-SemiBold',
                              fontSize: 13,
                            ),
                          ),
                        ),
                        ),
                      ],
                    ),
                  )
                      :
                  // enable button
                  InkWell(
                    onTap: (){
                      if(fromController.text == "" || toController.text == "" || toController.text == "0.0" || fromController.text == "0.0"){

                      }else {
                        FocusScope.of(context).unfocus();
                        approveFees();
                      }
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height/18,

                      width: width/7,
                      decoration: BoxDecoration(
                          gradient: AppColors.buttonGradient2,
                          borderRadius: BorderRadius.circular(25)
                      ),

                      child:   Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [

                          SizedBox(width: 4),
                          Center(
                            child: Text(
                              "Enable",
                              style: TextStyle(
                                fontFamily: 'Sf-SemiBold',
                                fontSize: 13,
                                color: AppColors.whiteColor
                              ),

                            ),),
                        ],
                      ),
                    ),
                  )
                      :
                  isLoading == true
                      ?
                  Helper.dialogCall.showLoader()
                      :
                  // main exchange button
                  InkWell(
                    onTap: (){
                      if(fromController.text == "" || toController.text == ""  || toController.text == "0.0" || fromController.text == "0.0" || double.parse(sendTokenBalance) <  double.parse(fromController.text)){

                      }else {
                        FocusScope.of(context).unfocus();
                        getSwapFees();
                      }
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height/18,

                      width: width/7,
                      decoration: BoxDecoration(
                          color: fromController.text == "0.0" || providerActive == 0 || fromController.text.isEmpty || toController.text == "0.0" || double.parse(sendTokenBalance) <  double.parse(fromController.text) ? AppColors.blueColor.withOpacity(0.25):AppColors.blueColor,
                          gradient: AppColors.buttonGradient2,
                          borderRadius: BorderRadius.circular(25)
                      ),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:  [

                          const SizedBox(width: 4),
                          Center(
                            child: Text(
                              "Exchange",
                              style: TextStyle(
                                  fontFamily: 'Sf-SemiBold',
                                  fontSize: 13,
                                  color: fromController.text == "0.0" || providerActive == 0 || fromController.text.isEmpty || toController.text == "0.0" || double.parse(sendTokenBalance) <  double.parse(fromController.text) ?  AppColors.whiteColor.withOpacity(0.35) : AppColors.white
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),


                  const SizedBox(height: 70,)
                ],
              ),
            )



          ],
        ),
      ),
    );

  }

}
