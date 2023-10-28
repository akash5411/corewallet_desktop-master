import 'dart:convert';

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
import 'package:corewallet_desktop/Values/components.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:corewallet_desktop/Values/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImportWalletPage extends StatefulWidget {
  const ImportWalletPage({Key? key}) : super(key: key);

  @override
  State<ImportWalletPage> createState() => _ImportWalletPageState();
}

class _ImportWalletPageState extends State<ImportWalletPage> {

  TextEditingController phraseController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController rePasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  late AccountProvider accountProvider;
  late TokenProvider tokenProvider;
  late UiProvider uiProvider;
  late WalletProvider walletProvider;

  bool hasError = true;

  GlobalKey<FormState> formKey = GlobalKey();

  bool isLoading = false,termBool = false,showPass = true, showRePass = true;
  var deviceId = "";

  importAccount() async {
    setState(() {
      isLoading = true;
    });



    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    deviceId = sharedPreferences.getString('deviceId')!;
    //print(deviceId);

    var data = {
      "name": nameController.text,
      "device_id": deviceId,
      "type":  "mnemonic",
      "password": passwordController.text,
      "mnemonic": phraseController.text.trim()
    };

    // print("initCreateWallet");
    // print(jsonEncode(data));

    await accountProvider.addAccount(data, '/initCreateWallet');
    if (accountProvider.isSuccess == true) {
      sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('isLogin', 'true');
      sharedPreferences.setInt('account', 1);
      sharedPreferences.setString('password', passwordController.text);
      //print(sharedPreferences.getString('isLogin'));

      // print("accountProvider.accountData === > ${accountProvider.accountData.length}");
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

      getAccount();

    } else {

      setState(() {
        isLoading = false;
      });


      Helper.dialogCall.showToast(context, "Invalid Seed Phrase!!");

    }
  }

  getAccount() async {
    //print("account=======> ");
    await DBAccountProvider.dbAccountProvider.getAllAccount();
    getToken();
  }

  var currency;
  getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    currency = sharedPreferences.getString("currency") ?? "USD";
    //print("token =======> ");

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

    uiProvider.DashBoardpage("Wallet");
    setState(() {
      Utils.pageName="Dashboard";
    });
    walletProvider.changeListnerWallet("Wallet");
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainDashboardUiScreen()),(route) => false,);


    setState(() {
      isLoading = false;
    });
  }


  @override
  void initState() {
    super.initState();
    accountProvider = Provider.of<AccountProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    uiProvider = Provider.of<UiProvider>(context, listen: false);
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {

    accountProvider = Provider.of<AccountProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);
    uiProvider = Provider.of<UiProvider>(context, listen: false);
    walletProvider = Provider.of<WalletProvider>(context, listen: false);

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                  const SizedBox(width: 20),

                  Text(
                      "Import Wallet",
                      style: TextStyle(
                          color: AppColors.White,
                          fontFamily: "Sf-SemiBold",
                          fontSize: Responsive.isMobile(context)?18:20
                      )
                  ),

                ],
              ),

              //Seed Phrase
              const SizedBox(height: 40),
              const Text(
                  "Seed Phrase",
                  style: TextStyle(
                      color: AppColors.White,
                      fontFamily: "Sf-SemiBold",
                      fontSize: 14
                  )
              ),
              const SizedBox(height: 10),

              //Seed Phrase TextField
              TextFormField(
                controller: phraseController,
                cursorColor:  AppColors.white,
                style: const TextStyle(
                    color: AppColors.white,
                    fontFamily: "Sf-Regular",
                  fontSize: 14
                ),

                validator:(value){
                  if(value!.isEmpty){
                    setState(() {
                      hasError = true;
                    });
                    //  return "Enter your password";
                    return "";
                  }
                  else{
                    setState(() {
                      hasError = false;
                    });
                  }
                  return null;
                },
                onChanged: (value){
                  if(value.isEmpty){
                    setState(() {
                      hasError = true;
                    });
                  }else{
                    setState(() {
                      hasError = false;
                    });
                  }
                },

                decoration: InputDecoration(
                  fillColor: AppColors.ContainergreySearch,
                  filled: true,
                  isDense: true,
                  hintText: "Seed Phrase",
                  suffixIcon: InkWell(
                    onTap: () async {

                      ClipboardData? data = await Clipboard.getData('text/plain');
                      String? value = data?.text.toString();

                      List list = value!.trim().split(" ");
                      if(list.length == 12 || list.length == 24){
                        setState(() {
                          phraseController.text = value;
                        });
                      } else {
                        Helper.dialogCall.showToast(
                            context, "Invalid Seed Phrase!!"
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        "assets/icons/wallet/copy 1.svg",
                        height: 10,
                        width: 10,
                      ),
                    ),
                  ),
                  hintStyle: const TextStyle(
                      color: AppColors.greydark,
                      fontFamily: "Sf-Regular",
                    fontSize: 14
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
                  errorStyle: const TextStyle(
                    height: 0,fontSize: 0,
                  )
                ),
              ),
              const SizedBox(height: 10),

              // note
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  "typically 12 or 24 words separated by single space",
                    style: textStyle.copyWith(
                        fontSize: 14,
                        color: AppColors.white.withOpacity(0.6),
                        fontFamily: "Sf-SemiBold"
                    )
                ),
              ),

              //Name
              const SizedBox(height: 20),
              const Text(
                  "Wallet Name",
                  style: TextStyle(
                      color: AppColors.White,
                      fontFamily: "Sf-SemiBold",
                      fontSize: 14
                  )
              ),
              const SizedBox(height: 10),

              //Name TextField
              TextFormField(
                controller: nameController,
                cursorColor:  AppColors.white,
                style: const TextStyle(
                    color: AppColors.white,
                    fontFamily: "Sf-Regular",
                    fontSize: 14
                ),

                validator:(value){
                  if(value!.isEmpty){
                    setState(() {
                      hasError = true;
                    });
                    return "";
                  }
                  else{
                    setState(() {
                      hasError = false;
                    });
                  }
                  return null;
                },
                onChanged: (value){
                  if(value.isEmpty){
                    setState(() {
                      hasError = true;
                    });
                  }else{
                    setState(() {
                      hasError = false;
                    });
                  }
                },

                decoration: InputDecoration(
                    fillColor: AppColors.ContainergreySearch,
                    filled: true,
                    isDense: true,
                    hintText: "Wallet Name",
                    hintStyle: const TextStyle(
                        color: AppColors.greydark,
                        fontFamily: "Sf-Regular",
                        fontSize: 14
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
                    errorStyle: const TextStyle(
                      height: 0,fontSize: 0,
                    )
                ),
              ),


              // Password
              const SizedBox(height: 20),
              const Text(
                  "Password",
                  style: TextStyle(
                      color: AppColors.White,
                      fontFamily: "Sf-SemiBold",
                      fontSize: 14
                  )
              ),
              const SizedBox(height: 10),

              //Password TextField
              TextFormField(
                obscureText: showPass,
                controller: passwordController,
                cursorColor:  AppColors.white,
                style: const TextStyle(
                    color: AppColors.white,
                    fontFamily: "Sf-Regular",
                    fontSize: 14
                ),
                validator:(value){
                  if(value!.isEmpty){
                    setState(() {
                      hasError = true;
                    });
                    return "";
                  }else if(value != rePasswordController.text){
                    setState(() {
                      hasError = true;
                    });
                    return "";
                  }else{
                    setState(() {
                      hasError = false;
                    });
                  }
                  return null;
                },
                onChanged: (value){
                  if(value.isEmpty){
                    setState(() {
                      hasError = true;
                    });
                  }else if(value != rePasswordController.text){
                    setState(() {
                      hasError = true;
                    });
                  }else{
                    setState(() {
                      hasError = false;
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


                    const Icon(Icons.visibility,color: AppColors.white,size: 18,)
                    :
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        "assets/icons/eye_off.png",
                        height: 10,
                        width: 10,
                        color: AppColors.white,
                      ),
                    ),
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

              // Re-Password
              const SizedBox(height: 20),
              const Text(
                  "Re-Enter Password",
                  style: TextStyle(
                      color: AppColors.White,
                      fontFamily: "Sf-SemiBold",
                      fontSize: 14
                  )
              ),
              const SizedBox(height: 10),

              //Re-Password TextField
              TextFormField(
                obscureText: showRePass,
                controller: rePasswordController,
                cursorColor:  AppColors.white,
                style: const TextStyle(
                    color: AppColors.white,
                    fontFamily: "Sf-Regular",
                    fontSize: 14
                ),

                validator:(value){
                  if(value!.isEmpty){
                    setState(() {
                      hasError = true;
                    });
                    return "";
                  }else if(value.length < 5){
                    setState(() {
                      hasError = true;
                    });
                    return "";
                  }else if(value != passwordController.text){
                    setState(() {
                      hasError = true;
                    });
                    return "";
                  }else{
                    setState(() {
                      hasError = false;
                    });
                  }
                  return null;
                },
                onChanged: (value){
                  if(value.isEmpty){
                    setState(() {
                      hasError = true;
                    });
                  }else if(value.length < 5){
                    setState(() {
                      hasError = true;
                    });
                  }else if(value != passwordController.text){
                    setState(() {
                      hasError = true;
                    });
                  }else{
                    setState(() {
                      hasError = false;
                    });
                  }
                },

                decoration: InputDecoration(
                  fillColor: AppColors.ContainergreySearch,
                  filled: true,
                  isDense: true,
                  hintText: "Example21@#!",
                  suffixIcon: InkWell(
                    onTap: (){
                      setState(() {
                        showRePass = !showRePass;
                      });
                    },
                    child: !showRePass
                        ?

                    const Icon(Icons.visibility,color: AppColors.white,size: 18,)
                    :
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        "assets/icons/eye_off.png",
                        height: 10,
                        width: 10,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  hintStyle: const TextStyle(
                      color: AppColors.greydark,
                      fontFamily: "Sf-Regular",
                      fontSize: 14
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
              const SizedBox(height: 10),

              // check box
              InkWell(
                onTap: (){
                  setState(() {
                    termBool = !termBool;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                          color: termBool ? AppColors.blueColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            width: 1.5,
                            color: termBool ? AppColors.blueColor : AppColors.white,
                          )
                      ),
                      child: termBool ? const Center(child: Icon(Icons.check,size: 18,color: Colors.white,)) : const SizedBox(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "I understand that CATENA can't recover this password for me",
                        style: TextStyle(
                            color: AppColors.white.withOpacity(0.6),
                            fontFamily: "Sf-Regular",
                            fontSize: 14
                        )
                      ),
                    )
                  ],
                ),
              ),

              const Spacer(),

              // submit button
              isLoading == true
                  ?
              Helper.dialogCall.showLoader()
                  :
              InkWell(
                onTap: () {
                  if (formKey.currentState!.validate() && !hasError && termBool) {
                    // print("check1");
                    importAccount();
                  }else{
                    // print("check");
                  }
                },
                child: Center(
                  child: Container(
                    height: 50,
                    width: Responsive.isDesktop(context) ? width/2 : width,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: hasError || !termBool ? AppColors.blueColor.withOpacity(0.25):AppColors.blueColor,

                        gradient: AppColors.buttonGradient2,
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: Text(
                        "Import Existing Wallet",
                        style: textStyle.copyWith(
                            fontSize: 14,
                            color: hasError || !termBool ? AppColors.white.withOpacity(0.5): AppColors.white ,
                            fontFamily: "Sf-SemiBold"
                        )
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }
}
