class CatalogConfig {
  const CatalogConfig._();

  static const bool hideUnavailableProducts = false;
  static const bool showUnavailableBadge = true;
  static const bool showUnavailableProducts =
      !hideUnavailableProducts && showUnavailableBadge;
}
