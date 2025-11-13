import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_strings.dart';

class ReviewDetailPage extends StatelessWidget {
  const ReviewDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SKeys.vehicleInspection.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${SKeys.driver.tr}: Ahmad'),
            Text('${SKeys.date.tr}: 20/09/2025'),
            Text('${SKeys.time.tr}: 08:15 AM'),
            Text('${SKeys.vehicle.tr}: ABC123'),
            const Divider(height: 24),
            const Text('Inspection Results:'),
            const SizedBox(height: 8),
            const Text('✓ Headlights - Pass'),
            const Text('✓ Tail Lights - Pass'),
            Row(
              children: [
                const Text('✗ Left Tire - Fail  '),
                TextButton(
                  onPressed: () {},
                  child: Text('${SKeys.view.tr} Photo'),
                ),
              ],
            ),
            const Text('✓ Brakes - Pass'),
            const SizedBox(height: 12),
            const Text('GPS Location:'),
            const SizedBox(height: 6),
            Container(
              height: 120,
              color: Color(0xFFF0F0F0),
              child: const Center(child: Text('[Mini Map View]')),
            ),
            const SizedBox(height: 12),
            Text('${SKeys.odometerReading.tr}: 45,678 KM'),
            const SizedBox(height: 12),
            const Text('Add Remarks:'),
            const SizedBox(height: 8),
            const TextField(maxLines: 3),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(SKeys.rejected.tr)),
                      );
                    },
                    child: Text(SKeys.reject.tr),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(SKeys.approved.tr)),
                      );
                    },
                    child: Text(SKeys.approve.tr),
                  ),
                ),
              ],
            ),
            // Add bottom padding for device navigation buttons
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}
