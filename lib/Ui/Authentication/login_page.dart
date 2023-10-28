import 'package:corewallet_desktop/Custom_DashboardMenu/MainScreenPage.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_address.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_provider.dart';
import 'package:corewallet_desktop/Provider/Account_Provider.dart';
import 'package:corewallet_desktop/Provider/Token_Provider.dart';
import 'package:corewallet_desktop/Provider/Wallet_Provider.dart';
import 'package:corewallet_desktop/Ui/Authentication/select_wallet_page.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:corewallet_desktop/Values/utils.dart';
import 'package:corewallet_desktop/values/Helper/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Provider/uiProvider.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();

  late AccountProvider accountProvider;
  late TokenProvider tokenProvider;
  late UiProvider uiProvider;
  late WalletProvider walletProvider;

  var errorText = "";
  late String deviceId;
  bool isLoading = false;

  bool showPass = true,hasError = false;

  getAccount() async {

    await DBAccountProvider.dbAccountProvider.getAllAccount();

    getToken();

  }

  var currency = "";
  getToken() async {

    // await DBTokenProvider.dbTokenProvider.deleteAllToken();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    currency = sharedPreferences.getString("currency") ?? "USD";

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
    walletProvider.changeListnerWallet("Wallet");
    setState(() {
      Utils.pageName="Dashboard";
    });
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainDashboardUiScreen()));

    setState((){
      isLoading = false;
    });

  }

  loginAccount() async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      deviceId = sharedPreferences.getString('deviceId')!;
      errorText = "";
      isLoading = true;
    });

    var data = {
      "device_id": deviceId,
      "password": passwordController.text,
    };

    await accountProvider.loginAccount(data,'/deviceLogin');
    if(accountProvider.isSuccess == true){

      getAccount();

    }
    else{

      setState(() {
        isLoading = false;
      });
      errorText = "Incorrect_Password!!";

      Helper.dialogCall.showToast(context, "Incorrect Password!!");


    }

  }

  deleteAlert() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darklightgrey,
        title: const Text(
          'Are you sure',
            style: TextStyle(
                color: AppColors.White,
                fontFamily: "Sf-SemiBold",
                fontSize: 14
            )
        ),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Icon(
              Icons.warning_amber,
              size: 17,
              color: AppColors.yellowColor,
            ),
            Flexible(
              child: Text(
                '  Do you want to Delete Your All Accounts?',
                  style: TextStyle(
                      color: AppColors.White,
                      fontFamily: "Sf-SemiBold",
                      fontSize: 14
                  )
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'No',
                style: TextStyle(
                    color: AppColors.White,
                    fontFamily: "Sf-SemiBold",
                    fontSize: 14
                )
            ),
          ),
          TextButton(
            onPressed: () {

              Navigator.pop(context);
              deleteAllAccountApi();

            },
            /*Navigator.of(context).pop(true)*/
            child: const Text(
              'Yes',
                style: TextStyle(
                    color: AppColors.White,
                    fontFamily: "Sf-SemiBold",
                    fontSize: 14
                )
            ),
          ),
        ],
      ),
    );
  }

  deleteAllAccountApi() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      deviceId = sharedPreferences.getString('deviceId')!;
    });
    var data = {
      "device_id":"$deviceId"
    };

    await accountProvider.forgotPassword(data,'/forgotPassword');

    if(accountProvider.isPassword == true){
      DBAccountProvider.dbAccountProvider.deleteAllAccount();
      await DbAccountAddress.dbAccountAddress.deleteAllAccountAddress();
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('isLogin', 'false');
      sharedPreferences.clear();

      createDeviceId();
    }
  }

  createDeviceId() async {

    deviceId = (await  PlatformDeviceId.getDeviceId)!.trim();
    SharedPreferences  sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('deviceId', deviceId.trim());

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const SelectWalletPage()
        )
    );

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
    uiProvider = Provider.of<UiProvider>(context, listen: true);
    walletProvider = Provider.of<WalletProvider>(context, listen: true);


    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              SizedBox(height: height * 0.2),

              // top logo and title
              Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.transparent.withOpacity(0.5),
                        blurRadius: 70.0,
                        // spreadRadius: 1.0,
                      )
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/drawericon/cartenalogo.svg',
                        height: height * 0.1,
                        width: width * 0.1,
                        alignment: Alignment.center,
                      ),
                      SizedBox(height: 0,),
                      Center(
                        child: SvgPicture.asset(
                          'assets/icons/drawericon/catenatext.svg',
                          height: height * 0.09,width: width * 0.09,alignment: Alignment.center,
                        ),
                      )


                    ],
                  )
              ),

              SizedBox(height: height * 0.12),

              //Wallet name
              const Text(
                  "Password",
                  style: TextStyle(
                      color: AppColors.White,
                      fontFamily: "Sf-SemiBold",
                      fontSize: 14
                  )
              ),
              const SizedBox(height: 10),

              //Wallet name TextField
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
                    //  return "Enter your password";
                    return "";
                  }else if(int.parse(value) < 5){
                    setState(() {
                      hasError = true;
                    });
                    return "";
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
                  }else{
                    setState(() {
                      hasError = false;
                      errorText = "";
                    });
                  }
                },
                obscuringCharacter: "*",

                decoration: InputDecoration(
                    fillColor: AppColors.ContainergreySearch,
                    filled: true,
                    isDense: true,
                    hintText: "Enter Password",

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
              const SizedBox(height: 40),

              isLoading == true
                  ?
              Helper.dialogCall.showLoader()
                  :
              InkWell(
                onTap: () {
                  if(passwordController.text.isNotEmpty){
                    FocusScope.of(context).unfocus();
                    loginAccount();
                  }
                },
                child: Center(
                  child: Container(
                    height: 50,
                    width: Responsive.isDesktop(context) ? width/4: width,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        gradient: AppColors.buttonGradient2,
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: const Text(
                        "Log In",
                        style: TextStyle(
                            fontSize: 14,
                            color:AppColors.white ,
                            fontFamily: "Sf-SemiBold"
                        )
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: InkWell(
                  onTap: (){
                    deleteAlert();
                  },
                  child: const Text(
                    "Reset Wallet",
                    style: TextStyle(
                      color: AppColors.White,
                      fontFamily: "Sf-SemiBold",
                      fontSize: 14
                    )
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
