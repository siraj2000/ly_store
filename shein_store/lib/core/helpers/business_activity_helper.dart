import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

const List<String> businessActivityTypeIds = [
  'clothing',
  'shoes',
  'bags',
  'beauty',
  'makeup',
  'electronics',
  'home',
  'accessories',
  'jewelry',
  'kids',
  'sports',
  'perfumes',
  'appliances',
  'mixed',
];

String localizedBusinessActivity(BuildContext context, String id) {
  final l10n = AppLocalizations.of(context)!;
  switch (id) {
    case 'clothing':
      return l10n.businessClothing;
    case 'shoes':
      return l10n.businessShoes;
    case 'bags':
      return l10n.businessBags;
    case 'beauty':
      return l10n.businessBeauty;
    case 'makeup':
      return l10n.businessMakeup;
    case 'electronics':
      return l10n.businessElectronics;
    case 'home':
      return l10n.businessHome;
    case 'accessories':
      return l10n.businessAccessories;
    case 'jewelry':
      return l10n.businessJewelry;
    case 'kids':
      return l10n.businessKids;
    case 'sports':
      return l10n.businessSports;
    case 'perfumes':
      return l10n.businessPerfumes;
    case 'appliances':
      return l10n.businessAppliances;
    default:
      return l10n.businessMixed;
  }
}
