import 'dart:async';
import 'package:corewallet_desktop/Values/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Ui/Authentication/login_page.dart';
import 'key.dart';

class IdleTimeout extends StatefulWidget {
  Widget child;


  IdleTimeout({super.key,required this.child});

  @override
  _IdleTimeoutState createState() => _IdleTimeoutState();
}

class _IdleTimeoutState extends State<IdleTimeout> {
  Timer? _timer;
  int? duration;
  Future<void> _resetTimer() async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      duration = sharedPreferences.getInt("autoLock")?? 5;
    });

    if(duration == -1){}
    else {

      if (_timer != null) {
        _timer!.cancel();
      }

      if(Utils.pageName=="Dashboard"){

        _timer = Timer(
            Duration(minutes: duration!), () {
              setState(() {
                Utils.pageName="LoginPage";
              });
              myGlobalKey.currentState!.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) =>const LoginPage(),
                  ), (route) => true
              );
            });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void didUpdateWidget(IdleTimeout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (duration != duration) {
      // print("didUpdateWidget call --------> ");
      _resetTimer();
    }
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _resetTimer();
      },
      child:widget.child
    );
  }
}
