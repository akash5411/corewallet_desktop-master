

import 'package:corewallet_desktop/Provider/ExchangeProvider.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Exchange/Exchange.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ExchangeHistroy.dart';

class MainExchangePage extends StatefulWidget {
  const MainExchangePage({Key? key}) : super(key: key);

  @override
  State<MainExchangePage> createState() => _MainExchangePageState();
}

class _MainExchangePageState extends State<MainExchangePage> {

  late ExchangeProvider exchangeProvider;


  @override
  void initState() {
    // TODO: implement initState

    exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);


  }

  @override
  Widget build(BuildContext context) {
    exchangeProvider = Provider.of<ExchangeProvider>(context, listen: true);

    return Scaffold(
      body:
      exchangeProvider.exchange_PageName=="Exchange"
      ?
      Exchange_Page()
          :

      exchangeProvider.exchange_PageName=="exchangehistroy"
          ?
      ExchangeHistroy()
           :
          SizedBox(),
    );
  }
}
