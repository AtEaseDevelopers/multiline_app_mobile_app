import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'report_detail_controller.dart';
import '../../data/services/storage_service.dart';

class ReportDetailPage extends StatefulWidget {
  const ReportDetailPage({super.key});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  final controller = Get.put(ReportDetailController());
  WebViewController? webViewController;
  final isWebViewLoading = true.obs;
  final isInitializing = true.obs;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    // Get auth token
    final token = await StorageService.getToken();

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            isWebViewLoading.value = true;
          },
          onPageFinished: (String url) {
            isWebViewLoading.value = false;
          },
          onWebResourceError: (WebResourceError error) {
            Get.snackbar(
              'Error',
              'Failed to load report: ${error.description}',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      );

    // Load the report with authorization header
    final url = controller.getReportUrl();
    await webViewController!.loadRequest(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/pdf'},
    );

    isInitializing.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.report.friendlyName),
        actions: [
          Obx(() {
            if (controller.isDownloading.value) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: controller.downloadProgress.value > 0
                          ? controller.downloadProgress.value
                          : null,
                    ),
                  ),
                ),
              );
            }

            return IconButton(
              icon: const Icon(Icons.download),
              onPressed: controller.downloadReport,
              tooltip: 'Download PDF',
            );
          }),
        ],
      ),
      body: Obx(() {
        // Show initialization loading
        if (isInitializing.value || webViewController == null) {
          return Container(
            color: Colors.white,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing PDF viewer...'),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            // WebView
            WebViewWidget(controller: webViewController!),

            // Loading indicator
            Obx(() {
              if (isWebViewLoading.value) {
                return Container(
                  color: Colors.white,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading report...'),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Download progress overlay
            Obx(() {
              if (controller.isDownloading.value &&
                  controller.downloadProgress.value > 0) {
                return Container(
                  color: Colors.black54,
                  child: Center(
                    child: Card(
                      margin: const EdgeInsets.all(32),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Downloading Report',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: controller.downloadProgress.value,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(controller.downloadProgress.value * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.report.fileName,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.isDownloading.value
                        ? null
                        : controller.downloadReport,
                    icon: controller.isDownloading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.download),
                    label: Text(
                      controller.isDownloading.value
                          ? 'Downloading...'
                          : 'Download to Device',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
