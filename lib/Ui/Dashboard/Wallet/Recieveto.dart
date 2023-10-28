import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_address.dart';
import 'package:corewallet_desktop/Provider/Wallet_Provider.dart';
import 'package:corewallet_desktop/Values/Helper/helper.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:corewallet_desktop/Values/styleandborder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecieveTo extends StatefulWidget {
  const RecieveTo({Key? key}) : super(key: key);

  @override
  State<RecieveTo> createState() => _RecieveToState();
}

class _RecieveToState extends State<RecieveTo> {

  late WalletProvider walletProvider;
  bool isLoaded = true;

  @override
  void initState() {
    super.initState();
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    Future.delayed(Duration.zero,(){
      selectedAccount();
    });
  }

  var currency = "",crySymbol = "";

  late String selectedAccountName = "",
      selectedAccountAddress = "",selectedAccountId;

  selectedAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    currency = sharedPreferences.getString("currency") ?? "USD";
    crySymbol = sharedPreferences.getString("crySymbol") ?? "\$";
    selectedAccountId = sharedPreferences.getString('accountId') ?? "";
    selectedAccountName = sharedPreferences.getString('accountName') ?? "";

    await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId, walletProvider.accountTokenList!.networkId);

    setState(() {
      selectedAccountAddress = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
      isLoaded = false;
    });
  }

  var width = 0.0,height = 0.0;

  @override
  Widget build(BuildContext context) {
    width=MediaQuery.of(context).size.width;
    height=MediaQuery.of(context).size.height;
    walletProvider = Provider.of<WalletProvider>(context, listen: true);

    return Scaffold(
        body: Padding(
          padding:  EdgeInsets.only(top: 20,right: 20,left: 20),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(

              children: [

                // app bar
                Row(
                  children: [

                    // back button
                    GestureDetector(
                      onTap: (){

                        walletProvider.changeListnerWallet("PriceChart");

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
                                 height: 24,
                             ),
                          )
                      ),
                    ),

                    const Expanded(child: SizedBox(width: 1,)),
                    SizedBox(width:Responsive.isTablet(context)?width/8: Responsive.isMobile(context)?width/5.7: width/10,),

                    // page title
                    const Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Text(
                          "Receive",
                          style: TextStyle(
                              color: AppColors.White,
                              fontFamily: "Sf-SemiBold",
                              fontSize: 20
                          )
                      ),
                    ),
                    const Expanded(child: SizedBox(width: 1,)),

                    // total balance showing
                    Container(
                        height: 55,
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
                                  const SizedBox(width: 20,),

                                  const Padding(
                                    padding: EdgeInsets.only(right: 28),
                                    child: Text("Balance:",style:TextStyle(color:AppColors.greydark, fontSize: 12,    fontFamily: 'Sf-SemiBold',)),
                                  ),
                                  Padding(
                                    padding:  const EdgeInsets.only(right: 20),
                                    child: Text(
                                        "$crySymbol ${walletProvider.showTotalValue.toStringAsFixed(2)}",
                                        style:const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Sf-SemiBold',
                                        )
                                    ),
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
                                      const SizedBox(width: 5,),
                                      SvgPicture.asset(
                                          'assets/icons/wallet/Vector.svg',
                                          width: 22
                                      ),
                                      // Image.asset("assets/images/Vector (2).png",width: 20),
                                      const SizedBox(width: 5,),
                                      Text(
                                          "$crySymbol ${walletProvider.cmcxBalance.toStringAsFixed(2)}",
                                          style:const TextStyle(color: Colors.grey,fontSize: 16,   fontFamily: 'Sf-Regular',)),
                                      const SizedBox(width: 15,),

                                    ],),
                                ),
                              ),  ),
                          ],
                        )
                    ),
                  ],
                ),
                const SizedBox(height: 20,),

                // token details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IntrinsicWidth(
                      child: Container(
                          alignment: Alignment.center,

                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.8),
                                blurRadius: 50,
                              )
                            ],

                          ),
                          child:ClipRRect(
                            borderRadius: BorderRadius.circular(400),
                            child: CachedNetworkImage(
                              fit: BoxFit.fill,
                              imageUrl: walletProvider.accountTokenList!.logo,
                              height: 45,
                              placeholder: (context, url) => Helper.dialogCall.showLoader(),
                              errorWidget: (context, url, error) =>
                                  Image.asset(
                                    "assets/icons/wallet/catenabackgroundimg.png",
                                  ),
                            ),
                          ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                        walletProvider.accountTokenList!.symbol,
                        style: const TextStyle(
                            color: AppColors.White,
                            fontFamily: "Sf-SemiBold",
                            fontSize: 12
                        )
                    ),

                   Container(
                       margin: const EdgeInsets.only(top: 30),
                       padding: const EdgeInsets.all(20),

                       height: height/5,
                       decoration:Boxdec.ContainerblackwithGrey,

                       /*child: QrImage(
                       data: "$selectedAccountAddress",
                       version: QrVersions.auto,

                       foregroundColor: AppColors.white,

                     )*/
                   )
                  ],
                ),

                const SizedBox(height: 20,),

                Text("Your ${walletProvider.accountTokenList!.symbol} Address  ${walletProvider.accountTokenList!.type}",
                    style: const TextStyle(
                        color: AppColors.greyColor,
                        fontFamily: "Sf-SemiBold",
                        fontSize: 12
                    )
                ),

                const SizedBox(height: 5,),

                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IntrinsicWidth(
                        child: Container(
                          height: MediaQuery.of(context).size.height/18,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              border: Border.all(color: AppColors.Blackgroungnew,width: 0),
                              color: AppColors.Blackgroungnew,
                              borderRadius: BorderRadius.circular(15)
                          ),

                          child:   Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 4,),
                              Center(child: Text(
                                "$selectedAccountAddress",
                                style: const TextStyle(

                                  color: AppColors.whiteColor,
                                  fontFamily: 'Sf-Regular',
                                  fontSize: 16,

                                ),

                              ),),

                            ],
                          ),),
                      ),
                      SizedBox(width: 15,),
                      InkWell(
                        onTap: (){
                          FlutterClipboard.copy('${selectedAccountAddress}').then(( value ) {
                            Helper.dialogCall.showToast(context, "Copied");
                          });
                        },
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/wallet/copy 1.svg',
                              height: 20,alignment: Alignment.center,
                            ),
                            const SizedBox(width: 4,),
                            const Center(
                              child: Text(
                                "Copy",
                                style: TextStyle(
                                  color: AppColors.greyColor,
                                  fontFamily: 'Sf-Medium',
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height/4,),
                //Copy // download //link section comment

          /*      Container(
                  width: Responsive.isMobile(context)?width/2: Responsive.isTablet(context)?width/5:  width/12,
                  decoration:Boxdec.ContainerblackwithGrey,

                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10,top: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // SizedBox(width: width*0.04,),
                        const Spacer(),


                        InkWell(
                          onTap: (){
                            FlutterClipboard.copy('${selectedAccountAddress}').then(( value ) {
                              Helper.dialogCall.showToast(context, "Copied");
                            });
                          },
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/wallet/copy 1.svg',
                                height: 20,alignment: Alignment.center,
                              ),
                              const SizedBox(width: 4,),
                              const Center(
                                child: Text(
                                  "Copy",
                                  style: TextStyle(
                                    color: AppColors.greyColor,
                                    fontFamily: 'Sf-Medium',
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Spacer(),
                        Container(width: 0.5,height: 20,color: AppColors.greyColor,),
                        Spacer(),
                        Column(children: [
                          SvgPicture.asset(
                            'assets/icons/wallet/arrow-down-1 2.svg',
                            height: 20,alignment: Alignment.center,
                          ),
                          SizedBox(width: 4,),
                          Center(child: Text(
                            "Download",
                            style: TextStyle(

                              color: AppColors.greyColor,
                              fontFamily: 'Sf-Medium',
                              fontSize: 9,

                            ),

                          ),),
                        ],),
                        // SizedBox(width: width*0.04,),
                        Spacer(),
                        Container(width: 0.5,height: 20,color: AppColors.greyColor,),
                        Spacer(),
                        // Expanded(child: SizedBox(width: 5,)),
                        Column(children: [
                          SvgPicture.asset(
                            'assets/icons/wallet/link-21 1.svg',
                            height: 20,alignment: Alignment.center,
                          ),
                          SizedBox(width: 4,),
                          Center(child: Text(
                            "View on Blockchain",
                            style: TextStyle(

                              color: AppColors.greyColor,
                              fontFamily: 'Sf-Medium',
                              fontSize: 9,

                            ),

                          ),),
                        ],),
                        Spacer(),

                        // SizedBox(width: width*0.04,),

                      ],
                    ),
                  ),),*/




              ],
            ),
          ),
        ));
  }
}


class UnicornOutlineButton extends StatelessWidget {
  final _GradientPainter _painter;
  final Widget _child;
  final VoidCallback _callback;
  final double _radius;

  UnicornOutlineButton({
    required double strokeWidth,
    required double radius,
    required Gradient gradient,
    required Widget child,
    required VoidCallback onPressed,
  })  : this._painter = _GradientPainter(strokeWidth: strokeWidth, radius: radius, gradient: gradient),
        this._child = child,
        this._callback = onPressed,
        this._radius = radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _painter,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _callback,
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: _callback,
          child: Container(
            constraints: BoxConstraints(minWidth: 88, minHeight: 48),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class _GradientPainter extends CustomPainter {
  final Paint _paint = Paint();
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  _GradientPainter({required double strokeWidth, required double radius, required Gradient gradient})
      : this.strokeWidth = strokeWidth,
        this.radius = radius,
        this.gradient = gradient;

  @override
  void paint(Canvas canvas, Size size) {
    // create outer rectangle equals size
    Rect outerRect = Offset.zero & size;
    var outerRRect = RRect.fromRectAndRadius(outerRect, Radius.circular(radius));

    // create inner rectangle smaller by strokeWidth
    Rect innerRect = Rect.fromLTWH(strokeWidth, strokeWidth, size.width - strokeWidth * 2, size.height - strokeWidth * 2);
    var innerRRect = RRect.fromRectAndRadius(innerRect, Radius.circular(radius - strokeWidth));

    // apply gradient shader
    _paint.shader = gradient.createShader(outerRect);

    // create difference between outer and inner paths and draw it
    Path path1 = Path()..addRRect(outerRRect);
    Path path2 = Path()..addRRect(innerRRect);
    var path = Path.combine(PathOperation.difference, path1, path2);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
