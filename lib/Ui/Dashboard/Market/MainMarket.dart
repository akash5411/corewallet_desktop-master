
import 'package:corewallet_desktop/Provider/MarketProvider.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Market/coins_page.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Market/loser_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Market.dart';
import 'WatchlistMarket.dart';
import 'gainre_page.dart';



class MainMarket extends StatefulWidget {
  const MainMarket({Key? key}) : super(key: key);

  @override
  State<MainMarket> createState() => _MainMarketState();
}

class _MainMarketState extends State<MainMarket> {

  late MarketProvider marketProvider;


  @override
  void initState() {
    super.initState();

    marketProvider = Provider.of<MarketProvider >(context, listen: false);


  }
  @override
  Widget build(BuildContext context) {
    marketProvider = Provider.of<MarketProvider>(context, listen: true);


    return Scaffold(
      body:
      marketProvider.market_PageName == "Market"
          ?
      Market_Page()
          :
      marketProvider.market_PageName == "Gainer"
          ?
      const MarketMorePage()
          :
      marketProvider.market_PageName == "Loser"
          ?
      const MarketLoserPage()
          :
      marketProvider.market_PageName == "Coins"
          ?
      const TopCoinsPage()
          :
/*      marketProvider.market_PageName == "WatchlistMarket"
          ?
      const WatchListMarket()
          :*/
      const SizedBox(),
    );
  }
}
