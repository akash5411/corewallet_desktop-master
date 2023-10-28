import 'dart:convert';

import 'package:corewallet_desktop/Handlers/ApiHandle.dart';
import 'package:corewallet_desktop/Models/StakeModel.dart';
import 'package:flutter/cupertino.dart';

class StakingProvider with ChangeNotifier{


  var staking_PageName="Staking";

  changeListnerStack( String value){
    staking_PageName= value;
    notifyListeners();

  }


  bool isLoading = false;
  var allowanceData = false;
  bool isAllowance = false;
  getAllowance(data, url) async {
    isAllowance = false;
    notifyListeners();

    await ApiHandler.post(data, url).then((responseData) {

      var value = json.decode(responseData.body);
      // print("check allowance :- $value");

      if(responseData.statusCode == 200 && value["status"] == true){

        isAllowance = true;
        allowanceData = value["isAllowance"];
        notifyListeners();
      }
      else {
        isAllowance = false;
        notifyListeners();
        print("=========== Check Allowance Api Error ==========");
      }
    });

  }


  var estimateApproveFeesData;
  bool isEstimateApproveFees = false;
  estimateApproveFees(data, url) async {
    isEstimateApproveFees = false;
    notifyListeners();

    await ApiHandler.post(data, url).then((responseData) {

      var value = json.decode(responseData.body);
      //print("check allowance :- $value");

      if(responseData.statusCode == 200 && value["status"] == true){

        isEstimateApproveFees = true;
        estimateApproveFeesData = value;
        notifyListeners();
      }
      else {
        isEstimateApproveFees = false;
        notifyListeners();
        print("=========== Estimate ApproveFees Api Error ==========");
      }
    });

  }

  var approveTokenData;
  bool approveTokenSuccess = false;
  approveToken(data, url) async {
    approveTokenSuccess = false;
    notifyListeners();

    await ApiHandler.post(data, url).then((responseData) {

      var value = json.decode(responseData.body);
      //print("check allowance :- $value");

      if(responseData.statusCode == 200 && value["status"] == true){

        approveTokenSuccess = true;
        approveTokenData = value;
        notifyListeners();
      }
      else {
        approveTokenSuccess = false;
        notifyListeners();
        print("=========== Approve TokenSuccess Api Error ==========");
      }
    });

  }


  var createStakeData;
  bool createStakeSuccess = false;
  createStake(data, url) async {
    createStakeSuccess = false;
    notifyListeners();

    await ApiHandler.post(data, url).then((responseData) {

      var value = json.decode(responseData.body);
      //print("check allowance :- $value");

      if(responseData.statusCode == 200 && value["status"] == true){

        createStakeSuccess = true;
        createStakeData = value;
        notifyListeners();
      }
      else {
        createStakeSuccess = false;
        notifyListeners();
        print("=========== createStake Api Error ==========");
      }
    });

  }

  var stakeestimate;
  bool estimateStake = false;
  estimateStakeMethod(data, url) async {
    estimateStake = false;
    notifyListeners();

    await ApiHandler.post(data, url).then((responseData) {

      var value = json.decode(responseData.body);
      //print("Estimate Create Stake :- $value");

      if(responseData.statusCode == 200 && value["status"] == true){

        estimateStake = true;
        stakeestimate = value;
        notifyListeners();
      }
      else {
        estimateStake = false;
        notifyListeners();
        print("=========== Estimate Create Stake Api Error ==========");
      }
    });

  }


  StakeInfo? stakeInfoModel;
  bool stackInfoLoading = false;
  getStackInfo(data,url) async{
    stakeInfoModel = null;
    stackInfoLoading = true;
    isLoading = true;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData) {

      var value = json.decode(responseData.body);
      // print(value);
      if(responseData.statusCode == 200 && value["status"] == true) {
        stakeInfoModel = StakeInfo.fromJson(value["data"]);

        loadStake = true;
        stackInfoLoading = false;
        isLoading = false;
        notifyListeners();
      }
      else {
        isLoading = false;
        notifyListeners();

        print("=========== Get Stack Info Api Error ==========");
      }
    });
  }


  bool loadStake = false;
  List<StakeList> stackList = [];
  List<bool> stakeExpand = [];
  int totalPage = 0 ;

  getStakes(data,url) async {
    isLoading = true;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData) {

      var value = json.decode(responseData.body);
      //print(value);
      if(responseData.statusCode == 200 && value["status"] == true) {

        final items = value["stakeList"].cast<Map<String, dynamic>>();
        List<StakeList> list = items.map<StakeList>((val) {
          return StakeList.fromJson(val);
        }).toList();


        stackList.addAll(list);
        stakeExpand = List.filled(stackList.length, false);

        totalPage = value["total_page"];

        loadStake = true;
        isLoading = false;
        notifyListeners();
      }
      else {
        isLoading = false;
        notifyListeners();

        print("=========== Get Stack Api Error ==========");
      }
    });

  }


  var estimateWithdrawData;
  bool Withdrawbool =  false;
  estimateWithdraw(data,url) async {
    isLoading = true;
    Withdrawbool = false;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData){

      var value = json.decode(responseData.body);

      // print("value--->  $value");

      if(responseData.statusCode == 200 && value["status"] == true)
      {
        estimateWithdrawData = value;

        isLoading = false;
        Withdrawbool = true;
        notifyListeners();
      }
      else
      {
        isLoading = false;
        Withdrawbool = false;
        notifyListeners();

        print("=========== Estimate Api Error ==========");

      }

    });

  }

  var estimateHarvestWithdrawData;
  bool harvestWithdrawBool =  false;
  estimateHarvestWithdraw(data,url) async {
    //isLoading = true;
    harvestWithdrawBool = false;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData){

      var value = json.decode(responseData.body);

      // print(value);

      if(responseData.statusCode == 200 && value["status"] == true)
      {
        estimateHarvestWithdrawData = value;

       // isLoading = false;
        harvestWithdrawBool = true;
        notifyListeners();
      }
      else
      {
      //  isLoading = false;
        harvestWithdrawBool = false;
        notifyListeners();

        print("=========== harvest Withdraw Api Error ==========");

      }

    });

  }


  var WithdrawStake;
  bool WithdrawBool =  false;
  WithdrawStakeToken(data,url) async {
    isLoading = true;
    WithdrawBool = false;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData){

      var value = json.decode(responseData.body);
      // print("WithdrawStakeToken $value");

      if(responseData.statusCode == 200 && value["status"] == true)
      {
        WithdrawStake = value;

        isLoading = false;
        WithdrawBool = true;
        notifyListeners();
      }
      else
      {
        isLoading = false;
        WithdrawBool = false;
        notifyListeners();

        print("=========== WithDraw Stack Api Error ==========");

      }

    });

  }

  var harvestStake;
  bool harvestStakeBool =  false;
  harvestStakeToken(data,url) async {
    isLoading = true;
    harvestStakeBool = false;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData){

      var value = json.decode(responseData.body);

      if(responseData.statusCode == 200 && value["status"] == true)
      {
        harvestStake = value;

        isLoading = false;
        harvestStakeBool = true;
        notifyListeners();
      }
      else
      {
        isLoading = false;
        harvestStakeBool = false;
        notifyListeners();

        print("=========== harvest Stack Api Error ==========");

      }

    });

  }
}