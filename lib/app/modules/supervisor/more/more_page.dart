import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_strings.dart';

class SupervisorMorePage extends StatelessWidget {
  const SupervisorMorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SKeys.navMore.tr)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(SKeys.settings.tr),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(SKeys.helpSupport.tr),
          ),
        ],
      ),
    );
  }
}
