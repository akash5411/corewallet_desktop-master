import 'package:corewallet_desktop/Ui/Authentication/CreateWallet/create_page_step1.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/components.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'ImportWallet/import_page.dart';

class SelectWalletPage extends StatefulWidget {
  const SelectWalletPage({Key? key}) : super(key: key);

  @override
  State<SelectWalletPage> createState() => _SelectWalletPageState();
}

class _SelectWalletPageState extends State<SelectWalletPage> {
  @override
  Widget build(BuildContext context) {

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo and title
          const Spacer(),
          Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.transparent,
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
                    height: height * 0.07,
                    width: width * 0.07,
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
          SizedBox(height: height * 0.12 ),

          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateWallet(isNew: false),
                  )
              );
            },
            child: Container(
              height: 50,
              width:Responsive.isDesktop(context) ?  width * 0.25 : width * 0.4,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppColors.buttonGradient2,
                borderRadius: BorderRadius.circular(8)
              ),
              child: Text(
                "Create New Wallet",
                style: textStyle.copyWith(
                  fontSize: 14,
                  color: AppColors.white,
                  fontFamily: "Sf-SemiBold"
                )
              ),
            ),
          ),
          SizedBox(height: height * 0.02),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ImportWalletPage(),
                )
              );
            },
            child: Container(
              height: 50,
              width:Responsive.isDesktop(context) ?  width * 0.25 : width * 0.4,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppColors.buttonGradient2,
                borderRadius: BorderRadius.circular(8)
              ),
              child: Text(
                "Import Existing Wallet",
                style: textStyle.copyWith(
                    fontSize: 14,
                    color: AppColors.white,
                    fontFamily: "Sf-SemiBold"
                )
              ),
            ),
          ),
          const Spacer(),

          Text(
            "© CATENA Multi-Chain, 2023 All rights reserved",
              style: textStyle.copyWith(
                  fontSize: 12,
                  color: AppColors.white
              )
          ),
          SizedBox(height: height * 0.02),

        ],
      ),
    );
  }
}
