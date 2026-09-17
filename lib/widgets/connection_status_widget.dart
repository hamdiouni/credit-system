// OFFLINE-ONLY MODE: This file is disabled for offline-only operation
// Uncomment this file if you want to add online connectivity features in the future

/*
import 'package:flutter/material.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

/// Connection Status Widget - Shows online/offline status
class ConnectionStatusWidget extends StatefulWidget {
  const ConnectionStatusWidget({Key? key}) : super(key: key);

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget> {
  bool _isConnected = true;
  
  @override
  void initState() {
    super.initState();
    // _checkConnection();
    // _listenToConnectionChanges();
  }
  
  // Future<void> _checkConnection() async {
  //   final connectivityResult = await Connectivity().checkConnectivity();
  //   setState(() {
  //     _isConnected = connectivityResult.first != ConnectivityResult.none;
  //   });
  // }
  
  // void _listenToConnectionChanges() {
  //   Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
  //     setState(() {
  //       _isConnected = results.first != ConnectivityResult.none;
  //     });
  //   });
  // }
  
  @override
  Widget build(BuildContext context) {
    // Always show offline mode in offline-only version
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.shade700,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.storage, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            'Offline Mode - All data stored locally',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Connection Status Indicator (for app bar)
class ConnectionStatusIndicator extends StatefulWidget {
  const ConnectionStatusIndicator({Key? key}) : super(key: key);

  @override
  State<ConnectionStatusIndicator> createState() => _ConnectionStatusIndicatorState();
}

class _ConnectionStatusIndicatorState extends State<ConnectionStatusIndicator> {
  bool _isConnected = false; // Always offline in offline-only version
  
  @override
  void initState() {
    super.initState();
    // _checkConnection();
    // _listenToConnectionChanges();
  }
  
  // Future<void> _checkConnection() async {
  //   final connectivityResult = await Connectivity().checkConnectivity();
  //   setState(() {
  //     _isConnected = connectivityResult.first != ConnectivityResult.none;
  //   });
  // }
  
  // void _listenToConnectionChanges() {
  //   Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
  //     setState(() {
  //       _isConnected = results.first != ConnectivityResult.none;
  //     });
  //   });
  // }
  
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.storage, // Offline storage icon
      color: Colors.blue,
      size: 20,
    );
  }
}
*/

// Simplified offline-only versions
import 'package:flutter/material.dart';

class ConnectionStatusWidget extends StatelessWidget {
  const ConnectionStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Hidden in offline mode
  }
}

class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.storage,
      color: Colors.blue,
      size: 20,
    );
  }
}
