import 'package:corewallet_desktop/Ui/Dashboard/Wallet/Wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'appColors.dart';


class MyStyle{

  static BoxDecoration buttonDecoration = BoxDecoration(
    color: AppColors.greenColor,
    borderRadius: BorderRadius.circular(5),
  );




}

 var fieldStyle1 =InputDecoration(
      disabledBorder: InputBorder.none,
      enabledBorder:OutlineInputBorder(
        borderSide: const BorderSide(color:AppColors.bordergrey ,),
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.bordergrey),
          borderRadius: BorderRadius.circular(16)
      ),
    );

var fieldStyle = InputDecoration(
    hintText: 'Old Password',
    // contentPadding: const EdgeInsets.all(16),
    disabledBorder: InputBorder.none,
    isDense: true,
    enabledBorder:OutlineInputBorder(
      borderSide: const BorderSide(color:AppColors.bordergrey ,),
      borderRadius: BorderRadius.circular(16),
    ),
    focusedBorder:OutlineInputBorder(
        borderSide: const BorderSide(color:AppColors.bordergrey ,),
        borderRadius: BorderRadius.circular(16)
    ),
    border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.bordergrey),
        borderRadius: BorderRadius.circular(16)
        ));

class  Boxdec{
  static BoxDecoration Containercoinshadow =  BoxDecoration(
    borderRadius: BorderRadius.circular(100),
    gradient: LinearGradient(
        colors: [
          AppColors.blackColor.withOpacity(0.8) ,
          //AppColors.blackColor.withOpacity(0.3) ,
          AppColors.blackcontainershadow.withOpacity(0.8),
          AppColors.blackcontainershadow.withOpacity(0.3),
          AppColors.blackcontainershadow.withOpacity(0.5),

        ],
        begin: Alignment.bottomRight,
        end: Alignment.bottomRight

    ),
  );



  static BoxDecoration Bluecoinshadow =  BoxDecoration(
    borderRadius: BorderRadius.circular(100),
    gradient: LinearGradient(
        colors: [

          //AppColors.blackColor.withOpacity(0.3) ,
          AppColors.darkblue.withOpacity(0.6),
          AppColors.darkblue.withOpacity(0.6),
          // AppColors.darkblue


        ],
        begin: Alignment.bottomRight,
        end: Alignment.bottomRight

    ),
  );


/* row deocration*/
  static BoxDecoration ContainerRowBackgroundgradient=BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        // tileMode: TileMode.,
        colors: [
          // /AppColors.Containerbluestatic.withOpacity(0.6),
          AppColors.Containerdashblue.withOpacity(0.08),
          AppColors.textColor2.withOpacity(0.2),
          AppColors.textColor2.withOpacity(0.3),
        ],
      ),


      border: Border.all(color: AppColors.ContainergreyhomeColor,width: 0),
      // color: AppColors.ContainergreyhomeColor,
      borderRadius: BorderRadius.circular(15)
  );
  static BoxDecoration ContainerBalancegradientLeft=BoxDecoration(
    border: Border.all(color: AppColors.greydark.withOpacity(0.4),width: 1.7),

    gradient: LinearGradient(
      begin: Alignment.topRight,

      end: Alignment.bottomLeft,
      // tileMode: TileMode.,
      colors: [
        AppColors.Containerbluestatic.withOpacity(0.4),
        AppColors.Containerbluestatic.withOpacity(0.4),
        // AppColors.Containerbluestatic.withOpacity(0.4),
        // AppColors.Containerbluestatic.withOpacity(0.4),
        AppColors.darklightgrey.withOpacity(0.8),
        AppColors.darklightgrey.withOpacity(0.8),
        //  AppColors.darklightgrey,
      ],
    ),
    // color: AppColors.darklightgrey,
    borderRadius: BorderRadius.circular(22),
  );
  static BoxDecoration ContainerBalancegradientRight=BoxDecoration(
    border: Border.all(color: AppColors.greydark.withOpacity(0.2),width: 1.7),

    gradient: LinearGradient(
      begin: Alignment.topRight,

      end: Alignment.bottomLeft,
      // tileMode: TileMode.,
      colors: [
        AppColors.Containerbluestatic.withOpacity(0.4),
        AppColors.Containerbluestatic.withOpacity(0.4),
        AppColors.darklightgrey.withOpacity(0.8),
        AppColors.darklightgrey.withOpacity(0.8),
        //  AppColors.darklightgrey,
      ],
    ),
    // color: AppColors.darklightgrey,
    borderRadius: BorderRadius.circular(20),
  );
/*  send buttons*/
  static BoxDecoration ButtonDecorationGradientwithBorder= BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        // tileMode: TileMode.,
        colors: [
          AppColors.darkblueContainer.withOpacity(0.1),
          AppColors.darkblueContainer.withOpacity(0.1),

          AppColors.pinkColor.withOpacity(0.1),
          AppColors.blueColor2.withOpacity(0.1),

          Colors.white.withOpacity(0.08),
          Colors.white.withOpacity(0.08),
          //Colors.white.withOpacity(0.1),
          // AppColors.darkblueContainer.withOpacity(0.2),

        ],
      ),
      border: GradientBoxBorder(
        gradient: LinearGradient(
            begin : Alignment.topRight,
            end : Alignment.bottomRight,
            colors: [
              AppColors.greydark.withOpacity(0.3),
              AppColors.darkblueContainer.withOpacity(0.3),
              AppColors.darkblueContainer.withOpacity(0.3),
              //  AppColors.darkblueContainer,
              //AppColors.darkblueContainer,
            ]),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(25)
  );


  static  BoxDecoration ContainerblackwithGrey =  BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        // tileMode: TileMode.,
        colors: [
          AppColors.Containerdashblue.withOpacity(0.08),
          AppColors.Containerdashblue.withOpacity(0.08),
         // AppColors.textColor2.withOpacity(0.2),
          AppColors.textColor2.withOpacity(0.2),
          //Colors.white.withOpacity(0.1),
          // AppColors.darkblueContainer.withOpacity(0.2),

        ],
      ),
      border: GradientBoxBorder(
        gradient: LinearGradient(
            begin : Alignment.topRight,
            end : Alignment.bottomRight,
            colors: [
              AppColors.greyColor2,

              AppColors.darkblueContainer.withOpacity(0.1),
              AppColors.darkblueContainer.withOpacity(0.3),
              //  AppColors.darkblueContainer,
            ]),
        width: 1,
      ),

      // boxShadow: [BoxShadow(
      //   color: AppColors.blackColor,
      //   blurRadius: 5.0,),],
      // color: AppColors.containerbackgroundgrey,
      borderRadius: BorderRadius.circular(25)
  );

/*Backbutton container color*/
   static BoxDecoration BackButtonGradient=BoxDecoration(
       border: GradientBoxBorder(
         gradient: LinearGradient(
             begin : Alignment.topRight,
             end : Alignment.bottomRight,
             colors: [
               AppColors.greyColor2,

               AppColors.darkblueContainer.withOpacity(0.7),
               AppColors.greydark.withOpacity(0.1),
               //  AppColors.darkblueContainer,
             ]),
         width: 1,
       ),

       // border: Border.all(color:AppColors.greydark,width: 1.1),

       borderRadius: BorderRadius.circular(15),
       gradient: LinearGradient(
         // begin: Alignment.topRight,
         // end: Alignment.bottomLeft,
         colors: [
           AppColors.greyColor2,
           AppColors.BlackgroundBlue,

         ],));

}












