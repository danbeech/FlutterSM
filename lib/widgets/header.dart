import 'package:flutter/material.dart';

AppBar header(context, { bool isAppTitle = false, String titleText, removeBackButton = false}) {
  return AppBar(
    iconTheme: IconThemeData(
            color: Colors.black,
          ),
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      isAppTitle ? "FanFund" : titleText,
      style: TextStyle(
        color: Theme.of(context).primaryColor.withOpacity(0.7),
        fontFamily: isAppTitle ? "Signatra" : "",
        fontSize: isAppTitle ? 50.0 : 22.0
      ),
    ),
    centerTitle: true,
    backgroundColor: Colors.white,
  );
}
