import 'package:corewallet_desktop/Provider/HistroyProvider.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:corewallet_desktop/Values/styleandborder.dart';
// import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Exchange/Exchange.dart';

class HistoryModel {
  // bool expanded = false;
  String? name ,shortname, send,number,from,to,value;
  String? img;


  HistoryModel(
      {required this.name,
        this.shortname,
        this.send,

        this.number,
        this.from,
        this.to,
        this.value,
        this.img});
}

class Histroy_Page extends StatefulWidget {
  const Histroy_Page({Key? key}) : super(key: key);

  @override
  State<Histroy_Page> createState() => _Histroy_PageState();
}

class _Histroy_PageState extends State<Histroy_Page> {
  late HistroyProvider histroyProvider;
  // final GlobalKey<ExpansionTileCardState> cardA = new GlobalKey();
  // final GlobalKey<ExpansionTileCardState> cardB = new GlobalKey();
  bool onclickYN = false;
  bool _isExpanded = false;

  String datetime = DateFormat("dd MMM, yyyy").format(DateTime.now());

  bool click = true;
  List<HistoryModel> itemData = <HistoryModel>[
    HistoryModel(
      img:"assets/icons/bitcoin.png" ,
      name: 'Bitcoin',
      shortname: 'BTC',
      send: 'sent',
      number: '0.03',
      from: '0x4c...nb7v',
      to: '0x4c...nb7v',
      value: '644.87',),
    HistoryModel(
      img:"assets/icons/Binance.png",
      name: 'Binance',
      shortname: 'BNB',
      send: 'recieve',
      number: '0.03',
      from: '0x4c...nb7v',
      to: '0x4c...nb7v',
      value: '644.87',),
    HistoryModel(
      img: "assets/icons/Core_Multichain.png",
      name: 'Core MultiChain',
      shortname: 'CMCX',
      send: 'recieve',
      number: '0.03',
      from: '0x4c...nb7v',
      to: '0x4c...nb7v',
      value: '644.87',),
  ];
  int? _selected;


/*  List<ExchangeDropdownCoin> CoinDrop = [
    ExchangeDropdownCoin(
        name: 'Bitcoin',
        img: "assets/icons/bitcoin.png",
        shortname: "BTC",
        price: "0",
        coinsdollar: "0.0"),
    // Exercise(name: 'Ethereum',img: "assets/icons/bitcoin.png"),
    ExchangeDropdownCoin(
        name: 'Thether',
        img: "assets/icons/Tether.png",
        shortname: "USDT",
        price: "0",
        coinsdollar: "0.0"),
    ExchangeDropdownCoin(
        name: 'Binance',
        img: "assets/icons/Binance.png",
        shortname: "BNB",
        price: "0",
        coinsdollar: "0.0"),
    ExchangeDropdownCoin(
        name: 'Core MultiChain',
        img: "assets/icons/Core_Multichain.png",
        shortname: "CMCX",
        price: "0",
        coinsdollar: "0.0"),
    ExchangeDropdownCoin(
        name: 'Bitcoin',
        img: "assets/icons/bitcoin.png",
        shortname: "BTC",
        price: "0",
        coinsdollar: "0.0"),
    ExchangeDropdownCoin(
        name: 'USD Coin',
        img: "assets/icons/USDcoin.png",
        shortname: "USD",
        price: "0",
        coinsdollar: "0.0"),
  ];*/

  @override
  void initState() {
    // TODO: implement initState
    histroyProvider = Provider.of<HistroyProvider>(context, listen: false);
  }

  var width, height;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    histroyProvider = Provider.of<HistroyProvider>(context, listen: true);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 10, right: 20, left: 20),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                      child: SizedBox(
                        width: 1,
                      )),
                  Padding(
                    padding: const EdgeInsets.only(left: 140),
                    child: Text("History",
                        style: TextStyle(
                            color: AppColors.White,
                            fontFamily: "Sf-SemiBold",
                            fontSize: 20)),
                  ),
                  Expanded(
                      child: SizedBox(
                        width: 1,
                      )),
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
              // SizedBox(height: 20,),
//secondrow

              Row(
                children: [
                  Spacer(),
                  SizedBox(
                    width:Responsive.isMobile(context)?MediaQuery.of(context).size.width/2.5: MediaQuery.of(context).size.width/3.5,
                    height: MediaQuery.of(context).size.height/24,

                    child: TextField(
                      style: TextStyle(color: AppColors.greyColor),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(0),
                        fillColor: AppColors.ContainergreySearch,
                        filled: true,
                        isDense: true,
                        hintText: "Search",
                        hintStyle: TextStyle(color: AppColors.greydark,fontFamily: "Sf-Regular",fontSize: 14),
                        prefixIcon: Padding( padding:  EdgeInsets.all(6),
                          child:SvgPicture.asset(
                              'assets/icons/wallet/search.svg',
                              width: 22
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
                  Spacer(),
                  Padding(
                    padding:  EdgeInsets.only(right: 20),
                    child: Image.asset("assets/icons/alertbo.png",width: 20,color: AppColors.greyColor,),
                  ),


                ],
              ),


              Padding(
                padding: EdgeInsets.only(top: 10, left: 5, right: 5),
                child: Container(
                  height: MediaQuery.of(context).size.height / 16,
                  decoration: BoxDecoration(
                      border:
                      Border.all(color: AppColors.darklightgrey, width: 0),
                      color: AppColors.HeaderdarkbluesColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Assets Name",
                        style: TextStyle(
                            color: AppColors.WhiteText,
                            fontFamily: "Sf-Regular",
                            fontSize: 15),
                      ),
                      SizedBox(
                        width: width / 8,
                      ),
                      Text(
                        "Type",
                        style: TextStyle(
                            color: AppColors.WhiteText,
                            fontFamily: "Sf-Regular",
                            fontSize: 15),
                      ),
                      Expanded(
                          child: SizedBox(
                            width: 20,
                          )),
                      SizedBox(
                        width: 30,
                      ),
                      Text(
                        "Amount",
                        style: TextStyle(
                            color: AppColors.WhiteText,
                            fontFamily: "Sf-Regular",
                            fontSize: 15),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                    ],
                  ),
                ),
              ),


              SizedBox(
                height: 10,
              ),

              ListView.builder(
                // padding: EdgeInsets.fromLTRB(14, 0, 14, 60),
                itemCount: itemData.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  int id = index + 1;
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        SizedBox(height: 5,),

                        Padding(
                          padding: const EdgeInsets.only(left: 0,),
                          child:index==0
                              ?
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(datetime,style: TextStyle(color: AppColors.greyColor,fontFamily: "Sf-SemiBold",fontSize: 12)),)
                              :
                          SizedBox(),
                        ),

                        // Container(
                        //   decoration: BoxDecoration(
                        //       border: Border.all(color: Colors.transparent, width: 1),
                        //       // color:AppColors.containerbackgroundgrey ,
                        //       borderRadius: BorderRadius.circular(20)),
                        //      child: ExpansionTileCard(
                        //         onExpansionChanged: (value){
                        //                  setState(() {
                        //                   _isExpanded = value;
                        //                 });
                        //        },
                        //           trailing: Padding(
                        //            padding: const EdgeInsets.only(top: 0),
                        //               child: Container(
                        //                 child: _isExpanded
                        //                     ?
                        //                 SvgPicture.asset('assets/icons/Market/uparrow.svg', width: 15)
                        //                     :
                        //                 SvgPicture.asset('assets/icons/Market/downarrow.svg', width: 15),)
                        //             ),
                        //
                        //             baseColor: AppColors.greydark.withOpacity(0.3),
                        //             expandedTextColor: AppColors.containerbackgroundgrey,
                        //             // key: cardA,
                        //             expandedColor: AppColors.containerbackgroundgrey,
                        //
                        //           title: Column(
                        //             mainAxisAlignment: MainAxisAlignment.start,
                        //             crossAxisAlignment: CrossAxisAlignment.center,
                        //             children: [
                        //               Padding(
                        //                 padding: const EdgeInsets.only(top: 8.0,bottom: 8.0),
                        //                 child: Row(
                        //                   mainAxisAlignment: MainAxisAlignment.start,
                        //                   crossAxisAlignment: CrossAxisAlignment.center,
                        //                   children: [
                        //                     Container(
                        //                       decoration:Boxdec.ButtonDecorationGradientwithBorder,
                        //                       height:40,
                        //                       width: 40,
                        //                       child: Padding(
                        //                         padding: const EdgeInsets.all(10),
                        //                         child: Container(
                        //                           decoration: BoxDecoration(
                        //                               shape: BoxShape.circle, // BoxShape.circle or BoxShape.retangle
                        //                               //color: const Color(0xFF66BB6A),
                        //                           ),
                        //                           width: 18,
                        //                           height: 18,
                        //                           child: SvgPicture.asset(
                        //                               'assets/icons/wallet/bitcoin.svg'),
                        //                         ),
                        //                       ),
                        //                     ),
                        //                     SizedBox(width: 8,),
                        //                     // Image.asset(itemData[index].img.toString(),width: 70),
                        //                     Container(
                        //                       width: width/7,
                        //                       child: Column(
                        //                         mainAxisAlignment: MainAxisAlignment.start,
                        //                         crossAxisAlignment: CrossAxisAlignment.start,
                        //                         children: [
                        //                           Text(itemData[index].name.toString(),style: TextStyle(color: AppColors.whiteEF,fontFamily: "Sf-SemiBold",fontSize: 13)),
                        //                           Text("${itemData[index].shortname}", style:TextStyle(color: AppColors.greyColor,fontFamily: "Sf-Regular",fontSize: 12),),
                        //                         ],),
                        //                     ),
                        //
                        //
                        //                       itemData[index].send==1
                        //                           ?
                        //                       SvgPicture.asset(
                        //                         'assets/icons/drawericon/Send.svg',
                        //                         width: 22)
                        //                           :
                        //                        SvgPicture.asset(
                        //                         'assets/icons/wallet/receive.svg',
                        //                           width: 22,color: index==0?AppColors.greenColor:AppColors.redColor,
                        //                     ),
                        //
                        //                     SizedBox(width: 4,),
                        //                     Text("${itemData[index].send}", style:TextStyle(color: AppColors.whiteColor,fontFamily: "Sf-Regular",fontSize: 15),),
                        //
                        //                     Spacer(),
                        //                     Text("${itemData[index].number}", style:TextStyle(color: AppColors.white,fontFamily: "Sf-Regular",fontSize: 15),),
                        //                     SizedBox(width: 3,),
                        //                     Text("${itemData[index].shortname}", style:TextStyle(color: AppColors.white,fontFamily: "Sf-Regular",fontSize: 14),),
                        //                   ],
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //
                        //    children: <Widget>[
                        //       Container(
                        //         color:AppColors.containerbackgroundgrey,
                        //         child: Column(
                        //           children: [
                        //           Padding(
                        //             padding: const EdgeInsets.only(left: 20,top: 10,bottom: 10),
                        //             child: Row(
                        //               mainAxisAlignment: MainAxisAlignment.start,
                        //               crossAxisAlignment: CrossAxisAlignment.start,
                        //               children: [
                        //                 Container(
                        //                     width: width/20,
                        //                     child: Text("From", style:TextStyle(color: AppColors.greyColor,fontFamily: "Sf-Regular",fontSize: 15),)),
                        //
                        //                  Padding(
                        //                    padding: const EdgeInsets.only(left:0),
                        //                    child: Text("${itemData[index].from}", style:TextStyle(color: AppColors.whiteColor,fontFamily: "Sf-SemiBold",fontSize: 15),),
                        //                  ),
                        //               ],
                        //             ),
                        //           ),
                        //           Padding(
                        //             padding: const EdgeInsets.only(top: 10,left: 20,right: 20),
                        //             child: Row(
                        //               mainAxisAlignment: MainAxisAlignment.start,
                        //               crossAxisAlignment: CrossAxisAlignment.start,
                        //               children: [
                        //                 Container(
                        //                     width: width/20 ,
                        //                     child: Text("To", style:TextStyle(color: AppColors.greyColor,fontFamily: "Sf-Regular",fontSize: 15),)),
                        //
                        //                 Column(children: [
                        //                   Text("${itemData[index].to}", style:TextStyle(color: AppColors.whiteColor,fontFamily: "Sf-SemiBold",fontSize: 15),),
                        //                 ],),
                        //               ],
                        //             ),
                        //           ),
                        //           Padding(
                        //             padding: const EdgeInsets.all(20),
                        //             child: Row(
                        //               mainAxisAlignment: MainAxisAlignment.start,
                        //               crossAxisAlignment: CrossAxisAlignment.start,
                        //               children: [
                        //                 Container(
                        //                     width: width/20 ,
                        //                     child: Text("Value", style:TextStyle(color: AppColors.greyColor,fontFamily: "Sf-Regular",fontSize: 15),)),
                        //
                        //                 Column(children: [
                        //                   Text("${itemData[index].value}", style:TextStyle(color: AppColors.whiteColor,fontFamily: "Sf-SemiBold",fontSize: 15),),
                        //                 ],),
                        //               ],
                        //             ),
                        //           ),
                        //         ],),
                        //       ),
                        //
                        //       SizedBox(
                        //         height: 10,
                        //       ),
                        //     ],
                        //   ),
                        // )
                      ]);
                },
              ),

              // SizedBox(height: 20,),
              SizedBox(
                height: height * 0.09,
              ),

              SizedBox(
                height: 70,
              )
              // Image.asset("assets/icons/cirvedleft.png",width: width/4,)
            ],
          ),
        ),
      ),
    );
  }
}