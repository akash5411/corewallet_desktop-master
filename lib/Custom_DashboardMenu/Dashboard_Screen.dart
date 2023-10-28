
import 'package:corewallet_desktop/Ui/Dashboard/Exchange/Exchange.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Wallet/PriceChart.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Wallet/Recieveto.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Wallet/Sendto.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Wallet/Wallet.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Wallet/Wallet_Add_Assets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/ExchangeProvider.dart';
import '../Provider/MarketProvider.dart';
import '../Provider/Wallet_Provider.dart';

class MainWallet extends StatefulWidget {
  const MainWallet({
    Key? key,
  }) : super(key: key);


  @override
  State<MainWallet> createState() => _MainWalletState();
}

class _MainWalletState extends State<MainWallet> {

  final GlobalKey _key = GlobalKey();
  late WalletProvider walletProvider;
  late ExchangeProvider exchangeProvider;
  late MarketProvider marketProvider;


  @override
  void initState() {
    super.initState();
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);
    marketProvider = Provider.of<MarketProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context)  {

    walletProvider = Provider.of<WalletProvider>(context, listen: true);
    exchangeProvider = Provider.of<ExchangeProvider>(context, listen: true);
    marketProvider = Provider.of<MarketProvider>(context, listen: true);
    return  Scaffold(
      key: _key,
      body: walletProvider.wallet_PageName=="Wallet"
          ?
      const Wallet()
          :
      walletProvider.wallet_PageName=="PriceChart"
          ?
      const Price_Chart()
          :
      walletProvider.wallet_PageName=="AddAssets"
          ?
      const Wallets_Add_assets()
          :
      walletProvider.wallet_PageName == "SendTo"
          ?
      const SendToPage()
          :
      walletProvider.wallet_PageName == "RecieveTo"
          ?
      const RecieveTo()
          :
      exchangeProvider.exchange_PageName == "Exchange"
          ?
      const Exchange_Page()
          :
      const SizedBox(),

    );
  }
}


