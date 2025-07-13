import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: const Text(''),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Row(
              children: [
                Text('English', style: TextStyle(color: Colors.white)),
                SizedBox(width: 5),
                Icon(Icons.language, color: Colors.white),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Color(0xFF333333),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              margin: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Mariam',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white70,
                    ),
                    label: const Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),

            // My Order Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Order',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OrderIcon(
                    icon: Icons.hourglass_empty,
                    label: 'Pending\nPayment',
                  ),
                  OrderIcon(
                    icon: Icons.local_shipping,
                    label: 'In Transit\n(Shipping)',
                  ),
                  OrderIcon(
                    icon: Icons.pending_actions,
                    label: 'Pending\nFeedback',
                  ),
                  OrderIcon(
                    icon: Icons.assignment_return,
                    label: 'Return &\nRefund',
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 30),

            // Main List
            _buildListItem(context, Icons.shopping_cart, 'Cart'),
            _buildListItem(context, Icons.favorite, 'Wish List'),
            _buildListItem(context, Icons.image, 'Image History'),
            _buildListItem(context, Icons.search, 'Recently Searched'),
            const Divider(color: Colors.white24, height: 30),

            // Secondary List
            _buildListItem(
              context,
              Icons.location_on,
              'Address Management',
              showImages: false,
            ),
            _buildListItem(
              context,
              Icons.headset_mic,
              'Customer Center',
              showImages: false,
            ),
            _buildListItem(
              context,
              Icons.person_add,
              'Invite Friend',
              showImages: false,
            ),
            _buildListItem(
              context,
              Icons.chat,
              'Friend Code',
              showImages: false,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 2, // Profile is selected
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    IconData icon,
    String title, {
    bool showImages = true,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: showImages
          ? SizedBox(
              width: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Image.network(
                      'https://placehold.co/30x30/7CFC00/FFFFFF?text=P${index + 1}',
                      width: 30,
                      height: 30,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image, size: 30);
                      },
                    ),
                  );
                }),
              ),
            )
          : const Icon(Icons.chevron_right, color: Colors.white),
      onTap: () {
        Navigator.pushNamed(context, '/profile');
      },
    );
  }
}

class OrderIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const OrderIcon({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.white),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}
