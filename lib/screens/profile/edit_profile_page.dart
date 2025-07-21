import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Mariam');
  final _emailController = TextEditingController(text: 'mariam@example.com');
  final _phoneController = TextEditingController(text: '+250 788 123 456');
  final _locationController = TextEditingController(text: 'Kigali, Rwanda');

  bool _notificationsEnabled = true;
  bool _emailNotifications = true;

  final List<String> _languages = [
    'English',
    'Kinyarwanda',
    'French',
    'Swahili',
  ];
  String _selectedLanguage = 'English';

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];
  String _selectedGender = 'Female';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user != null) {
        final user = userProvider.user!;
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _locationController.text = user.location;
        _selectedLanguage = user.language;
        _notificationsEnabled = user.notificationsEnabled;
        _emailNotifications = user.emailNotifications;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

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
              'Edit Profile',
              style: TextStyle(
                color: themeProvider.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => _saveProfile(themeProvider),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfileImageSection(themeProvider),
                  const SizedBox(height: 30),
                  _buildPersonalInfoSection(themeProvider),
                  const SizedBox(height: 20),
                  _buildPreferencesSection(themeProvider),
                  const SizedBox(height: 20),
                  _buildActionButtons(themeProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileImageSection(ThemeProvider themeProvider) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: themeProvider.borderColor),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                      border: Border.all(
                        color: themeProvider.borderColor,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child:
                          userProvider.profileImageFile != null
                              ? Image.file(
                                userProvider.profileImageFile!,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              )
                              : userProvider.user?.profileImage.isNotEmpty ==
                                  true
                              ? Image.network(
                                userProvider.user!.profileImage,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 50,
                                  );
                                },
                              )
                              : const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 50,
                              ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showImagePickerOptions(themeProvider),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: themeProvider.backgroundColor,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Tap to change profile picture',
                style: TextStyle(
                  color: themeProvider.secondaryTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonalInfoSection(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'Full Name',
            _nameController,
            Icons.person,
            themeProvider,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Email',
            _emailController,
            Icons.email,
            themeProvider,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Phone Number',
            _phoneController,
            Icons.phone,
            themeProvider,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Location',
            _locationController,
            Icons.location_on,
            themeProvider,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            'Gender',
            _selectedGender,
            _genders,
            Icons.person_outline,
            themeProvider,
            (value) {
              setState(() {
                _selectedGender = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildDropdownField(
            'Language',
            _selectedLanguage,
            _languages,
            Icons.language,
            themeProvider,
            (value) {
              setState(() {
                _selectedLanguage = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Push Notifications',
            'Receive app notifications',
            _notificationsEnabled,
            (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            Icons.notifications,
            themeProvider,
          ),
          _buildSwitchTile(
            'Email Notifications',
            'Receive email updates',
            _emailNotifications,
            (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
            Icons.email,
            themeProvider,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    ThemeProvider themeProvider,
  ) {
    return Column(
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
        TextFormField(
          controller: controller,
          style: TextStyle(color: themeProvider.textColor),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.green),
            filled: true,
            fillColor: themeProvider.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeProvider.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeProvider.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> options,
    IconData icon,
    ThemeProvider themeProvider,
    Function(String?) onChanged,
  ) {
    return Column(
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: themeProvider.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeProvider.borderColor),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    dropdownColor: themeProvider.cardColor,
                    style: TextStyle(color: themeProvider.textColor),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: themeProvider.secondaryTextColor,
                    ),
                    items:
                        options.map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildActionButtons(ThemeProvider themeProvider) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _saveProfile(themeProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _resetToDefaults(themeProvider),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: themeProvider.borderColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Reset to Defaults',
              style: TextStyle(color: themeProvider.textColor, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePickerOptions(ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: themeProvider.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Update Profile Picture',
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromCamera();
                      },
                      themeProvider: themeProvider,
                    ),
                    _buildImageOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromGallery();
                      },
                      themeProvider: themeProvider,
                    ),
                    _buildImageOption(
                      icon: Icons.delete,
                      label: 'Remove',
                      onTap: () {
                        Navigator.pop(context);
                        _removeProfileImage();
                      },
                      themeProvider: themeProvider,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: themeProvider.textColor, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.updateProfileImageFile(imageFile);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.updateProfileImageFile(imageFile);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeProfileImage() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.removeProfileImage();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture removed'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _saveProfile(ThemeProvider themeProvider) async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Update user information
      await userProvider.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        location: _locationController.text,
      );

      // Update language preference
      userProvider.setLanguage(_selectedLanguage);

      // Update notification settings
      userProvider.updateNotificationSettings(
        pushNotifications: _notificationsEnabled,
        emailNotifications: _emailNotifications,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  void _resetToDefaults(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: themeProvider.cardColor,
            title: Text(
              'Reset to Defaults',
              style: TextStyle(color: themeProvider.textColor),
            ),
            content: Text(
              'Are you sure you want to reset all preferences to their default values?',
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
                onPressed: () {
                  setState(() {
                    _selectedLanguage = 'English';
                    _selectedGender = 'Female';
                    _notificationsEnabled = true;
                    _emailNotifications = true;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preferences reset to defaults'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text(
                  'Reset',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
