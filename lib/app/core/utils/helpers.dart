import 'package:flutter/material.dart';

class GeoPos {
  final double lat;
  final double lng;
  final double? accuracy;
  const GeoPos(this.lat, this.lng, {this.accuracy});
}

class Helpers {
  static void showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
