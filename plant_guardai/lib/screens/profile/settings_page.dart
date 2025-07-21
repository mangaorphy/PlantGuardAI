import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/currency_provider.dart';
import '../../models/user_model.dart';
import '../theme_demo_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<String> _languages = [
    'English',
    'Kinyarwanda',
    'French',
    'Swahili',
  ];
  final List<String> _currencies = ['RWF', 'USD', 'EUR', 'KES', 'UGX'];
  final List<String> _themes = ['Light', 'Dark', 'Auto'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user == null) {
        userProvider.initializeUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.user == null) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Scaffold(
                backgroundColor: themeProvider.backgroundColor,
                body: const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                ),
              );
            },
          );
        }

        final user = userProvider.user!;

        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Scaffold(
              backgroundColor: themeProvider.backgroundColor,
              appBar: AppBar(
                backgroundColor: themeProvider.backgroundColor,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Settings',
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildNotificationSettings(
                      userProvider,
                      user,
                      themeProvider,
                    ),
                    const SizedBox(height: 20),
                    _buildAppearanceSettings(userProvider, user, themeProvider),
                    const SizedBox(height: 20),
                    _buildSecuritySettings(userProvider, user, themeProvider),
                    const SizedBox(height: 20),
                    _buildDataSettings(userProvider, user, themeProvider),
                    const SizedBox(height: 20),
                    _buildAboutSettings(themeProvider),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationSettings(
    UserProvider userProvider,
    UserModel user,
    ThemeProvider themeProvider,
  ) {
    return _buildSettingsSection('Notifications', themeProvider, [
      _buildSwitchTile(
        'Push Notifications',
        'Receive push notifications on your device',
        user.notificationsEnabled,
        (value) =>
            userProvider.updateNotificationSettings(pushNotifications: value),
        Icons.notifications,
        themeProvider,
      ),
      _buildSwitchTile(
        'Email Notifications',
        'Get updates via email',
        user.emailNotifications,
        (value) =>
            userProvider.updateNotificationSettings(emailNotifications: value),
        Icons.email,
        themeProvider,
      ),
      _buildSwitchTile(
        'SMS Notifications',
        'Receive text message alerts',
        user.smsNotifications,
        (value) =>
            userProvider.updateNotificationSettings(smsNotifications: value),
        Icons.message,
        themeProvider,
      ),
      _buildSwitchTile(
        'Order Updates',
        'Get notified about order status changes',
        user.orderUpdates,
        (value) => userProvider.updateNotificationSettings(orderUpdates: value),
        Icons.shopping_bag,
        themeProvider,
      ),
      _buildSwitchTile(
        'Promotional Offers',
        'Receive notifications about special deals',
        user.promotionalOffers,
        (value) =>
            userProvider.updateNotificationSettings(promotionalOffers: value),
        Icons.local_offer,
        themeProvider,
      ),
    ]);
  }

  Widget _buildAppearanceSettings(
    UserProvider userProvider,
    UserModel user,
    ThemeProvider themeProvider,
  ) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return _buildSettingsSection('Appearance', themeProvider, [
          _buildDropdownTile(
            'Language',
            'Select your preferred language',
            user.language,
            _languages,
            (value) {
              userProvider.setLanguage(value!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Language changed to $value'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            Icons.language,
            themeProvider,
          ),
          _buildDropdownTile(
            'Currency',
            'Choose your currency',
            currencyProvider.selectedCurrency,
            _currencies,
            (value) async {
              currencyProvider.updateCurrency(value!);
              userProvider.updateAppSettings(currency: value);

              await currencyProvider.clearCache();

              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) setState(() {});
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Currency changed to $value - Test: ${currencyProvider.formatPriceSync(1000.0)}',
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            Icons.monetization_on,
            themeProvider,
          ),
          _buildDropdownTile(
            'Theme',
            'Choose app appearance',
            themeProvider.selectedTheme,
            _themes,
            (value) {
              themeProvider.updateTheme(value!);
              userProvider.updateAppSettings(theme: value);

              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) setState(() {});
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Theme changed to $value - ${themeProvider.isDarkMode ? "Dark Mode" : "Light Mode"} activated!',
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            Icons.palette,
            themeProvider,
          ),
          const SizedBox(height: 16),
          _buildRefreshRatesButton(currencyProvider),
          const SizedBox(height: 8),
          _buildThemeDemoButton(),
        ]);
      },
    );
  }

  Widget _buildRefreshRatesButton(CurrencyProvider currencyProvider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed:
            currencyProvider.isLoading
                ? null
                : () async {
                  await currencyProvider.updateExchangeRates();
                  if (currencyProvider.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(currencyProvider.errorMessage!),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Exchange rates updated!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
        icon:
            currencyProvider.isLoading
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.refresh),
        label: Text(
          currencyProvider.isLoading ? 'Updating...' : 'Refresh Exchange Rates',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildThemeDemoButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ThemeDemoPage()),
          );
        },
        icon: const Icon(Icons.palette),
        label: const Text('Theme Demo & Test'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSecuritySettings(
    UserProvider userProvider,
    UserModel user,
    ThemeProvider themeProvider,
  ) {
    return _buildSettingsSection('Security', themeProvider, [
      _buildSwitchTile(
        'Biometric Login',
        'Use fingerprint or face ID to login',
        user.biometricLogin,
        (value) => userProvider.updateSecuritySettings(biometricLogin: value),
        Icons.fingerprint,
        themeProvider,
      ),
      _buildActionTile(
        'Change Password',
        'Update your account password',
        _changePassword,
        Icons.lock,
        themeProvider,
      ),
      _buildActionTile(
        'Two-Factor Authentication',
        'Add an extra layer of security',
        _setupTwoFactorAuth,
        Icons.security,
        themeProvider,
      ),
    ]);
  }

  Widget _buildDataSettings(
    UserProvider userProvider,
    UserModel user,
    ThemeProvider themeProvider,
  ) {
    return _buildSettingsSection('Data & Privacy', themeProvider, [
      _buildSwitchTile(
        'Auto Backup',
        'Automatically backup your data',
        user.autoBackup,
        (value) => userProvider.updateDataSettings(autoBackup: value),
        Icons.backup,
        themeProvider,
      ),
      _buildSwitchTile(
        'Location Services',
        'Allow app to access your location',
        user.locationServices,
        (value) => userProvider.updateDataSettings(locationServices: value),
        Icons.location_on,
        themeProvider,
      ),
      _buildSwitchTile(
        'Crash Reporting',
        'Help improve the app by sending crash reports',
        user.crashReporting,
        (value) => userProvider.updateDataSettings(crashReporting: value),
        Icons.bug_report,
        themeProvider,
      ),
      _buildActionTile(
        'Download Data',
        'Download a copy of your data',
        _downloadData,
        Icons.download,
        themeProvider,
      ),
      _buildActionTile(
        'Delete Account',
        'Permanently delete your account',
        _deleteAccount,
        Icons.delete_forever,
        themeProvider,
      ),
    ]);
  }

  Widget _buildAboutSettings(ThemeProvider themeProvider) {
    return _buildSettingsSection('About', themeProvider, [
      _buildActionTile(
        'Terms of Service',
        'Read our terms and conditions',
        _showTerms,
        Icons.description,
        themeProvider,
      ),
      _buildActionTile(
        'Privacy Policy',
        'Learn how we protect your privacy',
        _showPrivacyPolicy,
        Icons.privacy_tip,
        themeProvider,
      ),
      _buildActionTile(
        'Help & Support',
        'Get help or contact support',
        _showHelp,
        Icons.help,
        themeProvider,
      ),
      _buildInfoTile('App Version', '1.0.0', Icons.info, themeProvider),
    ]);
  }

  Widget _buildSettingsSection(
    String title,
    ThemeProvider themeProvider,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: themeProvider.secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: Colors.green),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    String value,
    List<String> options,
    Function(String?) onChanged,
    IconData icon,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: themeProvider.secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            dropdownColor: themeProvider.cardColor,
            style: TextStyle(color: themeProvider.textColor),
            items:
                options.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    VoidCallback onTap,
    IconData icon,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Colors.green, size: 24),
        title: Text(
          title,
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: themeProvider.secondaryTextColor,
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: themeProvider.secondaryTextColor,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: themeProvider.secondaryTextColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'Change Password',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Password change functionality will be implemented in a future update.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
    );
  }

  void _setupTwoFactorAuth() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Two-factor authentication setup coming soon!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _downloadData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data download feature coming soon!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to permanently delete your account? This action cannot be undone.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Account deletion feature will be implemented.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showTerms() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terms of Service will be displayed here.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy Policy will be displayed here.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help & Support will be available here.'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
