import 'package:flutter/material.dart';
import 'appColors.dart';

var textStyle = TextStyle(
    color: AppColors.kPrimaryColor,
    fontFamily: "Roboto-Regular"
);

var fieldStyle = InputDecoration(
    hintStyle: TextStyle(fontSize: 15 ,color: Colors.white),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
          topRight: Radius.circular(30)
      ),
      borderSide: BorderSide(
        color: Colors.white,
      ),
    ),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
            topRight: Radius.circular(30)
        ),
        borderSide: BorderSide(
          color: Colors.white,
        )
    ),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
            topRight: Radius.circular(30)
        ),
        borderSide: BorderSide(
          color: Colors.red,
        )
    ),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
            topRight: Radius.circular(30)
        ),
        borderSide: BorderSide(
          color: Colors.red,
        )
    )
);





var decoration = BoxDecoration(
    gradient: LinearGradient(begin: Alignment.topLeft,end: Alignment.bottomRight,colors: [Color(0xFFFF647C),Color(0xFFD62A44)]),
    shape: BoxShape.circle,
    boxShadow: [new BoxShadow(
      color: Color.fromRGBO(60, 57, 57, 0.8),
      offset: Offset(0, 2),
      blurRadius: 3,
    )]
);



var round = BorderRadius.only(
    bottomLeft: Radius.circular(30),
    bottomRight: Radius.circular(30),
    topRight: Radius.circular(30)
);

