class AppPreferencesModel {
  const AppPreferencesModel({
    required this.country,
    required this.language,
    required this.currency,
    this.notificationsEnabled = false,
    this.hasSeenOnboarding = false,
    this.themeMode = 'system',
  });

  final String country;
  final String language;
  final String currency;
  final bool notificationsEnabled;
  final bool hasSeenOnboarding;
  final String themeMode;

  AppPreferencesModel copyWith({
    String? country,
    String? language,
    String? currency,
    bool? notificationsEnabled,
    bool? hasSeenOnboarding,
    String? themeMode,
  }) {
    return AppPreferencesModel(
      country: country ?? this.country,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  factory AppPreferencesModel.fromJson(Map<String, dynamic> json) {
    return AppPreferencesModel(
      country: json['country'] as String? ?? 'United States',
      language: json['language'] as String? ?? 'English',
      currency: json['currency'] as String? ?? 'USD',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      hasSeenOnboarding: json['hasSeenOnboarding'] as bool? ?? false,
      themeMode: json['themeMode'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toJson() => {
    'country': country,
    'language': language,
    'currency': currency,
    'notificationsEnabled': notificationsEnabled,
    'hasSeenOnboarding': hasSeenOnboarding,
    'themeMode': themeMode,
  };
}
