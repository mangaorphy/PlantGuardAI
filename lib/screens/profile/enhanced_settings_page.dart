import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/product_provider.dart';
import '/ui/models/user_model.dart';
import '../../utils/localization.dart';
import '../../cart_page.dart';
import '../../wishlist_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class EnhancedSettingsPage extends StatefulWidget {
  const EnhancedSettingsPage({super.key});

  @override
  State<EnhancedSettingsPage> createState() => _EnhancedSettingsPageState();
}

class _EnhancedSettingsPageState extends State<EnhancedSettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _languages = [
    'English',
    'Kinyarwanda',
    'French',
    'Swahili',
  ];

  final List<String> _currencies = ['RWF', 'USD', 'EUR', 'KES', 'UGX'];

  final List<String> _themes = ['Light', 'Dark', 'System'];

  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAppVersion();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user == null) {
        userProvider.initializeUser();
      }
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
          ),
        );

    _animationController.forward();
  }

  Future<void> _loadAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _appVersion = '1.0.0';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<
      UserProvider,
      ThemeProvider,
      CurrencyProvider,
      CartProvider
    >(
      builder:
          (
            context,
            userProvider,
            themeProvider,
            currencyProvider,
            cartProvider,
            child,
          ) {
            if (userProvider.user == null) {
              return Scaffold(
                backgroundColor: themeProvider.backgroundColor,
                body: const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                ),
              );
            }

            final user = userProvider.user!;

            return LocalizationProvider(
              locale: user.language,
              child: Scaffold(
                backgroundColor: themeProvider.backgroundColor,
                appBar: _buildAppBar(context, themeProvider),
                body: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildUserSummaryCard(
                            context,
                            user,
                            themeProvider,
                            cartProvider,
                          ),
                          const SizedBox(height: 20),
                          _buildNotificationsSection(
                            context,
                            user,
                            userProvider,
                            themeProvider,
                          ),
                          const SizedBox(height: 20),
                          _buildAppearanceSection(
                            context,
                            user,
                            userProvider,
                            themeProvider,
                            currencyProvider,
                          ),
                          const SizedBox(height: 20),
                          _buildSecuritySection(
                            context,
                            user,
                            userProvider,
                            themeProvider,
                          ),
                          const SizedBox(height: 20),
                          _buildDataPrivacySection(
                            context,
                            user,
                            userProvider,
                            themeProvider,
                          ),
                          const SizedBox(height: 20),
                          _buildShoppingSection(
                            context,
                            themeProvider,
                            cartProvider,
                          ),
                          const SizedBox(height: 20),
                          _buildAboutSection(context, themeProvider),
                          const SizedBox(height: 20),
                          _buildLogoutSection(context, themeProvider),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: themeProvider.backgroundColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'settings'.tr(context),
        style: TextStyle(
          color: themeProvider.textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: themeProvider.textColor),
          onPressed: () {
            _animationController.reset();
            _animationController.forward();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('settings_refreshed'.tr(context)),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserSummaryCard(
    BuildContext context,
    UserModel user,
    ThemeProvider themeProvider,
    CartProvider cartProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: user.profileImage.startsWith('assets/')
                    ? AssetImage(user.profileImage) as ImageProvider
                    : NetworkImage(user.profileImage),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.location,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  Icons.shopping_cart,
                  '${cartProvider.itemCount}',
                  'cart_items'.tr(context),
                ),
              ),
              Expanded(
                child: Consumer<WishlistProvider>(
                  builder: (context, wishlistProvider, child) {
                    return _buildSummaryItem(
                      Icons.favorite,
                      '${wishlistProvider.itemCount}',
                      'wishlist_items'.tr(context),
                    );
                  },
                ),
              ),
              Expanded(
                child: Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    return _buildSummaryItem(
                      Icons.shopping_bag,
                      '${productProvider.products.length}',
                      'available_products'.tr(context),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String count, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(
    BuildContext context,
    UserModel user,
    UserProvider userProvider,
    ThemeProvider themeProvider,
  ) {
    return _buildSection(
      context,
      'notifications'.tr(context),
      'stay_updated_desc'.tr(context),
      Icons.notifications,
      themeProvider,
      [
        _buildSwitchTile(
          context,
          Icons.notifications_active,
          'push_notifications'.tr(context),
          'Get instant notifications',
          user.notificationsEnabled,
          (value) =>
              _updateUserSetting(userProvider, 'notificationsEnabled', value),
          themeProvider,
        ),
        _buildSwitchTile(
          context,
          Icons.email,
          'email_notifications'.tr(context),
          'Receive updates via email',
          user.emailNotifications,
          (value) =>
              _updateUserSetting(userProvider, 'emailNotifications', value),
          themeProvider,
        ),
        _buildSwitchTile(
          context,
          Icons.sms,
          'sms_notifications'.tr(context),
          'Get SMS alerts',
          user.smsNotifications,
          (value) =>
              _updateUserSetting(userProvider, 'smsNotifications', value),
          themeProvider,
        ),
        _buildSwitchTile(
          context,
          Icons.local_shipping,
          'order_updates'.tr(context),
          'Track your orders',
          user.orderUpdates,
          (value) => _updateUserSetting(userProvider, 'orderUpdates', value),
          themeProvider,
        ),
        _buildSwitchTile(
          context,
          Icons.local_offer,
          'promotional_offers'.tr(context),
          'Special deals and offers',
          user.promotionalOffers,
          (value) =>
              _updateUserSetting(userProvider, 'promotionalOffers', value),
          themeProvider,
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    UserModel user,
    UserProvider userProvider,
    ThemeProvider themeProvider,
    CurrencyProvider currencyProvider,
  ) {
    return _buildSection(
      context,
      'appearance'.tr(context),
      'customize_look'.tr(context),
      Icons.palette,
      themeProvider,
      [
        _buildDropdownTile(
          context,
          'language'.tr(context),
          'select_language'.tr(context),
          user.language,
          _languages,
          (value) => _updateLanguage(userProvider, value!),
          Icons.language,
          themeProvider,
        ),
        _buildDropdownTile(
          context,
          'currency'.tr(context),
          'select_currency'.tr(context),
          user.currency,
          _currencies,
          (value) => _updateCurrency(userProvider, currencyProvider, value!),
          Icons.attach_money,
          themeProvider,
        ),
        _buildDropdownTile(
          context,
          'theme'.tr(context),
          'choose_theme'.tr(context),
          user.theme,
          _themes,
          (value) => _updateTheme(userProvider, themeProvider, value!),
          Icons.brightness_6,
          themeProvider,
        ),
      ],
    );
  }

  Widget _buildSecuritySection(
    BuildContext context,
    UserModel user,
    UserProvider userProvider,
    ThemeProvider themeProvider,
  ) {
    return _buildSection(
      context,
      'security'.tr(context),
      'secure_account'.tr(context),
      Icons.security,
      themeProvider,
      [
        _buildSwitchTile(
          context,
          Icons.fingerprint,
          'biometric_login'.tr(context),
          'enable_biometric'.tr(context),
          user.biometricLogin,
          (value) => _updateUserSetting(userProvider, 'biometricLogin', value),
          themeProvider,
        ),
        _buildActionTile(
          context,
          Icons.lock_reset,
          'change_password'.tr(context),
          'update_password'.tr(context),
          () => _showChangePasswordDialog(context, themeProvider),
          themeProvider,
        ),
        _buildActionTile(
          context,
          Icons.verified_user,
          'two_factor'.tr(context),
          'enable_2fa'.tr(context),
          () => _showTwoFactorDialog(context, themeProvider),
          themeProvider,
        ),
      ],
    );
  }

  Widget _buildDataPrivacySection(
    BuildContext context,
    UserModel user,
    UserProvider userProvider,
    ThemeProvider themeProvider,
  ) {
    return _buildSection(
      context,
      'data_privacy'.tr(context),
      'data_usage'.tr(context),
      Icons.privacy_tip,
      themeProvider,
      [
        _buildSwitchTile(
          context,
          Icons.backup,
          'auto_backup'.tr(context),
          'backup_data'.tr(context),
          user.autoBackup,
          (value) => _updateUserSetting(userProvider, 'autoBackup', value),
          themeProvider,
        ),
        _buildSwitchTile(
          context,
          Icons.location_on,
          'location_services'.tr(context),
          'enable_location'.tr(context),
          user.locationServices,
          (value) =>
              _updateUserSetting(userProvider, 'locationServices', value),
          themeProvider,
        ),
        _buildSwitchTile(
          context,
          Icons.bug_report,
          'crash_reporting'.tr(context),
          'help_improve'.tr(context),
          user.crashReporting,
          (value) => _updateUserSetting(userProvider, 'crashReporting', value),
          themeProvider,
        ),
      ],
    );
  }

  Widget _buildShoppingSection(
    BuildContext context,
    ThemeProvider themeProvider,
    CartProvider cartProvider,
  ) {
    return _buildSection(
      context,
      'Shopping & Orders'.tr(context),
      'Manage your shopping experience',
      Icons.shopping_bag,
      themeProvider,
      [
        _buildActionTile(
          context,
          Icons.shopping_cart,
          'view_cart'.tr(context),
          'cart_items_count'
              .tr(context)
              .replaceAll('{count}', '${cartProvider.itemCount}'),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartPage()),
          ),
          themeProvider,
        ),
        _buildActionTile(
          context,
          Icons.favorite,
          'view_wishlist'.tr(context),
          'Manage your saved items',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WishlistPage()),
          ),
          themeProvider,
        ),
        _buildActionTile(
          context,
          Icons.history,
          'order_history'.tr(context),
          'View your past orders',
          () => _showOrderHistory(context, themeProvider),
          themeProvider,
        ),
        _buildActionTile(
          context,
          Icons.clear_all,
          'clear_cart'.tr(context),
          'Remove all items from cart',
          () => _showClearCartDialog(context, cartProvider, themeProvider),
          themeProvider,
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, ThemeProvider themeProvider) {
    return _buildSection(
      context,
      'about'.tr(context),
      'App information and support',
      Icons.info,
      themeProvider,
      [
        _buildInfoTile(
          context,
          Icons.apps,
          'app_version'.tr(context),
          _appVersion,
          themeProvider,
        ),
        _buildActionTile(
          context,
          Icons.description,
          'terms_service'.tr(context),
          'Read our terms and conditions',
          () => _launchUrl('https://plantguard.ai/terms'),
          themeProvider,
        ),
        _buildActionTile(
          context,
          Icons.privacy_tip,
          'privacy_policy'.tr(context),
          'Learn about our privacy practices',
          () => _launchUrl('https://plantguard.ai/privacy'),
          themeProvider,
        ),
        _buildActionTile(
          context,
          Icons.help,
          'help_support'.tr(context),
          'Get help and support',
          () => _launchUrl('https://plantguard.ai/support'),
          themeProvider,
        ),
        _buildActionTile(
          context,
          Icons.star,
          'rate_app'.tr(context),
          'Rate us on the app store',
          () => _rateApp(),
          themeProvider,
        ),
        _buildActionTile(
          context,
          Icons.share,
          'share_app'.tr(context),
          'Share PlantGuard AI with friends',
          () => _shareApp(),
          themeProvider,
        ),
      ],
    );
  }

  Widget _buildLogoutSection(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red, size: 28),
        title: Text(
          'logout'.tr(context),
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: const Text(
          'Sign out of your account',
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.red,
          size: 16,
        ),
        onTap: () => _showLogoutDialog(context, themeProvider),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    ThemeProvider themeProvider,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Expanded(
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
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: themeProvider.textColor.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    ThemeProvider themeProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: themeProvider.textColor.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: Colors.green, size: 22),
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
            color: themeProvider.textColor.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        value: value,
        activeColor: Colors.green,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownTile(
    BuildContext context,
    String title,
    String subtitle,
    String value,
    List<String> options,
    Function(String?) onChanged,
    IconData icon,
    ThemeProvider themeProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: themeProvider.textColor.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.green, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: TextStyle(
                color: themeProvider.textColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green.withOpacity(0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.green),
                ),
              ),
              dropdownColor: themeProvider.cardColor,
              style: TextStyle(color: themeProvider.textColor),
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
    ThemeProvider themeProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: themeProvider.textColor.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.green, size: 22),
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
            color: themeProvider.textColor.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: themeProvider.textColor.withOpacity(0.5),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    ThemeProvider themeProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: themeProvider.textColor.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.green, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: themeProvider.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            color: themeProvider.textColor.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Helper methods for updating settings
  void _updateUserSetting(
    UserProvider userProvider,
    String setting,
    dynamic value,
  ) {
    final user = userProvider.user!;
    UserModel updatedUser;

    switch (setting) {
      case 'notificationsEnabled':
        updatedUser = user.copyWith(notificationsEnabled: value);
        break;
      case 'emailNotifications':
        updatedUser = user.copyWith(emailNotifications: value);
        break;
      case 'smsNotifications':
        updatedUser = user.copyWith(smsNotifications: value);
        break;
      case 'orderUpdates':
        updatedUser = user.copyWith(orderUpdates: value);
        break;
      case 'promotionalOffers':
        updatedUser = user.copyWith(promotionalOffers: value);
        break;
      case 'biometricLogin':
        updatedUser = user.copyWith(biometricLogin: value);
        break;
      case 'autoBackup':
        updatedUser = user.copyWith(autoBackup: value);
        break;
      case 'locationServices':
        updatedUser = user.copyWith(locationServices: value);
        break;
      case 'crashReporting':
        updatedUser = user.copyWith(crashReporting: value);
        break;
      default:
        return;
    }

    userProvider.updateUser(updatedUser);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('settings_saved'.tr(context)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _updateLanguage(UserProvider userProvider, String language) {
    userProvider.setLanguage(language);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${'language_changed'.tr(context)} $language'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _updateCurrency(
    UserProvider userProvider,
    CurrencyProvider currencyProvider,
    String currency,
  ) {
    userProvider.setCurrency(currency);
    currencyProvider.updateCurrency(currency);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${'currency_changed'.tr(context)} $currency'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _updateTheme(
    UserProvider userProvider,
    ThemeProvider themeProvider,
    String theme,
  ) {
    userProvider.setTheme(theme);

    switch (theme) {
      case 'Light':
        themeProvider.updateTheme('Light');
        break;
      case 'Dark':
        themeProvider.updateTheme('Dark');
        break;
      case 'System':
        themeProvider.updateTheme('Auto');
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${'theme_changed'.tr(context)} $theme'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Dialog methods
  void _showChangePasswordDialog(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        title: Text(
          'change_password'.tr(context),
          style: TextStyle(color: themeProvider.textColor),
        ),
        content: Text(
          'This feature will be implemented with proper authentication.',
          style: TextStyle(color: themeProvider.textColor.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ok'.tr(context),
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        title: Text(
          'two_factor'.tr(context),
          style: TextStyle(color: themeProvider.textColor),
        ),
        content: Text(
          'Two-factor authentication will be implemented with proper security measures.',
          style: TextStyle(color: themeProvider.textColor.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ok'.tr(context),
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderHistory(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        title: Text(
          'order_history'.tr(context),
          style: TextStyle(color: themeProvider.textColor),
        ),
        content: Text(
          'Order history feature will be implemented with order tracking.',
          style: TextStyle(color: themeProvider.textColor.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ok'.tr(context),
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(
    BuildContext context,
    CartProvider cartProvider,
    ThemeProvider themeProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        title: Text(
          'clear_cart'.tr(context),
          style: TextStyle(color: themeProvider.textColor),
        ),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
          style: TextStyle(color: themeProvider.textColor.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(context),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cart cleared successfully'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text('Clear', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.cardColor,
        title: Text(
          'logout'.tr(context),
          style: TextStyle(color: themeProvider.textColor),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: themeProvider.textColor.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(context),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/welcome',
                (route) => false,
              );
            },
            child: Text(
              'logout'.tr(context),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // External links and sharing
  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _rateApp() {
    // Implement app store rating
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('App store rating will be implemented'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareApp() {
    Share.share(
      'Check out PlantGuard AI - Your intelligent plant care companion!\n\nDownload now: https://plantguard.ai/download',
      subject: 'PlantGuard AI - Smart Plant Care',
    );
  }
}
