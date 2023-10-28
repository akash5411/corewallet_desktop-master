
import 'package:corewallet_desktop/LocalDb/Local_Account_address.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_provider.dart';
import 'package:corewallet_desktop/LocalDb/Local_Token_provider.dart';
import 'package:corewallet_desktop/Models/AccountTokenModel.dart';
import 'package:corewallet_desktop/Models/NetworkModel.dart';
import 'package:corewallet_desktop/Provider/StakingProvider.dart';
import 'package:corewallet_desktop/Provider/Token_Provider.dart';
import 'package:corewallet_desktop/Provider/Wallet_Provider.dart';
import 'package:corewallet_desktop/Values/Helper/helper.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:corewallet_desktop/Values/styleandborder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hovering/hovering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Exchange/Exchange.dart';

class CreateStake extends StatefulWidget {
  const CreateStake({Key? key}) : super(key: key);

  @override
  State<CreateStake> createState() => _CreateStakeState();
}

class _CreateStakeState extends State<CreateStake> {

  late StakingProvider stakeProvider;
  late WalletProvider walletProvider;
  late TokenProvider tokenProvider;

  TextEditingController amountController = TextEditingController();
  String selected = "30",sendValue = "0",selectedPr = "15";


  @override
  void initState() {
    super.initState();
    stakeProvider = Provider.of<StakingProvider>(context, listen: false);
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
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

    setState(() {
      isLoaded = false;
      currency = sharedPreferences.getString("currency") ?? "USD";
      crySymbol = sharedPreferences.getString("crySymbol") ?? "\$";
      selectedAccountId = sharedPreferences.getString('accountId') ?? "";
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";

      //print("$selectedAccountName");

    });

    getAllowance();
    getTokenPrice();

  }


  String allownceGasprice = "",allownceGaslimit = "",allownceFees = "";

  allowenceBottom(BuildContext context) {

    showDialog(
        context:context,
        barrierColor: Colors.transparent,
        builder: (context) {
          return AlertDialog(
            actionsPadding: EdgeInsets.zero,
            backgroundColor: AppColors.darklightgrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {

                  return Container(
                    width: width/3.3,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        const Center(
                          child: Text(
                            "Enable CMCX Staking",
                            style: TextStyle(
                              color:  AppColors.whiteColor,
                              fontSize: 16.0,
                              fontFamily: "Sf-SemiBold",
                            ),
                          ),
                        ),

                        SizedBox(height: 40),

                        Row(
                          children: [

                            const Expanded(
                              child: Text(
                                //getTranslated(context, "gas_price"),
                                "Gas Price:",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 14.0,
                                  fontFamily: "Roboto-Medium",
                                ),
                              ),
                            ),

                            Text(
                              "$allownceGasprice wei",
                              //"Upto 6% Returns on 30 Days",
                              style: const TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 12.0,
                                fontFamily: "Sf-Regular",
                              ),
                            ),

                          ],
                        ),

                        SizedBox(height: 15),

                        Row(
                          children: [

                            const Expanded(
                              child: Text(
                                "Gas Limit :",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 14.0,
                                  fontFamily: "Sf-SemiBold",
                                ),
                              ),
                            ),

                            Text(
                              "$allownceGaslimit",
                              //"Upto 6% Returns on 30 Days",
                              style: const TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 12.0,
                                fontFamily: "Sf-Regular",
                              ),
                            ),

                          ],
                        ),

                        SizedBox(height: 15),

                        Row(
                          children: [

                            const Expanded(
                              child: Text(
                                //getTranslated(context, "withdrawal_fees"),
                                "Approve Fees :",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 14.0,
                                  fontFamily: "Sf-SemiBold",
                                ),
                              ),
                            ),

                            Text(
                              "$allownceFees BNB",
                              //"Upto 6% Returns on 30 Days",
                              style: const TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 12.0,
                                fontFamily: "Sf-Regular",
                              ),
                            ),

                          ],
                        ),

                        SizedBox(height: 40),

                        InkWell(
                          onTap: (){
                            Navigator.pop(context);
                            getBNBTokenBalance();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: AppColors.buttonGradient2,
                                borderRadius: BorderRadius.circular(6),
                                color: AppColors.blueColor
                            ),
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            child: const Center(
                              child: Text(
                                "Confirm",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 16.0,
                                  fontFamily: "Sf-Regular",
                                ),
                              ),
                            ),
                          ),
                        )

                      ],
                    ),
                  );
                }
            ),
          );
        }
    ).whenComplete(() {

      setState(() {
        isLoaded = false;
      });

    });
  }

  getAllowance() async {

    await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId,2);
    selectedAccountAddress = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
    selectedAccountPrivateAddress = Helper.dialogCall.decryptAddressColumn(DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress);

    // print("allowance");
    setState(() {
      isLoaded = true;
    });

    var data = {
      "privateKey": "$selectedAccountPrivateAddress",
      "amount":"1"
    };

    await stakeProvider.getAllowance(data, '/checkAllowence');

    setState(() {
      isLoaded = false;
    });


  }

  getCMCXTokenBalance() async {

    setState((){
      isLoaded = true;
    });

    var data = {
      "address": "$selectedAccountAddress",
      "tokenAddress": "0xb2343143f814639c9b1f42961c698247171df34a" ,
      "network_id": "2"
    };

    //print(data);

    await tokenProvider.getTokenBalance(data,'/getTokenBalance');
    var body = tokenProvider.tokenBalance;
    //print(body);
    if(double.parse(body['data']["balance"]) > 1 && double.parse(body['data']["balance"]) > double.parse(amountController.text)){
      stakeEstimate();
    }else{
      Helper.dialogCall.showToast(context, "Insufficient CMCX balance please deposit some");

      setState((){
        isLoaded = false;
      });
    }

  }

  getBNBTokenBalance() async {

    setState((){
      isLoaded = true;
    });

    var data = {
      "address": "$selectedAccountAddress",
      "tokenAddress": "" ,
      "network_id": "2"
    };

    //print(data);

    await tokenProvider.getTokenBalance(data,'/getTokenBalance');
    var body = tokenProvider.tokenBalance;
    //print(body);
    if(body != null){
      if(double.parse(body['data']["balance"]) > double.parse(allownceFees)){
        confirmAllowence();
      }else{
        Helper.dialogCall.showToast(context, "Insufficient gas balance");

        setState((){
          isLoaded = false;
        });
      }
    }

  }

  getEstimateApproveFees() async {

    setState(() {
      isLoaded = true;
    });

    var data = {
      "privateKey": "$selectedAccountPrivateAddress",
    };

    await stakeProvider.estimateApproveFees(data, '/estimateApproveFees');

    if(stakeProvider.isEstimateApproveFees){
      allownceGasprice = stakeProvider.estimateApproveFeesData["gasPrice"];
      allownceGaslimit = stakeProvider.estimateApproveFeesData["gasLimit"];
      allownceFees = "${stakeProvider.estimateApproveFeesData["approveFees"]}";
      allowenceBottom(context);
    }else{
      setState((){
        isLoaded = false;
      });
    }

  }

  confirmAllowence()async{
    setState(() {
      isLoaded = true;
    });

    var data = {
      "privateKey": "$selectedAccountPrivateAddress",
    };

    await stakeProvider.approveToken(data, '/approveToken');

    if(stakeProvider.approveTokenSuccess){
      getAllowance();
    }
    else{
      getAllowance();
    }
    setState((){
      isLoaded = false;
    });
  }

  stakeEstimateBottom(BuildContext context) {

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actionsPadding: EdgeInsets.zero,
            backgroundColor: AppColors.darklightgrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {

                  return Container(
                    width: width/3.8,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        const Center(
                          child: Text(
                            "CMCX Staking",
                            style: TextStyle(
                              color: AppColors.whiteColor,
                              fontSize: 16.0,
                              fontFamily: "Sf-Regular",
                            ),
                          ),
                        ),

                        SizedBox(height: 40),

                        Row(
                          children: [

                            const Expanded(
                              child: Text(
                                "Gas Price :",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 14.0,
                                  fontFamily: "Sf-SemiBold",
                                ),
                              ),
                            ),
                            Text(
                              "$stakeGasprice wei",
                              style: const TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 12.0,
                                fontFamily: "Sf-Regular",
                              ),
                            ),

                          ],
                        ),

                        SizedBox(height: 15),

                        Row(
                          children: [

                            const Expanded(
                              child: Text(
                                "Gas Limit :",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 14.0,
                                  fontFamily: "Sf-SemiBold",
                                ),
                              ),
                            ),

                            Text(
                              "$stakeGaslimit",
                              style: const TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 12.0,
                                fontFamily: "Sf-Regular",
                              ),
                            ),

                          ],
                        ),

                        SizedBox(height: 15),

                        Row(
                          children: [

                            const Expanded(
                              child: Text(
                                "Approve Fees :",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 14.0,
                                  fontFamily: "Sf-SemiBold",
                                ),
                              ),
                            ),

                            Text(
                              "$stakeFees BNB",
                              style: const TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 12.0,
                                fontFamily: "Sf-Regular",
                              ),
                            ),

                          ],
                        ),

                        SizedBox(height: 40),

                        isLoaded
                            ?
                        Helper.dialogCall.showLoader()
                            :
                        InkWell(
                          onTap: (){
                            // Navigator.pop(context);
                            setState(() {
                              isLoaded = true;
                            });
                            createStake();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.buttonGradient2,
                                borderRadius: BorderRadius.circular(6),
                            ),
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            child: const Center(
                              child: Text(
                                "Confirm",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 16.0,
                                  fontFamily: "Roboto-Regular",
                                ),
                              ),
                            ),
                          ),
                        )

                      ],
                    ),
                  );
                }
            ),
          );
        }).whenComplete(() {
      setState(() {
        isLoaded = false;
      });
    });
  }


  String stakeGasprice = "",stakeGaslimit = "",stakeFees = "";

  stakeEstimate() async {
    setState(() {
      isLoaded = true;
    });

    var data = {
      "privateKey" : "$selectedAccountPrivateAddress",
      "amount" : "${amountController.text}",
      "timeperiod" : "$sendValue"
    };

    await stakeProvider.estimateStakeMethod(data,'/estimateCreateStake');
    //print(stakeProvider.stakeestimate);

    if(stakeProvider.estimateStake == true){

      setState(() {
        stakeGasprice = "${stakeProvider.stakeestimate['gasPrice']}";
        stakeGaslimit = "${stakeProvider.stakeestimate['gasLimit']}";
        stakeFees = "${stakeProvider.stakeestimate['fees']}";
        isLoaded = false;
        stakeEstimateBottom(context);
      });

    }else{

      Helper.dialogCall.showToast(context, "Insufficient gas balance");
      setState((){
        isLoaded = false;
      });
    }
  }

  createStake()async{

    setState(() {
      isLoaded = true;
    });

    var data = {
      "privateKey": "$selectedAccountPrivateAddress",
      "amount": "${amountController.text}",
      "timeperiod":"$sendValue",
    };

    await stakeProvider.createStake(data, '/createStake');

    if(stakeProvider.createStakeSuccess){

      Helper.dialogCall.showToast(context, "Stake Created successfully. It will take a few seconds please refresh the page");

      stakeProvider.changeListnerStack('Staking');
      Navigator.pop(context,'Refresh');


    }
    else{
      Navigator.pop(context,'Refresh');
      Helper.dialogCall.showToast(context, "Stake creation error!! Please try again.");

    }

    setState(() {
      isLoaded = false;
    });
  }

  var sendTokenBalance = "0";
  AccountTokenList? accountTokenList;

  getTokenPrice() async {
    await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId,"","");
    setState(() {
      accountTokenList = DBTokenProvider.dbTokenProvider.tokenList.where((element) => "${element.token_id}" == "3").first;
      print(accountTokenList!.toJson());
    });
  }





  var width,height;

  @override
  Widget build(BuildContext context) {

    width=MediaQuery.of(context).size.width;
    height=MediaQuery.of(context).size.height;

    stakeProvider = Provider.of<StakingProvider>(context, listen: true);
    walletProvider = Provider.of<WalletProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);


    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 10,right: 20,left: 20),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                      stakeProvider.changeListnerStack('Staking');
                    },
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: Boxdec.BackButtonGradient,
                        child: Center(
                          child:Image.asset(
                              "assets/icons/backarrow.png",
                              height: 24
                          ),
                        )
                    ),
                  ),

                  const Expanded(child: SizedBox(width: 1,)),

                  const Padding(
                    padding: EdgeInsets.only(left: 140),
                    child: Text(
                        "Create Stake",
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
                                        fontSize: 16  ,
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

              // bnb validator
              //secondrow
              Container(
                padding: EdgeInsets.only(top: 10,bottom: 10),
                margin: EdgeInsets.symmetric(horizontal: 20,vertical: 40),
                alignment: Alignment.center,
                width: Responsive.isDesktop(context)? width * 0.28 :Responsive.isTablet(context)? width * 0.4 : width * 0.42,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,

                      end: Alignment.bottomLeft,
                      // tileMode: TileMode.,
                      colors: [

                        // AppColors.darkblueContainer.withOpacity(0.2),


                        // AppColors.darkblueContainer.withOpacity(0.9),
                        // AppColors.darkblueContainer,
                        AppColors.darkblueContainer.withOpacity(0.1),

                        AppColors.darkblueContainer,
                        // AppColors.darkblueContainer,



                      ],
                    ),
                    color: AppColors.ContainerblackColor,borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 20),
                    Container(
                      decoration:Boxdec.Containercoinshadow,
                      height:50,
                      width: 50,
                      padding: const EdgeInsets.all(10),
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
                        child: SvgPicture.asset(
                            'assets/icons/wallet/Vector.svg',
                            width: 22
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                            "Validator",
                          style:TextStyle(
                              color: AppColors.greyColor,
                              fontFamily: "Sf-SemiBold",
                              fontSize: 11
                          ),
                        ),
                        const SizedBox(height: 4,),
                        Row(
                          children: const [
                            Text(
                              "CORE MultiChain",
                              style:TextStyle(
                                  color: AppColors.White,
                                  fontFamily: "Sf-SemiBold",
                                  fontSize: 13
                              ),
                            ),
                            Text(
                              " CMCX",
                              style:TextStyle(
                                  color: AppColors.greyColor,
                                  fontFamily: "Sf-Regular",
                                  fontSize: 10
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4,),

                      ],
                    ),
                    Expanded(child: SizedBox(width: 30,)),

                    Row(
                      children:  [
                        const Text(
                          "APR",
                          style:TextStyle(
                              color: AppColors.greyColor,
                              fontFamily: "Sf-Regular",
                              fontSize: 10
                          ),
                        ),
                        Text(
                          " $selectedPr%",
                          style:const TextStyle(
                              color: AppColors.greenColor,
                              fontFamily: "Sf-Regular",
                              fontSize: 10
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width:20),

                 
                  ],
                ),
              ),


              // date selection
              const SizedBox(height: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Padding(
                    padding: EdgeInsets.only(left:10,right:0,bottom:5),
                    child: Text(
                      "Choose The Number of Days",
                      style: TextStyle(
                        color: AppColors.white,
                        fontFamily: 'Sf-SemiBold',
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),

                  Row(

                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: (){
                          setState(() {
                            selected = "30";
                            sendValue = "0";
                            selectedPr = "15";
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height/22,
                          width: Responsive.isDesktop(context) ? width * 0.07 : width * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.bordergrey  ,
                                 width: 2,
                                // style: BorderStyle.solid
                            ),

                              color: selected == "30" ?
                              AppColors.blueColor2
                                  :
                              AppColors.containerbackgroundgrey,
                              borderRadius: BorderRadius.circular(25),

                          ),


                          // duration: Duration(milliseconds: 200),
                          child: const Center(
                            child: Text(
                              "30D",
                              style: TextStyle(
                                color: AppColors.white,
                                fontFamily: 'Sf-SemiBold',
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width:4),

                      InkWell(
                        onTap: (){
                          setState(() {
                            selected = "60";
                            sendValue = "1";
                            selectedPr = "22.5";
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height/22,
                          width: Responsive.isDesktop(context) ? width * 0.07 : width * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.bordergrey  ,
                              width: 2,
                              // style: BorderStyle.solid
                            ),

                            color: selected == "60" ?
                            AppColors.blueColor2
                                :
                            AppColors.containerbackgroundgrey,
                            borderRadius: BorderRadius.circular(25),

                          ),


                          // duration: Duration(milliseconds: 200),
                          child: const Center(child: Text(
                            "60D",
                            style: TextStyle(
                              color: AppColors.white,
                              fontFamily: 'Sf-SemiBold',
                              fontSize: 13,
                            ),

                          ),),),
                      ),
                      const SizedBox(width:4),

                      InkWell(
                        onTap: (){
                          setState(() {
                            selected = "90";
                            sendValue = "2";
                            selectedPr = "29";
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height/22,
                          width: Responsive.isDesktop(context) ? width * 0.07 : width * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.bordergrey  ,
                              width: 2,
                              // style: BorderStyle.solid
                            ),

                            color: selected == "90"
                                ?
                            AppColors.blueColor2
                                :
                            AppColors.containerbackgroundgrey,
                            borderRadius: BorderRadius.circular(25),

                          ),


                          // duration: Duration(milliseconds: 200),
                          child:
                          const Center(child: Text(
                            "90D",
                            style: TextStyle(
                              color: AppColors.white,
                              fontFamily: 'Sf-SemiBold',
                              fontSize: 13,
                            ),

                          ),),),
                      ),
                      const SizedBox(width:4),

                      InkWell(
                        onTap: (){
                          setState(() {
                            selected = "180";
                            sendValue = "3";
                            selectedPr = "36.3";
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height/22,
                          width: Responsive.isDesktop(context) ? width * 0.07 : width * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.bordergrey  ,
                              width: 2,
                              // style: BorderStyle.solid
                            ),

                            color: selected == "180"
                                ?
                            AppColors.blueColor2
                                :
                            AppColors.containerbackgroundgrey,
                            borderRadius: BorderRadius.circular(25),

                          ),


                          // duration: Duration(milliseconds: 200),
                          child:
                          const Center(child: Text(
                            "180D",
                            style: TextStyle(
                              color: AppColors.white,
                              fontFamily: 'Sf-SemiBold',
                              fontSize: 13,
                            ),

                          ),),),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  Padding(
                    padding: const EdgeInsets.only(left: 20,right:0,top: 5),
                    child: Text(
                      "$selectedPr% APY On $selected Days. Locked Until ${DateFormat("dd/MM/yyyy hh:mm aa").format(DateTime.now().add(Duration(days: int.parse(selected))))}",
                      style: const TextStyle(
                        color: AppColors.greyColor,
                        fontFamily: 'Sf-Regular',
                        fontSize: 12,

                      ),

                    ),
                  ),

                ],
              ),

              // SizedBox(height: 20,),


              SizedBox(height: height/15,),

              const Text(
                  "Enter Amount",
                  style: TextStyle(
                      color: AppColors.White,
                      fontFamily: "Sf-SemiBold",
                      fontSize: 15
                  )
              ),

              Padding(
                padding: const EdgeInsets.only(left: 150),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IntrinsicWidth(
                      child: TextField(
                        controller: amountController,
                        cursorColor:AppColors.whiteColor,
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          setState(() {});
                        },
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                        ],
                        style: const TextStyle(
                            color: AppColors.White,
                            fontFamily: "Sf-Regular",
                            fontSize: 25
                        ),
                        decoration: const InputDecoration(
                            border: InputBorder.none,

                            hintText: "0.00",
                            hintStyle: TextStyle(color: AppColors.greyColor2,fontFamily: "Sf-Regular",fontSize: 30),
                            labelStyle: TextStyle(
                                color: Colors.grey
                            )
                        ),

                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: 150,
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              amountController.text = "${double.parse(sendTokenBalance).round()}";
                            });
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
                                fontSize: 20,

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
                  "$crySymbol ${(double.parse(amountController.text.isEmpty ? "0.00" : amountController.text) * (accountTokenList == null ? 0.0:accountTokenList!.price)).toStringAsFixed(2)}",
                  style: const TextStyle(
                      color: AppColors.greyColor,
                      fontFamily: "Sf-SemiBold",
                      fontSize: 15
                  )
              ),
              SizedBox(height: height/19,),

              // submit and enable button
              isLoaded
                  ?
              Helper.dialogCall.showLoader()
                  :
              stakeProvider.allowanceData != true
                  ?
              InkWell(
                onTap: (){
                  if(amountController.text.isNotEmpty){
                    if(double.parse(amountController.text) >= 1){

                      if(double.parse(accountTokenList!.balance) >= 1 || double.parse(amountController.text) > double.parse(accountTokenList!.balance) ){
                        FocusScope.of(context).unfocus();
                        getEstimateApproveFees();
                      }else{
                        print("1");

                        Helper.dialogCall.showToast(context, "Insufficient CMCX balance");
                      }
                    }else{
                      print("2");

                      Helper.dialogCall.showToast(context, "Minimum Stack Amount is 1.");
                    }
                  }else{
                    print("3");
                    Helper.dialogCall.showToast(context, "Please Enter Stack Amount");
                  }
                },
                child: Container(
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

                  child:   Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const SizedBox(width: 4,),
                      Center(
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (Rect bounds) {
                            return AppColors.buttonGradient.createShader(

                                Offset.zero & bounds.size);
                          },
                          child: Row(
                            children: const [
                              Text(
                                "Enable",
                                style: TextStyle(
                                  fontFamily: 'Sf-SemiBold',
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  :
              InkWell(
                onTap: (){


                  if(amountController.text.isNotEmpty || double.parse(amountController.text.isEmpty  ? "0" : amountController.text) > 1) {
                    print(amountController.text);

                    FocusScope.of(context).unfocus();
                    getCMCXTokenBalance();
                  }else{
                    Helper.dialogCall.showToast(context, "Please Enter Amount");
                  }
                },
                child: Container(
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

                  child:   Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const SizedBox(width: 4,),
                      Center(
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (Rect bounds) {
                            return AppColors.buttonGradient.createShader(Offset.zero & bounds.size);
                          },
                          child: Row(
                            children: const [
                              Text(
                                "Stack",
                                style: TextStyle(
                                  fontFamily: 'Sf-SemiBold',
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height/17,),

              // divider
              Container(
                width: width/1,
                height: 1,
                color: AppColors.greyColor2,

              ),
              SizedBox(height: height/28,),


              Container(
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("This is a two step process:",style: TextStyle(color: AppColors.White,fontFamily: "Sf-SemiBold",fontSize: 13)),
                    SizedBox(height: 5,),
                    Text("1. You need to approve the funds to stake",style: TextStyle(color: AppColors.greyColor,fontFamily: "Sf-Regular",fontSize: 12)),
                    Text("2. Later you will be asked to confirm the deposit. Once both transactions are signed you will see your stake.",style: TextStyle(color: AppColors.greyColor,fontFamily: "Sf-Regular",fontSize: 12)),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
