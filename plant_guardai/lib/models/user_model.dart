class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String profileImage;
  final String language;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool orderUpdates;
  final bool promotionalOffers;
  final bool darkMode;
  final bool biometricLogin;
  final bool autoBackup;
  final bool locationServices;
  final bool crashReporting;
  final String currency;
  final String theme;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.profileImage,
    this.language = 'English',
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.orderUpdates = true,
    this.promotionalOffers = true,
    this.darkMode = true,
    this.biometricLogin = false,
    this.autoBackup = true,
    this.locationServices = true,
    this.crashReporting = true,
    this.currency = 'RWF',
    this.theme = 'Dark',
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? location,
    String? profileImage,
    String? language,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? orderUpdates,
    bool? promotionalOffers,
    bool? darkMode,
    bool? biometricLogin,
    bool? autoBackup,
    bool? locationServices,
    bool? crashReporting,
    String? currency,
    String? theme,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      profileImage: profileImage ?? this.profileImage,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotionalOffers: promotionalOffers ?? this.promotionalOffers,
      darkMode: darkMode ?? this.darkMode,
      biometricLogin: biometricLogin ?? this.biometricLogin,
      autoBackup: autoBackup ?? this.autoBackup,
      locationServices: locationServices ?? this.locationServices,
      crashReporting: crashReporting ?? this.crashReporting,
      currency: currency ?? this.currency,
      theme: theme ?? this.theme,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'profileImage': profileImage,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'orderUpdates': orderUpdates,
      'promotionalOffers': promotionalOffers,
      'darkMode': darkMode,
      'biometricLogin': biometricLogin,
      'autoBackup': autoBackup,
      'locationServices': locationServices,
      'crashReporting': crashReporting,
      'currency': currency,
      'theme': theme,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      location: json['location'],
      profileImage: json['profileImage'],
      language: json['language'] ?? 'English',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      smsNotifications: json['smsNotifications'] ?? false,
      orderUpdates: json['orderUpdates'] ?? true,
      promotionalOffers: json['promotionalOffers'] ?? true,
      darkMode: json['darkMode'] ?? true,
      biometricLogin: json['biometricLogin'] ?? false,
      autoBackup: json['autoBackup'] ?? true,
      locationServices: json['locationServices'] ?? true,
      crashReporting: json['crashReporting'] ?? true,
      currency: json['currency'] ?? 'RWF',
      theme: json['theme'] ?? 'Dark',
    );
  }
}
