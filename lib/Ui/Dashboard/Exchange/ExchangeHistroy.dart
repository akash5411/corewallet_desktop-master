import 'package:cached_network_image/cached_network_image.dart';
import 'package:corewallet_desktop/Handlers/ApiHandle.dart';
import 'package:corewallet_desktop/LocalDb/Local_Exchange_Provider.dart';
import 'package:corewallet_desktop/Provider/ExchangeProvider.dart';
import 'package:corewallet_desktop/Provider/Wallet_Provider.dart';
import 'package:corewallet_desktop/Values/Helper/helper.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/styleandborder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class ExchangeHistroy extends StatefulWidget {
  const ExchangeHistroy({Key? key}) : super(key: key);

  @override
  State<ExchangeHistroy> createState() => _ExchangeHistroyState();
}

class _ExchangeHistroyState extends State<ExchangeHistroy> {
  late ExchangeProvider exchangeProvider;

  late WalletProvider walletProvider;

  String datetime = DateFormat("MMM, dd, yyyy").format(DateTime.now());

  var crySymbol = "";
  bool isLoading = false;
  getExchangeHistory()async{

    setState(() {
      isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      crySymbol = sharedPreferences.getString("crySymbol") ?? "\$";
    });

    await DBExchange.exchangeDB.getExchangeList();

    Future.delayed(
        const Duration(milliseconds: 500),(){
          setState(() {
            isLoading = false;
          });
        });
  }


@override
  void initState() {
    super.initState();

    exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    getExchangeHistory();


}

  @override
  Widget build(BuildContext context) {

    exchangeProvider = Provider.of<ExchangeProvider>(context, listen: true);
    walletProvider = Provider.of<WalletProvider>(context, listen: true);

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body:Padding(
        padding: const EdgeInsets.only(top: 20,right: 20,left: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // App bar
            Row(
              children: [

                InkWell(
                  onTap: (){

                    exchangeProvider.changeListnerExchange("Exchange");

                    // Navigator.pop(context);
                  },
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: Boxdec.BackButtonGradient,

                      child: Center(
                          child:
                          Image.asset(
                            "assets/icons/backarrow.png",
                            height: 24,
                            color: AppColors.greydark,
                          )
                      )
                  ),
                ),

                const Expanded(child: SizedBox(width: 1,)),

                const Padding(
                  padding: EdgeInsets.only(left: 140),
                  child: Text(
                      "Exchange History",
                      style: TextStyle(
                          color: AppColors.White,
                          fontFamily: "Sf-SemiBold",
                          fontSize: 20
                      )
                  ),
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
                                child: Text(
                                    "Balance:",
                                    style:TextStyle(
                                      color:AppColors.greydark,
                                      fontSize: 12,
                                      fontFamily: 'Sf-SemiBold',
                                    )
                                ),
                              ),
                              const SizedBox(width: 0,),
                              Padding(
                                padding:  const EdgeInsets.only(right: 20),
                                child: Text(
                                    "$crySymbol ${walletProvider.showTotalValue.toStringAsFixed(2)}",
                                    style: const TextStyle(
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
                                      style:const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontFamily: 'Sf-Regular',
                                      )
                                  ),
                                  const SizedBox(width: 15,),

                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                ),
              ],
            ),
            const SizedBox(height: 20,),

            // listing ui
            Expanded(
              child: isLoading
                  ?
              Helper.dialogCall.showLoader()
                  :
              DBExchange.exchangeDB.exchangeList.isEmpty
                  ?
              // empty list ui
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/Exchange/error.svg",
                    width: width * 0.4,
                    height: height * 0.4,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Exchange not found !",
                    style: TextStyle(
                        color: AppColors.white.withOpacity(0.4),
                        fontFamily: "Sf-Regular",
                        fontSize: 13
                    ),
                  )
                ],
              )
                  :
             // Grouped List
              GroupedListView(
                groupHeaderBuilder: (element) {
                  return  Padding(
                    padding: const EdgeInsets.only(left:5,bottom: 8.0),
                    child: Text(
                        DateFormat("MMM dd,yyyy").format(DateTime.parse(element.dataTime)),
                        style: TextStyle(
                            color: AppColors.white.withOpacity(0.6),
                            fontFamily: "Sf-SemiBold",
                            fontSize: 12
                        )
                    ),
                  );
                },
                elements: DBExchange.exchangeDB.exchangeList,
                groupBy: (element) =>DateFormat("MMM dd,yyyy").format(DateTime.parse(element.dataTime)),
                itemBuilder: (context, element) {

                  return InkWell(
                    onTap: () async{
                      await launchUrl(Uri.parse("https://bscscan.com/tx/${element.hexLink}"));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding:const EdgeInsets.symmetric(horizontal: 20,vertical: 10) ,
                      alignment: Alignment.center,
                      height:70 ,
                      decoration: BoxDecoration(
                        // border: Border.all(color: AppColors.darkblueContainer,width: 0),
                          color: AppColors.ContainergreyhomeColor,
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: width * 0.18,
                            child: Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Token",
                                    style:TextStyle(
                                        color: AppColors.white.withOpacity(0.6),
                                        fontFamily: "Sf-Regular",
                                        fontSize: 12
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(400),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.fill,
                                            imageUrl: element.fromTokenIcon,
                                            height: 22,
                                            alignment: Alignment.center,
                                            placeholder: (context, url) => Helper.dialogCall.showLoader(),
                                            errorWidget: (context, url, error) =>
                                                Image.asset(
                                                  "assets/icons/wallet/catenabackgroundimg.png",
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 10,),
                                        Flexible(
                                          child: Text(
                                            element.fromTokenName,
                                            style:const TextStyle(
                                                color: AppColors.whiteEF,
                                                fontFamily: "Sf-Regular",
                                                fontSize: 14
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5,),
                                        Text(
                                          element.fromSymbol,
                                          style:const TextStyle(
                                            color: AppColors.greydark,
                                            fontFamily: "Sf-Regular",
                                            fontSize: 10
                                        ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(),
                          Row(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Amount",
                                    textAlign: TextAlign.end,
                                    style:TextStyle(
                                      color: AppColors.white.withOpacity(0.6),
                                      fontFamily: "Sf-Regular",
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 5,),
                                  Text(
                                    ApiHandler.calculateLength3(element.fromAmount),
                                    textAlign: TextAlign.end,
                                    style:const TextStyle(
                                      color: AppColors.whiteEF,
                                      fontFamily: "Sf-Regular",
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),


                              Container(
                                color: AppColors.greydark.withOpacity(0.4),
                                width:MediaQuery.of(context).size.width*0.02,
                                height: 1,
                                alignment: Alignment.center,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 0,left: 10,right: 10),
                                child: Container(
                                  alignment: Alignment.center,
                                  child:  SvgPicture.asset(
                                      'assets/icons/Market/frame.svg',
                                      width: 22
                                  ),
                                ),
                              ),
                              Container(
                                color: AppColors.greydark.withOpacity(0.4),
                                width:MediaQuery.of(context).size.width*0.02,
                                height: 1,
                                alignment: Alignment.center,
                              ),

                              const SizedBox(width: 10,height:0),

                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Amount",
                                    textAlign: TextAlign.end,
                                    style:TextStyle(
                                      color: AppColors.white.withOpacity(0.6),
                                      fontFamily: "Sf-Regular",
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 5,),
                                  Text(
                                    ApiHandler.calculateLength3(element.toAmount),
                                    textAlign: TextAlign.end,
                                    style:const TextStyle(
                                      color: AppColors.whiteEF,
                                      fontFamily: "Sf-Regular",
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const Spacer(),

                          SizedBox(
                            width: width * 0.18,
                            child: Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Token",
                                    textAlign: TextAlign.end,
                                    style:TextStyle(
                                        color: AppColors.white.withOpacity(0.6),
                                        fontFamily: "Sf-Regular",
                                        fontSize: 12
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [

                                        Text(
                                          element.toSymbol,
                                          style:const TextStyle(
                                              color: AppColors.greydark,
                                              fontFamily: "Sf-Regular",
                                              fontSize: 10
                                          ),
                                        ),
                                        const SizedBox(width: 5,),
                                        Flexible(
                                          child: Text(
                                            "${element.toTokenName}",
                                            textAlign: TextAlign.end,
                                            style:const TextStyle(
                                                color: AppColors.whiteEF,
                                                fontFamily: "Sf-Regular",
                                                fontSize: 14
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5,),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(400),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.fill,
                                            imageUrl: element.toTokenIcon,
                                            height: 22,
                                            alignment: Alignment.center,
                                            placeholder: (context, url) => Helper.dialogCall.showLoader(),
                                            errorWidget: (context, url, error) =>
                                                Image.asset(
                                                  "assets/icons/wallet/catenabackgroundimg.png",
                                                ),
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
