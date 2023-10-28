import 'package:corewallet_desktop/Provider/SettingProvider.dart';
import 'package:corewallet_desktop/Values/Helper/helper.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting_Page extends StatefulWidget {
  const Setting_Page({Key? key}) : super(key: key);

  @override
  State<Setting_Page> createState() => _Setting_PageState();
}

class _Setting_PageState extends State<Setting_Page> {
  late SettingProvider settingsProvider;

  String countryValue = "";
  String stateValue = "";
  String cityValue = "";
  String address = "";


  var currencyName = "United States Dollar";
  var currencyShort = "USD";
  var currencySymbol= "\$";

   Image? imgsymb;
   int autoLockValue  = 5;

  List<int> countries = [5,10,15,-1];


  FocusNode dropDownNode = FocusNode();

  var width = 0.0,height = 0.0;
  bool askPassword = false;


  getCurrency()async{
    SharedPreferences  preferences = await SharedPreferences.getInstance();

    setState(() {
      currencyShort = preferences.getString("currency") ?? "USD";
      currencySymbol = preferences.getString("crySymbol") ?? "\$";
      currencyName = preferences.getString("currencyName") ?? "United States Dollar";
      askPassword = preferences.getBool("askPassword") ?? false;
      autoLockValue = preferences.getInt("autoLock") ?? 5;
    });
  }


  getCurrencyApi() async {
    await settingsProvider.getCurrency("/cmc/fiatCurrencyList");
  }


  currencyDialog(){
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, StateSetter setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor:AppColors.containerbackgroundgrey,
                contentPadding:  EdgeInsets.zero,
                alignment: Alignment.center,
                insetPadding: EdgeInsets.zero,
                content: SingleChildScrollView(
                  child: Container(
                    width:Responsive.isMobile(context) ? width * 0.5 : width * 0.4,
                    decoration:  BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient:  const LinearGradient(
                          colors:[Color(0xFF222831),AppColors.blackColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 15),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            children:  [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Icon(
                                  Icons.arrow_back_ios_outlined,
                                  color: AppColors.whiteColor,
                                  size: 18,
                                ),
                              ),

                              const SizedBox(width: 15),

                              const Expanded(
                                child: Text(
                                  "Select Currency",
                                  style: TextStyle(
                                      color: AppColors.whiteColor,
                                      fontFamily: "Sf-SemiBold",
                                      fontSize: 13
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),

                        Container(
                          constraints: BoxConstraints(
                              maxHeight: height * 0.7
                          ),
                          child: ListView.builder(
                            itemCount: settingsProvider.fiatModel!.data.length,
                            itemBuilder: (context, index) {
                              var list = settingsProvider.fiatModel!.data[index];
                              return InkWell(
                                onTap: () async {
                                  SharedPreferences preferences = await SharedPreferences.getInstance();
                                  setState(() {
                                    currencyName=list.name;
                                    currencyShort=list.symbol;
                                    currencySymbol=list.sign;

                                    preferences.setString('crySymbol', currencySymbol);
                                    preferences.setString('currency', currencyShort);
                                    preferences.setString('currencyName', currencyName);
                                    preferences.setString('cryChange',currencyName);

                                  });

                                  Navigator.pop(context);
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [

                                    const SizedBox(width: 15),
                                    SvgPicture.network(
                                      "https://s2.coinmarketcap.com/static/cloud/img/fiat-flags/${list.symbol}.svg",
                                      height: 20,
                                      width: 20,
                                      placeholderBuilder: (context) => SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: Helper.dialogCall.showLoader()
                                      ),
                                    ),

                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child:SizedBox(
                                            width: width/8,
                                            child: Text(
                                                "${list.name}",
                                                style: const TextStyle(
                                                    color: AppColors.whiteColor,
                                                    fontFamily: "Sf-Regular",
                                                    fontSize: 13
                                                ),
                                                textAlign: TextAlign.start,
                                                overflow: TextOverflow.fade,
                                                maxLines: 1
                                            )
                                        ),
                                      ),
                                    ),

                                    Icon(
                                      list.symbol == currencyShort ? Icons.radio_button_checked: Icons.radio_button_off,
                                      color:list.symbol != currencyShort ? AppColors.white.withOpacity(0.1) : AppColors.darkblue,
                                    ),
                                    const SizedBox(width: 15),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
        );
      },
    ).whenComplete(() => setState((){}));
  }

  @override
  void initState() {
    super.initState();
    settingsProvider = Provider.of<SettingProvider>(context, listen: false);

    getCurrency();
    getCurrencyApi();
  }


  @override
  Widget build(BuildContext context) {
    settingsProvider = Provider.of<SettingProvider>(context, listen: true);

    height=MediaQuery.of(context).size.height;
    width=MediaQuery.of(context).size.width;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20,right: 20,top: 20),
        child: Column(
          children: [
            const Text(
              "Setting",
              style: TextStyle(
                  color: AppColors.White,
                  fontFamily: "Sf-SemiBold",
                  fontSize: 20
              )
            ),

            // main ui
            Expanded(
              child: ListView(
                children: [
                  // Personalize
                  Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Personalize",
                        style:TextStyle(
                            color: AppColors.greyColor,
                            fontFamily: "Sf-SemiBold",
                            fontSize: 15
                        ),
                      )
                  ),
                  const SizedBox(height: 10),

                  //Set Currency
                  Container(
                    padding: const EdgeInsets.only(left: 20),

                    height:MediaQuery.of(context).size.height/10 ,
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.darkblueContainer,width: 0),
                        color: AppColors.ContainergreyhomeColor,
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 0),
                                child: Text(
                                  "Set Currency",
                                  style:TextStyle(
                                      color: AppColors.White,
                                      fontFamily: "Sf-SemiBold",
                                      fontSize: 15
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5,),
                              SizedBox(
                                  width: width/3,
                                  child: const Text(
                                    "Set your preferred local currency",
                                    style:TextStyle(
                                        color: AppColors.WhiteText,
                                        fontFamily: "Sf-Regular",
                                        fontSize: 12
                                    ),
                                  )
                              ),
                            ],
                          ),
                        ),


                        InkWell(
                          onTap: (){
                            if(settingsProvider.fiatModel != null) {
                              currencyDialog();
                            }
                          },
                          child: Container(
                            width: width/3.5,
                            decoration: BoxDecoration(
                              color:AppColors.ContainergreyhomeColor,
                              border: Border.all(color: AppColors.greyColor2, width:1.5),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [

                                const SizedBox(width: 15),
                                SvgPicture.network(
                                  "https://s2.coinmarketcap.com/static/cloud/img/fiat-flags/$currencyShort.svg",
                                  height: 20,
                                  width: 20,
                                  placeholderBuilder: (context) => SizedBox(
                                      height: 20,
                                      width: 20,
                                    child: Helper.dialogCall.showLoader()
                                  ),
                                ),

                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child:SizedBox(
                                        width: width/8,
                                        child: Text(
                                            "${currencyName}",
                                            style: const TextStyle(
                                                color: AppColors.whiteColor,
                                                fontFamily: "Sf-Regular",
                                                fontSize: 13
                                            ),
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.fade,
                                            maxLines: 1
                                        )
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Image.asset(
                                    "assets/icons/arrow-left-1 1.png",
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                                // Spacer(),
                                // Text(countries),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                      ],
                    ),
                  ),

                  /*SizedBox(height: 10,),
                  Container(
                    height:MediaQuery.of(context).size.height/10 ,
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.darkblueContainer,width: 0),
                        color: AppColors.ContainergreyhomeColor,
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Container(
                                // width: MediaQuery.of(context).size.width/7,
                                  child:
                                  Text("Auto-Update", style:TextStyle(color: AppColors.White,fontFamily: "Sf-SemiBold",fontSize: 15),)
                              ),
                            ),
                            Text("Automatically install updates on the next startup", style:TextStyle(color: AppColors.WhiteText,fontFamily: "Sf-Regular",fontSize: 12),),
                          ],),
                      ),

                      Expanded(child: SizedBox(width: width,)),

                      Container(
                        child: FlutterSwitch(
                          width: 40.0,
                          height: 20.0,
                          activeColor: AppColors.darkblue,
                          valueFontSize: 20.0,
                          toggleSize: 20.0,
                          value: status,
                          borderRadius: 30.0,
                          padding: 1.0,
                          showOnOff: false,
                          onToggle: (val) {
                            setState(() {
                              status = val;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 30,),
                    ],),
                  ),

                  SizedBox(height: 10,),

                  Container(
                  height:MediaQuery.of(context).size.height/10 ,
                  decoration: BoxDecoration(
                      border: Border.all(color: AppColors.darkblueContainer,width: 0),
                      color: AppColors.ContainergreyhomeColor,
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: Row(children: [
                     Padding(
                       padding: const EdgeInsets.only(left: 20),
                       child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Container(
                              // width: MediaQuery.of(context).size.width/7,
                                child:
                                Text("About App", style:TextStyle(color: AppColors.White,fontFamily: "Sf-SemiBold",fontSize: 15),)
                            ),
                          ),

                          Row(
                            children: [
                              Text("Version 2.1.0 -", style:TextStyle(color: AppColors.WhiteText,fontFamily: "Sf-Regular",fontSize: 12),),
                              SizedBox(height: 5,),
                              Text("Last Update 13.02.2023", style:TextStyle(color: AppColors.WhiteText,fontFamily: "Sf-Regular",fontSize: 12),),
                            ],
                          ),

                        ],),
                    ),
                    Expanded(child: SizedBox(width: width,)),
                    Container(
                        child:Text("Check Update", style:TextStyle(color: AppColors.blueColor2,fontFamily: "Sf-SemiBold",fontSize: 13),)
                    ),
                    SizedBox(width: 30,),
                  ],),
                ),
                  SizedBox(height: 10,),
                  Container(
                    height:MediaQuery.of(context).size.height/10 ,
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.darkblueContainer,width: 0),
                        color: AppColors.ContainergreyhomeColor,
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Container(
                                // width: MediaQuery.of(context).size.width/7,
                                child: Text("Notifications",
                                    style:TextStyle(color: AppColors.White,fontFamily: "Sf-SemiBold",fontSize: 15),)
                              ),
                            ),
                            SizedBox(height: 5,),
                            Text("Allow notifications show your desktop",
                                   style:TextStyle(color: AppColors.WhiteText,fontFamily: "Sf-Regular",fontSize: 12),),
                          ],),
                      ),
                      Expanded(child: SizedBox(width: width,)),
                      Container(
                        child: FlutterSwitch(
                          width: 40.0,
                          height: 20.0,
                          activeColor: AppColors.darkblue,
                          valueFontSize: 20.0,
                          toggleSize: 20.0,
                          value: status1,
                          borderRadius: 30.0,
                          padding: 1.0,
                          showOnOff: false,
                          onToggle: (val) {
                            setState(() {
                              status1 = val;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 30,),
                    ],),
                  ),*/

                  const SizedBox(height: 10),

                  //Security
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Security",
                      style:TextStyle(
                          color: AppColors.greyColor,
                          fontFamily: "Sf-SemiBold",
                          fontSize: 15
                      ),
                    )
                  ),

                  const SizedBox(height: 5),

                  //Auto-Lock
                  Container(
                    padding: const EdgeInsets.only(left: 20),

                    height:MediaQuery.of(context).size.height/10 ,
                     decoration: BoxDecoration(
                        border: Border.all(color: AppColors.darkblueContainer,width: 0),
                        color: AppColors.ContainergreyhomeColor,
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(left: 0),
                                child: Text(
                                  "Auto-Lock",
                                  style:TextStyle(
                                      color: AppColors.White,
                                      fontFamily: "Sf-SemiBold",
                                      fontSize: 15
                                  ),
                                ),
                              ),
                              SizedBox(height: 5,),
                              Text(
                                  "Application lock after a specified duration. This security helps if you leave app open",
                                  style:TextStyle(
                                    color: AppColors.WhiteText,
                                    fontFamily: "Sf-Regular",
                                    fontSize: 12,
                                    overflow: TextOverflow.fade,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  maxLines: 2
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 50),
                        SizedBox(
                          height: 50,
                          child: IntrinsicWidth(
                            stepWidth: width/12,
                            child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color:AppColors.ContainergreyhomeColor, //background color of dropdown button
                                  border: Border.all(color: AppColors.greyColor2, width:2), //border of dropdown button
                                  borderRadius: BorderRadius.circular(15), //border raiuds of dropdown button

                                ),
                                child: DropdownButton(
                                  underline: const SizedBox(),
                                  isExpanded: true,
                                  icon: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Image.asset("assets/icons/arrow-left-1 1.png",width: 20,height: 20,),
                                  ),
                                  dropdownColor: AppColors.containerbackgroundgrey,
                                  borderRadius: BorderRadius.circular(15),
                                  value: autoLockValue,
                                  items: countries.map((country){
                                    return DropdownMenuItem(
                                      value: country,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                    text: country == -1  ? "" : 'After ',
                                                    style: const TextStyle(
                                                        color: AppColors.whiteColor,
                                                        fontFamily: "Sf-Regular",
                                                      fontSize: 12
                                                    )
                                                ),
                                                TextSpan(
                                                  text: country == -1 ? "Never" : '$country Min',
                                                    style: const TextStyle(
                                                        color: AppColors.whiteColor,
                                                      fontFamily: "Sf-SemiBold",
                                                      fontSize: 12
                                                    )
                                                ),
                                              ],
                                            ),

                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (country) async {
                                    SharedPreferences pre = await SharedPreferences.getInstance();

                                    setState(() {
                                      autoLockValue = country!;
                                      pre.setInt("autoLock", country);
                                    });
                                  },
                                )
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  //Ask Password on Transactions
                  Container(
                    padding: const EdgeInsets.only(left: 20),

                    height:MediaQuery.of(context).size.height/10 ,
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.darkblueContainer,width: 0),
                        color: AppColors.ContainergreyhomeColor,
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(left: 0),
                                child: Text(
                                  "Ask Password on Transactions",
                                  style:TextStyle(
                                      color: AppColors.White,
                                      fontFamily: "Sf-SemiBold",
                                      fontSize: 15
                                  ),
                                ),
                              ),
                              Text(
                                "Medicine sempre smudge raucous exerts begone",
                                style:TextStyle(
                                    color: AppColors.WhiteText,
                                    fontFamily: "Sf-Regular",
                                    fontSize: 12
                                ),
                              ),
                            ],
                          ),
                        ),

                        FlutterSwitch(
                          width: 40.0,
                          height: 20.0,
                          activeColor: AppColors.darkblue,
                          valueFontSize: 20.0,
                          toggleSize: 20.0,
                          value: askPassword,
                          borderRadius: 30.0,
                          padding: 1.0,
                          showOnOff: false,
                          onToggle: (value) async {
                            SharedPreferences preferences = await SharedPreferences.getInstance();
                            setState(() {
                              askPassword =  value;
                              preferences.setBool('askPassword',value);
                            });
                          },
                        ),
                        const SizedBox(width: 30,),
                      ],
                    ),
                   ),
                  const SizedBox(height: 10),

                  //Backup text
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Backup",
                      style:TextStyle(
                          color: AppColors.greyColor,
                          fontFamily: "Sf-SemiBold",
                          fontSize: 15
                      ),
                    )
                  ),
                  const SizedBox(height:5),


                  //Backup
                  InkWell(
                    onTap: () {
                      settingsProvider.changeListnerSetting("backup");
                    },
                    child: Container(
                      padding: const EdgeInsets.only(left: 20),
                      height:MediaQuery.of(context).size.height/10 ,
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.darkblueContainer,width: 0),
                          color: AppColors.ContainergreyhomeColor,
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: Row(
                        children: [
                          Expanded (
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(left: 0),
                                  child: Text(
                                    "Backup",
                                    style:TextStyle(
                                        color: AppColors.White,
                                        fontFamily: "Sf-SemiBold",
                                        fontSize: 15
                                    ),
                                  ),
                                ),
                                Text(
                                  "The backup contains all your private keys that give you access to your money",
                                  maxLines: 2,
                                  style:TextStyle(
                                    color: AppColors.WhiteText,
                                    fontFamily: "Sf-Regular",
                                    fontSize: 12,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.whiteColor,
                            size: 15,
                          ),
                          const SizedBox(width: 30),
                        ]
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  /*Container(
                    height:MediaQuery.of(context).size.height/10 ,
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.darkblueContainer,width: 0),
                        color: AppColors.ContainergreyhomeColor,
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Container(
                                // width: MediaQuery.of(context).size.width/7,
                                  child:
                                  Text("Restore", style:TextStyle(color: AppColors.White,fontFamily: "Sf-SemiBold",fontSize: 15),)
                              ),
                            ),
                            Container(
                                width: width/2,
                                child: Text("Upload backup file to restore your wallets. They will be merged to your current backup", style:TextStyle(color: AppColors.WhiteText,fontFamily: "Sf-Regular",fontSize: 12,overflow: TextOverflow.fade,),maxLines: 2,)),
                          ],),
                      ),
                      Expanded(child: SizedBox(width: width,)),
                      Container(
                          child:Icon(Icons.arrow_forward_ios_rounded,
                            color: AppColors.whiteColor,size: 15,)
                      ),
                      SizedBox(width: 30,),
                    ],),
                  ),*/

                ],
              ),
            ),

          ],
        ),
      )
    );
  }
}
