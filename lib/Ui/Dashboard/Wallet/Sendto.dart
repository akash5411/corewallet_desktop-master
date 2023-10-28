import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:corewallet_desktop/Handlers/ApiHandle.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_address.dart';
import 'package:corewallet_desktop/Models/NetworkModel.dart';
import 'package:corewallet_desktop/Provider/Token_Provider.dart';
import 'package:corewallet_desktop/Provider/Transection_Provider.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Wallet/Wallet.dart';
import 'package:corewallet_desktop/Values/Helper/helper.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:corewallet_desktop/Values/styleandborder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../../../Provider/Wallet_Provider.dart';


class SendToPage extends StatefulWidget {
  const SendToPage({Key? key}) : super(key: key);

  @override
  State<SendToPage> createState() => _SendToPageState();
}

class _SendToPageState extends State<SendToPage> {
  late WalletProvider walletProvider;

  TextEditingController sendTokenQuantity = TextEditingController();
  TextEditingController toAddressController = TextEditingController();
  late TransectionProvider transectionProvider;
  late TokenProvider tokenProvider;

  bool passwordCheck = false;
  bool askPassword = false;


  @override
  void initState() {
    super.initState();
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    transectionProvider = Provider.of<TransectionProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    selectedAccount();
  }

  late String deviceId;
  String selectedAccountId = "",
      selectedAccountName = "",
      selectedAccountAddress = "",
      selectedAccountPrivateAddress = "";

  var currency = "", crySymbol = "";
  bool isLoaded = true,isLoading = false,showPass = true;
  List<NetworkList> networkList = [];

  selectedAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    currency = sharedPreferences.getString("currency") ?? "USD";
    askPassword = sharedPreferences.getBool("askPassword") ?? false;
    crySymbol = sharedPreferences.getString("crySymbol") ?? "\$";


    setState(() {
      if(askPassword == false){
        passwordCheck = true;
      }
      selectedAccountId = sharedPreferences.getString('accountId') ?? "";
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";
      // selectedAccountPrivateAddress = sharedPreferences.getString('accountPrivateAddress') ?? "";

    });

    await DbAccountAddress.dbAccountAddress.getAccountAddress(selectedAccountId);
    await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId,walletProvider.accountTokenList!.networkId);

    setState(() {
      networkList = tokenProvider.networkList.where((element) => "${element.id}" == "${walletProvider.accountTokenList!.networkId}").toList();
      selectedAccountAddress =DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
      selectedAccountPrivateAddress = Helper.dialogCall.decryptAddressColumn(DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress);
      isLoaded = false;
      // fromAddressController = TextEditingController(text: selectedAccountAddress);
    });

  }


  Web3Client? _web3client;
  getWeb3NetWorkFees()async{

    setState((){
      isLoading = true;
    });

    _web3client = Web3Client(
      "${networkList[0].url}",
      http.Client(),
    );

    // print(rpcUrl);

    setState((){
      isLoading = true;
    });


    //print(EtherAmount.inWei(BigInt.from(1)));

    var estimateGas = await _web3client!.estimateGas(
        sender:EthereumAddress.fromHex(selectedAccountAddress),
        to: EthereumAddress.fromHex(mainToAddress),
        value: EtherAmount.inWei(BigInt.from(double.parse(walletProvider.accountTokenList!.balance)))
    );
    var getGasPrice = await _web3client!.getGasPrice();

    //print("estimateGas === > ${"${estimateGas}"}");
    //print("getGasPrice === > ${"${getGasPrice.getInWei}"}");

    var value = BigInt.from(double.parse("$estimateGas") *  double.parse("${getGasPrice.getInWei}")) / BigInt.from(10).pow(18);
    //print(value);

    double tokenBalance = double.parse(double.parse(walletProvider.accountTokenList!.balance).toStringAsFixed(4)) - (value * 2);

    //print(tokenBalance);


    if(tokenBalance > 0){
      setState((){
        sendTokenQuantity = TextEditingController(
            text: tokenBalance.toStringAsFixed(4));
        isLoading = false;
      });
    }else{
      Helper.dialogCall.showToast(context, "Insufficient ${networkList[0].symbol} balance please deposit some ${networkList[0].symbol}");
    }

    setState((){
      isLoading = false;
    });

  }

  var mainToAddress = "";
  bool getAddressValidatorCall = false,maxButtonCall = false;
  addressValidator()async{
    setState(() {
      isLoading = true;
    });
    var data ={
      "network_id":walletProvider.accountTokenList!.networkId,
      "url": networkList[0].url,
      "from_addess": selectedAccountAddress.trim(),
      "to_address": toAddressController.text.trim()
    };
    // print("fff");
    // print(data);
    await transectionProvider.validateAddress(data,"/validateAddress");

    if(transectionProvider.validAddressResponse["status"] == true){
      setState(() {
        getAddressValidatorCall = true;
      });
      setState(() {
        isLoading = false;
        mainToAddress = transectionProvider.validAddressResponse["to_address"];
      });


      if(networkList.first.isTxfees != 0) {
        if (!maxButtonCall) {
          getNetworkFees();
        } else {
          // toAddressController.text = transectionProvider.validAddressResponse["to_address"];
          getWeb3NetWorkFees();
        }
      }else{
        confirmDialog(context);
      }

    }else{
      isLoading = false;
      Helper.dialogCall.showToast(context, "Wrong receiver's public address");
    }
  }


  bool isGetQuote = false;
  String sendGasPrice = "";
  String sendGas = "";
  String? sendNonce = "";
  String sendTransactionFee = "0.0";
  double totalUsd = 0.0;
  double totalSendValue = 0.0;


  getNetworkFees() async {

    setState((){
      isLoading = true;
    });

    var data = {
      "network_id": walletProvider.accountTokenList!.networkId,
      "privateKey": selectedAccountPrivateAddress,
      "from": selectedAccountAddress,
      "to": mainToAddress,
      "token_id": walletProvider.accountTokenList!.token_id,
      "value": "${sendTokenQuantity.text}",
      "gasPrice": "",
      "gas":"",
      "nonce": 0,
      "isCustomeRPC":false,
      "network_url":networkList.first.url,
      "tokenAddress":walletProvider.accountTokenList!.address,
      "decimals":walletProvider.accountTokenList!.decimals
    };

    // print(json.encode(data));

    await transectionProvider.getNetworkFees(data,'/getNetrowkFees',context);

    if( transectionProvider.isSuccess == true){

      var body = transectionProvider.networkData;

      setState(() {
        isGetQuote = true;
        isLoading = false;

        sendGasPrice = "${body['gasPrice']}";
        sendGas = "${body['gas']}";
        sendNonce = body['nonce'];
        sendTransactionFee = "${body['transactionFee']}";

        double networkUsd = 0.0,tokenUsd = 0.0;


        // if(isCustom == 0) {

          tokenUsd = double.parse(sendTokenQuantity.text) * double.parse("${walletProvider.accountTokenList!.price}");
          networkUsd = double.parse("$sendTransactionFee") * double.parse("${walletProvider.accountTokenList!.price}");

        // }else{
        //   tokenUsd = 0;
        //   networkUsd = 0;
        // }

        totalSendValue = double.parse(sendTokenQuantity.text) + double.parse("$sendTransactionFee");
        totalUsd = tokenUsd + networkUsd;

      });
      confirmDialog(context);
    }
    else{

      Helper.dialogCall.showToast(context, "Insufficient ${networkList[0].symbol} balance please deposit some ${networkList[0].symbol}");
      setState((){
        isLoading = false;

      });
    }

  }

  bool checkBox = false;
  confirmDialog(context){
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.darklightgrey,
            actionsPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            content: StatefulBuilder(

                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    width: MediaQuery.of(context).size.width/3,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [

                         SizedBox(height:Responsive.isMobile(context) || Responsive.isTablet(context)?10: 20),

                        const Padding(
                          padding: EdgeInsets.only(left: 5,bottom: 10),
                          child: Text(
                              'Asset',
                               style:TextStyle(color: Colors.white,fontSize: 14,fontFamily: 'Sf-SemiBold',)
                          ),
                        ),

                        Container(
                          decoration: BoxDecoration(
                              color: AppColors.darkBlack0A0.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding:  EdgeInsets.symmetric(vertical:Responsive.isMobile(context) || Responsive.isTablet(context)?6: 8),
                            child: Row(
                              children: [

                                const SizedBox(width: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(300),
                                  child: CachedNetworkImage(
                                    width: 40,height: 40,
                                    fit: BoxFit.fill,
                                    imageUrl: '${walletProvider.accountTokenList?.logo}',
                                    placeholder: (context, url) => Helper.dialogCall.showLoader(),
                                    errorWidget: (context, url, error) =>
                                        SvgPicture.asset(
                                            'assets/icons/drawericon/colorlogoonly.svg',
                                            width: 22
                                        ),
                                  ),
                                ),

                                SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                      '${walletProvider.accountTokenList?.name}',
                                      style:const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Sf-SemiBold',
                                      )
                                  ),
                                ),

                                const SizedBox(width: 12),

                              ],
                            ),
                          ),
                        ),
                         SizedBox(height:Responsive.isMobile(context) || Responsive.isTablet(context)?5: 10),

                        Container(
                          decoration: BoxDecoration(
                              color: AppColors.darkBlack0A0.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    'From Address',
                                      style:TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Sf-SemiBold',
                                      )
                                  ),
                                ),
                                SizedBox(height: 10),
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    "${selectedAccountAddress}",
                                    style:TextStyle(color: Colors.white,fontSize: 11,fontFamily: 'Sf-Regular',)
                                  ),
                                ),
                                SizedBox(height: 10),
                                const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                      'To Address',
                                      style:TextStyle(color: Colors.white,fontSize: 12,fontFamily: 'Sf-SemiBold',)
                                  ),
                                ),
                                SizedBox(height:Responsive.isMobile(context) || Responsive.isTablet(context)?5: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    "${transectionProvider.validAddressResponse["name"]} (${transectionProvider.validAddressResponse["to_address"]})",
                                      style:const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontFamily: 'Sf-Regular',
                                      )
                                  ),
                                ),


                                 SizedBox(height:Responsive.isTablet(context)?10: 15),

                                const Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    'Token Quantity',
                                      style:TextStyle(color: Colors.white,fontSize: 13,fontFamily: 'Sf-SemiBold',)
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Row(
                                    children: [

                                      Expanded(
                                        child: Text(
                                          '${sendTokenQuantity.text}   ${walletProvider.accountTokenList!.symbol}',
                                          style:const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'Sf-SemiBold',
                                          )
                                        ),
                                      ),

                                      /* widget.sendTokenId != ""
                                          ?
                                      Text(
                                        double.parse("${double.parse(sendTokenUsd)}").toStringAsFixed(8),
                                        style:TextStyle(color: Colors.white,fontSize: 14,fontFamily: 'Sf-SemiBold',)
                                      ):*/
                                      Text(
                                        double.parse("${double.parse(sendTokenQuantity.text)*walletProvider.accountTokenList!.price}").toStringAsFixed(2),
                                        style:const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'Sf-SemiBold',
                                        )
                                      ),

                                      Text(
                                        " $currency",
                                        style:const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'Sf-SemiBold',
                                        )
                                      ),

                                    ],
                                  ),
                                ),


                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Container(
                          decoration: BoxDecoration(
                              color: AppColors.darkBlack0A0.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding:  EdgeInsets.symmetric(vertical:Responsive.isMobile(context) || Responsive.isTablet(context)?5: 10,horizontal: 13),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                Row(
                                  children: [

                                    const Expanded(
                                      child: Text(
                                        'NetworkFee',
                                        style:TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontFamily: 'Sf-SemiBold',
                                        )
                                      ),
                                    ),

                                    Text(
                                      "${ApiHandler.calculateLength3(sendTransactionFee)}  ${networkList.first.symbol}",
                                        style:const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'Sf-Regular',
                                        )
                                    ),

                                  ],
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  children: [

                                    const Expanded(
                                      child: Text(
                                        'Max Total',
                                        style:TextStyle(color: Colors.white,fontSize: 14,fontFamily: 'Sf-SemiBold',)
                                      ),
                                    ),

                                    Text(
                                        walletProvider.accountTokenList?.networkId == 9
                                            ?
                                        double.parse("${double.parse('${sendTokenQuantity.text}')}").toStringAsFixed(4)
                                            :
                                        '${totalSendValue.toStringAsFixed(4)} ${networkList.first.symbol}',
                                        style:const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'Sf-Regular',
                                        )
                                    ),

                                  ],
                                ),

                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                      walletProvider.accountTokenList?.networkId == 9
                                          ?
                                      "(${double.parse("${double.parse(sendTokenQuantity.text) * walletProvider.accountTokenList!.price}").toStringAsFixed(4)} $currency)"
                                          :
                                      '(${totalUsd.toStringAsFixed(2)} $currency)',
                                      style:const TextStyle(
                                        color: Colors.white,fontSize: 12,
                                        fontFamily: 'Sf-Regular',
                                      )
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        askPassword
                            ?
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             SizedBox(height:Responsive.isMobile(context) || Responsive.isTablet(context)?5: 10),

                            const Text(
                                "Password",
                                style: TextStyle(
                                    color: AppColors.White,
                                    fontFamily: "Sf-SemiBold",
                                    fontSize: 14
                                )
                            ),
                             SizedBox(height:Responsive.isTablet(context)?5: 10),

                            //Password TextField
                            TextFormField(
                              obscureText: showPass,
                              cursorColor:  AppColors.white,
                              style: const TextStyle(
                                  color: AppColors.white,
                                  fontFamily: "Sf-Regular",
                                  fontSize: 14
                              ),
                              onChanged: (value) async {
                                SharedPreferences pre = await SharedPreferences.getInstance();
                                if(pre.getString("password") == value){
                                  setState(() {
                                    passwordCheck = true;
                                  });
                                }
                              },

                              decoration: InputDecoration(
                                fillColor: AppColors.ContainergreySearch,

                                filled: true,
                                isDense: true,
                                hintText: "Example21@#!",
                                hintStyle: const TextStyle(
                                    color: AppColors.greydark,
                                    fontFamily: "Sf-Regular",
                                    fontSize: 14
                                ),
                                suffixIcon: InkWell(
                                  onTap: (){
                                    setState(() {
                                      showPass = !showPass;
                                    });
                                  },
                                  child: !showPass
                                      ?
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Image.asset(
                                      "assets/icons/eye_off.png",
                                      height: 10,
                                      width: 10,
                                      color: AppColors.white,
                                    ),
                                  )
                                      :
                                  const Icon(Icons.visibility,color: AppColors.white,size: 18,),
                                ),
                                errorStyle: const TextStyle(
                                  height: 0,fontSize: 0,
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.transparent, width: 2),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                              ),
                            ),

                          ],
                        )
                            :
                        const SizedBox(),
                         SizedBox(height:Responsive.isMobile(context) || Responsive.isTablet(context)?10: 30),


                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            Theme(
                              data: Theme.of(context).copyWith(
                                unselectedWidgetColor: AppColors.white.withOpacity(0.5),
                              ),
                              child: Checkbox(
                                checkColor: AppColors.whiteColor,
                                activeColor: AppColors.blueColor,
                                value: checkBox,
                                onChanged: (value) {

                                  setState(() {
                                    checkBox = value!;
                                  });

                                },
                              ),
                            ),

                            Expanded(
                              child: Text(
                                "I understand all of the risks.I agree to the Terms and Conditions.",
                                  style:TextStyle(
                                    color:AppColors.white.withOpacity(0.5),
                                    fontSize: 12,
                                    fontFamily: 'Sf-Regular',
                                  )
                              ),
                            )

                          ],
                        ),

                         SizedBox(height:Responsive.isMobile(context) || Responsive.isTablet(context)?20: 30),


                        isLoading == true
                            ?
                        Helper.dialogCall.showLoader()
                            :
                        checkBox == false || passwordCheck == false
                            ?
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width-180,
                            height: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                gradient: AppColors.buttonGradient2,
                                color: AppColors.blueColor.withOpacity(0.23)
                            ),
                            child: Center(
                              child: Text(
                                  'Confirm send',
                                  style:TextStyle(
                                    color: Colors.white.withOpacity(0.2),
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
                            setState((){});
                            confirmSend();
                          },
                          child: Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width-180,
                              height: 45,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  gradient: AppColors.buttonGradient2
                              ),
                              child: const Center(
                                child: Text(
                                    'Confirm send',
                                    style:TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Sf-SemiBold',
                                    )
                                ),
                              ),
                            ),
                          ),
                        ),

                         SizedBox(height:Responsive.isMobile(context) || Responsive.isTablet(context)?10: 20),


                      ],
                    ),
                  );
                }
            ),
          );
        },
    ).whenComplete(() {

      setState(() {
        checkBox = false;
      });

    });
  }

  confirmSend() async {

    setState((){
      isLoading = true;
    });

    //print(selectedAccountPrivateAddress);
    // double value = double.parse(sendTokenQuantity.text) * 0.99;

    var data = {

      "network_id": walletProvider.accountTokenList!.networkId,
      "privateKey": selectedAccountPrivateAddress,
      "from": selectedAccountAddress,
      "to": toAddressController.text,
      "token_id": walletProvider.accountTokenList!.token_id,
      "value": "${sendTokenQuantity.text}",
      "gasPrice": sendGasPrice,
      "gas": sendGas,
      "nonce": sendNonce,
      "networkFee": sendTransactionFee,
      "isCustomeRPC": false,
      "network_url":networkList.first.url,
      "tokenAddress":walletProvider.accountTokenList!.address,
      "decimals":walletProvider.accountTokenList!.decimals
    };

    // print(jsonEncode(data));
    await transectionProvider.sendToken(data,'/sendAssets');
    Navigator.pop(context);
    if( transectionProvider.isSend == true){

      walletProvider.changeListnerWallet("Wallet");

      Helper.dialogCall.showToast(context, "Send Token Successfully Done");


      setState((){
        isLoading = false;

        sendGasPrice = "";
        sendGas = "";
        sendNonce = "";
        sendTransactionFee = "";

        toAddressController.clear();
        sendTokenQuantity.clear();

      });

    }
    else {
      if (walletProvider.accountTokenList!.networkId == 9 && transectionProvider.sendTokenData["status"] == false) {
        Helper.dialogCall.showToast(context, "Insufficient fees balance");

      } else {
        Helper.dialogCall.showToast(context, "Send token error");
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  var width,height;

  @override
  Widget build(BuildContext context) {
    walletProvider = Provider.of<WalletProvider>(context, listen: true);
    transectionProvider = Provider.of<TransectionProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);

    width=MediaQuery.of(context).size.width;
    height=MediaQuery.of(context).size.height;

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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                InkWell(
                  onTap: (){

                    walletProvider.changeListnerWallet("PriceChart");

                    // Navigator.pop(context);
                  },
                  child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: Boxdec.BackButtonGradient,

                      child: Center(
                        child:Image.asset("assets/icons/backarrow.png",height: 24),)),
                ),

               Spacer(),
               SizedBox(width:Responsive.isMobile(context)?width/4.8: width/9,),
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Center(child: Text("Send To",style: TextStyle(color: AppColors.White,fontFamily: "Sf-SemiBold",fontSize: 20))),
                ),
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
                              const SizedBox(width: 20),

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
                                      color: Colors.white,fontSize: 14,fontFamily: 'Sf-SemiBold',
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
            const SizedBox(height: 20,),

            isLoaded
                ?
            Center(child: Helper.dialogCall.showLoader())
                :
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // form address and to address
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      const Expanded(child: SizedBox(width: 0,height: 20,)),
                      const SizedBox(height: 10,),
                      Padding(
                        padding: const EdgeInsets.only(left: 0,bottom: 0,top: 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            // token image
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.9),
                                    blurRadius: 70,
                                  )
                                ],
                              ),
                              child: ClipRRect(
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
                            const SizedBox(height: 10),

                            // token symbol
                            Text(
                                "${walletProvider.accountTokenList!.symbol}",
                                style: const TextStyle(
                                    color: AppColors.White,
                                    fontFamily: "Sf-SemiBold",
                                    fontSize: 12
                                )
                            ),
                            const SizedBox(height: 10),

                            // token network fees and
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 40),
                                child: Container(
                                  padding: const EdgeInsets.only(top: 10,bottom: 10),
                                  margin: const EdgeInsets.fromLTRB(0,10,30,10),
                                  alignment: Alignment.center,
                                  width: width/4,
                                  decoration: const BoxDecoration(color: AppColors.ContainerblackColor,borderRadius: BorderRadius.all(Radius.circular(20))),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text("Available", style:TextStyle(color: AppColors.white.withOpacity(0.6),fontFamily: "Sf-SemiBold",fontSize: 10),),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${ApiHandler.calculateLength3(double.parse(walletProvider.accountTokenList!.balance).toString())} ${walletProvider.accountTokenList!.symbol}",
                                        style:const TextStyle(
                                            color: AppColors.White,
                                            fontFamily: "Sf-Regular",
                                            fontSize: 13
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "$crySymbol ${(double.parse(walletProvider.accountTokenList!.balance) * walletProvider.accountTokenList!.price).toStringAsFixed(2)}",
                                        style:TextStyle(
                                            color: AppColors.white.withOpacity(0.6),
                                            fontFamily: "Sf-SemiBold",
                                            fontSize: 10
                                        ),
                                      ),
                                    ],
                                  ),
                                  /*Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Expanded(child: SizedBox(width: 30,)),
                                      const SizedBox(width: 20,),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text("Available", style:TextStyle(color: AppColors.white.withOpacity(0.6),fontFamily: "Sf-SemiBold",fontSize: 10),),
                                          const SizedBox(height: 4,),
                                          Text(
                                            "${ApiHandler.calculateLength3(walletProvider.accountTokenList!.balance)} ${walletProvider.accountTokenList!.symbol}",
                                            style:const TextStyle(
                                                color: AppColors.White,
                                                fontFamily: "Sf-Regular",
                                                fontSize: 13
                                            ),
                                          ),
                                          const SizedBox(height: 4,),
                                          Text(
                                            "$crySymbol ${(double.parse(walletProvider.accountTokenList!.balance) * walletProvider.accountTokenList!.price).toStringAsFixed(2)}",
                                            style:TextStyle(
                                                color: AppColors.white.withOpacity(0.6),
                                                fontFamily: "Sf-SemiBold",
                                                fontSize: 10
                                            ),
                                          ),
                                        ],
                                      ),
                                      // SizedBox(width: 20,),
                                      Expanded(child: SizedBox(width: 30,)),
                                      Container(
                                        alignment: Alignment.center,
                                        height: height*0.04,
                                        width:width*0.00009,
                                        color: AppColors.greyColor,
                                      ),

                                      Expanded(child: SizedBox(width: 30,)),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text("Network Fee", style:TextStyle(color: AppColors.white.withOpacity(0.6),fontFamily: "Sf-SemiBold",fontSize: 10),),
                                          SizedBox(height: 4,),
                                          Text("0.0343094 CMCMX", style:TextStyle(color: AppColors.White,fontFamily: "Sf-Regular",fontSize: 13),),
                                          SizedBox(height: 4,),
                                          Text("\$ 0.5", style:TextStyle(color: AppColors.white.withOpacity(0.6),fontFamily: "Sf-SemiBold",fontSize: 10),),
                                        ],
                                      ),
                                      Expanded(child: SizedBox(width: 30,)),
                                    ],),*/

                                ),
                              ),
                            ),


                            Padding(
                              padding: const EdgeInsets.only(left: 38),
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // form text show here
                                    Padding(
                                      padding: EdgeInsets.only(right:Responsive.isMobile(context)?315:Responsive.isTablet(context)?330: 380),
                                      child: Container(
                                        height: 70,
                                        width:Responsive.isMobile(context)?250:Responsive.isTablet(context)?270: 330,
                                        // width:Responsive.isTablet(context)?width/2.7:Responsive.isMobile(context)?width/2.7:width/4,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/left.png'
                                            ),
                                            fit: BoxFit.fill,
                                          ),
                                        ),

                                        child:Padding(
                                          padding: const EdgeInsets.only(top:10,left: 30 ,right: 40),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "From",
                                                style:TextStyle(
                                                    color:AppColors.white.withOpacity(0.6),
                                                    fontFamily: "Sf-SemiBold",
                                                    fontSize: 12
                                                ),
                                              ),
                                              const SizedBox(height: 0,),
                                              Text(
                                                selectedAccountAddress,
                                                style:const TextStyle(
                                                    color: AppColors.white,
                                                    fontFamily: "Sf-Regular",
                                                    fontSize: 13
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // send arrow icon
                                    Padding(
                                      padding: const EdgeInsets.only(right: 40),
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            color: AppColors.containerbackgroundgrey,
                                            border: GradientBoxBorder(
                                              gradient: LinearGradient(
                                                  begin : Alignment.topRight,
                                                  end : Alignment.bottomRight,
                                                  colors: [
                                                    AppColors.greydark.withOpacity(0.4),
                                                    AppColors.darkblueContainer.withOpacity(0.4),
                                                    AppColors.darkblueContainer.withOpacity(0.4),
                                                    AppColors.darkblueContainer.withOpacity(0.4),
                                                    AppColors.darkblueContainer.withOpacity(0.4),
                                                  ]),
                                              width: 0,
                                            ),
                                            shape: BoxShape.circle),

                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SvgPicture.asset(
                                            'assets/icons/wallet/arrow.svg',
                                            alignment: Alignment.center,
                                          ),
                                        ),),
                                    ),

                                    // to address
                                    Padding(
                                      padding: EdgeInsets.only(left:Responsive.isTablet(context)?240:Responsive.isMobile(context)?250: 295),
                                      child: Container(
                                        height: 100,
                                        width:Responsive.isMobile(context)?280:Responsive.isTablet(context)?270:330,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/right.png'),
                                            fit: BoxFit.fill,
                                          ),),

                                        child:Padding(
                                          padding: const EdgeInsets.only(top:15,left: 20,right: 40),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 30),
                                                child: SizedBox(
                                                  child: TextField(
                                                    cursorColor: AppColors.whiteColor,
                                                    controller: toAddressController,
                                                    style:const TextStyle(
                                                        color: AppColors.white,
                                                        fontFamily: "Sf-Regular",
                                                        fontSize: 13
                                                    ),
                                                    maxLines: 2,
                                                    decoration: InputDecoration(
                                                      labelText: 'To',
                                                      labelStyle:TextStyle(color:AppColors.white.withOpacity(0.6),fontFamily: "Sf-SemiBold",fontSize: 14),
                                                      border: InputBorder.none,
                                                      hintText: "Enter Address",
                                                      hintStyle:  TextStyle(color: AppColors.white.withOpacity(0.4),fontFamily: "Sf-Regular",fontSize: 12),

                                                    ),

                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),),
                                    ),
                                  ],
                                ),
                              ),
                            ),



                          ],
                        ),
                      ),

                      Expanded(child: SizedBox(width: 20,height: 0,)),
                      // SizedBox(width: 40,height: 20,),
                    ],
                  ),

                  SizedBox(height: height*0.08,),
                  Text("Enter Amount",style: TextStyle(color: AppColors.white.withOpacity(0.6),fontFamily: "Sf-SemiBold",fontSize: 12)),
                  Padding(
                    padding: const EdgeInsets.only(left: 150),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IntrinsicWidth(
                          child: TextField(
                            controller: sendTokenQuantity,
                            textAlign: TextAlign.center,
                            onChanged: (value) {
                              setState(() {});
                            },
                            style: const TextStyle(color: AppColors.White,fontFamily: "Sf-SemiBold",
                                fontSize: 25),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "0.00",
                                hintStyle: const TextStyle(color: AppColors.greyColor2,fontFamily: "Sf-SemiBold",fontSize: 30),
                                labelStyle:  TextStyle(
                                    color: AppColors.white.withOpacity(0.1)
                                )
                            ),

                          ),
                        ),

                        InkWell(
                          onTap: (){

                            if(networkList[0].isEVM == 1){

                              if(toAddressController.text != "") {
                                setState((){
                                  FocusScope.of(context).unfocus();
                                  maxButtonCall = true;
                                });
                                addressValidator();
                                // getWeb3NetWorkFees();
                              }
                              else{
                                setState(() {
                                  isLoading = false;
                                });
                              }

                            }
                            else {

                              double tokenBalance = (double.parse(
                                  walletProvider.accountTokenList!.balance) * 96) / 100;

                              //print(tokenBalance.toStringAsFixed(3));
                              setState(() {
                                sendTokenQuantity = TextEditingController(
                                    text: tokenBalance.toStringAsFixed(3)
                                );
                              });
                            }
                          },
                          child: SizedBox(
                            height: 50,
                            width: 150,
                            child: Center(
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
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                      "$crySymbol "
                      "${(double.parse(sendTokenQuantity.text.isEmpty
                      ? "0.00" : sendTokenQuantity.text ) *
                      walletProvider.accountTokenList!.price).toStringAsFixed(2)}",

                      style: TextStyle(
                          color:AppColors.white.withOpacity(0.4),
                          fontFamily: "Sf-Regular",
                          fontSize: 15
                      )
                  ),
                  SizedBox(height: height*0.08,),


                  isLoading == true
                      ?
                  Helper.dialogCall.showLoader()
                      :
                  networkList.first.isTxfees == 0
                      ?
                  InkWell(
                    onTap: () {
                      if(
                      sendTokenQuantity.text.isEmpty
                          || double.parse(sendTokenQuantity.text) == 0.0
                          || toAddressController.text.isEmpty
                          || double.parse(sendTokenQuantity.text) == 0
                          || double.parse(sendTokenQuantity.text) < 0.00
                          || double.parse(walletProvider.accountTokenList!.balance) <  double.parse(sendTokenQuantity.text)
                      ){

                      }else{
                        FocusScope.of(context).unfocus();
                        addressValidator();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              AppColors.darkblueContainer.withOpacity(0.2),
                              AppColors.darkblueContainer.withOpacity(0.1),
                              AppColors.darkblueContainer.withOpacity(0.1),
                              AppColors.darkblueContainer.withOpacity(0.1),
                              AppColors.redColor.withOpacity(0.08),
                              AppColors.redColor.withOpacity(0.08),
                              AppColors.pinkColor.withOpacity(0.08),
                              AppColors.pinkColor.withOpacity(0.08),
                              AppColors.primaryColor.withOpacity(0.08 ),
                              AppColors.primaryColor.withOpacity(0.08 ),
                              AppColors.greyColor.withOpacity(0.1),
                              AppColors.greyColor.withOpacity(0.1),
                              AppColors.greyColor.withOpacity(0.1),
                              AppColors.greyColor.withOpacity(0.1),
                              AppColors.greyColor.withOpacity(0.1),
                            ],
                          ),

                          border: GradientBoxBorder(
                            gradient: LinearGradient(
                                begin : Alignment.topRight,
                                end : Alignment.bottomRight,
                                colors: [
                                  AppColors.greydark.withOpacity(0.4),
                                  AppColors.darkblueContainer.withOpacity(0.4),
                                  AppColors.darkblueContainer.withOpacity(0.4),
                                  AppColors.darkblueContainer.withOpacity(0.4),
                                  AppColors.darkblueContainer.withOpacity(0.4),
                                ]),
                            width: 0,
                          ),
                          borderRadius: BorderRadius.circular(25)
                      ),

                      child:   SizedBox(
                        height: MediaQuery.of(context).size.height/18,
                        width: width/6,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                                    fontFamily: 'Sf-SemiBold',
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],),
                      ),),
                  )
                      :
                  InkWell(
                    onTap: () {
                      if(
                      sendTokenQuantity.text.isEmpty
                          || double.parse(sendTokenQuantity.text) == 0.0
                          || toAddressController.text.isEmpty
                          || double.parse(sendTokenQuantity.text) == 0
                          || double.parse(sendTokenQuantity.text) < 0.00
                          || double.parse(walletProvider.accountTokenList!.balance) <  double.parse(sendTokenQuantity.text)
                      ){

                      }else{
                        FocusScope.of(context).unfocus();
                        if(getAddressValidatorCall) {
                          getNetworkFees();
                        }else{
                          addressValidator();
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              AppColors.darkblueContainer.withOpacity(0.2),
                              AppColors.darkblueContainer.withOpacity(0.1),
                              AppColors.darkblueContainer.withOpacity(0.1),
                              AppColors.darkblueContainer.withOpacity(0.1),
                              AppColors.redColor.withOpacity(0.08),
                              AppColors.redColor.withOpacity(0.08),
                              AppColors.pinkColor.withOpacity(0.08),
                              AppColors.pinkColor.withOpacity(0.08),
                              AppColors.primaryColor.withOpacity(0.08 ),
                              AppColors.primaryColor.withOpacity(0.08 ),
                              AppColors.greyColor.withOpacity(0.1),
                              AppColors.greyColor.withOpacity(0.1),
                              AppColors.greyColor.withOpacity(0.1),
                              AppColors.greyColor.withOpacity(0.1),
                              AppColors.greyColor.withOpacity(0.1),
                            ],
                          ),

                          border: GradientBoxBorder(
                            gradient: LinearGradient(
                                begin : Alignment.topRight,
                                end : Alignment.bottomRight,
                                colors: [
                                  AppColors.greydark.withOpacity(0.4),
                                  AppColors.darkblueContainer.withOpacity(0.4),
                                  AppColors.darkblueContainer.withOpacity(0.4),
                                  AppColors.darkblueContainer.withOpacity(0.4),
                                  AppColors.darkblueContainer.withOpacity(0.4),
                                ]),
                            width: 0,
                          ),
                          borderRadius: BorderRadius.circular(25)
                      ),

                      child:   SizedBox(
                        height: MediaQuery.of(context).size.height/18,
                        width: width/6,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                                    fontFamily: 'Sf-SemiBold',
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],),
                      ),),
                  ),

                  SizedBox(height: Responsive.isMobile(context) || Responsive.isTablet(context)?30:70,)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
