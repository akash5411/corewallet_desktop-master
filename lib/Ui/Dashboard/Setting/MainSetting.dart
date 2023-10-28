

import 'package:corewallet_desktop/Provider/SettingProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'PaswordChange.dart';
import 'Setting.dart';
import 'backUpPage.dart';




class MainSetting extends StatefulWidget {
  const MainSetting({Key? key}) : super(key: key);

  @override
  State<MainSetting> createState() => _MainSettingState();
}

class _MainSettingState extends State<MainSetting> {

  late SettingProvider settingsProvider;


  @override
  void initState() {
    // TODO: implement initState

    settingsProvider = Provider.of<SettingProvider>(context, listen: false);


  }

  @override
  Widget build(BuildContext context) {
    settingsProvider = Provider.of<SettingProvider>(context, listen: true);

    return Scaffold(
      body:
      settingsProvider.setting_PageName == "Setting"
          ?
      const Setting_Page()
           :
      settingsProvider.setting_PageName == "Changepassword"
          ?
      const PasswordChange()
          :
      settingsProvider.setting_PageName == "backup"
          ?
      const BackUpPage()
          :
      const SizedBox(),
    );
  }
}
