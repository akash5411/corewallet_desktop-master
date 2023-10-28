

import 'package:corewallet_desktop/Provider/HistroyProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Histroy.dart';

class MianHistroy extends StatefulWidget {
  const MianHistroy({Key? key}) : super(key: key);

  @override
  State<MianHistroy> createState() => _MianHistroyState();
}

class _MianHistroyState extends State<MianHistroy> {

  late HistroyProvider histroyProvider;


  @override
  void initState() {
    // TODO: implement initState

    histroyProvider = Provider.of<HistroyProvider>(context, listen: false);


  }

  @override
  Widget build(BuildContext context) {
    histroyProvider = Provider.of<HistroyProvider>(context, listen: true);

    return Scaffold(
      body:
      histroyProvider.histroy_PageName=="Histroy"
          ?
      Histroy_Page()
          :
      SizedBox(),
    );
  }
}
