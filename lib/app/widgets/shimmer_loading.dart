import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/app_colors.dart';

/// Reusable shimmer loading widgets for dashboard screens
class ShimmerLoading {
  /// Base shimmer effect wrapper
  static Widget shimmerEffect({
    required Widget child,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: child,
    );
  }

  /// Shimmer box with rounded corners
  static Widget box({
    required double width,
    required double height,
    double borderRadius = 12,
    required BuildContext context,
  }) {
    return shimmerEffect(
      context: context,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  /// Shimmer circle (for avatars, icons)
  static Widget circle({required double size, required BuildContext context}) {
    return shimmerEffect(
      context: context,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// Dashboard Hero Card Shimmer
  static Widget dashboardHero(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title shimmer
          box(width: 150, height: 16, borderRadius: 8, context: context),
          const SizedBox(height: 8),
          // Greeting shimmer
          box(width: 200, height: 24, borderRadius: 8, context: context),
          const SizedBox(height: 20),

          // Info container
          Container(
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info tags shimmer
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    box(
                      width: 120,
                      height: 36,
                      borderRadius: 14,
                      context: context,
                    ),
                    box(
                      width: 100,
                      height: 36,
                      borderRadius: 14,
                      context: context,
                    ),
                    box(
                      width: 130,
                      height: 36,
                      borderRadius: 14,
                      context: context,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Status and button shimmer
                Row(
                  children: [
                    box(
                      width: 100,
                      height: 36,
                      borderRadius: 20,
                      context: context,
                    ),
                    const Spacer(),
                    box(
                      width: 120,
                      height: 44,
                      borderRadius: 28,
                      context: context,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Work hours shimmer
                box(width: 150, height: 16, borderRadius: 8, context: context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Quick Action Grid Shimmer
  static Widget quickActionGrid({int itemCount = 4}) {
    return GridView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon shimmer
              circle(size: 48, context: context),
              const SizedBox(height: 16),
              // Title shimmer
              box(
                width: double.infinity,
                height: 18,
                borderRadius: 8,
                context: context,
              ),
              const SizedBox(height: 8),
              // Subtitle shimmer
              box(width: 120, height: 14, borderRadius: 8, context: context),
            ],
          ),
        );
      },
    );
  }

  /// Recent Activity List Shimmer
  static Widget recentActivityList({int itemCount = 3}) {
    return Builder(
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: List.generate(itemCount, (index) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        // Leading icon shimmer
                        circle(size: 48, context: context),
                        const SizedBox(width: 16),
                        // Content shimmer
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              box(
                                width: double.infinity,
                                height: 16,
                                borderRadius: 8,
                                context: context,
                              ),
                              const SizedBox(height: 8),
                              box(
                                width: 150,
                                height: 12,
                                borderRadius: 8,
                                context: context,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Trailing badge shimmer
                        box(
                          width: 70,
                          height: 28,
                          borderRadius: 12,
                          context: context,
                        ),
                      ],
                    ),
                  ),
                  if (index != itemCount - 1) const Divider(height: 0),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  /// Insight Card Shimmer
  static Widget insightCard() {
    return Builder(
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon shimmer
              circle(size: 48, context: context),
              const SizedBox(height: 16),
              // Value shimmer
              box(width: 120, height: 28, borderRadius: 8, context: context),
              const SizedBox(height: 8),
              // Title shimmer
              box(
                width: double.infinity,
                height: 16,
                borderRadius: 8,
                context: context,
              ),
              const SizedBox(height: 12),
              // Helper text shimmer
              box(width: 150, height: 12, borderRadius: 8, context: context),
            ],
          ),
        );
      },
    );
  }

  /// Stats Card Shimmer (for supervisor dashboard)
  static Widget statsCard() {
    return Builder(
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and label row
              Row(
                children: [
                  circle(size: 32, context: context),
                  const SizedBox(width: 8),
                  Expanded(
                    child: box(
                      width: double.infinity,
                      height: 14,
                      borderRadius: 8,
                      context: context,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Value shimmer
              box(width: 80, height: 24, borderRadius: 8, context: context),
            ],
          ),
        );
      },
    );
  }

  /// Complete Driver Dashboard Shimmer
  static Widget driverDashboard(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero card
          dashboardHero(context),
          const SizedBox(height: 24),

          // Section heading
          box(width: 150, height: 24, borderRadius: 8, context: context),
          const SizedBox(height: 12),

          // Quick actions grid
          quickActionGrid(itemCount: 4),
          const SizedBox(height: 28),

          // Section heading
          box(width: 180, height: 24, borderRadius: 8, context: context),
          const SizedBox(height: 12),

          // Recent activities
          recentActivityList(itemCount: 3),
          const SizedBox(height: 28),

          // Section heading
          box(width: 150, height: 24, borderRadius: 8, context: context),
          const SizedBox(height: 12),

          // Insight cards
          Row(
            children: [
              Expanded(child: insightCard()),
              const SizedBox(width: 16),
              Expanded(child: insightCard()),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  /// Complete Supervisor Dashboard Shimmer
  static Widget supervisorDashboard(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats overview
          box(width: 200, height: 28, borderRadius: 8, context: context),
          const SizedBox(height: 16),

          // Stats grid
          GridView.builder(
            itemCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, index) => statsCard(),
          ),
          const SizedBox(height: 28),

          // Section heading
          box(width: 180, height: 24, borderRadius: 8, context: context),
          const SizedBox(height: 12),

          // Pending reviews list
          recentActivityList(itemCount: 5),
          const SizedBox(height: 28),

          // Section heading
          box(width: 150, height: 24, borderRadius: 8, context: context),
          const SizedBox(height: 12),

          // Quick actions
          quickActionGrid(itemCount: 4),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
