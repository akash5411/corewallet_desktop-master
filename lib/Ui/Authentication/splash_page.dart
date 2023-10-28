import 'package:corewallet_desktop/LocalDb/Local_Account_address.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_provider.dart';
import 'package:corewallet_desktop/Provider/Account_Provider.dart';
import 'package:corewallet_desktop/Provider/Token_Provider.dart';
import 'package:corewallet_desktop/Ui/Authentication/select_wallet_page.dart';
import 'package:corewallet_desktop/Values/Helper/helper.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';


class SplashScreen extends StatefulWidget {
  const
  SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  late AccountProvider accountProvider;
  late TokenProvider tokenProvider;
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    accountProvider = Provider.of<AccountProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    getDeviceId();
  }


  late SharedPreferences sharedPreferences;
  late String deviceId;

  getDeviceId() async {

    deviceId = (await  PlatformDeviceId.getDeviceId)!.trim();
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('deviceId', "${deviceId.trim()}");
    getNetwork();

  }

  getNetwork() async {
    await tokenProvider.getNetworks('/getNetworks');
    getAccount();

  }

  getAccount() async {
    await DBAccountProvider.dbAccountProvider.getAllAccount();
    for(int i=0; i<DBAccountProvider.dbAccountProvider.newAccountList.length;i++){
      await importAccount(
          DBAccountProvider.dbAccountProvider.newAccountList[i].id,
          DBAccountProvider.dbAccountProvider.newAccountList[i].name,
          Helper.dialogCall.decryptAddressColumn(DBAccountProvider.dbAccountProvider.newAccountList[i].mnemonic)
      );
    }

    checkIfLogin();

  }

  importAccount(id,name,seed) async {
    setState(() {
      isLoading = true;
    });

    var data = {
      "acc_id": "$id",
      "name": "$name",
      "device_id": deviceId,
      "type": "mnemonic",
      "mnemonic": "$seed"
    };

    await accountProvider.addAccount(data, '/iniWalletCheck');

    if(accountProvider.isAccountLoad) {

      await DBAccountProvider.dbAccountProvider.deleteAccount("$id");
      await DbAccountAddress.dbAccountAddress.deleteAccountAddress("$id");

      for (int i = 0; i < accountProvider.accountData.length; i++) {
        for (int j = 0; j < tokenProvider.networkList.length; j++) {


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

    }
  }



  String isLogin = "false";

  checkIfLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString('isLogin') != null){
      isLogin = sharedPreferences.getString('isLogin')!;

      if(isLogin == "true"){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      }
      else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SelectWalletPage()));
      }

    }
    else{

      if(isLogin == "true"){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      }
      else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SelectWalletPage()));
      }

    }

  }


  @override
  Widget build(BuildContext context) {

    accountProvider = Provider.of<AccountProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(

      body: Container(
        width: width,
        color: AppColors.BlackgroundBlue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              // width: 150,
                alignment: Alignment.center,
                decoration:  BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.transparent,
                      blurRadius: 70.0,
                    )
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/drawericon/cartenalogo.svg',
                      width: 120,
                      alignment: Alignment.center,
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: SvgPicture.asset(
                        'assets/icons/drawericon/catenatext.svg',
                        width: MediaQuery.of(context).size.width*0.2,
                        alignment: Alignment.center,
                      ),
                    )


                  ],
                )),
          ],
        ),
      ),
    );
  }
}
