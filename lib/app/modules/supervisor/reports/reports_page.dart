import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_strings.dart';

class SupervisorReportsPage extends StatelessWidget {
  const SupervisorReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SKeys.navReports.tr)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(SKeys.report.tr, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.report_gmailerrorred_outlined),
              title: Text(SKeys.incidentsSummary.tr),
              subtitle: const Text('Today: 2  |  Week: 7  |  Month: 22'),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.inventory_outlined),
              title: Text(SKeys.inspectionsSummary.tr),
              subtitle: const Text('Pass: 18  |  Fail: 4'),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
