import 'package:corewallet_desktop/Idel_Page.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Buy_crypto/Buy_crypto.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Exchange/MainExchange.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Histroy/MainHistroy.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Market/MainMarket.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Setting/MainSetting.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Staking/mainStaking.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Support/Support.dart';
import 'package:corewallet_desktop/Ui/Dashboard/Watchlist/Mainwatchlist.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:corewallet_desktop/Values/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'sideMenu.dart';
import 'Dashboard_Screen.dart';
import '../Provider/Wallet_Provider.dart';
import '../Provider/uiProvider.dart';



class MainDashboardUiScreen extends StatefulWidget {
  const MainDashboardUiScreen({Key? key}) : super(key: key);

  @override
  State<MainDashboardUiScreen> createState() => _MainDashboardUiScreenState();
}

class _MainDashboardUiScreenState extends State<MainDashboardUiScreen> {

  late UiProvider uiProvider;
  late WalletProvider walletProvider;


  final _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    uiProvider = Provider.of<UiProvider>(context, listen: false);
    walletProvider = Provider.of<WalletProvider>(context, listen: false);

  }

  @override
  Widget build(BuildContext context) {
    uiProvider = Provider.of<UiProvider>(context, listen: true);
    walletProvider = Provider.of<WalletProvider>(context, listen: true);

    return Scaffold(
      key: _key,
      body: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{

          const SingleActivator(LogicalKeyboardKey.keyM,control: true): () {
            uiProvider.DashBoardpage("Market");
          },
          const SingleActivator(LogicalKeyboardKey.keyE,control: true): () {
            uiProvider.DashBoardpage("Exchange");
          },

          const SingleActivator(LogicalKeyboardKey.keyW,control: true): () {
            uiProvider.DashBoardpage("Wallet");
          },

          const SingleActivator(LogicalKeyboardKey.keyS,control: true): () {
            uiProvider.DashBoardpage("Setting");
          },

          const SingleActivator(LogicalKeyboardKey.keyQ,control: true): () {
            uiProvider.DashBoardpage("WatchList");
          },

          const SingleActivator(LogicalKeyboardKey.keyR,control: true): () {
            uiProvider.DashBoardpage("Staking");
          },
        },
        child: Focus(
          autofocus: true,
          child: Row(
            children: [
              SizedBox(
                  width: Responsive.isMobile(context)?120: 180,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5,top: 5,bottom: 5),
                    child: SideMenu(),
                  )),
              Expanded(

                child: uiProvider.dashboardPage == "Wallet"
                    ?
                MainWallet()
                    :
                uiProvider.dashboardPage == "Support"
                    ?
                Support_Page()
                    :
                uiProvider.dashboardPage == "Histroy"
                    ?
                MianHistroy()
                    :
                uiProvider.dashboardPage == "Staking"
                    ?
                MainStakingPage()
                    :
                uiProvider.dashboardPage == "Market"
                    ?
                MainMarket()
                    :
                uiProvider.dashboardPage == "Exchange"
                    ?
                MainExchangePage()
                    :
                uiProvider.dashboardPage == "BuyCrypto"
                    ?
                Buy_Crypto_Page()
                    :
                uiProvider.dashboardPage == "WatchList"
                    ?
                MainWatchList()
                    :
                uiProvider.dashboardPage == "Setting"
                    ?
                MainSetting()
                    :
                MainWallet(),
              ),
              //conditions
            ],
          ),
        ),
      )
    /*  IdleTimeout(
        child: ,
      ),*/
    );
  }
}