import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class AddressManagementPage extends StatefulWidget {
  const AddressManagementPage({super.key});

  @override
  State<AddressManagementPage> createState() => _AddressManagementPageState();
}

class _AddressManagementPageState extends State<AddressManagementPage> {
  List<Map<String, dynamic>> _addresses = [
    {
      'id': '1',
      'label': 'Home',
      'name': 'Mariam Uwimana',
      'phone': '+250 788 123 456',
      'address': 'Kigali, Gasabo District, Kacyiru Sector',
      'details': 'House No. 25, Near City Market',
      'isDefault': true,
    },
    {
      'id': '2',
      'label': 'Work',
      'name': 'Mariam Uwimana',
      'phone': '+250 788 123 456',
      'address': 'Kigali, Nyarugenge District, Central Business District',
      'details': 'Office Building, 3rd Floor, Room 301',
      'isDefault': false,
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
              'Address Management',
              style: TextStyle(
                color: themeProvider.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body:
              _addresses.isEmpty
                  ? _buildEmptyState(themeProvider)
                  : _buildAddressList(themeProvider),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addNewAddress(themeProvider),
            backgroundColor: Colors.green,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: themeProvider.secondaryTextColor,
          ),
          const SizedBox(height: 20),
          Text(
            'No addresses added yet',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your delivery addresses to make ordering easier',
            style: TextStyle(
              color: themeProvider.secondaryTextColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _addNewAddress(themeProvider),
            icon: const Icon(Icons.add),
            label: const Text('Add Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList(ThemeProvider themeProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _addresses.length,
      itemBuilder: (context, index) {
        return _buildAddressCard(_addresses[index], themeProvider);
      },
    );
  }

  Widget _buildAddressCard(
    Map<String, dynamic> address,
    ThemeProvider themeProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              address['isDefault'] ? Colors.green : themeProvider.borderColor,
          width: address['isDefault'] ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: address['isDefault'] ? Colors.green : Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      address['label'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (address['isDefault']) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Default',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              PopupMenuButton<String>(
                color: themeProvider.cardColor,
                icon: Icon(
                  Icons.more_vert,
                  color: themeProvider.secondaryTextColor,
                ),
                onSelected:
                    (value) =>
                        _handleAddressAction(value, address, themeProvider),
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Edit',
                              style: TextStyle(color: themeProvider.textColor),
                            ),
                          ],
                        ),
                      ),
                      if (!address['isDefault'])
                        PopupMenuItem(
                          value: 'default',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Set as Default',
                                style: TextStyle(
                                  color: themeProvider.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(color: themeProvider.textColor),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            address['name'],
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address['phone'],
            style: TextStyle(
              color: themeProvider.secondaryTextColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            address['address'],
            style: TextStyle(color: themeProvider.textColor, fontSize: 14),
          ),
          if (address['details'].isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              address['details'],
              style: TextStyle(
                color: themeProvider.secondaryTextColor,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleAddressAction(
    String action,
    Map<String, dynamic> address,
    ThemeProvider themeProvider,
  ) {
    switch (action) {
      case 'edit':
        _editAddress(address, themeProvider);
        break;
      case 'default':
        _setAsDefault(address);
        break;
      case 'delete':
        _deleteAddress(address, themeProvider);
        break;
    }
  }

  void _addNewAddress(ThemeProvider themeProvider) {
    _showAddressForm(null, themeProvider);
  }

  void _editAddress(Map<String, dynamic> address, ThemeProvider themeProvider) {
    _showAddressForm(address, themeProvider);
  }

  void _showAddressForm(
    Map<String, dynamic>? address,
    ThemeProvider themeProvider,
  ) {
    final nameController = TextEditingController(text: address?['name'] ?? '');
    final phoneController = TextEditingController(
      text: address?['phone'] ?? '',
    );
    final addressController = TextEditingController(
      text: address?['address'] ?? '',
    );
    final detailsController = TextEditingController(
      text: address?['details'] ?? '',
    );
    String selectedLabel = address?['label'] ?? 'Home';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: themeProvider.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address == null ? 'Add New Address' : 'Edit Address',
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Label selection
                Text(
                  'Label',
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children:
                      ['Home', 'Work', 'Other'].map((label) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedLabel = label;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    selectedLabel == label
                                        ? Colors.green
                                        : themeProvider.backgroundColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: themeProvider.borderColor,
                                ),
                              ),
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      selectedLabel == label
                                          ? Colors.white
                                          : themeProvider.textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 16),

                // Form fields
                _buildTextField('Full Name', nameController, themeProvider),
                _buildTextField('Phone Number', phoneController, themeProvider),
                _buildTextField(
                  'Address',
                  addressController,
                  themeProvider,
                  maxLines: 2,
                ),
                _buildTextField(
                  'Additional Details (Optional)',
                  detailsController,
                  themeProvider,
                  maxLines: 2,
                ),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: themeProvider.secondaryTextColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isNotEmpty &&
                              phoneController.text.isNotEmpty &&
                              addressController.text.isNotEmpty) {
                            _saveAddress(
                              address,
                              selectedLabel,
                              nameController.text,
                              phoneController.text,
                              addressController.text,
                              detailsController.text,
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text(
                          address == null ? 'Add' : 'Update',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    ThemeProvider themeProvider, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(color: themeProvider.textColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: themeProvider.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: themeProvider.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: themeProvider.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.green),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveAddress(
    Map<String, dynamic>? existingAddress,
    String label,
    String name,
    String phone,
    String address,
    String details,
  ) {
    if (existingAddress != null) {
      // Update existing address
      setState(() {
        final index = _addresses.indexWhere(
          (addr) => addr['id'] == existingAddress['id'],
        );
        if (index != -1) {
          _addresses[index] = {
            ..._addresses[index],
            'label': label,
            'name': name,
            'phone': phone,
            'address': address,
            'details': details,
          };
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Add new address
      setState(() {
        _addresses.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'label': label,
          'name': name,
          'phone': phone,
          'address': address,
          'details': details,
          'isDefault': _addresses.isEmpty, // First address becomes default
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _setAsDefault(Map<String, dynamic> address) {
    setState(() {
      // Remove default from all addresses
      for (var addr in _addresses) {
        addr['isDefault'] = false;
      }
      // Set selected address as default
      address['isDefault'] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${address['label']} set as default address'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteAddress(
    Map<String, dynamic> address,
    ThemeProvider themeProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: themeProvider.cardColor,
            title: Text(
              'Delete Address',
              style: TextStyle(color: themeProvider.textColor),
            ),
            content: Text(
              'Are you sure you want to delete this address?',
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
              TextButton(
                onPressed: () {
                  setState(() {
                    _addresses.removeWhere(
                      (addr) => addr['id'] == address['id'],
                    );
                    // If deleted address was default and there are remaining addresses, make first one default
                    if (address['isDefault'] && _addresses.isNotEmpty) {
                      _addresses[0]['isDefault'] = true;
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Address deleted successfully!'),
                      backgroundColor: Colors.green,
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
}
