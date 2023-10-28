

import 'package:flutter/material.dart';

/// Clip widget in oval shape at left side
class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    //Arranca desde la punta topLeft
    Path path = Path();

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * .05, size.height);
    path.quadraticBezierTo(size.width * .2, size.height * .5, size.width * .03, .04);
    // path.quadraticBezierTo(size.width / 2, size.height * 0.2, size.width, size.height - height);
    path.lineTo(size.width, 0.0);
    path.lineTo(0.0, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper old) => false;
}


class ArcClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    //Arranca desde la punta topLeft
    Path path = Path();

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * .05, size.height);
    path.quadraticBezierTo(size.width * .2, size.height * .5, size.width * .03, .04);
    // path.quadraticBezierTo(size.width / 2, size.height * 0.2, size.width, size.height - height);
    path.lineTo(size.width, 0.0);
    path.lineTo(0.0, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper old) => false;
}