import 'package:corewallet_desktop/Provider/Account_Provider.dart';
import 'package:corewallet_desktop/Provider/Token_Provider.dart';
import 'package:corewallet_desktop/Ui/Authentication/CreateWallet/create_page_step2.dart';
import 'package:corewallet_desktop/Values/Helper/helper.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateWallet extends StatefulWidget {
  bool isNew;

  CreateWallet({Key? key,required this.isNew}) : super(key: key);

  @override
  State<CreateWallet> createState() => _CreateWalletState();
}

class _CreateWalletState extends State<CreateWallet> {

  TextEditingController passwordController = TextEditingController();
  TextEditingController rePasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  bool showPass = true, showRePass = true,termBool = false,hasError = true;

  late AccountProvider accountProvider;
  late TokenProvider tokenProvider;

  String deviceId = "",phraseLength = "12";
  bool isLoading = false;
  GlobalKey<FormState> formKey = GlobalKey();


  importAccount() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    deviceId = sharedPreferences.getString('deviceId')!;


    var data = {
      "name": nameController.text,
      "device_id": deviceId,
      "type": "new",
      "password": widget.isNew ? "" : passwordController.text,
      "words":int.parse(phraseLength),
      "mnemonic": ""
    };

    // print(jsonEncode(data));

    await accountProvider.addAccount(data, widget.isNew ? '/createWallet' : '/initCreateWallet');
    if (accountProvider.isSuccess == true) {

      if(!widget.isNew) {
        sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString('isLogin', 'false');
        sharedPreferences.setInt('account', 1);
        sharedPreferences.setString('password', passwordController.text);
      }
      var body = accountProvider.accountData;
      String seedPhase = body[0]['mnemonic'];

      List seedPharse = seedPhase.trim().split(" ");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CreateWalletStep2(
              seedPhare: seedPharse,
              isNew:widget.isNew
          ),
        ),
      );
    } else {

      setState(() {
        isLoading = false;
      });

      Helper.dialogCall.showToast(context, "Account Create Error");
    }
  }

  @override
  void initState() {
    super.initState();
    accountProvider = Provider.of<AccountProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
  }


  @override
  Widget build(BuildContext context) {

    accountProvider = Provider.of<AccountProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20),

              //App Bar
              Row(
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
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
                          child:Image.asset("assets/icons/backarrow.png",height: 24),)),
                  ),
                  const SizedBox(width: 20),

                  Text(
                      "Create Password",
                      style: TextStyle(
                          color: AppColors.White,
                          fontFamily: "Sf-SemiBold",
                          fontSize: Responsive.isMobile(context)?18:20
                      )
                  ),

                ],
              ),
              const SizedBox(height: 40),

              // Mnemonic Phrase text
              const Text(
                  "Mnemonic Phrase",
                  style: TextStyle(
                      color: AppColors.White,
                      fontFamily: "Sf-SemiBold",
                      fontSize: 14
                  )
              ),
              const SizedBox(height: 10),

              // Mnemonic Phrase option row
              Row(
                children: [

                  InkWell(
                    onTap: (){
                      setState(() {
                        phraseLength = "12";
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          phraseLength == "12"
                              ?
                          Icons.radio_button_checked
                              :
                          Icons.radio_button_off,
                          color:  phraseLength == "12" ? AppColors.whiteColor : AppColors.greyColor,
                        ),
                        SizedBox(width: 10),

                        Text(
                          "12 word",
                          style: TextStyle(
                              fontSize: 14,
                              color: phraseLength != "12" ? AppColors.white.withOpacity(0.5): AppColors.white ,
                              fontFamily: "Sf-SemiBold"
                          )
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 20),

                  InkWell(
                    onTap: (){
                      setState(() {
                        phraseLength = "24";
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          phraseLength == "24"
                              ?
                          Icons.radio_button_checked
                              :
                          Icons.radio_button_off,
                          color:  phraseLength == "24" ? AppColors.whiteColor : AppColors.greyColor,
                        ),

                        SizedBox(width: 10),

                        Text(
                          "24 word",
                          style: TextStyle(
                              fontSize: 14,
                              color: phraseLength != "24" ? AppColors.white.withOpacity(0.5): AppColors.white ,
                              fontFamily: "Sf-SemiBold"
                          )
                        ),
                      ],
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 10),

              //Wallet name
              const Text(
                  "Wallet Name",
                  style: TextStyle(
                      color: AppColors.White,
                      fontFamily: "Sf-SemiBold",
                      fontSize: 14
                  )
              ),
              const SizedBox(height: 10),

              //Wallet name TextField
              TextFormField(
                controller: nameController,
                cursorColor:  AppColors.white,
                style: const TextStyle(
                    color: AppColors.white,
                    fontFamily: "Sf-Regular",
                    fontSize: 14
                ),

                validator:(value){
                  if(value!.isEmpty){
                    setState(() {
                      hasError = true;
                    });
                    //  return "Enter your password";
                    return "";
                  }
                  else{
                    setState(() {
                      hasError = false;
                    });
                  }
                  return null;
                },
                onChanged: (value){
                  if(value.isEmpty){
                    setState(() {
                      hasError = true;
                    });
                  }else{
                    setState(() {
                      hasError = false;
                    });
                  }
                },

                decoration: InputDecoration(
                    fillColor: AppColors.ContainergreySearch,
                    filled: true,
                    isDense: true,
                    hintText: "Wallet Name",

                    hintStyle: const TextStyle(
                        color: AppColors.greydark,
                        fontFamily: "Sf-Regular",
                        fontSize: 14
                    ),

                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.transparent),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.transparent, width: 2),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    errorStyle: const TextStyle(
                      height: 0,fontSize: 0,
                    )
                ),
              ),
              const SizedBox(height: 20),

              // Password
              const Text(
                  "Password",
                  style: TextStyle(
                      color: AppColors.White,
                      fontFamily: "Sf-SemiBold",
                      fontSize: 14
                  )
              ),
              const SizedBox(height: 10),

              //Password TextField
              TextFormField(
                obscureText: showPass,
                controller: passwordController,
                cursorColor:  AppColors.white,
                style: const TextStyle(
                    color: AppColors.white,
                    fontFamily: "Sf-Regular",
                    fontSize: 14
                ),
                validator:(value){
                  if(value!.isEmpty){
                    setState(() {
                      hasError = true;
                    });
                    return "";
                  }else if(value != rePasswordController.text){
                    setState(() {
                      hasError = true;
                    });
                    return "";
                  }else{
                    setState(() {
                      hasError = false;
                    });
                  }
                  return null;
                },
                onChanged: (value){
                  if(value.isEmpty){
                    setState(() {
                      hasError = true;
                    });
                  }else if(value != rePasswordController.text){
                    setState(() {
                      hasError = true;
                    });
                  }else{
                    setState(() {
                      hasError = false;
                    });
                  }
                },

                decoration: InputDecoration(
                  suffixIcon: InkWell(
                    onTap: (){
                      setState(() {
                        showPass = !showPass;
                      });
                    },
                    child: !showPass
                        ?


                    const Icon(Icons.visibility,color: AppColors.white,size: 18,)
                    :
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        "assets/icons/eye_off.png",
                        height: 10,
                        width: 10,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  fillColor: AppColors.ContainergreySearch,
                  filled: true,
                  isDense: true,
                  hintText: "Example21@#!",
                  hintStyle: const TextStyle(
                      color: AppColors.greydark,
                      fontFamily: "Sf-Regular",
                      fontSize: 14
                  ),
                  errorStyle: const TextStyle(
                    height: 0,fontSize: 0,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.transparent),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.transparent, width: 2),
                      borderRadius: BorderRadius.circular(10)
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Re-Password
              const Text(
                  "Re-Enter Password",
                  style: TextStyle(
                      color: AppColors.White,
                      fontFamily: "Sf-SemiBold",
                      fontSize: 14
                  )
              ),
              const SizedBox(height: 10),

              //Re-Password TextField
              TextFormField(
                obscureText: showRePass,
                controller: rePasswordController,
                cursorColor:  AppColors.white,
                style: const TextStyle(
                    color: AppColors.white,
                    fontFamily: "Sf-Regular",
                    fontSize: 14
                ),

                validator:(value){
                  if(value!.isEmpty){
                    setState(() {
                      hasError = true;
                    });
                    return "";
                  }else if(value.length < 5){
                    setState(() {
                      hasError = true;
                    });
                    return "";
                  }else if(value != passwordController.text){
                    setState(() {
                      hasError = true;
                    });
                    return "";
                  }else{
                    setState(() {
                      hasError = false;
                    });
                  }
                  return null;
                },
                onChanged: (value){
                  if(value.isEmpty){
                    setState(() {
                      hasError = true;
                    });
                  }else if(value.length < 5){
                    setState(() {
                      hasError = true;
                    });
                  }else if(value != passwordController.text){
                    setState(() {
                      hasError = true;
                    });
                  }else{
                    setState(() {
                      hasError = false;
                    });
                  }
                },

                decoration: InputDecoration(
                  fillColor: AppColors.ContainergreySearch,
                  filled: true,
                  isDense: true,
                  hintText: "Example21@#!",
                  hintStyle: const TextStyle(
                      color: AppColors.greydark,
                      fontFamily: "Sf-Regular",
                      fontSize: 14
                  ),
                  suffixIcon: InkWell(
                    onTap: (){
                      setState(() {
                        showRePass = !showRePass;
                      });
                    },
                    child: !showRePass
                        ?


                    const Icon(Icons.visibility,color: AppColors.white,size: 18,)
                    :
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        "assets/icons/eye_off.png",
                        height: 10,
                        width: 10,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  errorStyle: const TextStyle(
                    height: 0,fontSize: 0,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.transparent),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.transparent, width: 2),
                      borderRadius: BorderRadius.circular(10)
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // check box
              InkWell(
                onTap: (){
                  setState(() {
                    termBool = !termBool;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                          color: termBool ? AppColors.blueColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            width: 1.5,
                            color: termBool ? AppColors.blueColor : AppColors.white,
                          )
                      ),
                      child: termBool ? const Center(child: Icon(Icons.check,size: 18,color: Colors.white,)) : const SizedBox(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                          "I understand that CATENA can't recover this password for me",
                          style: TextStyle(
                              color: AppColors.white.withOpacity(0.6),
                              fontFamily: "Sf-Regular",
                              fontSize: 14
                          )
                      ),
                    )
                  ],
                ),
              ),
              const Spacer(),

              // submit button
              isLoading == true
                  ?
              Helper.dialogCall.showLoader()
                  :
              InkWell(
                onTap: () {
                  if (formKey.currentState!.validate() && !hasError && termBool) {
                    // print("check1");
                    importAccount();
                  }
                },
                child: Center(
                  child: Container(
                    height: 50,
                    width: Responsive.isDesktop(context) ? width/2 : width,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: hasError || !termBool ? AppColors.blueColor.withOpacity(0.25):AppColors.blueColor,

                        gradient: AppColors.buttonGradient2,
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: Text(
                        "Continue",
                        style: TextStyle(
                            fontSize: 14,
                            color: hasError || !termBool ? AppColors.white.withOpacity(0.5): AppColors.white ,
                            fontFamily: "Sf-SemiBold"
                        )
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }
}
