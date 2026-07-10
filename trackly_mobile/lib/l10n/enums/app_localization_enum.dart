enum AppLocalizationEnum {
  arabic(
    lang: 'ar',
    country: 'SA',
  ),
  english(
    lang: 'en',
    country: 'US',
  ),
  ;

  final String lang;
  final String country;

  const AppLocalizationEnum({
    required this.lang,
    required this.country,
  });

  String get localeKey => '${lang}_$country';

  static List<String> get rtlLanguages => [
    arabic.lang,
  ];
}
