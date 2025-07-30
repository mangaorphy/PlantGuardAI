import 'package:flutter/material.dart';

class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static const Map<String, Map<String, String>> _localizedValues = {
    'English': {
      // General
      'app_name': 'PlantGuard AI',
      'home': 'Home',
      'search': 'Search',
      'cart': 'Cart',
      'wishlist': 'Wishlist',
      'profile': 'Profile',
      'settings': 'Settings',
      'back': 'Back',
      'save': 'Save',
      'cancel': 'Cancel',
      'ok': 'OK',
      'error': 'Error',
      'success': 'Success',
      'loading': 'Loading...',
      'retry': 'Retry',
      'refresh': 'Refresh',

      // Settings Page
      'notifications': 'Notifications',
      'push_notifications': 'Push Notifications',
      'email_notifications': 'Email Notifications',
      'sms_notifications': 'SMS Notifications',
      'order_updates': 'Order Updates',
      'promotional_offers': 'Promotional Offers',
      'stay_updated_desc': 'Stay updated with your orders and offers',

      'appearance': 'Appearance',
      'language': 'Language',
      'select_language': 'Select your preferred language',
      'currency': 'Currency',
      'select_currency': 'Select your preferred currency',
      'theme': 'Theme',
      'choose_theme': 'Choose your preferred theme',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
      'customize_look': 'Customize your app appearance',

      'security': 'Security',
      'biometric_login': 'Biometric Login',
      'enable_biometric': 'Enable fingerprint/face login',
      'change_password': 'Change Password',
      'update_password': 'Update your account password',
      'two_factor': 'Two-Factor Authentication',
      'enable_2fa': 'Add extra security to your account',
      'secure_account': 'Keep your account secure',

      'data_privacy': 'Data & Privacy',
      'auto_backup': 'Auto Backup',
      'backup_data': 'Automatically backup your data',
      'location_services': 'Location Services',
      'enable_location': 'Enable location for better recommendations',
      'crash_reporting': 'Crash Reporting',
      'help_improve': 'Help improve the app',
      'data_usage': 'Manage your data and privacy settings',

      'about': 'About',
      'app_version': 'App Version',
      'terms_service': 'Terms of Service',
      'privacy_policy': 'Privacy Policy',
      'help_support': 'Help & Support',
      'rate_app': 'Rate Our App',
      'logout': 'Logout',

      // Shopping & Products
      'products': 'Products',
      'add_to_cart': 'Add to Cart',
      'add_to_wishlist': 'Add to Wishlist',
      'remove_from_cart': 'Remove from Cart',
      'remove_from_wishlist': 'Remove from Wishlist',
      'total_items': 'Total Items',
      'subtotal': 'Subtotal',
      'total': 'Total',
      'checkout': 'Checkout',
      'empty_cart': 'Your cart is empty',
      'empty_wishlist': 'Your wishlist is empty',
      'continue_shopping': 'Continue Shopping',

      // Plant Analysis
      'plant_analysis': 'Plant Analysis',
      'analyze_plant': 'Analyze Plant',
      'take_photo': 'Take Photo',
      'choose_photo': 'Choose Photo',
      'analyzing': 'Analyzing...',
      'analysis_result': 'Analysis Result',

      // Messages
      'language_changed': 'Language changed to',
      'currency_changed': 'Currency changed to',
      'theme_changed': 'Theme changed to',
      'settings_saved': 'Settings saved successfully',
      'item_added_cart': 'Item added to cart',
      'item_removed_cart': 'Item removed from cart',
      'item_added_wishlist': 'Item added to wishlist',
      'item_removed_wishlist': 'Item removed from wishlist',

      // Additional Settings
      'cart_items': 'Cart Items',
      'wishlist_items': 'Wishlist Items',
      'available_products': 'Available Products',
      'view_cart': 'View Cart',
      'view_wishlist': 'View Wishlist',
      'order_history': 'Order History',
      'clear_cart': 'Clear Cart',
      'share_app': 'Share App',
      'settings_refreshed': 'Settings refreshed',
      'cart_items_count': '{count} items in cart',
    },

    'Kinyarwanda': {
      // General
      'app_name': 'PlantGuard AI',
      'home': 'Urugo',
      'search': 'Gushaka',
      'cart': 'Agasanduku',
      'wishlist': 'Ibyifuza',
      'profile': 'Umwirondoro',
      'settings': 'Igenamiterere',
      'back': 'Subira',
      'save': 'Bika',
      'cancel': 'Kuraguza',
      'ok': 'Sawa',
      'error': 'Ikosa',
      'success': 'Byagenze neza',
      'loading': 'Biratunganywa...',
      'retry': 'Ongera ugerageze',
      'refresh': 'Kuvugurura',

      // Settings Page
      'notifications': 'Ubutumwa',
      'push_notifications': 'Ubutumwa bwihuse',
      'email_notifications': 'Ubutumwa bwa Email',
      'sms_notifications': 'Ubutumwa bwa SMS',
      'order_updates': 'Amakuru y\'ibicuruzwa',
      'promotional_offers': 'Amatangazo',
      'stay_updated_desc': 'Komeza uhabwa amakuru ku bicuruzwa n\'amatangazo',

      'appearance': 'Isura',
      'language': 'Ururimi',
      'select_language': 'Hitamo ururimi rwawe',
      'currency': 'Ifaranga',
      'select_currency': 'Hitamo ifaranga ryawe',
      'theme': 'Ubwoko',
      'choose_theme': 'Hitamo ubwoko bw\'isura',
      'light': 'Urumuri',
      'dark': 'Umwijima',
      'system': 'Sisitemu',
      'customize_look': 'Hindura isura y\'application',

      'security': 'Umutekano',
      'biometric_login': 'Kwinjira n\'intoki',
      'enable_biometric': 'Emera kwinjira n\'intoki/ubuso',
      'change_password': 'Hindura ijambo ry\'ibanga',
      'update_password': 'Vugurura ijambo ry\'ibanga',
      'two_factor': 'Kugenzura inshuro ebyiri',
      'enable_2fa': 'Ongeraho umutekano muri konti yawe',
      'secure_account': 'Bika konti yawe ifite umutekano',

      'data_privacy': 'Amakuru n\'Ubwigenge',
      'auto_backup': 'Kubika byikora',
      'backup_data': 'Bika amakuru yawe mu buryo bwikora',
      'location_services': 'Serivisi z\'ahantu',
      'enable_location': 'Emera ahantu kugira ngo ubone ibyifuza byiza',
      'crash_reporting': 'Gutanga raporo z\'ibibazo',
      'help_improve': 'Dufashe gutezimbere application',
      'data_usage': 'Menya amakuru yawe n\'ubwigenge',

      'about': 'Kubyerekeye',
      'app_version': 'Verisiyo ya App',
      'terms_service': 'Amabwiriza y\'ikoreshwa',
      'privacy_policy': 'Politiki y\'ubwigenge',
      'help_support': 'Ubufasha n\'Inkunga',
      'rate_app': 'Tanga igipimo cya App',
      'logout': 'Gusohoka',

      // Shopping & Products
      'products': 'Ibicuruzwa',
      'add_to_cart': 'Shyira mu gasanduku',
      'add_to_wishlist': 'Shyira mu byifuza',
      'remove_from_cart': 'Kuraho mu gasanduku',
      'remove_from_wishlist': 'Kuraho mu byifuza',
      'total_items': 'Ibintu byose',
      'subtotal': 'Igiteranyo gito',
      'total': 'Igiteranyo',
      'checkout': 'Kwishyura',
      'empty_cart': 'Agasanduku kawe kari ubusa',
      'empty_wishlist': 'Ibyifuza byawe biri ubusa',
      'continue_shopping': 'Komeza guhaha',

      // Plant Analysis
      'plant_analysis': 'Isesengura ry\'ibimera',
      'analyze_plant': 'Sesengura ikimera',
      'take_photo': 'Fata ifoto',
      'choose_photo': 'Hitamo ifoto',
      'analyzing': 'Birasesengurwa...',
      'analysis_result': 'Ibisubizo by\'isesengura',

      // Messages
      'language_changed': 'Ururimi rwahinduwe kuri',
      'currency_changed': 'Ifaranga ryahinduwe kuri',
      'theme_changed': 'Ubwoko bwahinduwe kuri',
      'settings_saved': 'Igenamiterere ryabitswe neza',
      'item_added_cart': 'Ikintu cyashyizwe mu gasanduku',
      'item_removed_cart': 'Ikintu cyavanywe mu gasanduku',
      'item_added_wishlist': 'Ikintu cyashyizwe mu byifuza',
      'item_removed_wishlist': 'Ikintu cyavanywe mu byifuza',

      // Additional Settings
      'cart_items': 'Ibintu mu gasanduku',
      'wishlist_items': 'Ibintu mu byifuza',
      'available_products': 'Ibicuruzwa biboneka',
      'view_cart': 'Reba agasanduku',
      'view_wishlist': 'Reba ibyifuza',
      'order_history': 'Amateka y\'ibisabwa',
      'clear_cart': 'Siba agasanduku',
      'share_app': 'Sangira App',
      'settings_refreshed': 'Igenamiterere ryavuguruwe',
      'cart_items_count': 'Ibintu {count} mu gasanduku',
    },

    'French': {
      // General
      'app_name': 'PlantGuard AI',
      'home': 'Accueil',
      'search': 'Rechercher',
      'cart': 'Panier',
      'wishlist': 'Liste de souhaits',
      'profile': 'Profil',
      'settings': 'Paramètres',
      'back': 'Retour',
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'ok': 'OK',
      'error': 'Erreur',
      'success': 'Succès',
      'loading': 'Chargement...',
      'retry': 'Réessayer',
      'refresh': 'Actualiser',

      // Settings Page
      'notifications': 'Notifications',
      'push_notifications': 'Notifications push',
      'email_notifications': 'Notifications par e-mail',
      'sms_notifications': 'Notifications SMS',
      'order_updates': 'Mises à jour des commandes',
      'promotional_offers': 'Offres promotionnelles',
      'stay_updated_desc': 'Restez informé de vos commandes et offres',

      'appearance': 'Apparence',
      'language': 'Langue',
      'select_language': 'Sélectionnez votre langue préférée',
      'currency': 'Devise',
      'select_currency': 'Sélectionnez votre devise préférée',
      'theme': 'Thème',
      'choose_theme': 'Choisissez votre thème préféré',
      'light': 'Clair',
      'dark': 'Sombre',
      'system': 'Système',
      'customize_look': 'Personnalisez l\'apparence de votre application',

      'security': 'Sécurité',
      'biometric_login': 'Connexion biométrique',
      'enable_biometric': 'Activer la connexion par empreinte/visage',
      'change_password': 'Changer le mot de passe',
      'update_password': 'Mettre à jour votre mot de passe',
      'two_factor': 'Authentification à deux facteurs',
      'enable_2fa': 'Ajoutez une sécurité supplémentaire à votre compte',
      'secure_account': 'Gardez votre compte sécurisé',

      'data_privacy': 'Données et confidentialité',
      'auto_backup': 'Sauvegarde automatique',
      'backup_data': 'Sauvegarder automatiquement vos données',
      'location_services': 'Services de localisation',
      'enable_location':
          'Activer la localisation pour de meilleures recommandations',
      'crash_reporting': 'Rapport de plantage',
      'help_improve': 'Aidez à améliorer l\'application',
      'data_usage': 'Gérez vos paramètres de données et de confidentialité',

      'about': 'À propos',
      'app_version': 'Version de l\'application',
      'terms_service': 'Conditions d\'utilisation',
      'privacy_policy': 'Politique de confidentialité',
      'help_support': 'Aide et support',
      'rate_app': 'Évaluer notre application',
      'logout': 'Se déconnecter',

      // Shopping & Products
      'products': 'Produits',
      'add_to_cart': 'Ajouter au panier',
      'add_to_wishlist': 'Ajouter à la liste de souhaits',
      'remove_from_cart': 'Retirer du panier',
      'remove_from_wishlist': 'Retirer de la liste de souhaits',
      'total_items': 'Articles totaux',
      'subtotal': 'Sous-total',
      'total': 'Total',
      'checkout': 'Commander',
      'empty_cart': 'Votre panier est vide',
      'empty_wishlist': 'Votre liste de souhaits est vide',
      'continue_shopping': 'Continuer vos achats',

      // Plant Analysis
      'plant_analysis': 'Analyse des plantes',
      'analyze_plant': 'Analyser la plante',
      'take_photo': 'Prendre une photo',
      'choose_photo': 'Choisir une photo',
      'analyzing': 'Analyse en cours...',
      'analysis_result': 'Résultat de l\'analyse',

      // Messages
      'language_changed': 'Langue changée en',
      'currency_changed': 'Devise changée en',
      'theme_changed': 'Thème changé en',
      'settings_saved': 'Paramètres enregistrés avec succès',
      'item_added_cart': 'Article ajouté au panier',
      'item_removed_cart': 'Article retiré du panier',
      'item_added_wishlist': 'Article ajouté à la liste de souhaits',
      'item_removed_wishlist': 'Article retiré de la liste de souhaits',

      // Additional Settings
      'cart_items': 'Articles du panier',
      'wishlist_items': 'Articles de la liste de souhaits',
      'available_products': 'Produits disponibles',
      'view_cart': 'Voir le panier',
      'view_wishlist': 'Voir la liste de souhaits',
      'order_history': 'Historique des commandes',
      'clear_cart': 'Vider le panier',
      'share_app': 'Partager l\'app',
      'settings_refreshed': 'Paramètres actualisés',
      'cart_items_count': '{count} articles dans le panier',
    },

    'Swahili': {
      // General
      'app_name': 'PlantGuard AI',
      'home': 'Nyumbani',
      'search': 'Tafuta',
      'cart': 'Kikapu',
      'wishlist': 'Orodha ya matakwa',
      'profile': 'Wasifu',
      'settings': 'Mipangilio',
      'back': 'Rudi',
      'save': 'Hifadhi',
      'cancel': 'Ghairi',
      'ok': 'Sawa',
      'error': 'Kosa',
      'success': 'Mafanikio',
      'loading': 'Inapakia...',
      'retry': 'Jaribu tena',
      'refresh': 'Onyesha upya',

      // Settings Page
      'notifications': 'Arifa',
      'push_notifications': 'Arifa za kusukuma',
      'email_notifications': 'Arifa za barua pepe',
      'sms_notifications': 'Arifa za SMS',
      'order_updates': 'Masasisho ya maagizo',
      'promotional_offers': 'Matoleo ya uuzaji',
      'stay_updated_desc': 'Endelea kupokea habari za maagizo na matoleo yako',

      'appearance': 'Mwonekano',
      'language': 'Lugha',
      'select_language': 'Chagua lugha unayopendelea',
      'currency': 'Sarafu',
      'select_currency': 'Chagua sarafu unayopendelea',
      'theme': 'Mandhari',
      'choose_theme': 'Chagua mandhari unayopendelea',
      'light': 'Mwanga',
      'dark': 'Giza',
      'system': 'Mfumo',
      'customize_look': 'Badilisha mwonekano wa programu yako',

      'security': 'Usalama',
      'biometric_login': 'Kuingia kwa viumbe',
      'enable_biometric': 'Wezesha kuingia kwa kidole/uso',
      'change_password': 'Badilisha nywila',
      'update_password': 'Sasisha nywila yako',
      'two_factor': 'Uthibitisho wa hatua mbili',
      'enable_2fa': 'Ongeza usalama zaidi kwa akaunti yako',
      'secure_account': 'Weka akaunti yako salama',

      'data_privacy': 'Data na Faragha',
      'auto_backup': 'Hifadhi otomatiki',
      'backup_data': 'Hifadhi data yako kiotomatiki',
      'location_services': 'Huduma za mahali',
      'enable_location': 'Wezesha eneo kwa mapendekezo bora',
      'crash_reporting': 'Ripoti za kusonga',
      'help_improve': 'Saidia kuboresha programu',
      'data_usage': 'Dhibiti mipangilio ya data na faragha yako',

      'about': 'Kuhusu',
      'app_version': 'Toleo la Programu',
      'terms_service': 'Masharti ya Huduma',
      'privacy_policy': 'Sera ya Faragha',
      'help_support': 'Msaada na Usaidizi',
      'rate_app': 'Kadiria Programu yetu',
      'logout': 'Toka',

      // Shopping & Products
      'products': 'Bidhaa',
      'add_to_cart': 'Ongeza kwenye kikapu',
      'add_to_wishlist': 'Ongeza kwenye orodha ya matakwa',
      'remove_from_cart': 'Ondoa kutoka kikapa',
      'remove_from_wishlist': 'Ondoa kutoka orodha ya matakwa',
      'total_items': 'Vitu vyote',
      'subtotal': 'Jumla ndogo',
      'total': 'Jumla',
      'checkout': 'Lipia',
      'empty_cart': 'Kikapu chako ni tupu',
      'empty_wishlist': 'Orodha yako ya matakwa ni tupu',
      'continue_shopping': 'Endelea ununuzi',

      // Plant Analysis
      'plant_analysis': 'Uchanganuzi wa Mimea',
      'analyze_plant': 'Changanua Mmea',
      'take_photo': 'Piga Picha',
      'choose_photo': 'Chagua Picha',
      'analyzing': 'Inachanganua...',
      'analysis_result': 'Matokeo ya Uchanganuzi',

      // Messages
      'language_changed': 'Lugha imebadilishwa kuwa',
      'currency_changed': 'Sarafu imebadilishwa kuwa',
      'theme_changed': 'Mandhari imebadilishwa kuwa',
      'settings_saved': 'Mipangilio imehifadhiwa kwa mafanikio',
      'item_added_cart': 'Kitu kimeongezwa kwenye kikapu',
      'item_removed_cart': 'Kitu kimeondolewa kutoka kikapu',
      'item_added_wishlist': 'Kitu kimeongezwa kwenye orodha ya matakwa',
      'item_removed_wishlist': 'Kitu kimeondolewa kutoka orodha ya matakwa',

      // Additional Settings
      'cart_items': 'Vitu vya Kikapu',
      'wishlist_items': 'Vitu vya Orodha ya Matakwa',
      'available_products': 'Bidhaa Zinazopatikana',
      'view_cart': 'Angalia Kikapu',
      'view_wishlist': 'Angalia Orodha ya Matakwa',
      'order_history': 'Historia ya Maagizo',
      'clear_cart': 'Safisha Kikapu',
      'share_app': 'Shiriki App',
      'settings_refreshed': 'Mipangilio imeonyeshwa upya',
      'cart_items_count': 'Vitu {count} katika kikapu',
    },
  };

  String translate(String key) {
    return _localizedValues[languageCode]?[key] ??
        _localizedValues['English']?[key] ??
        key;
  }

  static AppLocalizations of(BuildContext context) {
    final userProvider = context
        .dependOnInheritedWidgetOfExactType<LocalizationProvider>();
    return AppLocalizations(userProvider?.locale ?? 'English');
  }
}

class LocalizationProvider extends InheritedWidget {
  final String locale;

  const LocalizationProvider({
    Key? key,
    required this.locale,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(LocalizationProvider oldWidget) {
    return locale != oldWidget.locale;
  }
}

// Extension to make translation easier
extension StringTranslation on String {
  String tr(BuildContext context) {
    return AppLocalizations.of(context).translate(this);
  }
}
