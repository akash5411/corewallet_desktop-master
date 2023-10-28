

import 'package:corewallet_desktop/Provider/SettingProvider.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:corewallet_desktop/Values/styleandborder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';


class PasswordChange extends StatefulWidget {
  const PasswordChange({Key? key}) : super(key: key);

  @override
  State<PasswordChange> createState() => _PasswordChangeState();
}

class _PasswordChangeState extends State<PasswordChange> {
  late SettingProvider settingsProvider;
  bool resetShowPassword = false;
  bool resetShowPassword1 = false;
  bool resetShowPassword2 = false;
  bool resetConfirmPassword = false;

  TextEditingController _confirmcontroller =TextEditingController();
  TextEditingController _oldcontroller =TextEditingController();
  TextEditingController _newcontroller =TextEditingController();
  var width,height;
  bool status=false;

  @override
  void initState() {
    // TODO: implement initState
    settingsProvider = Provider.of<SettingProvider>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height=MediaQuery.of(context).size.height;
    width=MediaQuery.of(context).size.width;
    settingsProvider = Provider.of<SettingProvider>(context, listen: true);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20,right: 20,top: 20),
        child: SingleChildScrollView(
          physics:NeverScrollableScrollPhysics() ,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Row(
              children: [
                InkWell(
                  onTap: (){
                    settingsProvider.changeListnerSetting("Setting");
                    // Navigator.pop(context);
                  },
                  child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: Boxdec.BackButtonGradient,
                      child: Center(
                        child:SvgPicture.asset(
                            'assets/icons/Market/backArrow.svg',
                            width: 22
                        ),),),
                ),

                Expanded(child: SizedBox(width: 1,)),

                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Text("Change Password",style: TextStyle(color: AppColors.White,fontFamily: "Sf-SemiBold",fontSize: 20)),
                ),
                Expanded(child: SizedBox(width: 1,)),
              ],
            ),
            SizedBox(height: 20,),

              SizedBox(
                height: height/1,
                child: ListView(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                      Container(
                          width: width/3,
                          alignment: Alignment.centerLeft,
                          child: Text("Semper glade considerable untameable airs heats, drooping grasp. Iceberg hollows ditties hemlocks", style:TextStyle(color: AppColors.WhiteText,fontFamily: "Sf-Regular",fontSize: 14,),textAlign: TextAlign.center)),

                      SizedBox(height: 50,),

                      Center(
                        child: Container(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  // alignment: Alignment.centerLeft,
                                    child: Text("Old Password",style: TextStyle(color: AppColors.White,fontFamily: "Sf-SemiBold",fontSize: Responsive.isTablet(context)?12:14))),
                                SizedBox(height: 5,),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  width: Responsive.isMobile(context)?width/3: width/4,
                                  child: TextField(
                                    style: TextStyle(color: AppColors.whiteColor),
                                    decoration:fieldStyle1.copyWith(
                                      hintText: "Old Password",labelStyle:TextStyle(color: AppColors.whiteColor,fontFamily: "Sf-Regular",fontSize:  Responsive.isTablet(context)?10:10),
                                      hintStyle: TextStyle(color: AppColors.whiteColor),
                                      suffixIcon: Padding(
                                          padding: const EdgeInsets.only(right: 20),
                                          child:  InkWell(
                                            onTap: (){
                                              setState(() {
                                                resetShowPassword =! resetShowPassword;
                                              });
                                            },
                                            child:resetShowPassword==false?
                                            Icon(Icons.remove_red_eye,color: AppColors.whiteColor,)
                                                :
                                            Icon(Icons.visibility_off,color: AppColors.whiteColor,),)
                                      ),

                                    ) ,
                                    obscureText: resetShowPassword,
                                    controller: _oldcontroller,
                                    onSubmitted: (String value) {
                                      debugPrint(value);
                                    },),
                                ),
                                SizedBox(height: height/22,),
                                Container(
                                    width: Responsive.isMobile(context)?width/3: width/4,height:1,color: AppColors.ContainergreySearch),
                                SizedBox(height: height/22,),
                                //2
                                Container(
                                  // alignment: Alignment.centerLeft,
                                    child: Text("New Password",style: TextStyle(color: AppColors.White,fontFamily: "Sf-SemiBold",fontSize: Responsive.isTablet(context)?12:14))),
                                SizedBox(height: 5,),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  width: Responsive.isMobile(context)?width/3: width/4,
                                  child: TextField(
                                    obscureText:!resetShowPassword1,
                                    style: TextStyle(color: AppColors.whiteColor),
                                    decoration:fieldStyle1.copyWith(
                                      hintText: "New Password",labelStyle:TextStyle(color: AppColors.whiteColor,fontFamily: "Sf-Regular",fontSize:  Responsive.isTablet(context)?10:10),
                                      hintStyle: TextStyle(color: AppColors.whiteColor),
                                      suffixIcon: Padding(
                                          padding: const EdgeInsets.only(right: 20),
                                          child:  InkWell(
                                            onTap: (){
                                              setState(() {
                                                resetShowPassword1 =! resetShowPassword1;
                                              });
                                            },
                                            child:resetShowPassword1==true?
                                            Icon(Icons.remove_red_eye,color: AppColors.whiteColor,)
                                                :
                                            Icon(Icons.visibility_off,color: AppColors.whiteColor,),)
                                      ),
                                    ) ,
                                    controller: _newcontroller,
                                    onSubmitted: (String value) {
                                    },),
                                ),
                                //3
                                SizedBox(height: 10,),
                                Container(
                                  // alignment: Alignment.centerLeft,
                                    child: Text("Confirm New Password",style:
                                    TextStyle(color: AppColors.White,fontFamily: "Sf-SemiBold",fontSize: Responsive.isTablet(context)?12:14))),
                                SizedBox(height: 5,),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  width: Responsive.isMobile(context)?width/3: width/4,
                                  child: TextField(
                                    obscureText: resetShowPassword2,
                                    style: TextStyle(color: AppColors.whiteColor),
                                      decoration:fieldStyle1.copyWith(
                                      hintText: "Confirm New Password",labelStyle:
                                          TextStyle(color: AppColors.whiteColor,fontFamily: "Sf-Regular",fontSize:  Responsive.isTablet(context)?10:10),
                                      hintStyle: TextStyle(color: AppColors.whiteColor),
                                      suffixIcon:Padding(
                                          padding: const EdgeInsets.only(right: 20),
                                          child:  InkWell(
                                            onTap: (){
                                              setState(() {
                                                resetShowPassword2 =! resetShowPassword2;
                                              });

                                            },
                                            child:resetShowPassword2==false?
                                            Icon(Icons.remove_red_eye,color: AppColors.whiteColor,)
                                                :
                                            Icon(Icons.visibility_off,color: AppColors.whiteColor,),)
                                      ),
                                    ) ,
                                    controller: _confirmcontroller,
                                    onSubmitted: (String value) {
                                      debugPrint(value);
                                    },),
                                ),
                              ],
                            )),
                      ),

                      SizedBox(height: 20,),

                      InkWell(
                        onTap: (){
                          // _showDialogRadioobutttonCoin(context);
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height/18,
                          width: Responsive.isMobile(context)?width/3: width/5.5,
                          decoration: Boxdec.ButtonDecorationGradientwithBorder,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              SizedBox(width: 4,),
                              Center(child:
                              ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (Rect bounds) {
                                  return AppColors.buttonGradient.createShader(
                                      Offset.zero & bounds.size);
                                },
                                child: Text(
                                  "Change Password",
                                  style: TextStyle(
                                    fontFamily: 'Sf-SemiBold',
                                    fontSize: 13,
                                  ),
                                ),
                              ),),
                            ],
                          ),),
                      ),
                      SizedBox(height: height/6,),
                    ],),
                    SizedBox(height: 50,),
                  ],
                  physics: AlwaysScrollableScrollPhysics(),
                ),
              ),
            ],),
        ),
      ),
    );
  }
}
