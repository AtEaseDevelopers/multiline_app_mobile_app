import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notification_service.dart';
import '../../widgets/custom_dialog.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService();

  final notifications = <NotificationItem>[].obs;
  final isLoading = false.obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  /// Load all notifications
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      print('📱 Loading notifications...');
      final response = await _notificationService.getNotifications();
      print('✅ Notifications loaded: ${response.notifications.length} items');

      notifications.value = response.notifications;
      unreadCount.value = response.unreadCount;
    } catch (e) {
      print('❌ Error in controller: $e');
      Get.snackbar(
        'Error',
        'Failed to load notifications: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  /// Mark single notification as read
  Future<void> markAsRead(NotificationItem notification) async {
    if (notification.isRead) return; // Already read

    try {
      await _notificationService.markAsRead(notification.id);

      // Update local state
      final index = notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        notifications[index] = NotificationItem(
          id: notification.id,
          isRead: true,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          expiryDate: notification.expiryDate,
          createdAt: notification.createdAt,
        );
        notifications.refresh();

        // Decrease unread count
        if (unreadCount.value > 0) {
          unreadCount.value--;
        }
      }

      Get.snackbar(
        'Success',
        'Notification marked as read',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark as read: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();

      // Update local state - mark all as read
      notifications.value = notifications.map((notification) {
        return NotificationItem(
          id: notification.id,
          isRead: true,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          expiryDate: notification.expiryDate,
          createdAt: notification.createdAt,
        );
      }).toList();

      unreadCount.value = 0;

      Get.snackbar(
        'Success',
        'All notifications marked as read',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark all as read: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Show confirmation dialog for mark all as read
  void showMarkAllAsReadDialog() {
    Get.dialog(
      CustomDialog(
        title: 'Mark All as Read',
        content: 'Are you sure you want to mark all notifications as read?',
        icon: Icons.done_all,
        iconColor: Colors.blue,
        confirmText: 'Mark All',
        onConfirm: () {
          Get.back();
          markAllAsRead();
        },
      ),
    );
  }

  /// Delete single notification
  Future<void> deleteNotification(NotificationItem notification) async {
    try {
      await _notificationService.deleteNotification(notification.id);

      // Remove from local state
      notifications.removeWhere((n) => n.id == notification.id);

      // Decrease unread count if it was unread
      if (!notification.isRead && unreadCount.value > 0) {
        unreadCount.value--;
      }

      Get.snackbar(
        'Success',
        'Notification deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete notification: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
