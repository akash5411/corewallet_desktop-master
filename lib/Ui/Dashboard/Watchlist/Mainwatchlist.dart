

import 'package:corewallet_desktop/Provider/WatchlistProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Market/WatchlistMarket.dart';

class MainWatchList extends StatefulWidget {
  const MainWatchList({Key? key}) : super(key: key);

  @override
  State<MainWatchList> createState() => _MainWatchListState();
}

class _MainWatchListState extends State<MainWatchList> {
  late WatchListProvider watchProvider;


  @override
  void initState() {
    // TODO: implement initState

    watchProvider = Provider.of<WatchListProvider >(context, listen: false);


  }
  @override
  Widget build(BuildContext context) {
    watchProvider = Provider.of<WatchListProvider>(context, listen: true);


    return Scaffold(
      body:

      watchProvider.watchListPage == "WatchList"
          ?
      WatchListMarket()
          :
      SizedBox(),
    );
  }
}
