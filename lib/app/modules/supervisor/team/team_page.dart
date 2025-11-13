import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_strings.dart';

class SupervisorTeamPage extends StatelessWidget {
  const SupervisorTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SKeys.navTeam.tr)),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: 8,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, i) {
          return ListTile(
            leading: CircleAvatar(child: Text('${i + 1}')),
            title: Text('Driver ${i + 1}'),
            subtitle: const Text('Status: Active'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          );
        },
      ),
    );
  }
}
