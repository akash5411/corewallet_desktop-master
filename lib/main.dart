import 'dart:io';
import 'package:corewallet_desktop/Custom_DashboardMenu/MainScreenPage.dart';
import 'package:corewallet_desktop/Idel_Page.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_address.dart';
import 'package:corewallet_desktop/LocalDb/Local_Account_provider.dart';
import 'package:corewallet_desktop/LocalDb/Local_Exchange_Provider.dart';
import 'package:corewallet_desktop/LocalDb/Local_Token_provider.dart';
import 'package:corewallet_desktop/Provider/HistroyProvider.dart';
import 'package:corewallet_desktop/Provider/Transection_Provider.dart';
import 'package:corewallet_desktop/Ui/Authentication/ImportWallet/import_page.dart';
import 'package:corewallet_desktop/Ui/Authentication/login_page.dart';
import 'package:corewallet_desktop/Ui/Authentication/splash_page.dart';
import 'package:corewallet_desktop/Values/appColors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'LocalDb/Local_Watchlist_provider.dart';
import 'Provider/Account_Provider.dart';
import 'Provider/BuyCryptoProvider.dart';
import 'Provider/ExchangeProvider.dart';
import 'Provider/MarketProvider.dart';
import 'Provider/SettingProvider.dart';
import 'Provider/StakingProvider.dart';
import 'Provider/Token_Provider.dart';
import 'Provider/Wallet_Provider.dart';
import 'Provider/WatchlistProvider.dart';
import 'Provider/uiProvider.dart';
import 'key.dart';

Future<void> main()  async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions;

  if(Platform.isWindows) {
    windowOptions = const WindowOptions(
      size: Size(900, 700),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      alwaysOnTop: false,
      fullScreen: false,
      titleBarStyle: TitleBarStyle.normal,
      minimumSize: Size(855, 715),

    );
  }else{
    windowOptions = const WindowOptions(
      size: Size(800, 815),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      fullScreen: false,
      titleBarStyle: TitleBarStyle.normal,
      minimumSize: Size(800, 815),

    );
  }

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });


  DbAccountAddress accountAddressDB = DbAccountAddress.dbAccountAddress;
  DBAccountProvider accountProviderDB = DBAccountProvider.dbAccountProvider;
  DBTokenProvider tokenProviderDB = DBTokenProvider.dbTokenProvider;
  DBWatchListProvider watchListProviderDB = DBWatchListProvider.dbWatchListProvider;
  DBExchange exchangeDB = DBExchange.exchangeDB;

  accountAddressDB.initDB();
  accountProviderDB.initDB();
  tokenProviderDB.initDB();
  watchListProviderDB.initDB();
  exchangeDB.initDB();

  // Initialize FFI
  sqfliteFfiInit();

  runApp( MyApp());
}
class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

   MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {



  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        ChangeNotifierProvider(create: (context) => AccountProvider()),
        ChangeNotifierProvider(create: (context) => TokenProvider()),
        ChangeNotifierProvider(create: (context) => WatchListProvider()),
        ChangeNotifierProvider(create: (context) => UiProvider()),
        ChangeNotifierProvider(create: (context) => WalletProvider()),
        ChangeNotifierProvider(create: (context) => ExchangeProvider()),
        ChangeNotifierProvider(create: (context) => MarketProvider()),
        ChangeNotifierProvider(create: (context) => BuyCryptoProvider()),
        ChangeNotifierProvider(create: (context) => StakingProvider()),
        ChangeNotifierProvider(create: (context) => HistroyProvider()),
        ChangeNotifierProvider(create: (context) => SettingProvider()),
        ChangeNotifierProvider(create: (context) => TransectionProvider()),
      ],
      child: MaterialApp(
        navigatorKey: myGlobalKey,
        debugShowCheckedModeBanner: false,
        title: 'Catena',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            highlightColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            shadowColor: Colors.transparent,
            splashColor: Colors.transparent,
            scaffoldBackgroundColor: AppColors.BlackgroundBlue
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

