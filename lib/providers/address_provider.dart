import 'package:flutter/foundation.dart';
import '../models/address_model.dart';

class AddressProvider with ChangeNotifier {
  final List<AddressModel> _addresses = [];
  bool _isLoading = false;

  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  bool get isLoading => _isLoading;
  int get addressCount => _addresses.length;
  bool get isEmpty => _addresses.isEmpty;

  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  // Initialize with demo data
  void initializeAddresses() {
    _addresses.clear();
    _addresses.addAll([
      AddressModel(
        id: '1',
        label: 'Home',
        name: 'Mariam Uwimana',
        phone: '+250 788 123 456',
        address: 'Kigali, Gasabo District, Kacyiru Sector',
        details: 'House No. 25, Near City Market',
        isDefault: true,
      ),
      AddressModel(
        id: '2',
        label: 'Work',
        name: 'Mariam Uwimana',
        phone: '+250 788 123 456',
        address: 'Kigali, Nyarugenge District, Central Business District',
        details: 'Office Building, 3rd Floor, Room 301',
        isDefault: false,
      ),
    ]);
    notifyListeners();
  }

  // Add new address
  Future<void> addAddress({
    required String label,
    required String name,
    required String phone,
    required String address,
    String details = '',
    bool setAsDefault = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final newAddress = AddressModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: label,
        name: name,
        phone: phone,
        address: address,
        details: details,
        isDefault: setAsDefault || _addresses.isEmpty,
      );

      // If setting as default, remove default from others
      if (setAsDefault || _addresses.isEmpty) {
        for (int i = 0; i < _addresses.length; i++) {
          _addresses[i] = _addresses[i].copyWith(isDefault: false);
        }
      }

      _addresses.add(newAddress);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update existing address
  Future<void> updateAddress({
    required String id,
    String? label,
    String? name,
    String? phone,
    String? address,
    String? details,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 400));

      final index = _addresses.indexWhere((addr) => addr.id == id);
      if (index >= 0) {
        _addresses[index] = _addresses[index].copyWith(
          label: label,
          name: name,
          phone: phone,
          address: address,
          details: details,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Set address as default
  Future<void> setDefaultAddress(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(
          isDefault: _addresses[i].id == id,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete address
  Future<void> deleteAddress(String id) async {
    final address = _addresses.firstWhere((addr) => addr.id == id);

    // Prevent deleting default address if it's the only one or if there are multiple
    if (address.isDefault && _addresses.length > 1) {
      throw Exception(
        'Cannot delete default address. Set another as default first.',
      );
    }

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      _addresses.removeWhere((addr) => addr.id == id);

      // If we deleted the only address or default address, set first one as default
      if (_addresses.isNotEmpty && !_addresses.any((addr) => addr.isDefault)) {
        _addresses[0] = _addresses[0].copyWith(isDefault: true);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Get address by ID
  AddressModel? getAddressById(String id) {
    try {
      return _addresses.firstWhere((address) => address.id == id);
    } catch (e) {
      return null;
    }
  }

  // Check if address label already exists
  bool labelExists(String label, {String? excludeId}) {
    return _addresses.any(
      (address) =>
          address.label.toLowerCase() == label.toLowerCase() &&
          address.id != excludeId,
    );
  }

  // Get addresses by type/label
  List<AddressModel> getAddressesByLabel(String label) {
    return _addresses
        .where((address) => address.label.toLowerCase() == label.toLowerCase())
        .toList();
  }
}
