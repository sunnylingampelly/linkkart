import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class ApiSettingsScreen extends StatefulWidget {
  const ApiSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends State<ApiSettingsScreen> {
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  bool _isTestingConnection = false;
  String? _connectionStatus;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('api_ip') ?? '192.168.1.8';
    final savedPort = prefs.getString('api_port') ?? '8000';
    
    setState(() {
      _ipController.text = savedIp;
      _portController.text = savedPort;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_ip', _ipController.text);
    await prefs.setString('api_port', _portController.text);
    
    // Update the base URL in AppConstants
    final newBaseUrl = 'http://${_ipController.text}:${_portController.text}/api/v1';
    AppConstants.baseUrl = newBaseUrl;
    
    // Also update the first item in baseUrls list for consistency
    if (AppConstants.baseUrls.isNotEmpty) {
      AppConstants.baseUrls[0] = newBaseUrl;
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Settings saved! Backend URL: $newBaseUrl'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionStatus = null;
    });

    try {
      final testUrl = 'http://${_ipController.text}:${_portController.text}';
      
      // Simple HTTP test
      final response = await http.get(Uri.parse(testUrl)).timeout(
        const Duration(seconds: 5),
        onTimeout: () => http.Response('Timeout', 408),
      );
      
      final isReachable = response.statusCode < 500;
      
      setState(() {
        _isTestingConnection = false;
        _connectionStatus = isReachable
            ? '✅ Connection successful!'
            : '❌ Cannot reach backend (Status: ${response.statusCode})';
      });

      if (isReachable) {
        await _saveSettings();
      }
    } catch (e) {
      setState(() {
        _isTestingConnection = false;
        _connectionStatus = '❌ Error: ${e.toString()}';
      });
    }
  }

  Future<void> _autoDetect() async {
    setState(() {
      _isTestingConnection = true;
      _connectionStatus = 'Scanning network...';
    });

    try {
      // Try each URL in the list
      for (String url in AppConstants.baseUrls) {
        final uri = Uri.parse(url);
        try {
          final response = await http.get(Uri.parse('http://${uri.host}:${uri.port}')).timeout(
            const Duration(seconds: 3),
          );
          
          if (response.statusCode < 500) {
            // Found working server!
            setState(() {
              _ipController.text = uri.host;
              _portController.text = uri.port.toString();
              _isTestingConnection = false;
              _connectionStatus = '✅ Found working server at ${uri.host}:${uri.port}!';
            });
            
            await _saveSettings();
            return;
          }
        } catch (e) {
          // Try next URL
          continue;
        }
      }
      
      // None worked
      setState(() {
        _isTestingConnection = false;
        _connectionStatus = '❌ No working server found. Please enter manually.';
      });
    } catch (e) {
      setState(() {
        _isTestingConnection = false;
        _connectionStatus = '❌ Auto-detect failed: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'API Settings',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Enter your computer\'s IP address where the backend is running',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // IP Address
              Text(
                'IP Address',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _ipController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.inter(fontSize: 16),
                decoration: InputDecoration(
                  hintText: '192.168.1.38',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),

                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),

                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),

                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Port
              Text(
                'Port',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _portController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(fontSize: 16),
                decoration: InputDecoration(
                  hintText: '8000',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),

                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),

                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),

                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Connection status
              if (_connectionStatus != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _connectionStatus!.startsWith('✅')
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    border: Border.all(
                      color: _connectionStatus!.startsWith('✅')
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _connectionStatus!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _connectionStatus!.startsWith('✅')
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Test Connection button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isTestingConnection ? null : _testConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  child: _isTestingConnection
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Test Connection',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Auto-detect button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isTestingConnection ? null : _autoDetect,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  child: Text(
                    'Auto-Detect Server',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // How to find IP
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to find your IP address:',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Windows: Open CMD and type "ipconfig"\n'
                      'Look for "IPv4 Address" under your WiFi adapter\n\n'
                      'Mac: System Preferences → Network\n'
                      'Select WiFi and look for IP Address',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }
}
