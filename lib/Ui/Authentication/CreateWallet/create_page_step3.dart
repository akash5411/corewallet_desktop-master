import 'package:corewallet_desktop/Custom_DashboardMenu/MainScreenPage.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_address.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_provider.dart';
import 'package:corewallet_desktop/LocalDb/Local_Token_provider.dart';
import 'package:corewallet_desktop/Provider/Account_Provider.dart';
import 'package:corewallet_desktop/Provider/Token_Provider.dart';
import 'package:corewallet_desktop/Provider/Wallet_Provider.dart';
import 'package:corewallet_desktop/Provider/uiProvider.dart';
import 'package:corewallet_desktop/Values/Helper/helper.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:corewallet_desktop/Values/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CreateWalletStep3 extends StatefulWidget {
  var seedPhase;
  bool isNew;
  CreateWalletStep3({Key? key,required this.isNew,required this.seedPhase}) : super(key: key);

  @override
  State<CreateWalletStep3> createState() => _CreateWalletStep3State();
}

class _CreateWalletStep3State extends State<CreateWalletStep3> {

  late String firstId,secondId,thardId;
  String firstSeed = "",secondSeed = "", thardSeed = "";

  late String firstSelectId,secondSelectId, thardSelectId;


  //new code
  List seedList = [];
  List newSeedList = [];
  List<String> mySelectList = [];


  late List newList;

  late AccountProvider accountProvider;
  late TokenProvider tokenProvider;
  late UiProvider uiProvider;
  late WalletProvider walletProvider;

  String deviceId = "";
  bool isLoading =  false;


  getAccount() async {
    setState(() {
      isLoading = true;
    });


    for(int i=0; i<accountProvider.accountData.length; i++){

      for(int j=0; j<tokenProvider.networkList.length; j++){


        var networkPrivateKey = Helper.dialogCall.encryptAddressColumn(accountProvider.accountData[i][tokenProvider.networkList[j].privateKeyName]);

        await DbAccountAddress.dbAccountAddress.createAccountAddress(
            accountProvider.accountData[i]["id"],
            accountProvider.accountData[i][tokenProvider.networkList[j].publicKeyName],
            networkPrivateKey,
            tokenProvider.networkList[j].publicKeyName,
            tokenProvider.networkList[j].privateKeyName,
            tokenProvider.networkList[j].id,
            tokenProvider.networkList[j].name
        );

      }

      var mnemonic = Helper.dialogCall.encryptAddressColumn(accountProvider.accountData[i]["mnemonic"]);

      await DBAccountProvider.dbAccountProvider.createAccount(
          "${accountProvider.accountData[i]["id"]}",
          accountProvider.accountData[i]["device_id"],
          accountProvider.accountData[i]["name"],
          mnemonic
      );


    }

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('accountId', "${accountProvider.accountData[0]["id"]}");
    sharedPreferences.setString('accountName', accountProvider.accountData[0]["name"]);


    await DBAccountProvider.dbAccountProvider.getAllAccount();

    if(widget.isNew){
      getTokenForOld("${accountProvider.accountData[0]["id"]}");
    }else {
      getToken();
    }
  }

  var currency = "";
  getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    currency = sharedPreferences.getString("currency") ?? "USD";
    await DBTokenProvider.dbTokenProvider.deleteAllToken();

    for (int i = 0; i < DBAccountProvider.dbAccountProvider.newAccountList.length; i++) {

      await DbAccountAddress.dbAccountAddress.getAccountAddress(DBAccountProvider.dbAccountProvider.newAccountList[i].id);
      var data = {};

      for (int j = 0; j < DbAccountAddress.dbAccountAddress.allAccountAddress.length; j++) {
        data[DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicKeyName] = DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicAddress;
      }

      data["convert"] = currency;

      await tokenProvider.getAccountToken(data, '/getAccountTokens', DBAccountProvider.dbAccountProvider.newAccountList[i].id);

    }

    if(tokenProvider.isSuccess){
      uiProvider.DashBoardpage("Wallet");
      walletProvider.changeListnerWallet("Wallet");
      setState(() {
        Utils.pageName="Dashboard";
      });

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainDashboardUiScreen(),
          ),
              (route) => false
      );
    }


    setState(() {
      isLoading = false;
    });
  }

  getTokenForOld(String accountId) async {
    await DbAccountAddress.dbAccountAddress.getAccountAddress(accountId);

    var data = {};

    for (int j = 0; j < DbAccountAddress.dbAccountAddress.allAccountAddress.length; j++) {
      data[DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicKeyName] = DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicAddress;
    }
    await tokenProvider.getAccountToken(data, '/getAccountTokens', accountId);
    if(tokenProvider.isSuccess) {

      uiProvider.DashBoardpage("Wallet");
      walletProvider.changeListnerWallet("Wallet");
      setState(() {
        Utils.pageName="Dashboard";
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MainDashboardUiScreen(),
        ),
            (route) => false,
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // print(widget.seedPhase.length.toString());
    // print(widget.seedPhase.length);
    accountProvider = Provider.of<AccountProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    uiProvider = Provider.of<UiProvider>(context, listen: false);
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    // print("seedphase on initistate ${widget.seedPhase}");
//old
  /*  firstId = "${widget.seedPhase[0]['id']}";
    secondId = "${widget.seedPhase[2]['id']}";
    thardId = "${widget.seedPhase[4]['id']}";

    newList = widget.seedPhase..shuffle();*/
//new

    List seedData = [];
    seedData.addAll(widget.seedPhase);


    List shuffleList = [];
    shuffleList.addAll(seedData..shuffle());

    seedList.addAll(shuffleList);

    newSeedList.addAll(widget.seedPhase);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    accountProvider = Provider.of<AccountProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);
    uiProvider = Provider.of<UiProvider>(context, listen: false);
    walletProvider = Provider.of<WalletProvider>(context, listen: false);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      bottomNavigationBar: isLoading
          ?
      IntrinsicHeight(
        child: Helper.dialogCall.showLoader(),
      )
          :
      IntrinsicHeight(
        child: InkWell(
          onTap: () async {

            //old
       /*     if(firstId == firstSelectId && secondId == secondSelectId && thardId == thardSelectId){
              SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
              sharedPreferences.setString('isLogin', 'true');
              getAccount();
            }
            else{
              Helper.dialogCall.showToast(context, "Confirm Seed Phrase Failed Try Again");
            }*/


            if(widget.seedPhase.join(",") == mySelectList.join(",")){
              SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
              sharedPreferences.setString('isLogin', 'true');
              getAccount();
              // print(widget.seedPhase.length.toString());

            }
            else{
              Helper.dialogCall.showToast(context, "Confirm Seed Phrase Failed Try Again");
            }

          },
          child: Center(
            child: Container(
              height: 50,
              margin: const EdgeInsets.fromLTRB(20,0,20,20),
              width: Responsive.isDesktop(context) ? width/2 : width,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: mySelectList.length == 12 || mySelectList.length == 24?
                   AppColors.blueColor:AppColors.blueColor.withOpacity(0.25),

                  gradient:
                  AppColors.buttonGradient2


                  ,


                  borderRadius: BorderRadius.circular(8)
              ),
              child: const Text(
                  "Submit",
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.white ,
                      fontFamily: "Sf-SemiBold"
                  )
              ),

            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 20),

            //App Bar
            Row(
              children: [
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
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
                        child:Image.asset("assets/icons/backarrow.png",height: 24),)),
                ),
              ],
            ),
            const SizedBox(height: 40),

            InkWell(
              onTap: (){
                setState(() {
                  mySelectList.clear();

                });
              },
              child: const Text(
                  "Confirm Seed Phrase",
                  style: TextStyle(
                      color: AppColors.White,
                      fontFamily: "Sf-SemiBold",
                      fontSize: 18
                  )
              ),
            ),
            const SizedBox(height: 10),

            Text(
                "Select each word in the order it was presented to you",
                style: TextStyle(
                    color: AppColors.white.withOpacity(0.5),
                    fontFamily: "Sf-SemiBold",
                    fontSize: 12
                )
            ),

            const SizedBox(height: 40),



            const SizedBox(height: 38),

            Container(
                width: width,
                padding: const EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.center,
                constraints: const BoxConstraints(
                    minHeight: 153
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.whiteColor.withOpacity(0.1),
                    )
                ),
                child: mySelectList.isEmpty
                    ?
                const Text(
                  "Please select you seed parse in sequence",
                  style: TextStyle(color:AppColors.white),

                )
                    :
                Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runAlignment:WrapAlignment.center,
                    alignment: WrapAlignment.center,
                    direction: Axis.horizontal,
                    runSpacing: 15,
                    spacing: 15,
                    children: mySelectList.map((list){
                      var index = mySelectList.indexOf(list);
                      return InkWell(
                        onTap: (){
                          setState(() {
                            seedList.add(list);
                            mySelectList.remove(list);
                          });
                        },
                        child: IntrinsicWidth(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15,right: 15),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 10),
                              alignment: Alignment.center,
                              constraints: const BoxConstraints(
                                  minWidth: 120,
                                  minHeight: 24
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border253A66)
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "${index+1}.",
                                    style: const TextStyle(
                                        color: AppColors.greydark,
                                        fontFamily: "Sf-Regular",
                                        fontSize: 14
                                    ),
                                  ),

                                  Expanded(
                                    child: Text(
                                      " $list",
                                      style:const TextStyle(
                                          color: AppColors.White,
                                          fontFamily: "Sf-Regular",
                                          fontSize: 14)
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  InkWell(
                                    onTap: () {

                                      setState(() {
                                        if(!seedList.contains(list)){
                                          seedList.add(list);
                                          seedList.toSet().toList();
                                          mySelectList.remove(list);
                                        }
                                      });
                                    },
                                    child: const Icon(
                                      Icons.clear,
                                      color: AppColors.whiteColor,
                                      size: 17,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList()
                )
            ),
            const SizedBox(height: 20),

            Center(
              child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment:WrapAlignment.center,
                  alignment: WrapAlignment.center,
                  direction: Axis.horizontal,
                  spacing: 20,
                  runSpacing: 20,

                  children: seedList.map((e){
                    return InkWell(
                      onTap: (){
                        setState(() {


                          if(!mySelectList.contains(e)){
                            mySelectList.add(e);
                            mySelectList =  mySelectList.toSet().toList();
                            seedList.remove(e);
                          }
                        });
                      },
                      child: IntrinsicWidth(
                        child: Container(

                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 10),
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(
                              minWidth: 120,
                              minHeight: 24
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.whiteColor.withOpacity(0.1),
                              )
                          ),
                          child: Text(
                            e,
                            style:TextStyle(
                                color: AppColors.whiteColor.withOpacity(0.6),
                                fontSize: 12
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList()
              ),
            ),
            const SizedBox(height: 40),


/*
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  color: AppColors.Blackgroungnew ,
                  borderRadius: BorderRadius.circular(8)
              ),
              child: Row(

                children: [
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        setState(() {
                          firstSeed = "";
                        });
                      },
                      child:  Center(
                        child: Text(
                            "$firstId. $firstSeed",
                            style: TextStyle(
                                color: AppColors.white.withOpacity(0.5),
                                fontFamily: "Sf-SemiBold",
                                fontSize: 12
                            )
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width:05),
                  Container(height: 30,color: AppColors.searchbackground,width: 2),
                  const SizedBox(width:05),
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        setState(() {
                          secondSeed = "";
                        });
                      },
                      child:  Center(
                        child: Text(
                            "$secondId. $secondSeed",
                            style: TextStyle(
                                color: AppColors.white.withOpacity(0.5),
                                fontFamily: "Sf-SemiBold",
                                fontSize: 12
                            )
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width:05),
                  Container(height: 30,color: AppColors.searchbackground,width: 2),
                  const SizedBox(width:05),
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        setState(() {
                          thardSeed = "";
                        });
                      },
                      child: Center(
                        child: Text(
                            "$thardId. $thardSeed",
                            style: TextStyle(
                                color: AppColors.white.withOpacity(0.5),
                                fontFamily: "Sf-SemiBold",
                                fontSize: 12
                            )
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),*/

            const SizedBox(height: 35),

       /*     Row(

              children: [
                Expanded(
                  child: InkWell(
                    onTap: (){
                      if(firstSeed == ""){
                        setState(() {
                          firstSeed = "${newList[0]['name']}";
                          firstSelectId = "${newList[0]['id']}";
                        });
                      }
                      else if(secondSeed == ""){
                        setState(() {
                          secondSeed = "${newList[0]['name']}";
                          secondSelectId = "${newList[0]['id']}";
                        });
                      }
                      else if(thardSeed == ""){
                        setState(() {
                          thardSeed = "${newList[0]['name']}";
                          thardSelectId = "${newList[0]['id']}";
                        });
                      }
                      else{

                      }
                      setState(() {

                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color:  firstSeed == newList[0]['name'] || secondSeed == newList[0]['name'] || thardSeed == newList[0]['name'] ? AppColors.darklightgrey:AppColors.border253A66)
                      ),
                      child:  Center(
                        child: Text(
                          "${newList[0]["name"]}",
                          style: TextStyle(
                              color: firstSeed == newList[0]['name'] || secondSeed == newList[0]['name'] || thardSeed == newList[0]['name'] ? AppColors.darklightgrey : AppColors.whiteColor
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width:10),
                Expanded(
                  child: InkWell(
                    onTap: (){
                      if(firstSeed == ""){
                        setState(() {
                          firstSeed = "${newList[1]['name']}";
                          firstSelectId = "${newList[1]['id']}";
                        });
                      }
                      else if(secondSeed == ""){
                        setState(() {
                          secondSeed = "${newList[1]['name']}";
                          secondSelectId = "${newList[1]['id']}";
                        });
                      }
                      else if(thardSeed == ""){
                        setState(() {
                          thardSeed = "${newList[1]['name']}";
                          thardSelectId = "${newList[1]['id']}";
                        });
                      }
                      else{

                      }
                      setState(() {

                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color:  firstSeed == newList[1]['name'] || secondSeed == newList[1]['name'] || thardSeed == newList[1]['name'] ? AppColors.darklightgrey:AppColors.border253A66)
                      ),
                      child:  Center(
                        child: Text(
                          "${newList[1]["name"]}",
                          style: TextStyle(
                              color: firstSeed == newList[1]['name'] || secondSeed == newList[1]['name'] || thardSeed == newList[1]['name'] ? AppColors.darklightgrey : AppColors.whiteColor
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width:10),
                Expanded(
                  child: InkWell(
                    onTap: (){
                      if(firstSeed == ""){
                        setState(() {
                          firstSeed = "${newList[2]['name']}";
                          firstSelectId = "${newList[2]['id']}";
                        });
                      }
                      else if(secondSeed == ""){
                        setState(() {
                          secondSeed = "${newList[2]['name']}";
                          secondSelectId = "${newList[2]['id']}";
                        });
                      }
                      else if(thardSeed == ""){
                        setState(() {
                          thardSeed = "${newList[2]['name']}";
                          thardSelectId = "${newList[2]['id']}";
                        });
                      }
                      else{

                      }
                      setState(() {

                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color:  firstSeed == newList[2]['name'] || secondSeed == newList[2]['name'] || thardSeed == newList[2]['name'] ? AppColors.darklightgrey:AppColors.border253A66)
                      ),
                      child: Center(
                        child: Text(
                          "${newList[2]["name"]}",
                          style: TextStyle(
                              color: firstSeed == newList[2]['name'] || secondSeed == newList[2]['name'] || thardSeed == newList[2]['name'] ? AppColors.darklightgrey : AppColors.whiteColor
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(

              children: [
                const SizedBox(width:35),
                Expanded(
                  child: InkWell(
                    onTap: (){
                      if(firstSeed == ""){
                        setState(() {
                          firstSeed = "${newList[3]['name']}";
                          firstSelectId = "${newList[3]['id']}";
                        });
                      }
                      else if(secondSeed == ""){
                        setState(() {
                          secondSeed = "${newList[3]['name']}";
                          secondSelectId = "${newList[3]['id']}";
                        });
                      }
                      else if(thardSeed == ""){
                        setState(() {
                          thardSeed = "${newList[3]['name']}";
                          thardSelectId = "${newList[3]['id']}";
                        });
                      }
                      else{

                      }
                      setState(() {

                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color:  firstSeed == newList[3]['name'] || secondSeed == newList[3]['name'] || thardSeed == newList[3]['name'] ? AppColors.darklightgrey:AppColors.border253A66)
                      ),
                      child:  Center(
                        child: Text(
                          "${newList[3]["name"]}",
                          style: TextStyle(
                              color: firstSeed == newList[3]['name'] || secondSeed == newList[3]['name'] || thardSeed == newList[3]['name'] ? AppColors.darklightgrey : AppColors.whiteColor
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width:20),
                Expanded(
                  child: InkWell(
                    onTap: (){
                      if(firstSeed == ""){
                        setState(() {
                          firstSeed = "${newList[4]['name']}";
                          firstSelectId = "${newList[4]['id']}";
                        });
                      }
                      else if(secondSeed == ""){
                        setState(() {
                          secondSeed = "${newList[4]['name']}";
                          secondSelectId = "${newList[4]['id']}";
                        });
                      }
                      else if(thardSeed == ""){
                        setState(() {
                          thardSeed = "${newList[4]['name']}";
                          thardSelectId = "${newList[4]['id']}";
                        });
                      }
                      else{

                      }
                      setState(() {

                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color:  firstSeed == newList[4]['name'] || secondSeed == newList[4]['name'] || thardSeed == newList[4]['name'] ? AppColors.darklightgrey:AppColors.border253A66)
                      ),
                      child:  Center(
                        child: Text(
                          "${newList[4]["name"]}",
                          style: TextStyle(
                              color: firstSeed == newList[4]['name'] || secondSeed == newList[4]['name'] || thardSeed == newList[4]['name'] ? AppColors.darklightgrey : AppColors.whiteColor
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width:35),
              ],
            ),*/



      /*      isLoading == true
                ?
            SizedBox(
                height:42,
                child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.blueColor,
                    )
                )
            )
                :
            InkWell(
              onTap: () async {

                if(widget.seedPhase.join(",") == mySelectList.join(",")){

                  getAccount();

                }
                else{
                  Helper.dialogCall.showToast(context, "Confirm_Seed_Phrase_Failed_Try_Again");
                }

              },
              child: Container(
                width: width,
                height: 42,
                decoration: BoxDecoration(
                    color: widget.seedPhase.join(",") != mySelectList.join(",")
                        ?
                    AppColors.blueColor.withOpacity(0.25)
                        :
                    AppColors.blueColor,

                    borderRadius: BorderRadius.circular(16)
                ),
                child:  Center(
                  child: Text(
                    "Continue",
                    // style: MyTextStyle.buttonStyle14w.copyWith(
                    //     color: widget.seedPhase.join(",") != mySelectList.join(",")
                    //         ?
                    //     AppColors.whiteColor.withOpacity(0.3)
                    //         :
                    //     AppColors.whiteColor
                    // ),
                  ),
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
