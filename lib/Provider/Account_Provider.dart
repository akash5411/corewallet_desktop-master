import 'dart:convert';
import 'package:corewallet_desktop/values/Helper/helper.dart';
import 'package:flutter/material.dart';
import '../Handlers/ApiHandle.dart';
import '../LocalDb/Local_Account_provider.dart';


class AccountProvider with ChangeNotifier{



  bool isLoading = false;
  bool isSuccess = false;

  var accountData;
  bool isAccountLoad = false;
  addAccount(data,url) async {
    isLoading = true;
    isSuccess = false;
    isAccountLoad = false;
    notifyListeners();

      await ApiHandler.post(data,url).then((responseData){

        var value = json.decode(responseData.body);
        // print("account add =====>  $value");

        if(responseData.statusCode == 200 && value["status"] == true)
        {
          accountData = value["accounts"];

          isLoading = false;
          isSuccess = true;
          isAccountLoad = true;
          notifyListeners();
        }
        else
        {
          isLoading = false;
          isSuccess = false;
          isAccountLoad = false;
          notifyListeners();
          // print("=========== Add Account Api Error ==========");

        }

      });
  }


  var allAccounts;
  getAccount(data,url) async
  {
    isLoading = true;
    isSuccess = false;

      await ApiHandler.post(data,url).then((responseData){

        var value = json.decode(responseData.body);
        //print(value);
        if(responseData.statusCode == 200 && value["status"] == true)
        {
          isSuccess = true;
          allAccounts = value;
          DBAccountProvider.dbAccountProvider.deleteAllAccount();

         /* (allAccounts["accounts"] as List).map((accounts){
            DBAccountProvider.dbAccountProvider.createAccount(AccountList.fromJson(accounts));
          }).toList();*/

          isLoading = false;
          notifyListeners();
        }
        else
        {
          isLoading = false;
          isSuccess = false;
          notifyListeners();
          // print("=========== Get Account Api Error ==========");
        }

      });

  }


  bool isAccount = false;
  var checkAccountList;
  checkAccount(data,url) async
  {
    isLoading = true;

      await ApiHandler.post(data,url).then((responseData){

        var value = json.decode(responseData.body);
        if(responseData.statusCode == 200 && value["status"] == true)
        {
          isAccount = true;
          isLoading = false;
          checkAccountList = value;
          notifyListeners();
        }
        else
        {
          isAccount = false;
          isLoading = false;
          print("=========== Account Check Api Error ==========");
          notifyListeners();

        }
      });

  }


  var loginAccountDetails;
  loginAccount(data,url) async
  {
    isLoading = true;
    isSuccess = false;
    notifyListeners();

      await ApiHandler.post(data,url).then((responseData){

        var value = json.decode(responseData.body);
        //print(value);

        if(responseData.statusCode == 200 && value["status"] == true)
        {
          isSuccess = true;
          isLoading = false;
          loginAccountDetails = value;

          notifyListeners();
        }
        else
        {
          isSuccess = false;
          isLoading = false;
          notifyListeners();

          print("=========== Login Api Error ==========");

        }
      });

  }


  bool isdeleted = true;
  var deleteData;
  deleteAccount(data,url) async
  {
    isLoading = true;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData){

        var value = json.decode(responseData.body);
        //print(value);

        if(responseData.statusCode == 200 && value["status"] == true)
        {
          isdeleted = true;
          deleteData = value;
          notifyListeners();
        }
        else
        {
          isdeleted = false;
          isLoading = false;
          notifyListeners();
          print("=========== Delete Account Api Error ==========");

        }

      });

  }


  bool isPassword = false;
  forgotPassword(data,url) async
  {
    isLoading = true;
    notifyListeners();

      await ApiHandler.post(data,url).then((responseData){

        var value = json.decode(responseData.body);
        //print(value);

        if(responseData.statusCode == 200 && value["status"] == true)
        {
          isPassword = true;
          isLoading = false;
          notifyListeners();
        }
        else
        {
          isPassword = false;
          isLoading = false;
          notifyListeners();

          print("=========== Forgot Password Api Error ==========");

        }
      });

  }


  bool isChange = false;
  changeAccountName(data,url) async
  {
    isLoading = true;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData){

        var value = json.decode(responseData.body);
        //print(value);

        if(responseData.statusCode == 200 && value["status"] == true)
        {
          isChange = true;
          isLoading = false;
          notifyListeners();
        }
        else
        {
          isChange = false;
          isLoading = false;
          notifyListeners();
          print("=========== Account Name Change Api Error ==========");

        }
      });

  }


  bool isGetHelp = false;
  getHelp(data,url) async {
    isLoading = true;
    notifyListeners();

    await ApiHandler.post1(data,url).then((responseData){

      var value = json.decode(responseData.body);
      //print(value);

      if(responseData.statusCode == 200 && value["status"] == true)
      {
        isGetHelp = true;
        isLoading = false;
        notifyListeners();
      }
      else
      {
        isGetHelp = false;
        isLoading = false;
        notifyListeners();
        print("=========== Get Help Api Error ==========");
      }
    });

  }



  var profileData;
  getProfile(data,url) async{
    profileData = null;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData) {
      var value = json.decode(responseData.body);

      // print("get profile ===> $value");
      if(responseData.statusCode == 200 && value["status"] == true) {


        isLoading = false;
        profileData = value["data"];

        notifyListeners();

      }else{
        isLoading = false;
        profileData = value["data"];

        notifyListeners();

        print("=========== get profile Api Error ==========");
      }
    });
  }

  bool setProfileStatus = false;
  var setProfileData;
  setProfileName(data,url,context, ) async{
    Helper.dialogCall.showAlertDialog(context);
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData) {
      var value = json.decode(responseData.body);

      // print("update user name  ===> $value");
      if(responseData.statusCode == 200 && value["status"] == true) {

        isLoading = false;
        setProfileStatus = value["status"];
        setProfileData = value["data"];
        Helper.dialogCall.showToast(context, "profile update");

        Navigator.pop(context);
        notifyListeners();

      }else{
        isLoading = false;
        setProfileStatus = value["status"];
        Helper.dialogCall.showToast(context, "${value["data"]}");

        Navigator.pop(context);

        notifyListeners();

        print("=========== insert Edit profile Api Error ==========");
      }
    });
  }

  sendContactRequest(data,url,context, ) async{
    Helper.dialogCall.showAlertDialog(context);
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData) {
      var value = json.decode(responseData.body);

      // print("update user name  ===> $value");
      if(responseData.statusCode == 200 && value["status"] == true) {

        isLoading = false;
        Helper.dialogCall.showToast(context, "request_send");

        Navigator.pop(context,"refresh");
        Navigator.pop(context,"refresh");
        notifyListeners();

      }else{
        isLoading = false;
        Helper.dialogCall.showToast(context, "${value["data"]}");

        Navigator.pop(context,"refresh");

        notifyListeners();

        print("=========== send contact Request Api Error ==========");
      }
    });
  }









}