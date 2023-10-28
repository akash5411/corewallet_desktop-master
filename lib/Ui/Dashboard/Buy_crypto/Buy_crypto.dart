import 'package:corewallet_desktop/Provider/BuyCryptoProvider.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:corewallet_desktop/Values/styleandborder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../Exchange/Exchange.dart';


class Buy_Crypto_Page extends StatefulWidget {
  const Buy_Crypto_Page({Key? key}) : super(key: key);

  @override
  State<Buy_Crypto_Page> createState() => _Buy_Crypto_PageState();
}

class _Buy_Crypto_PageState extends State<Buy_Crypto_Page> {
  late BuyCryptoProvider buycryptoProvider;



  int? _selected;
  List CoinDrop = [];
  _showDialogRadioobutttonCoin(BuildContext context) {
    showDialog(
      context: context,

      builder: (BuildContext context,) {
        return StatefulBuilder(
          builder: (context, StateSetter setState) {
            return AlertDialog(
              actionsPadding:EdgeInsets.symmetric(vertical: 10,horizontal: 30),
              contentPadding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(12.0),),),
              backgroundColor:AppColors.containerbackgroundgrey,
              alignment: Alignment.center,
              insetPadding:EdgeInsets.symmetric(vertical: 20,horizontal: 20),
              icon: Row(
                children: [
                  InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back_ios_new_rounded,color: AppColors.whiteColor,weight: 3)),
                  SizedBox(width: 8,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width/2,
                    height: MediaQuery.of(context).size.height/25,

                    child: TextField(
                      style: TextStyle(color: AppColors.whiteColor),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(0),
                        fillColor: AppColors.darklightgrey,

                        filled: true,
                        isDense: true,
                        hintText: "Search",
                        hintStyle: TextStyle(color: AppColors.greydark,fontFamily: "Sf-Regular"),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(
                              left: 0,
                              right: 0,
                              top: 5,
                              bottom: 5),
                          child: Image.asset(
                            "assets/icons/search.png",height: 0,
                          ),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(25.0))),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors.transparent),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors.transparent, width: 2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),

                  ),
                ],
              ),

              content: SingleChildScrollView(
                child: Container(
                  width:MediaQuery.of(context).size.width/3,

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ConstrainedBox(
                        constraints: BoxConstraints(

                          maxHeight: MediaQuery
                              .of(context)
                              .size
                              .height * 0.8,
                        ),
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: CoinDrop.length,
                            itemBuilder: (BuildContext context, int index) {
                              return RadioListTile(contentPadding: EdgeInsets.all(0),

                                  dense: true,
                                  controlAffinity: ListTileControlAffinity.trailing,
                                  title: Row(
                                    children: [
                                      Image.asset(CoinDrop[index].img,height: 50),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(CoinDrop[index].name, style: TextStyle(
                                            color: AppColors.white,
                                            fontFamily: 'Sf-SemiBold',
                                            fontSize: 13,

                                          ),),
                                          Text(CoinDrop[index].shortname, style: TextStyle(
                                            color: AppColors.white,
                                            fontFamily: 'Sf-Regular',
                                            fontSize: 12,

                                          ),),
                                        ],
                                      ),
                                      Expanded(child: SizedBox(width: 2,)),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [

                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(CoinDrop[index].price, style: TextStyle(
                                                    color: AppColors.white,
                                                    fontFamily: 'Sf-Regular',
                                                    fontSize: 13,

                                                  ),),
                                                  Column(children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 5),
                                                      child: Text(CoinDrop[index].shortname, style: TextStyle(
                                                        color: AppColors.white,
                                                        fontFamily: 'Sf-SemiBold',
                                                        fontSize: 13,

                                                      ),),
                                                    ),
                                                    Text("\$${CoinDrop[index].coinsdollar}", style: TextStyle(
                                                      color: AppColors.white,
                                                      fontFamily: 'Sf-Regular',
                                                      fontSize: 11,

                                                    ),textAlign: TextAlign.end),

                                                  ],)
                                                ],)


                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  value: index,
                                  groupValue: _selected,
                                  toggleable: true,


                                  onChanged: (value) {
                                    //   exchangeProvider.changeListnerExchange("exchangehistroy");


                                    setState(() {
                                      _selected = index;
                                      // buycryptoProvider.changeListnerExchange("exchangehistroy");
                                      Navigator.pop(context);

                                    });
                                  });
                            }),
                      ),

                    ],
                  ),
                ),
              ),
            );
          },

        );
      },
    );
  }

  @override
  void initState() {
    buycryptoProvider = Provider.of<BuyCryptoProvider>(context, listen: false);
  }
  var width,height;
  @override
  Widget build(BuildContext context) {
    width=MediaQuery.of(context).size.width;
    height=MediaQuery.of(context).size.height;
    buycryptoProvider = Provider.of<BuyCryptoProvider>(context, listen: true);


    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20,right: 20,left: 20),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [

                  InkWell(
                    onTap: (){

                      // walletProvider.changeListnerWallet("PriceChart");

                      // Navigator.pop(context);
                    },
                    child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: Boxdec.BackButtonGradient,
                        child: Center(

                          child: SvgPicture.asset(
                        'assets/icons/Market/refresh 1.svg',
                            width: 22
                        ),),),
                  ),

                  Expanded(child: SizedBox(width: 1,)),

                  Padding(
                    padding: const EdgeInsets.only(left: 140),
                    child: Text("Buy Crypto",style: TextStyle(color: AppColors.White,fontFamily: "Sf-SemiBold",fontSize: 20)),
                  ),
                  Expanded(child: SizedBox(width: 1,)),

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
                              children: [
                                SizedBox(width: 20,),

                                Padding(
                                  padding: const EdgeInsets.only(right: 28),
                                  child: Text("Balance:",style:TextStyle(color:AppColors.greydark, fontSize: 12,    fontFamily: 'Sf-SemiBold',)),
                                ),
                                SizedBox(width: 0,),
                                Padding(
                                  padding:  EdgeInsets.only(right: 20),
                                  child: Text("\$ 0.0",style:TextStyle(color: Colors.white,fontSize: 16  ,fontFamily: 'Sf-SemiBold',)),
                                ),
                              ],),
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
                                    SizedBox(width: 5,),
                                    SvgPicture.asset(
                                        'assets/icons/wallet/Vector.svg',
                                        width: 22
                                    ),
                                    // Image.asset("assets/images/Vector (2).png",width: 20),
                                    SizedBox(width: 5,),
                                    Text("0.0",style:TextStyle(color: Colors.grey,fontSize: 16,   fontFamily: 'Sf-Regular',)),
                                    SizedBox(width: 15,),

                                  ],),
                              ),
                            ),  ),
                        ],
                      )
                  ),
                ],
              ),
              SizedBox(height: 10,),
//secondrow


              Container(
                padding: EdgeInsets.only(top: 10,bottom: 10),
                margin: EdgeInsets.symmetric(horizontal: 20,vertical: 40),
                alignment: Alignment.center,
                width:Responsive.isTablet(context)?width/2:Responsive.isMobile(context)?width/2: width/3,
                decoration: BoxDecoration(color: AppColors.ContainerblackColor,borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: SizedBox(width: 30,)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 20,),

                        Text("The Average Delivery Time", style:TextStyle(color: AppColors.white.withOpacity(0.6),fontFamily: "Sf-SemiBold",fontSize: 11),),
                        SizedBox(height: 4,),
                        Text("10 to 30 Minutes", style:TextStyle(color: AppColors.White,fontFamily: "Sf-Regular",fontSize: 10),),
                        SizedBox(height: 4,),

                      ],
                    ),
                     Expanded(child: SizedBox(width: 30,)),
                     Expanded(child: SizedBox(width: 30,)),
                   // SizedBox(width: 80,),
                    Container(
                      alignment: Alignment.center,
                      height: height*0.04,
                      width:width*0.0002,
                      color: AppColors.greyColor,

                    ),
                   // SizedBox(width: 60,),

                    Expanded(child: SizedBox(width: 30,)),
                   SizedBox(width: 20,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Network Fee", style:TextStyle(color: AppColors.white.withOpacity(0.6),fontFamily: "Sf-SemiBold",fontSize: 10),),
                        SizedBox(height: 4,),
                        Text("5%", style:TextStyle(color: AppColors.White,fontFamily: "Sf-Regular",fontSize: 12),),
                        SizedBox(height: 4,),
                        Text("are included", style:TextStyle(color: AppColors.greyColor,fontFamily: "Sf-SemiBold",fontSize: 10),),

                      ],
                    ),
                    Expanded(child: SizedBox(width: 30,)),
                    Spacer(),
                    Spacer(),
                    Spacer(),
                  ],),),





              SizedBox(height: height*0.09,),
              InkWell(
                onTap: (){
                  // _showDialogRadioobutttonCoin(context);
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
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            shadows: [

                            ],
                            fontFamily: 'Sf-SemiBold',
                            fontSize: 13,

                          ),

                        ),
                      ),),
                    ],
                  ),),
              ),


              SizedBox(height: 70,)

              // Image.asset("assets/icons/cirvedleft.png",width: width/4,)

            ],),
        ),
      ),
    );
  }
}
