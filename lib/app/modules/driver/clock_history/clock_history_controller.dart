import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/clock_history_model.dart';
import '../../../data/models/api_response.dart';
import '../../../data/services/driver_service.dart';
import '../../../data/services/storage_service.dart';

class ClockHistoryController extends GetxController {
  final DriverService _driverService = DriverService();

  // Observable lists and states
  final clockHistoryList = <ClockHistoryItem>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();

  // Pagination state
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalRecords = 0.obs;
  final hasMore = false.obs;
  final perPage = 10;

  // Scroll controller for pagination
  final ScrollController scrollController = ScrollController();

  int? userId;

  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
    _loadUserId();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  /// Load user ID from storage
  Future<void> _loadUserId() async {
    userId = await StorageService.getUserId();
    if (userId != null) {
      loadClockHistory();
    } else {
      errorMessage.value = 'User ID not found';
    }
  }

  /// Setup scroll listener for infinite scroll
  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent * 0.9 &&
          !isLoadingMore.value &&
          hasMore.value) {
        loadMore();
      }
    });
  }

  /// Load initial clock history
  Future<void> loadClockHistory() async {
    if (userId == null) return;

    try {
      isLoading.value = true;
      errorMessage.value = null;
      currentPage.value = 1;

      final data = await _driverService.getClockHistory(
        userId: userId!,
        page: currentPage.value,
        perPage: perPage,
      );

      clockHistoryList.value = data.clockHistory;
      totalPages.value = data.totalPages;
      totalRecords.value = data.totalRecords;
      hasMore.value = data.hasMore;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Failed to load clock history';
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more history (pagination)
  Future<void> loadMore() async {
    if (userId == null || !hasMore.value || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      final data = await _driverService.getClockHistory(
        userId: userId!,
        page: currentPage.value,
        perPage: perPage,
      );

      clockHistoryList.addAll(data.clockHistory);
      totalPages.value = data.totalPages;
      hasMore.value = data.hasMore;
    } on ApiException catch (e) {
      currentPage.value--; // Revert page number on error
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      currentPage.value--; // Revert page number on error
      Get.snackbar(
        'Error',
        'Failed to load more records',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Refresh clock history (pull to refresh)
  Future<void> refreshClockHistory() async {
    currentPage.value = 1;
    await loadClockHistory();
  }
}
