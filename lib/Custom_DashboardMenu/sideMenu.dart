import 'package:corewallet_desktop/Provider/SettingProvider.dart';
import 'package:corewallet_desktop/Ui/Authentication/login_page.dart';
import 'package:corewallet_desktop/Values/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../Provider/ExchangeProvider.dart';
import '../Provider/MarketProvider.dart';
import '../Provider/StakingProvider.dart';
import '../Provider/Wallet_Provider.dart';
import '../Provider/uiProvider.dart';
import '../Values/appColors.dart';
import '../Values/responsive.dart';


class SideMenu extends StatefulWidget {
  SideMenu({Key? key,}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}


class _SideMenuState extends State<SideMenu> {
  //demo
   UiProvider uiProvider = UiProvider();
   late MarketProvider marketProvider;
   late ExchangeProvider exchangeProvider;
   late StakingProvider stakingProvider;
   late SettingProvider settingProvider;

   Shader linearGradient = const LinearGradient(
     colors: <Color>[Colors.red, Colors.blue],
   ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

   WalletProvider walletProvider = WalletProvider();

   // List<bool> isSelected = List.filled(10,false);


   int isStockSetUp = 0,isTrading =0;


   @override
   void initState() {
     super.initState();
     uiProvider = Provider.of<UiProvider>(context, listen: false);
     walletProvider = Provider.of<WalletProvider>(context, listen: false);
     marketProvider = Provider.of<MarketProvider >(context, listen: false);
     exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);
     stakingProvider = Provider.of<StakingProvider>(context, listen: false);
     settingProvider = Provider.of<SettingProvider>(context, listen: false);
     // isSelected[0] = true;
   }

  @override
  Widget build(BuildContext context) {
    uiProvider = Provider.of<UiProvider>(context, listen: true);
    walletProvider = Provider.of<WalletProvider>(context, listen: true);
    marketProvider = Provider.of<MarketProvider>(context, listen: true);
    exchangeProvider = Provider.of<ExchangeProvider>(context, listen: true);
    stakingProvider = Provider.of<StakingProvider>(context, listen: true);
    settingProvider = Provider.of<SettingProvider>(context, listen: true);

    return Responsive.isTablet(context)|| Responsive.isDesktop(context)?
    Container(
      padding: EdgeInsets.only(left: 0,right: 0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.darklightgrey),
        color: Color(0xFF222831),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Padding(
        padding: const EdgeInsets.only(right: 0),
        child: Column(
          children: [

            Padding(
              padding:  EdgeInsets.only( top: 20,bottom:30,),
              child: Center(
                child: Container(
                  alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red,
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
                          'assets/icons/drawericon/colorlogoonly.svg',
                          height: 35,alignment: Alignment.center,
                        ),
                        SizedBox(height: 0,),
                        Center(
                          child: SvgPicture.asset(
                            'assets/icons/drawericon/catenatext.svg',
                            height: 29,width: 29,alignment: Alignment.center,
                          ),
                        )


                      ],
                    )),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                decoration: BoxDecoration(
                  color:uiProvider.dashboardPage == "Wallet"? AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),

                child: ListTile(
                  minLeadingWidth: 20,
                  horizontalTitleGap: 15,
                  dense: true,
                  selectedTileColor: Colors.red,
                  tileColor: AppColors.greenColor,
                  selected: true,
                  iconColor: Colors.red,
                  hoverColor: Colors.transparent,
                  leading: uiProvider.dashboardPage == "Wallet"? SvgPicture.asset(
                      'assets/icons/drawericon/walletgradent.svg',
                      width: 22
                  ) : SvgPicture.asset(
                      'assets/icons/drawericon/wallet-2 1.svg',
                      width: 22
                  ),

                  title:uiProvider.dashboardPage == "Wallet"?

                  ShaderMask(
                      blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect bounds) {
                      return AppColors.drawertextGradient.createShader(
                          Offset.zero & bounds.size);
                    },
                      child: Text('Wallet',style: TextStyle(height: 1.5,fontSize: 14,fontFamily: "Sf-Medium",color:   uiProvider.dashboardPage == "Wallet"? Colors.pink:AppColors.greyColor),)): Text('Wallet',style: TextStyle(color: AppColors.greydark,fontSize: 14,fontFamily: "Sf-Medium"),),
                             onTap: () {
                            setState(() {
                                  // print("click wallet");
                                  uiProvider.DashBoardpage("corewallet_dashboard");
                                  uiProvider.DashBoardpage("Wallet");
                                  walletProvider.changeListnerWallet("Wallet");
                                  // uiProvider.open   =! uiProvider.open;
                                  // isSelected = List.filled(10,false);
                                  // isSelected[0]=true;
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                decoration: BoxDecoration(
                  color:uiProvider.dashboardPage == "Market"? AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),


                child: ListTile(
                  // selected: true,
                  minLeadingWidth: 20,
                  horizontalTitleGap: 15,
                  dense: true,
                  enabled: true,
                  // selectedColor:isSelected[1]  == true ? Colors.grey:Colors.yellow,
                  // selectedTileColor:isSelected[1]  == true ? Colors.grey:Colors.yellow,
                  // tileColor:  isSelected[1]  == true ? Colors.pink:Colors.yellow,
                  // iconColor: isSelected[1]  == true ? Colors.red:Colors.yellow,
                  leading:uiProvider.dashboardPage == "Market"?
                  SvgPicture.asset(
                      'assets/icons/drawericon/trendgradient.svg',
                      width: 22
                  ): SvgPicture.asset(
                      'assets/icons/drawericon/trend-up 1.svg',
                      width: 22
                  ),




                  title:uiProvider.dashboardPage == "Market" ?
                  ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (Rect bounds) {
                        return AppColors.drawertextGradient.createShader(
                            Offset.zero & bounds.size);
                      },child: Text('Market',style: TextStyle(height: 1.5,fontSize: 14,fontFamily: "Sf-Medium",color:   uiProvider.dashboardPage == "Market"? Colors.pink:AppColors.greyColor),))
                  :
                  Text('Market',style: TextStyle(color: AppColors.greydark,fontSize: 14,fontFamily: "Sf-Medium")),
                  onTap: () {

                    uiProvider.DashBoardpage("corewallet_dashboard");
                    uiProvider.DashBoardpage("Market");
                    marketProvider.changeListnerMarket("Market");
                    uiProvider.notifyListeners();
                    setState(() {
                      // isSelected = List.filled(10,false);
                      uiProvider.dashboardPage == "Market";
                    });
                    // print(isSelected[1]);
                    },

                ),
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(left: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: uiProvider.dashboardPage == "Exchange" ?
                  AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),

                child: ListTile(
                  minLeadingWidth: 20,
                  horizontalTitleGap: 15,
                  dense: true,
                  leading:uiProvider.dashboardPage == "Exchange" ?
                  SvgPicture.asset(
                      'assets/icons/drawericon/framegradient.svg',
                      width: 22
                  ): SvgPicture.asset(
                      'assets/icons/drawericon/frame-1 1.svg',
                      width: 22
                  ),
                  title:uiProvider.dashboardPage == "Exchange"
                      ?
                  ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (Rect bounds) {
                        return AppColors.drawertextGradient.createShader(
                            Offset.zero & bounds.size);
                      },child: Text('Exchange',style: TextStyle(height: 1.5,fontSize: 14,fontFamily: "Sf-Medium",color:  uiProvider.dashboardPage == "Exchange"? Colors.pink:AppColors.greyColor),))
                  :
                  Text('Exchange',style: TextStyle(fontSize: 14,color: AppColors.greydark,fontFamily: "Sf-Medium",),),
                  onTap: () {
                    walletProvider.changeListnerWallet("PriceChart");
                    uiProvider.DashBoardpage("Exchange");
                    exchangeProvider.changeListnerExchange("Exchange");
                    uiProvider.notifyListeners();
                    // uiProvider.dashboardPage == "Exchange"
                    //     ?
                    // Exchange_Page():SizedBox();

                    setState(() {
                      // isSelected = List.filled(10,false);
                      // isSelected[2]=true;

                    });  },
                ),
              ),
            ),
/*
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(

                decoration: BoxDecoration(
                  color:isSelected[3]  == true ? AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),

                child: ListTile(
                  minLeadingWidth: 20,
                  horizontalTitleGap: 15,
                  dense: true,
                  leading:isSelected[3]  == false ?
                  SvgPicture.asset(
                      'assets/icons/drawericon/Send (1).svg',
                      width: 22
                  )

                      :
                  SvgPicture.asset(
                      'assets/icons/drawericon/buygradient.svg',
                      width: 22
                  ),
                  title: isSelected[3]  == false ?
                  Text('BuyCrypto',style: TextStyle(fontSize: 14,color: AppColors.greydark,fontFamily: "Sf-Medium",),)
                  :
                    ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect bounds) {
                       return AppColors.drawertextGradient.createShader(
                         Offset.zero & bounds.size);
                           },
                  child: Text('BuyCrypto',style: TextStyle(fontFamily: "Sf-Medium",height: 1.5,fontSize: 14),)),
                  onTap: () {
                    uiProvider.DashBoardpage("BuyCrypto");
                    uiProvider.notifyListeners();
                    // _hasBeenPressed = !_hasBeenPressed;
                    // uiProvider.hasBeenPressed=false;
                    // uiProvider.notifyListeners();
                    setState(() {
                      isSelected = List.filled(10,false);
                      isSelected[3]=true;

                    });                        },
                ),
              ),
            ),
*/
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                decoration: BoxDecoration(
                  color:uiProvider.dashboardPage == "Staking"
                      ? AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  //        gradient: const LinearGradient(
                  //       colors: [Color(0xFF222831), Color(0xFF222831),],
                  // ),
                  // border: Border.all(
                  //   color: Colors.grey,
                  //   width: 1.0,
                  // ),
                  borderRadius: BorderRadius.circular(15),
                ),

                child: ListTile(
                  minLeadingWidth: 20,
                  horizontalTitleGap: 15,
                  dense: true,
                  leading:uiProvider.dashboardPage == "Staking" ?
                    SvgPicture.asset(
                      'assets/icons/drawericon/stackgradient.svg',
                      width: 22
                  ):      SvgPicture.asset(
                      'assets/icons/drawericon/Send.svg',
                      width: 22
                  ),
                  title:uiProvider.dashboardPage == "Staking"
                      ?
                  ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (Rect bounds) {
                        return AppColors.drawertextGradient.createShader(
                            Offset.zero & bounds.size);
                      },
                      child: Text('Staking',style: TextStyle(height: 1.5,fontSize: 14,fontFamily: "Sf-Medium",color: uiProvider.dashboardPage == "Staking" ? Colors.pink:AppColors.greyColor),)): Text('Staking',style: TextStyle(color: AppColors.greydark,fontFamily: "Sf-Medium",fontSize: 14),),

                    onTap: () {
                    uiProvider.DashBoardpage("Staking");
                    stakingProvider.changeListnerStack("Staking");
                    uiProvider.notifyListeners();

                    setState(() {
                      // isSelected = List.filled(10,false);
                      // isSelected[4]=true;
                    });                        },
                ),
              ),
            ),


        /*    Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                decoration: BoxDecoration(
                  color:isSelected[5]  == true ? AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  //        gradient: const LinearGradient(
                  //       colors: [Color(0xFF222831), Color(0xFF222831),],
                  // ),
                  // border: Border.all(
                  //   color: Colors.grey,
                  //   width: 1.0,
                  // ),
                  borderRadius: BorderRadius.circular(15),
                ),

                child: ListTile(
                  minLeadingWidth: 20,
                  horizontalTitleGap: 15,
                  dense: true,
                  leading:isSelected[5]  == false ?
                  SvgPicture.asset(
                      'assets/icons/drawericon/refreshwhite.svg',
                      width: 22
                  )

                      :
                  SvgPicture.asset(
                      'assets/icons/drawericon/timegradient.svg',
                      width: 22
                  ),
                  title:
                  isSelected[5]  == false ?
                  Text('Histroy',style: TextStyle(fontSize: 14,color: AppColors.greydark,fontFamily: "Sf-Medium",),)
                    :
                    ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect bounds) {
                      return AppColors.drawertextGradient.createShader(
                          Offset.zero & bounds.size);
                    },
                    child: Text('Histroy',style: TextStyle(height: 1.5,fontSize: 14,fontFamily: "Sf-Medium",),)),
                  onTap: () {
                    uiProvider.DashBoardpage("Histroy");

                    uiProvider.notifyListeners();
                      setState(() {
                      isSelected = List.filled(10,false);
                      isSelected[5]=true;
                    });                           },
                ),
              ),
            ),*/
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                decoration: BoxDecoration(
                  color:uiProvider.dashboardPage == "WatchList"? AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  //        gradient: const LinearGradient(
                  //       colors: [Color(0xFF222831), Color(0xFF222831),],
                  // ),
                  // border: Border.all(
                  //   color: Colors.grey,
                  //   width: 1.0,
                  // ),
                  borderRadius: BorderRadius.circular(15),
                ),

                child: ListTile(
                  minLeadingWidth: 20,
                  horizontalTitleGap: 15,
                  dense: true,
                  leading: uiProvider.dashboardPage == "WatchList"?    SvgPicture.asset(
                    'assets/icons/drawericon/starwhite.svg',
                    width: 22,color: Colors.deepPurpleAccent,
                  ):  SvgPicture.asset(
                      'assets/icons/drawericon/starwhite.svg',
                      width: 22
                  )
                      ,
                  title:uiProvider.dashboardPage == "WatchList"
                      ? ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (Rect bounds) {
                        return AppColors.drawertextGradient.createShader(
                            Offset.zero & bounds.size);
                      },child: Text('Watchlist',style: TextStyle(height: 1.5,fontSize: 14,fontFamily: "Sf-Medium",),)):Text('Watchlist',style: TextStyle(fontSize: 14,color: AppColors.greydark,fontFamily: "Sf-Medium",),)
                  ,

                  onTap: () {

                    uiProvider.DashBoardpage("WatchList");
                    uiProvider.notifyListeners();

                    setState(() {
                      // isSelected = List.filled(10,false);
                      // isSelected[6]=true;
                    });
                    },
                ),
              ),
            ),

            Spacer(),
//setting section

            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                decoration: BoxDecoration(
                  color:uiProvider.dashboardPage == "Setting" ? AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),

                child: ListTile(
                  minLeadingWidth: 20,
                  horizontalTitleGap: 15,
                  dense: true,
                  contentPadding: EdgeInsets.only(left: 20),
                  leading:uiProvider.dashboardPage == "Setting"  ? SvgPicture.asset(
                      'assets/icons/drawericon/settinggradient.svg',
                      width: 22
                  )
                      :
                  SvgPicture.asset(
                      'assets/icons/drawericon/setting-2 1.svg',
                      width: 22
                  ),

                  title:uiProvider.dashboardPage == "Setting"  ?  ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (Rect bounds) {
                        return AppColors.drawertextGradient.createShader(
                            Offset.zero & bounds.size);
                      },
                      child: Text('Setting',style: TextStyle(height: 1.5,fontSize: 14,fontFamily: "Sf-Medium",),)):
                  Text('Setting',style: TextStyle(fontSize: 14,color: AppColors.greydark,fontFamily: "Sf-Medium",),)

                ,
                  onTap: () {

                    uiProvider.DashBoardpage("Setting");
                    settingProvider.changeListnerSetting("Setting");
                    uiProvider.notifyListeners();
                    setState(() {
                      // isSelected = List.filled(10,false);
                      // isSelected[7]=true;
                    });
                  },
                ),
              ),
            ),
/*
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Container(

                decoration: BoxDecoration(
                  color:isSelected[8]  == true ? AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  //        gradient: const LinearGradient(
                  //       colors: [Color(0xFF222831), Color(0xFF222831),],
                  // ),
                  // border: Border.all(
                  //   color: Colors.grey,
                  //   width: 1.0,
                  // ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  minLeadingWidth: 20,
                  dense: true,
                  horizontalTitleGap: 15,

                  leading: isSelected[8]  == false ?   SvgPicture.asset(
                      'assets/icons/drawericon/lifebuoy 1.svg',
                      width: 22
                  )

                        :
                    SvgPicture.asset(
                    'assets/icons/drawericon/lifebuoy 1.svg',
                    width: 22,color: Colors.deepPurpleAccent,
                ),
                  title:isSelected[8]  == false ?
                  Text('Support',style: TextStyle(fontSize: 14,color: AppColors.greydark,fontFamily: "Sf-Medium",),)
                  :
                  ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (Rect bounds) {
                        return AppColors.drawertextGradient.createShader(
                            Offset.zero & bounds.size);
                      },
                      child: Text('Support',style: TextStyle(height: 1.5,fontSize: 14,fontFamily: "Sf-Medium",),)),
                  onTap: () {
                    uiProvider.DashBoardpage("Support");
                    uiProvider.notifyListeners();
                    setState(() {
                      isSelected = List.filled(10,false);
                      isSelected[8]=true;
                    });                            },
                ),
              ),
            ),
*/

            Divider(
              color: AppColors.greydark.withOpacity(0.3),
              indent: 5,
               endIndent: 5,
              thickness: 1.5,
              height: 8,
            ),


            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Container(
                decoration: BoxDecoration(
                  color:uiProvider.dashboardPage == "Logout" ? AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                ),

                child: ListTile(

                  minLeadingWidth: 20,
                  horizontalTitleGap: 15,
                  dense: true,
                  leading: uiProvider.dashboardPage == "Logout" ?


                    SvgPicture.asset(
                    'assets/icons/drawericon/logout 1.svg',
                      width: 22,color: Colors.deepPurpleAccent,
                ):SvgPicture.asset(
                      'assets/icons/drawericon/logout 1.svg',
                      width: 22
                  ),
                  title:uiProvider.dashboardPage == "Logout" ?    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (Rect bounds) {
                        return AppColors.drawertextGradient.createShader(
                            Offset.zero & bounds.size);
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          height: 1.5,fontSize: 14,fontFamily: "Sf-Medium",
                        ),
                      )
                  ):Text('Logout',style: TextStyle(fontSize: 14,color: AppColors.greydark,fontFamily: "Sf-Medium"),),
                  onTap: () {
                    setState(() {
                      Utils.pageName="LoginPage";
                    });
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) =>const LoginPage(),
                        ), (route) => true);


                  },
                ),
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    )
      :
    Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.darklightgrey),
           color: Color(0xFF222831),
          borderRadius: BorderRadius.circular(20),
        ),

       child: Column(
          children: [
            Padding(
              padding:  EdgeInsets.only( top: 40,bottom:30,),
              child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red,
                        blurRadius: 80.0,
                        // spreadRadius: 1.0,
                      )
                    ],
                  ),

                  child:  SvgPicture.asset(
                      'assets/icons/drawericon/colorlogoonly.svg',
                    height: 45,
                  )
              ),
            ),


            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Container(
                decoration: BoxDecoration(
                  color:uiProvider.dashboardPage == "Wallet" ? AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                ),

                child: Column(
                  children: [
                    ListTile(
                      // minLeadingWidth: 20,
                      // horizontalTitleGap: 20,
                     dense: true,
                      title:
                      Container(
                        height: 20,
                        width: 20 ,
                        child: uiProvider.dashboardPage == "Wallet" ?
                        SvgPicture.asset(
                            'assets/icons/drawericon/walletgradent.svg',
                            width: 22
                        )
                            :
                        Center(
                          child:SvgPicture.asset(
                              'assets/icons/drawericon/wallet-2 1.svg',
                              width: 22
                          )
                        )
                            ,
                      ),

                      subtitle:uiProvider.dashboardPage == "Wallet"?
                      Center(
                        child: ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (Rect bounds) {
                              return AppColors.drawertextGradient.createShader(
                                  Offset.zero & bounds.size);
                            },child: Text('Wallet',style: TextStyle(height: 1.5,fontSize: 12,fontFamily: "Sf-Medium",color: uiProvider.dashboardPage == "Wallet" ? Colors.pink:AppColors.greyColor),)),
                      )
                          :
                      Center(child: Text('Wallet',style: TextStyle(color: AppColors.greydark,fontSize: 12,fontFamily: "Sf-Medium"),))

                      ,
                      onTap: () {
                        setState(() {
                          // print("click wallet");
                          uiProvider.DashBoardpage("corewallet_dashboard");
                          uiProvider.DashBoardpage("Wallet");
                          walletProvider.changeListnerWallet("Wallet");
                          // uiProvider.open   =! uiProvider.open;
                          // isSelected = List.filled(10,false);
                          // isSelected[0]=true;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                decoration: BoxDecoration(
                  color:uiProvider.dashboardPage == "Market"? AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                ),


                child: Column(
                  children: [
                    ListTile(
                      selected: true,
                      // minLeadingWidth: 20,
                      // horizontalTitleGap: 20,
                      dense: true,
                      // enabled: true,
                      // selectedColor:isSelected[1]  == true ? Colors.grey:Colors.yellow,
                      // selectedTileColor:isSelected[1]  == true ? Colors.grey:Colors.yellow,
                      // tileColor:  isSelected[1]  == true ? Colors.pink:Colors.yellow,
                      // iconColor: isSelected[1]  == true ? Colors.red:Colors.yellow,
                      title:

                      Container(
                        height: 20,
                        width: 20 ,

                        child: uiProvider.dashboardPage == "Market" ?
                        SvgPicture.asset(
                            'assets/icons/drawericon/trendgradient.svg',
                            width: 22
                        )
                            :
                        SvgPicture.asset(
                            'assets/icons/drawericon/trend-up 1.svg',
                            width: 22
                        ),
                      ),



                      subtitle:uiProvider.dashboardPage == "Market" ? Center(
                        child: ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (Rect bounds) {
                              return AppColors.drawertextGradient.createShader(
                                  Offset.zero & bounds.size);
                            },child: Text('Market',style: TextStyle(height: 1.5,fontSize: 12,fontFamily: "Sf-Medium",color: uiProvider.dashboardPage == "Market"? Colors.pink:AppColors.greyColor),)),
                      ):
                      Center(child: Text('Market',style: TextStyle(color: AppColors.greydark,fontSize: 12,fontFamily: "Sf-Medium"),))
                          ,
                      onTap: () {

                        uiProvider.DashBoardpage("corewallet_dashboard");
                        uiProvider.DashBoardpage("Market");
                        marketProvider.changeListnerMarket("Market");
                        uiProvider.notifyListeners();
                        setState(() {
                          // isSelected = List.filled(10,false);
                          // isSelected[1]=true;
                        });

                      },

                    ),
                  ],
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                decoration: BoxDecoration(
                  color:uiProvider.dashboardPage == "Exchange"? AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                ),

                child: ListTile(
                  // minLeadingWidth: 20,
                  // horizontalTitleGap: 20,
                  dense: true,
                  title:Container(

                    height: 20,
                    width: 20,
                    child: uiProvider.dashboardPage == "Exchange"?
                    SvgPicture.asset(
                        'assets/icons/drawericon/framegradient.svg',
                        width: 22
                    )
                        :
                    SvgPicture.asset(
                        'assets/icons/drawericon/frame-1 1.svg',
                        width: 22
                    )
                        ,
                  ),
                  subtitle:Center(
                    child: uiProvider.dashboardPage == "Exchange"
                        ?
                    ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (Rect bounds) {
                          return AppColors.drawertextGradient.createShader(
                              Offset.zero & bounds.size);
                        },child: Text('Exchange',style: TextStyle(height: 1.8,fontSize: 12,fontFamily: "Sf-Medium",color: uiProvider.dashboardPage == "Market" ? Colors.pink:AppColors.greyColor,),))
                        :
                    Text('Exchange',style: TextStyle(color: AppColors.greydark,fontFamily: "Sf-Medium",fontSize: 12),)
                        ,
                  ),
                  onTap: () {
                    walletProvider.changeListnerWallet("PriceChart");
                    uiProvider.DashBoardpage("Exchange");
                    exchangeProvider.changeListnerExchange("Exchange");
                    uiProvider.notifyListeners();
                    // uiProvider.dashboardPage == "Exchange"
                    //     ?
                    // Exchange_Page():SizedBox();

                    setState(() {
                      // isSelected = List.filled(10,false);
                      // isSelected[2]=true;

                    });                        },
                ),
              ),
            ),


/*
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                decoration: BoxDecoration(
                  color:isSelected[3]  == true ? AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                ),

                child: ListTile(
                  minLeadingWidth: 20,
                  horizontalTitleGap: 20,
                  dense: true,
                  title:Container(
                    width: 20,
                    height: 20,
                    child: isSelected[3]  == false ?
                    SvgPicture.asset(
                        'assets/icons/drawericon/Send (1).svg',
                        width: 22
                    )
                        :
                    SvgPicture.asset(
                        'assets/icons/drawericon/buygradient.svg',
                        width: 22
                    ),
                  ),
                  subtitle: Container(
                    width: 20,
                    // height: 20,
                    child: isSelected[3]  == false ?
                    Text('Buy Crypto',style: TextStyle(height: 2,color: AppColors.greydark,fontFamily: "Sf-Medium",),)
                        :
                    ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (Rect bounds) {
                          return AppColors.drawertextGradient.createShader(
                              Offset.zero & bounds.size);
                        },
                        child: Text('Buy Crypto',style: TextStyle(height: 2,fontSize: 14,fontFamily: "Sf-Medium",color:  isSelected[1]  == true ? Colors.pink:AppColors.greyColor),)),
                  ),
                  onTap: () {
                    uiProvider.DashBoardpage("BuyCrypto");
                    uiProvider.notifyListeners();
                    // _hasBeenPressed = !_hasBeenPressed;
                    // uiProvider.hasBeenPressed=false;
                    // uiProvider.notifyListeners();
                    setState(() {
                      isSelected = List.filled(10,false);
                      isSelected[3]=true;

                    });                        },
                ),
              ),
            ),
*/


            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: uiProvider.dashboardPage == "Staking" ? AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  //        gradient: const LinearGradient(
                  //       colors: [Color(0xFF222831), Color(0xFF222831),],
                  // ),
                  // border: Border.all(
                  //   color: Colors.grey,
                  //   width: 1.0,
                  // ),
                  borderRadius: BorderRadius.circular(17),
                ),

                child: ListTile(
                  // minLeadingWidth: 20,
                  // horizontalTitleGap: 20,
                  dense: true,
                  title:Container(
                    width: 20,height: 20,
                    child: uiProvider.dashboardPage == "Staking"?
                    SvgPicture.asset(
                        'assets/icons/drawericon/stackgradient.svg',
                        width: 22
                    )
                    :
                    SvgPicture.asset(
                        'assets/icons/drawericon/Send.svg',
                        width: 22
                    ),
                  ),
                  subtitle:Container(
                    alignment: Alignment.center,
                    // height: 20,
                    child:  uiProvider.dashboardPage == "Staking"
                        ?
                    ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (Rect bounds) {
                          return AppColors.drawertextGradient.createShader(
                              Offset.zero & bounds.size);
                        },
                        child: Text('Staking',style: TextStyle(height: 2,fontSize: 12,fontFamily: "Sf-Medium",color:  uiProvider.dashboardPage == "Staking"? Colors.pink:AppColors.greyColor),)): Text('Staking',style: TextStyle(fontSize: 12,color: AppColors.greydark,fontFamily: "Sf-Medium",),),
                  ),
                  onTap: () {
                    uiProvider.DashBoardpage("Staking");
                    stakingProvider.changeListnerStack("Staking");
                    uiProvider.notifyListeners();

                    setState(() {
                      // isSelected = List.filled(10,false);
                      // isSelected[4]=true;
                    });                        },
                ),
              ),
            ),


/*
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                decoration: BoxDecoration(
                  color:isSelected[5]  == true ? AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  //        gradient: const LinearGradient(
                  //       colors: [Color(0xFF222831), Color(0xFF222831),],
                  // ),
                  // border: Border.all(
                  //   color: Colors.grey,
                  //   width: 1.0,
                  // ),
                  borderRadius: BorderRadius.circular(17),
                ),

                child: ListTile(
                  // minLeadingWidth: 20,
                  // horizontalTitleGap: 20,
                  dense: true,
                  title:Center(
                    child: Container(
                      alignment: Alignment.center,
                      width: 20,
                      height: 20,
                      child: isSelected[5]  == false ?
                      SvgPicture.asset(
                          'assets/icons/drawericon/refreshwhite.svg',
                          width: 22
                      )

                          :
                      SvgPicture.asset(
                          'assets/icons/drawericon/timegradient.svg',
                          width: 22
                      ),
                    ),
                  ),
                  subtitle:
                  isSelected[5]  == false ?
                  Center(child: Text('Histroy',style: TextStyle(fontSize: 12,color: AppColors.greydark,fontFamily: "Sf-Medium",),))
                      :
                  Center(
                    child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (Rect bounds) {
                          return AppColors.drawertextGradient.createShader(
                              Offset.zero & bounds.size);
                        },
                        child: Text('Histroy',style: TextStyle(color:  isSelected[5]  == true ? Colors.pink:AppColors.greyColor,height: 1.7,fontSize: 12,fontFamily: "Sf-Medium",),)),
                  ),
                  onTap: () {
                    uiProvider.DashBoardpage("Histroy");

                    uiProvider.notifyListeners();
                    setState(() {
                      isSelected = List.filled(10,false);
                      isSelected[5]=true;
                    });                           },
                ),
              ),
            ),
*/


            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: uiProvider.dashboardPage == "WatchList"? AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  //        gradient: const LinearGradient(
                  //       colors: [Color(0xFF222831), Color(0xFF222831),],
                  // ),
                  // border: Border.all(
                  //   color: Colors.grey,
                  //   width: 1.0,
                  // ),
                  borderRadius: BorderRadius.circular(17),
                ),

                child: ListTile(
                  minLeadingWidth: 20,
                  horizontalTitleGap: 20,
                  dense: true,
                  title: Container(
                    height: 20,width: 20,
                    child:  uiProvider.dashboardPage == "WatchList"?     SvgPicture.asset(
                      'assets/icons/drawericon/starwhite.svg',
                      width: 22,color: Colors.deepPurpleAccent,
                    ):SvgPicture.asset(
                        'assets/icons/drawericon/starwhite.svg',
                        width: 22
                    )

                        ,
                  ),
                  subtitle:Container(
                    alignment: Alignment.center,

                    width: 25,
                    height: 20,
                    child:  uiProvider.dashboardPage == "WatchList"
                        ?    ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (Rect bounds) {
                          return AppColors.drawertextGradient.createShader(
                              Offset.zero & bounds.size);
                        },child: Text('Watchlist',style: TextStyle(color:  uiProvider.dashboardPage == "WatchList" ? Colors.pink:AppColors.greyColor,height: 2,fontSize: 12,fontFamily: "Sf-Medium",),))
                        :
                    Text('Watchlist',style: TextStyle(fontSize: 12,color: AppColors.greydark,fontFamily: "Sf-Medium",),)
                        ,
                  ),

                  onTap: () {

                    uiProvider.DashBoardpage("WatchList");
                    uiProvider.notifyListeners();

                    setState(() {
                      // isSelected = List.filled(10,false);
                      // isSelected[6]=true;
                    });
                  },
                ),
              ),
            ),

            Spacer(),
         //SETTINGS SECTION

            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                decoration: BoxDecoration(
                  color:uiProvider.dashboardPage == "Setting" ?
                  AppColors.darkBlack0A0.withOpacity(0.2) :Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                ),

                child: ListTile(
                  minLeadingWidth: 20,
                  horizontalTitleGap: 20,
                  dense: true,
                  contentPadding: EdgeInsets.only(left: 0),
                  title:Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      child: uiProvider.dashboardPage == "Setting"?

                      SvgPicture.asset(
                          'assets/icons/drawericon/settinggradient.svg',
                          width: 22
                      ):
                      SvgPicture.asset(
                          'assets/icons/drawericon/setting-2 1.svg',
                          width: 22
                      )
                          ,

                    ),
                  ),

                  subtitle:Center(
                    child: Container(
                      child: uiProvider.dashboardPage == "Setting" ?
                      ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (Rect bounds) {
                            return AppColors.drawertextGradient.createShader(
                                Offset.zero & bounds.size);
                          },
                          child: Text('Setting',style: TextStyle(color:   uiProvider.dashboardPage == "Setting" ? Colors.pink:AppColors.greyColor,height: 1.5,fontSize: 14,fontFamily: "Sf-Medium",),))
                          :
                      Text('Setting',style: TextStyle(color: AppColors.greydark,fontFamily: "Sf-Medium",),),
                    ),
                  ),
                  onTap: () {

                    uiProvider.DashBoardpage("Setting");
                    uiProvider.notifyListeners();
                    setState(() {
                      // isSelected = List.filled(10,false);
                      // isSelected[7]=true;
                    });
                  },
                ),
              ),
            ),
/*
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Container(

                decoration: BoxDecoration(
                  color:isSelected[8]  == true ? AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: ListTile(
                  minLeadingWidth: 20,
                  dense: true,
                  horizontalTitleGap: 20,

                  title: Container(
                    height: 20,
                    width: 20,
                    child: isSelected[8]  == false ?   SvgPicture.asset(
                        'assets/icons/drawericon/lifebuoy 1.svg',
                        width: 22
                    )

                        :
                    SvgPicture.asset(
                      'assets/icons/drawericon/lifebuoy 1.svg',
                      width: 22,color: Colors.deepPurpleAccent,
                    ),
                  ),
                  subtitle:Container(
                    alignment: Alignment.center,

                    width: 30,
                    height: 20,
                    child: isSelected[8]  == false ?
                    Text('Support',style: TextStyle(color: AppColors.greydark,fontFamily: "Sf-Medium",),)
                        :
                    ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (Rect bounds) {
                          return AppColors.drawertextGradient.createShader(
                              Offset.zero & bounds.size);
                        },
                        child: Text('Support',style: TextStyle(height: 1.5,fontSize: 14,fontFamily: "Sf-Medium",),)),
                  ),
                  onTap: () {
                    uiProvider.DashBoardpage("Support");
                    uiProvider.notifyListeners();
                    setState(() {
                      isSelected = List.filled(10,false);
                      isSelected[8]=true;
                    });                            },
                ),
              ),
            ),
*/

            Divider(
              color: AppColors.greydark.withOpacity(0.3),
              indent: 5,
              endIndent: 5,
              thickness: 1,
              height: 8,
            ),


            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: uiProvider.dashboardPage == "Logout" ? AppColors.darkBlack0A0.withOpacity(0.2): Colors.transparent,
                  borderRadius: BorderRadius.circular(17),
                ),

                child: ListTile(
                  minLeadingWidth: 20,
                  horizontalTitleGap: 20,
                  dense: true,
                  title: SizedBox(
                    width: 20,
                    height: 20,
                    child:  uiProvider.dashboardPage == "Logout"?

                    SvgPicture.asset(
                      'assets/icons/drawericon/logout 1.svg',
                      width: 22,color: Colors.deepPurpleAccent,

                    ):  SvgPicture.asset(
                        'assets/icons/drawericon/logout 1.svg',
                        width: 22
                    ),
                  ),
                  subtitle:Center(
                    child: SizedBox(
                    //  height: 20,
                     // width: 23,
                      child: uiProvider.dashboardPage == "Logout"
                          ?
                      ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (Rect bounds) {
                            return AppColors.drawertextGradient.createShader(
                                Offset.zero & bounds.size);
                          },
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              // height: 1.5,
                              fontSize: 14,
                              fontFamily: "Sf-Medium",
                            ),
                          )
                      )
                          :
                      const Text(
                        'Logout',
                        style: TextStyle(
                          color: AppColors.greydark,
                        ),
                      )
                          ,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      Utils.pageName="LoginPage";
                    });
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) =>const LoginPage(),
                        ), (route) => true);
                  },

                ),
              ),
            )
          ],
        ),


      
      );
  }
}





class DrawerListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const DrawerListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: onTap,
    );
  }
}