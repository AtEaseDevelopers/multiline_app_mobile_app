import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../core/values/app_strings.dart';

class ReviewListPage extends StatelessWidget {
  const ReviewListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${SKeys.pendingReviews.tr} (12)'),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.filter_list),
            label: Text(SKeys.view.tr),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          _ReviewCard(
            title: 'Vehicle Inspection',
            driver: 'Ahmad',
            time: '08:15 AM',
            vehicle: 'ABC123',
          ),
          _ReviewCard(
            title: 'Daily Checklist',
            driver: 'John',
            time: '07:45 AM',
            vehicle: '—',
            status: '⚠️ Failed',
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String title;
  final String driver;
  final String time;
  final String vehicle;
  final String? status;
  const _ReviewCard({
    required this.title,
    required this.driver,
    required this.time,
    required this.vehicle,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text('${SKeys.driver.tr}: $driver'),
            Text('${SKeys.time.tr}: $time'),
            Text('${SKeys.vehicle.tr}: $vehicle'),
            if (status != null) Text('${SKeys.status.tr}: $status'),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.reviewDetail),
                  icon: const Icon(Icons.visibility),
                  label: Text(SKeys.view.tr),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(SKeys.approved.tr)));
                  },
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(SKeys.rejected.tr)));
                  },
                  icon: const Icon(Icons.cancel, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
