import 'package:corewallet_desktop/Provider/BuyCryptoProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Buy_crypto.dart';


class MainBuyCrypto extends StatefulWidget {
  const MainBuyCrypto({Key? key}) : super(key: key);

  @override
  State<MainBuyCrypto> createState() => _MainBuyCryptoState();
}

class _MainBuyCryptoState extends State<MainBuyCrypto> {

  late BuyCryptoProvider buycryptoProvider;


  @override
  void initState() {
    // TODO: implement initState

    buycryptoProvider = Provider.of<BuyCryptoProvider>(context, listen: false);


  }

  @override
  Widget build(BuildContext context) {
    buycryptoProvider = Provider.of<BuyCryptoProvider>(context, listen: true);

    return Scaffold(
      body:
      buycryptoProvider.buyCrypto_PageName=="BuyCrypto"
          ?
      Buy_Crypto_Page()
          :
      SizedBox(),
    );
  }
}
