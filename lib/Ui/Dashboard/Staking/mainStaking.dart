import 'package:corewallet_desktop/Provider/StakingProvider.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Staking/Staking.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'createstake.dart';

class MainStakingPage extends StatefulWidget {
  const MainStakingPage({Key? key}) : super(key: key);

  @override
  State<MainStakingPage> createState() => _MainStakingPageState();
}

class _MainStakingPageState extends State<MainStakingPage> {
  late StakingProvider stakingProvider;


  @override
  void initState() {
    stakingProvider = Provider.of<StakingProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    stakingProvider = Provider.of<StakingProvider>(context, listen: true);

    return Scaffold(
      body:
      stakingProvider.staking_PageName=="Staking"
          ?
      Staking_Page()
          :
      stakingProvider.staking_PageName=="CreateStake"
          ?
      CreateStake()
          :
      SizedBox(),
    );
  }
}
