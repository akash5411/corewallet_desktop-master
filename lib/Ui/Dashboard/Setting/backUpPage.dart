
import 'package:clipboard/clipboard.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_address.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_provider.dart';
import 'package:corewallet_desktop/Provider/SettingProvider.dart';
import 'package:corewallet_desktop/Values/Helper/helper.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackUpPage extends StatefulWidget {

  const BackUpPage({Key? key,}) : super(key: key);

  @override
  State<BackUpPage> createState() => _BackUpPageState();
}

class _BackUpPageState extends State<BackUpPage> {

  var height = 0.0,width = 0.0;
  bool editName = false,showPass = false,showKeyPhrase = false;
  String addressType = "";

  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late Color borderColor;
  late SettingProvider settingsProvider;

  List<bool> isListSelected = [];

  @override
  void initState() {
    super.initState();
    settingsProvider = Provider.of<SettingProvider>(context, listen: false);
    getAllACKey();

  }

  List seedPhaseList = [];
  var selectedAccountId = "",selectedAccountName = "";
  bool isLoading = false;
  getAllACKey()async {

    setState(() {
      isLoading = true;
    });
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      selectedAccountId = sharedPreferences.getString('accountId') ?? "";
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";
    });


    await DbAccountAddress.dbAccountAddress.getAccountAddress(selectedAccountId);
    print(selectedAccountId);


    await DBAccountProvider.dbAccountProvider.getAccountById(int.parse(selectedAccountId));

       if(DBAccountProvider.dbAccountProvider.account.isNotEmpty ){

         setState(() {
           var seedPhase = Helper.dialogCall.decryptAddressColumn(DBAccountProvider.dbAccountProvider.account.first.mnemonic);
           print(seedPhase);
           if(seedPhase != ""){
             seedPhaseList = seedPhase.trim().split(" ");
             print(seedPhaseList);
           }
           isListSelected = List.filled(DbAccountAddress.dbAccountAddress.allAccountAddress.length, false);
           print(isListSelected );
         });

       }


    Future.delayed(const Duration(seconds: 1),(){
      setState(() {
        isLoading = false;
      });
    });
  }


  bool isVisible = false;
  @override
  Widget build(BuildContext context) {
    settingsProvider = Provider.of<SettingProvider>(context, listen: true);
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(

      body:DBAccountProvider.dbAccountProvider.account.isEmpty?
      Padding(
        padding: const EdgeInsets.only(left: 20,right: 20,top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            InkWell(
              onTap: (){
                settingsProvider.changeListnerSetting("Setting");
                // Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 0),
                child: Container(
                    alignment: Alignment.centerLeft,
                    width: width * 0.03,
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
                    child: Image.asset(
                        "assets/icons/backarrow.png",
                        height: 24
                    )
                ),
              ),
            ),

            Spacer(),

            Container(
              alignment: Alignment.center,
              child: SvgPicture.asset(
                "assets/icons/Exchange/error.svg",
                width: width * 0.4,
                height: height * 0.4,
                alignment: Alignment.center,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "The Backup files has been not created yet.",
                style: TextStyle(
                    color: AppColors.white.withOpacity(0.4),
                    fontFamily: "Sf-Regular",
                    fontSize: 13
                ),textAlign: TextAlign.center,
              ),
            ),
            Spacer(),
          ],
        ),
      )
        :
      Padding(
        padding: const EdgeInsets.only(left: 20,right: 20,top: 20),
        child: Column(
          children: [
            // app bar
            Row(
              children: [
                InkWell(
                  onTap: (){
                    settingsProvider.changeListnerSetting("Setting");
                    // Navigator.pop(context);
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
                        child:Image.asset(
                            "assets/icons/backarrow.png",
                            height: 24
                        ),
                      )
                  ),
                ),

                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Text(
                      "Backup Page",
                      style: TextStyle(
                          color: AppColors.White,
                          fontFamily: "Sf-SemiBold",
                          fontSize: Responsive.isMobile(context)?18:20
                      )
                  ),
                ),
                const Spacer(),

              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: isLoading
                  ?
              Helper.dialogCall.showLoader()
                  :
              SingleChildScrollView(
                child: Column(
                  children: [

                    isVisible == false
                        ?
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: (){
                              setState(() {
                                isVisible = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.whiteColor),
                                  borderRadius: BorderRadius.circular(4)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: const [
                                      Icon(Icons.lock,color: AppColors.whiteColor,size: 30),
                                      SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          "Show Your Seed Phrase",
                                            style: TextStyle(
                                                color: AppColors.White,
                                                fontFamily: "Sf-SemiBold",
                                                fontSize: 14
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 15,),
                          const Text(
                            "If you lose access to this device, your funds will be lost, unless you back up!",
                              style: TextStyle(
                                  color: AppColors.White,
                                  fontFamily: "Sf-SemiBold",
                                  fontSize: 14
                              )
                          ),

                        ],
                      ),
                    )
                        :
                    Container(
                      child: showKeyPhrase
                            ?
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 14),
                          decoration: BoxDecoration(
                            color:  AppColors.Blackgroungnew,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: Text(
                                  "Write down or copy these words in the right order and save them somewhere safe.",
                                  style: TextStyle(
                                    color: AppColors.White,
                                    fontFamily: "Sf-SemiBold",
                                    fontSize: 14
                                    ),
                                ),
                              ),
                              const SizedBox(height: 40,),
                              AlignedGridView.count(
                                physics: const NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                crossAxisCount: 3,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 20,
                                shrinkWrap: true,
                                itemCount: seedPhaseList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var list =  seedPhaseList[index];
                                  return InkWell(
                                    onTap: (){
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppColors.border253A66)
                                      ),
                                      child:Center(
                                        child: Text(
                                          "${index+1}. $list",
                                            style: const TextStyle(
                                                color: AppColors.White,
                                                fontFamily: "Sf-SemiBold",
                                                fontSize: 14
                                            )
                                        ),
                                      ),
                                    ),
                                  );

                                },

                              ),
                            ],
                          ),
                        )
                            :
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 15),
                          width: width,
                          color:  AppColors.Blackgroungnew,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Enter your password to reveal your seed phrase",
                                  style: TextStyle(
                                      color: AppColors.White,
                                      fontFamily: "Sf-SemiBold",
                                      fontSize: 14
                                  )
                              ),
                              SizedBox(height: 8),

                              const Text(
                                "Make sure no one is watching your screen",
                                  style: TextStyle(
                                      color: AppColors.White,
                                      fontFamily: "Sf-SemiBold",
                                      fontSize: 12
                                  )
                              ),
                              const SizedBox(height: 30),

                              SizedBox(
                                width: width/3,
                                child: TextFormField(
                                  obscureText: !showPass,
                                  controller: passwordController,
                                  cursorColor:  AppColors.white,
                                  style: const TextStyle(
                                      color: AppColors.white,
                                      fontFamily: "Sf-Regular",
                                      fontSize: 14
                                  ),
                                  onChanged: (value) {
                                    setState(() {});
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
                                      child: showPass
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
                              ),
                              SizedBox(height: 30),

                              InkWell(
                                onTap: () async {
                                  if(passwordController.text.isNotEmpty){
                                    FocusScope.of(context).unfocus();
                                    SharedPreferences pre = await SharedPreferences.getInstance();

                                    if(pre.getString("password") == passwordController.text){

                                      setState(() {
                                        showKeyPhrase = true;
                                      });
                                    }else{
                                      Helper.dialogCall.showToast(context, "Invalid password");
                                      setState(() {
                                        showKeyPhrase = false;
                                      });
                                    }
                                  }
                                },
                                child: Container(
                                  width: width/3.5,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.buttonGradient2,
                                      color: passwordController.text.isEmpty ? AppColors.blueColor.withOpacity(0.25) : AppColors.blueColor,
                                      borderRadius: BorderRadius.circular(8)

                                  ),
                                  child:  Center(
                                    child: Text(
                                      "View",
                                        style: TextStyle(
                                            color: passwordController.text.isNotEmpty ? AppColors.White : AppColors.White.withOpacity(0.2),
                                            fontFamily: "Sf-SemiBold",
                                            fontSize: 12
                                        )
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ),

                     ListView.builder(
                       physics: const NeverScrollableScrollPhysics(),
                       padding: const EdgeInsets.only(top: 20),
                      itemCount: DbAccountAddress.dbAccountAddress.allAccountAddress.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        var list = DbAccountAddress.dbAccountAddress.allAccountAddress[index];
                        return InkWell(
                          onTap: (){
                            setState(() {
                              isListSelected[index] = !isListSelected[index];
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(10,0,10,15),
                            decoration: BoxDecoration(
                                color: AppColors.Blackgroungnew,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      color: AppColors.white.withOpacity(0.02),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    offset: Offset(2,2)
                                  )
                                ]
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [


                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                          list.networkName,
                                          style: const TextStyle(
                                              color: AppColors.White,
                                              fontFamily: "Sf-SemiBold",
                                              fontSize: 14
                                          )
                                      ),
                                    ),
                                    Icon(
                                      isListSelected[index]
                                          ?
                                      Icons.keyboard_arrow_down
                                          :
                                      Icons.keyboard_arrow_up,
                                      color:  AppColors.whiteColor,
                                      size: 18,
                                    )
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                          list.publicAddress,
                                          style: const TextStyle(
                                              color: AppColors.White,
                                              fontFamily: "Sf-SemiBold",
                                              fontSize: 12
                                          )
                                      ),
                                    ),
                                    InkWell(
                                      onTap: (){
                                        FlutterClipboard.copy(list.publicAddress).then(( value ) {
                                          Helper.dialogCall.showToast(context, "${list.networkName} Public Address Copied");
                                        });
                                      },
                                      child: SvgPicture.asset(
                                        'assets/icons/wallet/copy 1.svg',
                                        height: 18,alignment: Alignment.center,
                                      ),
                                    )
                                  ],
                                ),


                                !isListSelected[index]
                                    ?
                                const SizedBox()
                                    :
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),

                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.whiteColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: Center(
                                          /*child: QrImage(
                                            size: 150,
                                            data: list.publicAddress,
                                            //embeddedImage: AssetImage('assets/icons/logo.png'),
                                            version: QrVersions.auto,

                                          ),*/
                                        ),
                                      ),

                                      !showKeyPhrase
                                          ?
                                      const SizedBox()
                                          :
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 7),

                                              const Text(
                                                "Private Key: ",
                                                  style: TextStyle(
                                                      color: AppColors.White,
                                                      fontFamily: "Sf-SemiBold",
                                                      fontSize: 12
                                                  )
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      list.privateAddress,
                                                        style: const TextStyle(
                                                            color: AppColors.White,
                                                            fontFamily: "Sf-SemiBold",
                                                            fontSize: 12
                                                        )
                                                    ),
                                                  ),

                                                  const SizedBox(width: 10),
                                                  InkWell(
                                                    onTap: (){
                                                      FlutterClipboard.copy(list.privateAddress).then(( value ) {
                                                        Helper.dialogCall.showToast(context, "Private Key Copied");
                                                      });
                                                    },
                                                    child: SvgPicture.asset(
                                                      'assets/icons/wallet/copy 1.svg',
                                                      height: 18,alignment: Alignment.center,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                     )
                  ],
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}
