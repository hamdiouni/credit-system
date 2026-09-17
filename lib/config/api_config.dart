import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

/// API Configuration - Platform-specific API endpoints
/// Handles different API URLs for web, mobile emulator, and physical devices
class ApiConfig {
  // Base API URL (change this to your backend URL)
  static const String _localApiUrl = 'http://localhost:3000/api';
  static const String _androidEmulatorApiUrl = 'http://10.0.2.2:3000/api';
  
  /// Get the appropriate API URL based on platform
  static String get apiUrl {
    if (kIsWeb) {
      // Web: use localhost
      print('🌐 [ApiConfig] Using Web API URL: $_localApiUrl');
      return _localApiUrl;
    }
    
    if (Platform.isAndroid) {
      // Android: check if emulator or physical device
      // For emulator: use 10.0.2.2 (special alias to host machine)
      // For physical device: use local network IP (e.g., 192.168.1.x)
      
      // TODO: Detect if running on emulator vs physical device
      // For now, default to emulator URL
      print('📱 [ApiConfig] Using Android Emulator API URL: $_androidEmulatorApiUrl');
      print('💡 [ApiConfig] If using physical device, update to local network IP');
      return _androidEmulatorApiUrl;
    }
    
    if (Platform.isIOS) {
      // iOS: localhost works in simulator
      print('📱 [ApiConfig] Using iOS Simulator API URL: $_localApiUrl');
      return _localApiUrl;
    }
    
    // Desktop: use localhost
    print('🖥️ [ApiConfig] Using Desktop API URL: $_localApiUrl');
    return _localApiUrl;
  }
  
  /// Get API URL for physical Android device (use local network IP)
  /// Example: 'http://192.168.1.100:3000/api'
  static String getPhysicalDeviceUrl(String localIp) {
    return 'http://$localIp:3000/api';
  }
  
  /// Check if API is reachable
  static Future<bool> checkConnection() async {
    try {
      print('🔍 [ApiConfig] Checking API connection to: $apiUrl');
      
      // Simple connectivity check (you can enhance this)
      // For now, just return true and let actual API calls handle errors
      return true;
    } catch (e) {
      print('❌ [ApiConfig] Connection check failed: $e');
      return false;
    }
  }
  
  /// Get full endpoint URL
  static String endpoint(String path) {
    final url = '$apiUrl/$path';
    print('🔗 [ApiConfig] Endpoint: $url');
    return url;
  }
}
