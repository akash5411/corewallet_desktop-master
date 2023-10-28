import 'package:flutter/material.dart';

abstract class AppColors{
  static const Color textColor = Color(0xff676767);
  static const Color textColor2 = Color(0xff767676);
  static const Color Containerdashblue = Color(0xff2C323B);
  static const Color gradient = Color(0xff4B5DFF);

  static const Color darkGreyColor = Color(0xff10151E);
  static const Color ContainerExpansionblue = Color(0xff323840);
  static const Color Containerbluestatic = Color(0xff282D36);
  static const Color searchcontainergrey = Color(0xff2E3135);
  static const Color HeaderdarkbluesColor = Color(0xff252B35);
  static const Color blackColor = Color(0xff0E0F11);
  static const Color ContainergreyhomeColor = Color(0xff353B43);
  static const Color ContainerblackColor = Color(0xff1E232B);
  static const Color backColor = Color(0xff000000);
  static const Color whiteColor = Color(0xffFFFFFF);
  static const Color blueColor = Color(0xff0500FF);
  static const Color blueColor1 = Color(0xff1A75FF);
  static const Color blueColor2 = Color(0xff627EEA);
  static const Color linkBlueColor3 = Color(0xff1A72F4);
  static const Color redColor = Color(0xffEF5350);
  static const Color darkRedColor = Color(0xffE94A4A);
  static const Color greenColor = Color(0xff66BB6A);
  static const Color blackcontainershadow = Color(0xff43465C);
  static const Color greyColor = Color(0xff999b9f);
  static const Color greyColor2 = Color(0xff474A51);
  static const Color orangeColor = Color(0xffFF7152);
  static const Color borderColor = Color(0xff0D1424);
  static const Color border253A66 = Color(0xff253A66);
  static const Color black090F1A = Color(0xff090F1A);
  static const Color black1622 = Color(0xff16223D);
  static const Color dividerColor = Color(0xff131D33);
  static const Color backgroundColor = Color(0xff00050f);
  static const Color backgroundColor2 = Color(0xffF0F0F0);
  static const Color selectedTextColor = Color(0xff1f232c);
  static const Color darkBlack0A0 = Color(0xff0A0F18);
  static const Color darkGrey = Color(0xff101520);
  static const Color bottomSheetColor = Color(0xff0B101B);
  static const Color boarderColor = Color(0xffCCCCCC);
  static const Color black0b = Color(0xff0B152A);
  static const Color black1A233 = Color(0xff1A2337);
  static const Color black545 = Color(0xff545D6E);
  static const Color thumbColor = Color(0xffD5DDEC);
  static const Color thumbColor2 = Color(0xff0B1934);
  static const Color color = Color(0xff262D3E);
  static const Color yellowColor = Color(0xffFFB240);
  static const Color pinkColor = Color(0xcdff6ec3);
  static const Color actionColor = Color(0xff0B0E14);
  static const Color whiteEF = Color(0xffEFF0F0);
  //old




  static const primaryColor = Color(0xFF685BFF);
  static const lightblueprimaryColor = Color(0xFF73a5c6);
  static const canvasColor = Color(0xFF2E2E48);
  static const scaffoldBackgroundColor = Color(0xFF464667);
  static const accentCanvasColor = Color(0xFF3E3E61);
  static const containerbackgroundgrey = Color(0xFF282E37);
  static const white = Colors.white;





  static const Color kPrimaryColor = Color(0xFFFFD800);
  static const Color Blackgroungnew = Color(0xFF1E232B);
  static const Color fakebgcolor = Color(0xFF464667);
  static const Color OrangeShadow = Color(0xFFFF7152);
  static const Color BlackgroundBlue = Color(0xFF222831);
  static const Color White = Color(0xFFFFFFFF);
  static const Color WhiteText = Color(0xFFAEAFB2);
  static const Color darklightgrey = Color(0xFF363B43);
  static const Color lightgreycontainershadow = Color(0xFFD9D9D9);
  static const Color greydark = Color(0xFF7F8287);
  static const Color darkblueContainer = Color(0xFF404258);
  static const Color darkblue = Color(0xFF4B5DFF);
  static const Color darkbluedark = Color(0xFF1523A5);
  static const Color ContainergreySearch = Color(0xFF32363D);
  static const Color Textgreen = Color(0xFF66BB6A);
  static const Color bordergrey = Color(0xFF2F353F);
  static const Color searchbackground = Color(0xFF2C2F33);



  static  LinearGradient buttonGradient = LinearGradient(
    colors: [
      Color(0xff4B5DFF),
      Color(0xffFF6C87),
      Color(0xffFF6C87),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    tileMode: TileMode.mirror,
    stops: [0.1,0.5,0.9],
  );
  static  LinearGradient buttondisableGradient = LinearGradient(
    colors: [
      Color(0xFF32363D),
      Color(0xFF32363D),
      Color(0xFF32363D),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    tileMode: TileMode.mirror,
    stops: [0.1,0.5,0.9],
  );




  static  LinearGradient drawertextGradient = LinearGradient(
    colors: [
      Color(0xff949ae6).withOpacity(0.5),
      Color(0xffFF6C87).withOpacity(0.6),

      Color(0xffFF6C87),

    ],
    begin: Alignment.topLeft,
    end: Alignment.centerRight,
    // tileMode: TileMode.mirror,
    stops: [0.06,0.3,0.9],
  );





  static  LinearGradient iconGradient = const LinearGradient(
    colors: [
      Color(0xff505EFB),
      Color(0xff949ae6),
      Color(0xffffb6c1),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    tileMode: TileMode.clamp,
    stops: [0.8,0.4,0.5],
  );


  static  LinearGradient buttonGradient2 = const LinearGradient(
    colors: [
      Color(0xff0500FF),
      Color(0xffFF7152),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    tileMode: TileMode.mirror,
    stops: [0.1,1],
  );

}
