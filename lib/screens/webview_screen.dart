import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../widgets/exit_dialog.dart';
import '../widgets/offline_view.dart';

const String kSiteUrl = 'https://faridpurpolice.top';

/// Schemes/hosts that the WebView should NOT handle internally — they belong
/// to other apps (dialer, WhatsApp, contact save) and are routed out via
/// `url_launcher` instead.
bool _isExternalLink(String url) {
  final lower = url.toLowerCase();
  return lower.startsWith('tel:') ||
      lower.startsWith('mailto:') ||
      lower.startsWith('sms:') ||
      lower.contains('wa.me/') ||
      lower.contains('api.whatsapp.com');
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _controller;
  late final PullToRefreshController _pullToRefreshController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  bool _isOffline = false;
  bool _isLoading = true;
  bool _hasShownPullHint = false;

  @override
  void initState() {
    super.initState();
    _pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(color: AppColors.primary),
      onRefresh: () async {
        await _controller?.reload();
      },
    );
    _checkConnectivity();
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen((results) {
      final offline = results.every((r) => r == ConnectivityResult.none);
      if (offline != _isOffline) {
        setState(() => _isOffline = offline);
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    final offline = results.every((r) => r == ConnectivityResult.none);
    if (mounted) setState(() => _isOffline = offline);
  }

  Future<void> _retry() async {
    await _checkConnectivity();
    if (!_isOffline) {
      await _controller?.reload();
    }
  }

  Future<bool> _handleBack() async {
    if (_controller != null && await _controller!.canGoBack()) {
      await _controller!.goBack();
      return false;
    }
    if (!mounted) return false;
    return showExitConfirmDialog(context);
  }

  void _maybeShowPullHint() {
    if (_hasShownPullHint) return;
    _hasShownPullHint = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('রিলোড করতে নিচে টানুন'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openExternal(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showFallback('অ্যাপ খোলা যাচ্ছে না: $url');
      }
    } catch (e) {
      _showFallback('লিংক খুলতে সমস্যা হয়েছে');
    }
  }

  void _showFallback(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<NavigationActionPolicy?> _handleNavigation(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    final url = navigationAction.request.url?.toString() ?? '';
    if (url.isNotEmpty && _isExternalLink(url)) {
      _openExternal(url);
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }

  void _handleDownload(
    InAppWebViewController controller,
    DownloadStartRequest request,
  ) {
    final url = request.url.toString();
    final contentDisposition = request.contentDisposition ?? '';
    final mimeType = request.mimeType ?? '';
    final suggestedFilename = request.suggestedFilename ??
        _filenameFromUrl(url, contentDisposition, mimeType);

    _startDownload(url, suggestedFilename);
  }

  String _filenameFromUrl(
    String url,
    String contentDisposition,
    String mimeType,
  ) {
    final match = RegExp(r'filename[^;=\n]*=((["\']).*?\2|[^;\n]*)')
        .firstMatch(contentDisposition);
    if (match != null) {
      return match.group(1)?.replaceAll('"', '').trim() ?? 'download';
    }
    final uri = Uri.tryParse(url);
    final last = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last
        : 'download';
    if (last.contains('.')) return last;
    if (mimeType.contains('vcard') || mimeType.contains('vcf')) {
      return '$last.vcf';
    }
    return last;
  }

  Future<void> _startDownload(String url, String filename) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        _showDownloadSnack('ডাউনলোড শুরু হয়েছে: $filename');
      } else {
        _showFallback('ডাউনলোড শুরু করা যাচ্ছে না');
      }
    } catch (e) {
      _showFallback('ডাউনলোডে সমস্যা হয়েছে');
    }
  }

  void _showDownloadSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'খুলুন',
          onPressed: () {
            // Best-effort: open Downloads folder
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _handleBack();
        if (shouldExit && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              if (!_isOffline)
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(kSiteUrl)),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    geolocationEnabled: true,
                    mediaPlaybackRequiresUserGesture: false,
                    allowFileAccess: true,
                    allowContentAccess: true,
                    useHybridComposition: true,
                    supportMultipleWindows: true,
                    useOnDownloadStart: true,
                  ),
                  pullToRefreshController: _pullToRefreshController,
                  onWebViewCreated: (controller) => _controller = controller,
                  shouldOverrideUrlLoading: _handleNavigation,
                  onDownloadStartRequest: _handleDownload,
                  onLoadStart: (controller, url) {
                    setState(() => _isLoading = true);
                  },
                  onLoadStop: (controller, url) async {
                    _pullToRefreshController.endRefreshing();
                    setState(() => _isLoading = false);
                    _maybeShowPullHint();
                  },
                  onReceivedError: (controller, request, error) {
                    _pullToRefreshController.endRefreshing();
                    if (request.isForMainFrame ?? true) {
                      setState(() => _isLoading = false);
                    }
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      _pullToRefreshController.endRefreshing();
                    }
                  },
                  onGeolocationPermissionsShowPrompt: (controller, origin) async {
                    return GeolocationPermissionShowPromptResponse(
                      origin: origin,
                      allow: true,
                      retain: true,
                    );
                  },
                  onPermissionRequest: (controller, request) async {
                    return PermissionResponse(
                      resources: request.resources,
                      action: PermissionResponseAction.GRANT,
                    );
                  },
                ),
              if (!_isOffline && _isLoading)
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text(
                          'লোড হচ্ছে...',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_isOffline) OfflineView(onRetry: _retry),
            ],
          ),
        ),
      ),
    );
  }
}
