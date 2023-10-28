import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class Helper {
  static final Helper dialogCall = Helper._();

  Helper._();

  showToast(context,String messages){
    return showToastWidget(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 18.0,vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 50.0),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          color: AppColors.darkRedColor,
        ),
        child: Text(
          messages,
          style: const TextStyle(
            color: AppColors.whiteColor,
          ),
        ),
      ),
      context: context,
    );

  }

  showLoader(){
    return const Center(
      child: SpinKitCircle(
        color: AppColors.white,
      ),
    );
  }

  showAlertDialog(BuildContext context){
    AlertDialog alert = AlertDialog(
      backgroundColor: AppColors.darklightgrey,
      content: SizedBox(
        height: 50,
        child: Row(

          mainAxisSize: MainAxisSize.min,
          children: [
            showLoader(),
            Container(
                margin: const EdgeInsets.only(left: 5),
                child: const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text("Loading ...",
                    style: TextStyle(
                      fontSize: 18,
                      color:  AppColors.whiteColor ,
                    ),
                  ),
                )
            ),
          ],
        ),
      ),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

  encryptAddressColumn(encryptValue){
    String encryptionKey = "53522d5174c4f7c03bcf0a67c5066bc9";
    final key = encrypt.Key.fromUtf8(encryptionKey);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encryptedValue = encrypter.encrypt(encryptValue, iv: iv);
    return  encryptedValue.base64;
  }

  decryptAddressColumn(decryptValue){
    String encryptionKey = "53522d5174c4f7c03bcf0a67c5066bc9";
    final key = encrypt.Key.fromUtf8(encryptionKey);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    // final encrypted = encrypter.encrypt(decryptValue);
    final encryptedValue = encrypter.decrypt64(decryptValue, iv: iv);
    return  encryptedValue;
  }

}