import 'package:flutter/material.dart';

/// Deprecated: Offline mode has been removed. Do not use.
@Deprecated('Offline mode removed. Do not use OfflineBanner.')
class OfflineBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  const OfflineBanner({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    throw UnsupportedError(
      'OfflineBanner is deprecated. Offline mode is not supported in this app.',
    );
  }
}
