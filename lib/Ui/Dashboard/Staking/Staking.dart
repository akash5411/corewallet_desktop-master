import 'package:corewallet_desktop/Handlers/ApiHandle.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_address.dart';
import 'package:corewallet_desktop/LocalDb/Local_Token_provider.dart';
import 'package:corewallet_desktop/Models/AccountTokenModel.dart';
import 'package:corewallet_desktop/Models/AllCoinModel.dart';
import 'package:corewallet_desktop/Provider/StakingProvider.dart';
import 'package:corewallet_desktop/Provider/Token_Provider.dart';
import 'package:corewallet_desktop/Provider/Wallet_Provider.dart';
import 'package:corewallet_desktop/Values/Helper/helper.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:corewallet_desktop/Values/styleandborder.dart';
import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Staking_Page extends StatefulWidget {
  const Staking_Page({Key? key}) : super(key: key);

  @override
  State<Staking_Page> createState() => _Staking_PageState();
}

class _Staking_PageState extends State<Staking_Page> {
  
  late StakingProvider stakeProvider;
  late TokenProvider tokenProvider;
  late WalletProvider walletProvider;

  var width = 0.0,height = 0.0;

  bool toggleChange = true;

  ScrollController _scrollViewController =  ScrollController();
  int page = 1;

  @override
  void initState() {
    super.initState();
    stakeProvider = Provider.of<StakingProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    walletProvider = Provider.of<WalletProvider>(context, listen: false);


    page = 1;
    stakeProvider.loadStake = false;
    stakeProvider.stackList.clear();
    stakeProvider.stakeExpand = [];
    selectedAccount();

    _scrollViewController.addListener(() {
      if (_scrollViewController.position.userScrollDirection == ScrollDirection.reverse) {
        if (isLoaded == false) {

          if(stakeProvider.totalPage > page) {
            page = page + 1;
            getStakes();
          }
        }
      }
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

    setState(() {
      isLoaded = false;
      currency = sharedPreferences.getString("currency") ?? "USD";
      crySymbol = sharedPreferences.getString("crySymbol") ?? "\$";
      selectedAccountId = sharedPreferences.getString('accountId') ?? "";
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";
      selectedAccountAddress = sharedPreferences.getString('accountAddress') ?? "";
      selectedAccountPrivateAddress = sharedPreferences.getString('accountPrivateAddress') ?? "";
    });
    getStackInfo();
    getStakes();
    getTokenDetail();
  }

  bool _showRefresh = false;

  getStackInfo() async {
    await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId,2);
    selectedAccountAddress = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
    selectedAccountPrivateAddress = DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress;

    var data = {
      "address": "$selectedAccountAddress"
    };


    await stakeProvider.getStackInfo(data,"/stakerInfo");
    if(mounted) {
      setState(() {
        _showRefresh = false;
      });
    }
  }

  getStakes() async {

    setState(() {
      isLoaded = true;
    });

    await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId,2);
    selectedAccountAddress = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
    selectedAccountPrivateAddress = Helper.dialogCall.decryptAddressColumn(DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress);

    var data = {
      "address": "$selectedAccountAddress",
      "page": page
    };

    await stakeProvider.getStakes(data, "/getStakeList");

    if(mounted) {
      setState(() {
        _showRefresh = false;
        isLoaded = false;
      });
    }
    // getTokenDetail();
  }


  String allownceGasprice ="", allownceGaslimit ="", allownceFees ="";

  getestimateWithdraw(index) async {

    Helper.dialogCall.showAlertDialog(context,);

    var data = {
      "privateKey": "$selectedAccountPrivateAddress",
      "index": "$index"
    };

    await stakeProvider.estimateWithdraw(data, '/estimateWithdrawStake');
    Navigator.pop(context);

    if (stakeProvider.Withdrawbool = true) {
      allownceGasprice = "${stakeProvider.estimateWithdrawData['gasPrice']}";
      allownceGaslimit = "${stakeProvider.estimateWithdrawData['gasLimit']}";
      allownceFees = "${stakeProvider.estimateWithdrawData['fees']}";

      withdrawBottom(context, index);
    }
  }

  withdrawBottom(BuildContext context, index) {
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
                    width: width/3.3,
                    padding: const EdgeInsets.symmetric(horizontal: 15,),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        const Center(
                          child: Text(
                            "Confirm Withdraw",
                            style: TextStyle(
                              color:  AppColors.whiteColor,
                              fontSize: 20.0,
                              fontFamily: "Sf-SemiBold",
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        Row(
                          children: [

                            const Expanded(
                              child: Text(
                                //getTranslated(context, "gas_price"),
                                "Gas Price:",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 16.0,
                                  fontFamily: "Roboto-Medium",
                                ),
                              ),
                            ),

                            Text(
                              "$allownceGasprice wei",
                              style: const TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 14.0,
                                fontFamily: "Sf-Regular",
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [

                            const Expanded(
                              child: Text(
                                "Gas Limit :",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 16.0,
                                  fontFamily: "Sf-SemiBold",
                                ),
                              ),
                            ),

                            Text(
                              allownceGaslimit,
                              //"Upto 6% Returns on 30 Days",
                              style: const TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 16.0,
                                fontFamily: "Sf-Regular",
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [

                            const Expanded(
                              child: Text(
                                //getTranslated(context, "withdrawal_fees"),
                                "Approve Fees :",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 16.0,
                                  fontFamily: "Sf-SemiBold",
                                ),
                              ),
                            ),

                            Text(
                              "$allownceFees BNB",
                              //"Upto 6% Returns on 30 Days",
                              style: const TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 16.0,
                                fontFamily: "Sf-Regular",
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 40),

                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            confirmWithdraw(index);
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
                                  fontSize: 20.0,
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
        }).whenComplete(() {
      setState(() {

      });
    });
  }

  String harvestGasprice ="", harvestGaslimit ="", harvestFees ="";

  getEstimateHarvest(index) async {
    Helper.dialogCall.showAlertDialog(context);
    var data = {
      "privateKey": "$selectedAccountPrivateAddress",
      "index": "$index"
    };

    await stakeProvider.estimateHarvestWithdraw(data, '/estimateHarvestStake');
    if (stakeProvider.harvestWithdrawBool = true) {
      harvestGasprice = "${stakeProvider.estimateHarvestWithdrawData['gasPrice']}";
      harvestGaslimit = "${stakeProvider.estimateHarvestWithdrawData['gasLimit']}";
      harvestFees = "${stakeProvider.estimateHarvestWithdrawData['fees']}";
      Navigator.pop(context);
      harvestWithdrawBottom(context, index);
    }
  }

  getBNBTokenBalance(index) async {

    Helper.dialogCall.showAlertDialog(context);
    var data = {
      "address": selectedAccountAddress,
      "tokenAddress": "" ,
      "network_id": "2"
    };

    //print(data);

    await tokenProvider.getTokenBalance(data,'/getTokenBalance');
    var body = tokenProvider.tokenBalance;
    //print(body);
    if(body != null){
      if(double.parse(body['data']["balance"]) > double.parse(harvestFees)){
        confirmHarvestWithdraw(index);
      }else{
        Navigator.pop(context);
        Helper.dialogCall.showToast(context, "Insufficient gas balance");
      }
    }
  }

  harvestWithdrawBottom(BuildContext context, index) {
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
                    width: width/3.3,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        const Center(
                          child: Text(
                            "Confirm Harvest Withdraw",
                            style: TextStyle(
                              color: AppColors.whiteColor,
                              fontSize: 20.0,
                              fontFamily: "Sf-Regular",
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        Row(
                          children: [

                            const Expanded(
                              child: Text(
                                "Gas Price :",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 16.0,
                                  fontFamily: "Sf-SemiBold",
                                ),
                              ),
                            ),

                            Text(
                              "$harvestGasprice wei",
                              style: const TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 14.0,
                                fontFamily: "Sf-Regular",
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [

                            const Expanded(
                              child: Text(
                                //getTranslated(context, "gas_limit"),
                                "Gas Limit :",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 16.0,
                                  fontFamily: "Sf-SemiBold",
                                ),
                              ),
                            ),

                            Text(
                              harvestGaslimit,
                              //"Upto 6% Returns on 30 Days",
                              style: const TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 14.0,
                                fontFamily: "Sf-Regular",
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [

                            const Expanded(
                              child: Text(
                                "Approve Fees :",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 16.0,
                                  fontFamily: "Sf-SemiBold",
                                ),
                              ),
                            ),

                            Text(
                              "$harvestFees BNB",
                              //"Upto 6% Returns on 30 Days",
                              style: const TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 14.0,
                                fontFamily: "Sf-Regular",
                              ),
                            ),

                          ],
                        ),


                        SizedBox(height: 40),

                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            getBNBTokenBalance(index);
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
                                  fontSize: 20.0,
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
        }).whenComplete(() {
          setState(() {});
    });
  }

  confirmWithdraw(index) async {
    Helper.dialogCall.showAlertDialog(context);

    var data = {
      "privateKey": selectedAccountPrivateAddress,
      "index": "$index"
    };

    // print(data);
    await stakeProvider.WithdrawStakeToken(data, '/withdrawStake');

    Navigator.pop(context);

    if (stakeProvider.WithdrawBool == true) {
      Helper.dialogCall.showToast(context, "Stack withdrawn successfully");
      getStakes();
    }else{
      Helper.dialogCall.showToast(context, "Insufficient BNB Balance");

    }
  }

  confirmHarvestWithdraw(index) async {
    var data = {
      "privateKey": "$selectedAccountPrivateAddress",
      "index": "$index"
    };

    await stakeProvider.harvestStakeToken(data, '/harvestStake');
    Navigator.pop(context);
    if (stakeProvider.harvestStakeBool == true) {
      Helper.dialogCall.showToast(context, "Harvest withdrawn successfully");
      getStakes();
    }
  }

  Future<void> _getData() async {
    setState(() {
      page = 1;
      stakeProvider.stackList.clear();
      stakeProvider.stakeExpand = [];
      _showRefresh = true;
      getStakes();
    });
  }

  doNothing() {}

   AccountTokenList? accountTokenList;
  List <AccountTokenList> listequaltoempty=[];
  getTokenDetail() async {
    await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId,"","");
    if(mounted) {
      setState(() {
        // accountTokenList =
        //     DBTokenProvider.dbTokenProvider.tokenList.firstWhere((
        //         element) => "${element.token_id}" == "3");

        listequaltoempty=   DBTokenProvider.dbTokenProvider.tokenList.where((
            element) => "${element.token_id}" == "3").toList();

        if(listequaltoempty.isNotEmpty) {
          accountTokenList = listequaltoempty[0];


        }
      });


    }
  }

  @override
  Widget build(BuildContext context) {
    
    width=MediaQuery.of(context).size.width;
    height=MediaQuery.of(context).size.height;

    stakeProvider = Provider.of<StakingProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);
    walletProvider = Provider.of<WalletProvider>(context, listen: true);

    return Scaffold(
      body: DeclarativeRefreshIndicator(
        color: AppColors.blueColor,
        backgroundColor: AppColors.whiteColor,
        onRefresh: stakeProvider.isLoading == true ? doNothing : _getData,
        refreshing: _showRefresh,
        child: Padding(
          padding: const EdgeInsets.only(top: 10,right: 20,left: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // AppBar
              Row(
                children: [


                  const Expanded(child: SizedBox(width: 1,)),

                  const Padding(
                    padding: EdgeInsets.only(left: 190),
                    child: Text("Staking",style: TextStyle(color: AppColors.White,fontFamily: "Sf-SemiBold",fontSize: 20)),
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
                                  child: Text("Balance:",style:TextStyle(color:AppColors.greydark, fontSize: 12,    fontFamily: 'Sf-SemiBold',)),
                                ),
                                const SizedBox(width: 0,),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
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

              //  ui body
              Expanded(
                  child:stakeProvider.stackInfoLoading
                      ?
                  Center(child: Helper.dialogCall.showLoader())
                      :

                  Column(
                    children: [
                      // All Bidding Balance (CMCX) and All Bidding Stakes
                      Container(
                        padding: const EdgeInsets.only(top: 10,bottom: 10),
                        margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 40),
                        alignment: Alignment.center,
                        width: width/3,
                        decoration: BoxDecoration(
                            color: AppColors.ContainerblackColor,
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(child: SizedBox(width: 30,)),

                            // All Bidding Balance (CMCX)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("All Bidding Balance (CMCX)", style:TextStyle(color: AppColors.greyColor,fontFamily: "Sf-SemiBold",fontSize: 11),),
                                const SizedBox(height: 4,),
                                Text(
                                  stakeProvider.stakeInfoModel == null
                                      ?
                                  "--"
                                      :
                                  NumberFormat.decimalPattern("en").format(
                                      double.parse(
                                          ApiHandler.calculateLength(
                                              stakeProvider.stakeInfoModel!.biddingBalance.toString()
                                          )
                                      )
                                  ),
                                  style:const TextStyle(color: AppColors.White,fontFamily: "Sf-Regular",fontSize: 10),),
                                const SizedBox(height: 4,),

                              ],
                            ),
                            const Expanded(child: SizedBox(width: 30,)),

                            Container(
                              alignment: Alignment.center,
                              height: height*0.04,
                              width:width*0.0002,
                              color: AppColors.greyColor,

                            ),

                            const Expanded(child: SizedBox(width: 30,)),

                            // All Bidding Stakes
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children:  [
                                const Text(
                                  "All Bidding Stakes",
                                  style:TextStyle(
                                      color: AppColors.greyColor,
                                      fontFamily: "Sf-SemiBold",
                                      fontSize: 10
                                  ),
                                ),
                                const SizedBox(height: 4,),
                                Text(
                                  stakeProvider.stakeInfoModel == null
                                      ?
                                  "--"
                                      :
                                  stakeProvider.stakeInfoModel!.biddingStakers,
                                  style:const TextStyle(
                                      color: AppColors.White,
                                      fontFamily: "Sf-Regular",
                                      fontSize: 12
                                  ),
                                ),
                                const SizedBox(height: 4,),
                              ],
                            ),
                            const Expanded(child: SizedBox(width: 30,)),
                          ],
                        ),
                      ),

                      // Your Stake and balance
                      Column(
                        children: [
                          const Text(
                            "Your Stake (CMCX)",
                            style:TextStyle(
                                color: AppColors.greyColor,
                                fontFamily: "Sf-Medium",
                                fontSize: 12
                            ),
                          ),
                          const SizedBox(height: 4,),
                          Text(
                            stakeProvider.stakeInfoModel == null
                                ? "--"
                                :
                            ApiHandler.calculateLength(double.parse("${stakeProvider.stakeInfoModel!.currentStake}").toString()),
                            style:TextStyle
                              (color: AppColors.whiteColor,
                                fontFamily: "Sf-Medium",
                                fontSize: Responsive.isTablet(context) ? 20 :
                                Responsive.isMobile(context) ? 23 : 30
                            ),
                          ),
                          const SizedBox(height: 4,),
                          Text(accountTokenList == null ?
                            "Balance: 0.00":
                            "Balance: ${(stakeProvider.stakeInfoModel!.currentStake *  accountTokenList!.price).toStringAsFixed(2)}",
                            style:const TextStyle(
                                color: AppColors.greyColor,
                                fontFamily: "Sf-Medium",
                                fontSize: 12
                            ),
                          ),
                        ],
                      ),

                     SizedBox(height: height * 0.09 ),
                      // create stack button
                      InkWell(
                        onTap: (){
                          stakeProvider.changeListnerStack('CreateStake');


                        },
                        child: Container(
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
                                child: Row(
                                  children: [
                                    Image.asset("assets/images/bluedb.png",width: 20),
                                    const Text(
                                      "Create Stake",
                                      style: TextStyle(
                                        shadows: [

                                        ],
                                        fontFamily: 'Sf-SemiBold',
                                        fontSize: 13,

                                      ),

                                    ),
                                  ],
                                ),
                              ),),
                            ],
                          ),),
                      ),


                      const SizedBox(height: 20),

                      Expanded(
                        child: Container(

                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                              border: Border.all(color: AppColors.bordergrey),
                              shape: BoxShape.rectangle,
                              color: AppColors.bordergrey,
                              borderRadius: BorderRadius.circular(20)

                          ),
                          alignment: Alignment.topCenter,
                          width: MediaQuery.of(context).size.width,

                          child: Column(

                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [

                              // toggle button
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  //Information
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          toggleChange = true;
                                        });
                                      },
                                      child: Container(

                                        // height: 40,
                                        width: MediaQuery.of(context).size.width / 3,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              width: toggleChange == true ? 2 : 1,
                                              color: (toggleChange == true)
                                                  ? AppColors.darkblue
                                                  : AppColors.darklightgrey,
                                              //width: 3
                                            ),
                                          ),
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding:  const EdgeInsets.only(bottom: 10,top: 10),
                                            child: Text("Information",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: toggleChange == true
                                                        ? AppColors.darkblue
                                                        : AppColors.greyColor,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  //Your Stakes
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          toggleChange = false;
                                        });
                                      },
                                      child: Container(
                                        // height: 40,
                                        width:Responsive.isTablet(context)|| Responsive.isMobile(context)? MediaQuery.of(context).size.width/3.5:MediaQuery.of(context).size.width / 2.5,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                                width: toggleChange == false ? 2 : 1,
                                                color: (toggleChange == false)
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
                                            child: Text("Your Stakes",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: toggleChange == false
                                                        ? AppColors.darkblue
                                                        : AppColors.greyColor,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              toggleChange == true
                                  ?
                              // Information page
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  // balance total stack and unStack
                                  Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(right:20),
                                        child: SizedBox(
                                            width:width/3,
                                            //height: height,
                                            child:Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 20,top: 20),
                                                  child: Row(
                                                    children:  [
                                                      const Text(
                                                        "Your Balance",
                                                        style: TextStyle(
                                                          color: AppColors.greyColor,
                                                          fontFamily: 'Sf-SemiBold',
                                                          fontSize: 10,

                                                        ),),
                                                      const Expanded(child: SizedBox(width: 20,)),
                                                      Text(
                                                        stakeProvider.stakeInfoModel == null
                                                            ?
                                                        "-- CMCX"
                                                            :
                                                        stakeProvider.stakeInfoModel!.balance == 0
                                                            ?
                                                        "${stakeProvider.stakeInfoModel!.balance} CMCX"
                                                            :
                                                        "${ApiHandler.calculateLength(stakeProvider.stakeInfoModel!.balance.toString())} CMCX",
                                                        style: const TextStyle(
                                                          color: AppColors.white,
                                                          fontFamily: 'Sf-SemiBold',
                                                          fontSize: 10,

                                                        ),

                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 20,top: 20),
                                                  child: Row(
                                                    children:  [
                                                      const Text(
                                                        "Total Staked",
                                                        style: TextStyle(
                                                          color: AppColors.greyColor,
                                                          fontFamily: 'Sf-SemiBold',
                                                          fontSize: 10,

                                                        ),),
                                                      const Expanded(child: SizedBox(width: 20)),

                                                      Text(
                                                        stakeProvider.stakeInfoModel == null ? "-- CMCX":
                                                        "${stakeProvider.stakeInfoModel
                                                        !.totalStaked} CMCX",

                                                        style: const TextStyle(
                                                          color: AppColors.white,
                                                          fontFamily: 'Sf-SemiBold',
                                                          fontSize: 10,

                                                        ),

                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 20,top: 20),
                                                  child: Row(
                                                    children:  [
                                                      const Text(
                                                        "Total Unstacked",
                                                        style: TextStyle(
                                                          color: AppColors.greyColor,
                                                          fontFamily: 'Sf-SemiBold',
                                                          fontSize: 10,

                                                        ),),
                                                      const Expanded(child: SizedBox(width: 20,)),
                                                      Text(
                                                        stakeProvider.stakeInfoModel == null ? "-- CMCX":
                                                        "${stakeProvider.stakeInfoModel!.totalUnstaked }CMCX",
                                                        style:const TextStyle(
                                                          color: AppColors.white,
                                                          fontFamily: 'Sf-SemiBold',
                                                          fontSize: 10,

                                                        ),

                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                        ),
                                      )
                                  ),

                                  Center(
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 30,bottom: 10),
                                      alignment: Alignment.center,
                                      color: Colors.grey,
                                     height: height * 0.26,
                                      width: 0.3,
                                    ),
                                  ),

                                  // current stack earn and reward
                                  Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 20,right: 70),
                                        child: SizedBox(
                                            width:width/2,
                                            child:Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 20,top: 20),
                                                  child: Row(
                                                    children: [
                                                      const Text(
                                                        "Current Stake",
                                                        style: TextStyle(
                                                          color: AppColors.greyColor,
                                                          fontFamily: 'Sf-SemiBold',
                                                          fontSize: 10,

                                                        ),
                                                      ),
                                                      const Expanded(child: SizedBox(width: 20,)),
                                                      Text(
                                                        "${stakeProvider.stakeInfoModel == null
                                                            ? "--":
                                                        ApiHandler.calculateLength(double.parse("${stakeProvider.stakeInfoModel!.currentStake}").toString())
                                                        } CMCX",
                                                        style: const TextStyle(
                                                          color: AppColors.white,
                                                          fontFamily: 'Sf-SemiBold',
                                                          fontSize: 10,

                                                        ),

                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 20,top: 20),
                                                  child: Row(
                                                    children:  [
                                                      const Text(
                                                        "Earned",
                                                        style: TextStyle(
                                                          color: AppColors.greyColor,
                                                          fontFamily: 'Sf-SemiBold',
                                                          fontSize: 10,

                                                        ),
                                                      ),
                                                      const  Expanded(child: SizedBox(width: 20,)),
                                                      Text(
                                                        stakeProvider.stakeInfoModel == null
                                                            ?
                                                        "-- CMCX"
                                                            :
                                                        "${ApiHandler.calculateLength(stakeProvider.stakeInfoModel!.totalEarned.toString())} CMCX",
                                                        style: const TextStyle(
                                                          color: AppColors.white,
                                                          fontFamily: 'Sf-SemiBold',
                                                          fontSize: 10,

                                                        ),

                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 20,top: 20),
                                                  child: Row(
                                                    children:  [
                                                      const Text(
                                                        "Claimed Reward",
                                                        style: TextStyle(
                                                          color: AppColors.greyColor,
                                                          fontFamily: 'Sf-SemiBold',
                                                          fontSize: 10,

                                                        ),),
                                                      const Expanded(child: SizedBox(width: 20,)),
                                                      Text(
                                                        stakeProvider.stakeInfoModel == null ? "--":
                                                        "${ApiHandler.calculateLength(
                                                            double.parse(
                                                                "${stakeProvider.stakeInfoModel!.totalClaimed}"
                                                            ).toString()
                                                        )} CMCX",
                                                        style:const TextStyle(
                                                          color: AppColors.white,
                                                          fontFamily: 'Sf-SemiBold',
                                                          fontSize: 10,

                                                        ),

                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                        ),
                                      )
                                  ),

                                ],
                              )
                                  :
                              // stack list
                              SizedBox(
                                height: height - height * 0.65,
                                child: !stakeProvider.loadStake || _showRefresh
                                    ?
                                Helper.dialogCall.showLoader()
                                    :
                                stakeProvider.stackList.isEmpty
                                    ?
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/Exchange/error.svg",
                                        width: width * 0.2,
                                        height: height * 0.1,
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        "You have no stake record yet",
                                        style: TextStyle(
                                            color: AppColors.white.withOpacity(0.4),
                                            fontFamily: "Sf-Regular",
                                            fontSize: 13
                                        ),
                                      ),
                                      SizedBox(height: 20),

                                      InkWell(
                                        onTap: (){
                                          stakeProvider.changeListnerStack('CreateStake');


                                        },
                                        child: Container(
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
                                                child: Row(
                                                  children: const [
                                                   Icon(
                                                     Icons.add,
                                                     size: 25,
                                                   ),
                                                    Text(
                                                      "Add Stake",
                                                      style: TextStyle(
                                                        shadows: [

                                                        ],
                                                        fontFamily: 'Sf-SemiBold',
                                                        fontSize: 13,

                                                      ),

                                                    ),
                                                  ],
                                                ),
                                              ),),
                                            ],
                                          ),),
                                      ),
                                    ],
                                  ),
                                )
                                    :
                                Column(
                                  children: [
                                    Expanded(
                                      child: ListView.builder(
                                        controller: _scrollViewController,
                                        shrinkWrap: true,
                                        itemCount: stakeProvider.stackList.length,
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          var list = stakeProvider.stackList[index];

                                          var staketime = DateTime.fromMillisecondsSinceEpoch(int.parse(list.staketime) * 1000).toUtc();
                                          var unstaketime = DateTime.fromMillisecondsSinceEpoch(int.parse(list.unstaketime) * 1000).toUtc();

                                          return Padding(
                                            padding: const EdgeInsets.only(left:10,right:10,top: 10,bottom: 10),
                                            child: Container(
                                              alignment: Alignment.center,
                                              width: double.infinity,
                                              height:MediaQuery.of(context).size.height/12 ,
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: AppColors.darkblueContainer,width: 0),
                                                  color: AppColors.ContainergreyhomeColor,
                                                  borderRadius: BorderRadius.circular(15)
                                              ),
                                              child: Row(children: [

                                                const SizedBox(
                                                  width: 20,
                                                  height: 20
                                                ),

                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Amount", style:TextStyle(
                                                        color: AppColors.greyColor,
                                                        fontFamily: "Sf-Regular",
                                                        fontSize:Responsive.isMobile(context)?11:  11),),
                                                    Text(
                                                      "${list.amount}",
                                                      style:TextStyle(
                                                          color: AppColors.white,
                                                          fontFamily: "Sf-Regular",
                                                          fontSize: Responsive.isMobile(context)?10: 11),
                                                    ),

                                                  ],
                                                ),
                                                const Spacer(),

                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text("Stake Date", style:TextStyle(color: AppColors.greyColor,fontFamily: "Sf-Regular",fontSize: 11),),
                                                    Row(
                                                      children:  [
                                                        Text(
                                                          DateFormat("dd.MM.yyyy").format(staketime),
                                                          style:const TextStyle(
                                                              color: AppColors.white,
                                                              fontFamily: "Sf-Regular",
                                                              fontSize: 12
                                                          ),
                                                        ),
                                                        const SizedBox(width: 2),

                                                        Text(
                                                          DateFormat("hh:mm aa").format(staketime),
                                                          style:const TextStyle(
                                                              color: AppColors.greyColor,
                                                              fontFamily: "Sf-Regular",
                                                              fontSize: 9
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                  ],
                                                ),
                                                const Spacer(),

                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "UnStake Date",
                                                      style:TextStyle(
                                                          color: AppColors.greyColor,
                                                          fontFamily: "Sf-Regular",
                                                          fontSize: 11
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          DateFormat("dd.MM.yyyy").format(unstaketime),
                                                          style:const TextStyle(
                                                              color: AppColors.white,
                                                              fontFamily: "Sf-Regular",
                                                              fontSize: 12
                                                          ),
                                                        ),
                                                        const SizedBox(width: 2),
                                                        Text(
                                                          DateFormat("hh:mm aa").format(unstaketime),
                                                          style:const TextStyle(
                                                              color: AppColors.greyColor,
                                                              fontFamily: "Sf-Regular",
                                                              fontSize: 9
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                  ],
                                                ),
                                                const Spacer(),

                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Harvest ",
                                                      style:TextStyle(
                                                          color: AppColors.greyColor,
                                                          fontFamily: "Sf-Regular",
                                                          fontSize: 11
                                                      ),
                                                    ),

                                                    Text(
                                                      ApiHandler.calculateLength(list.realtimeRewardPerBlock.toString()),
                                                      style:const TextStyle(
                                                          color: AppColors.whiteEF,
                                                          fontFamily: "Sf-Regular",
                                                          fontSize: 12
                                                      ),
                                                    ),








                                                  ],
                                                ),
                                                const Expanded(
                                                  child : SizedBox(width: 10)
                                                ),

                                                list.unstaked == 1
                                                    ?
                                                SizedBox()
                                                    :
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        if (DateTime.now().isAfter(unstaketime.toUtc())) {
                                                          getestimateWithdraw(list.indexId);
                                                        }
                                                      },
                                                      child: Container(
                                                        alignment: Alignment.center,
                                                        height: MediaQuery.of(context).size.height/20,
                                                        width: width/13,
                                                        decoration: BoxDecoration(
                                                            color:AppColors.greyColor,
                                                            borderRadius: BorderRadius.circular(25)

                                                        ),
                                                        child: const Center(
                                                          child: Text(
                                                            "Unstack",
                                                            style: TextStyle(
                                                              color: AppColors.white,
                                                              fontFamily: 'Sf-SemiBold',
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    const SizedBox(width: 10),

                                                    InkWell(
                                                      onTap: () {
                                                        getEstimateHarvest(list.indexId);
                                                      },
                                                      child: Container(
                                                        height: MediaQuery.of(context).size.height/20,
                                                        alignment: Alignment.center,
                                                        width: width/13,
                                                        decoration: BoxDecoration(
                                                            color: AppColors.blueColor,
                                                            borderRadius: BorderRadius.circular(25)
                                                        ),

                                                        child: const Center(
                                                          child: Text(
                                                            "Harvest",
                                                            style: TextStyle(
                                                              color: AppColors.white,
                                                              fontFamily: 'Sf-SemiBold',
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 20),




                                              ],),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    SizedBox(height: 10),

                                    toggleChange == true
                                        ?
                                    const SizedBox()
                                        :
                                    stakeProvider.isLoading && !_showRefresh
                                        ?
                                    Helper.dialogCall.showLoader()
                                        :
                                    const SizedBox(),
                                  ],
                                ),

                              ),




                            ],
                          ),

                        ),
                      ),
                    ],
                  )
              )

            ],
          ),
        ),
      ),
    );
  }
}
