import 'package:flutter/material.dart';

Container circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10.0),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.pink.withOpacity(0.7)),
    )
  );
}

Container linearProgress() {
  return Container(
    padding: EdgeInsets.only( bottom: 10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.pink.withOpacity(0.7)),
    ),
  );
}
