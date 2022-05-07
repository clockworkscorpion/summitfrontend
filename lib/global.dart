import 'package:flutter/material.dart';

Size screenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

double screenHeight(BuildContext context) {
  return screenSize(context).height;
}

double screenWidth(BuildContext context) {
  return screenSize(context).width;
}

double normalizedHeight (context) {
  return screenHeight(context)/720.0;
}

double normalizedWidth (context) {
  return screenWidth(context)/360.0;
}