class AppConstants {
  // Hive box names
  static const String settingsBox = 'settings';
  static const String tripsBox = 'trips';
  
  // Settings keys
  static const String themeKey = 'theme';
  static const String languageKey = 'language';
  
  // Trip fields
  static const String tripId = 'id';
  static const String tripName = 'name';
  static const String tripDestination = 'destination';
  static const String tripStartDate = 'startDate';
  static const String tripEndDate = 'endDate';
  static const String tripBudget = 'budget';
  static const String tripNotes = 'notes';
  static const String tripImageUrls = 'imageUrls';
  static const String tripUserId = 'userId';
  static const String tripCreatedAt = 'createdAt';
  
  // Firestore collections
  static const String usersCollection = 'users';
  static const String tripsCollection = 'trips';
  static const String settingsCollection = 'settings';
  
  // Default values
  static const String defaultLanguage = 'kk';
  
  // Assets paths
  static const String imagePath = 'assets/images/';
  static const String logoPath = '${imagePath}logo.png';

  // Validation constants
  static const int minPasswordLength = 6;
} 