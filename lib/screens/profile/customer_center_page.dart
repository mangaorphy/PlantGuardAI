import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class CustomerCenterPage extends StatefulWidget {
  const CustomerCenterPage({super.key});

  @override
  State<CustomerCenterPage> createState() => _CustomerCenterPageState();
}

class _CustomerCenterPageState extends State<CustomerCenterPage> {
  final List<Map<String, dynamic>> _quickHelp = [
    {
      'title': 'Order Issues',
      'description': 'Problems with your orders',
      'icon': Icons.shopping_bag_outlined,
      'color': Colors.blue,
    },
    {
      'title': 'Payment Help',
      'description': 'Payment and billing questions',
      'icon': Icons.payment,
      'color': Colors.green,
    },
    {
      'title': 'Delivery Info',
      'description': 'Shipping and delivery help',
      'icon': Icons.local_shipping,
      'color': Colors.orange,
    },
    {
      'title': 'Product Questions',
      'description': 'About our plant protection products',
      'icon': Icons.agriculture,
      'color': Colors.purple,
    },
  ];

  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'How do I track my order?',
      'answer':
          'You can track your order by going to the "My Orders" section in your profile. You\'ll receive real-time updates on your order status.',
    },
    {
      'question': 'What payment methods do you accept?',
      'answer':
          'We accept Mobile Money (MTN Mobile Money, Airtel Money), Visa, Mastercard, and cash on delivery for eligible areas.',
    },
    {
      'question': 'How do I identify plant diseases?',
      'answer':
          'Use our AI-powered plant disease detection feature by taking a photo of the affected plant. Our system will analyze and provide treatment recommendations.',
    },
    {
      'question': 'Do you offer organic products?',
      'answer':
          'Yes! We have a wide range of organic and eco-friendly plant protection products. Look for the "Organic" label on product listings.',
    },
    {
      'question': 'How long does delivery take?',
      'answer':
          'Delivery typically takes 1-3 business days within Kigali and 2-5 business days for other regions in Rwanda.',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
              'Customer Center',
              style: TextStyle(
                color: themeProvider.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(themeProvider),
                  _buildQuickHelp(themeProvider),
                  _buildContactOptions(themeProvider),
                  _buildFAQ(themeProvider),
                  _buildSupportInfo(themeProvider),
                  const SizedBox(height: 20), // Extra bottom padding
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.headset_mic, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            'How can we help you?',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our support team is here to assist you',
            style: TextStyle(
              color: themeProvider.secondaryTextColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickHelp(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Help',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio:
                  1.3, // Slightly increased for better proportions
            ),
            itemCount: _quickHelp.length,
            itemBuilder: (context, index) {
              return _buildQuickHelpCard(_quickHelp[index], themeProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickHelpCard(
    Map<String, dynamic> helpItem,
    ThemeProvider themeProvider,
  ) {
    return GestureDetector(
      onTap: () => _showHelpDetails(helpItem['title']),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: themeProvider.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeProvider.borderColor),
        ),
        child: Column(
          children: [
            // Icon section
            Expanded(
              flex: 2,
              child: Icon(helpItem['icon'], color: helpItem['color'], size: 28),
            ),
            // Title section
            Expanded(
              flex: 2,
              child: Text(
                helpItem['title'],
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Description section
            Expanded(
              flex: 2,
              child: Text(
                helpItem['description'],
                style: TextStyle(
                  color: themeProvider.secondaryTextColor,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOptions(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Us',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactOption(
            Icons.chat,
            'Live Chat',
            'Chat with our support team',
            () => _startLiveChat(themeProvider),
            themeProvider,
          ),
          _buildContactOption(
            Icons.phone,
            'Call Us',
            '+250 788 123 456',
            () => _makePhoneCall(),
            themeProvider,
          ),
          _buildContactOption(
            Icons.email,
            'Email Support',
            'support@plantguardai.com',
            () => _sendEmail(),
            themeProvider,
          ),
          _buildContactOption(
            Icons.message,
            'WhatsApp',
            'Message us on WhatsApp',
            () => _openWhatsApp(),
            themeProvider,
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
    ThemeProvider themeProvider,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Colors.green,
        child: Icon(Icons.headset_mic, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(color: themeProvider.textColor, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: themeProvider.secondaryTextColor, fontSize: 14),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: themeProvider.secondaryTextColor,
        size: 16,
      ),
    );
  }

  Widget _buildFAQ(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _faqItems.length,
            itemBuilder: (context, index) {
              return _buildFAQItem(_faqItems[index], themeProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(
    Map<String, dynamic> faqItem,
    ThemeProvider themeProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: ExpansionTile(
        title: Text(
          faqItem['question'],
          style: TextStyle(color: themeProvider.textColor, fontSize: 14),
        ),
        iconColor: Colors.green,
        collapsedIconColor: themeProvider.secondaryTextColor,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              faqItem['answer'],
              style: TextStyle(
                color: themeProvider.secondaryTextColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportInfo(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Support Hours',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Monday - Friday', '8:00 AM - 6:00 PM', themeProvider),
          _buildInfoRow('Saturday', '9:00 AM - 5:00 PM', themeProvider),
          _buildInfoRow('Sunday', '10:00 AM - 4:00 PM', themeProvider),
          const SizedBox(height: 16),
          Text(
            'Emergency Support',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'For urgent plant health emergencies, our 24/7 hotline is available at +250 700 000 000',
            style: TextStyle(
              color: themeProvider.secondaryTextColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: themeProvider.secondaryTextColor,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(color: themeProvider.textColor, fontSize: 14),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDetails(String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening help for $category...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _startLiveChat(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: themeProvider.cardColor,
            title: Text(
              'Live Chat',
              style: TextStyle(color: themeProvider.textColor),
            ),
            content: Text(
              'Connecting you to our support team...',
              style: TextStyle(color: themeProvider.secondaryTextColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: themeProvider.secondaryTextColor),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text(
                  'Start Chat',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _makePhoneCall() {
    _showSnackBar('Opening phone dialer...');
  }

  void _sendEmail() {
    _showSnackBar('Opening email client...');
  }

  void _openWhatsApp() {
    _showSnackBar('Opening WhatsApp...');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
