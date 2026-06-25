import 'package:flutter/material.dart';

import '../extensions/localization_extension.dart';
import '../../models/product_status.dart';

String localizedOrderStatus(BuildContext context, String status) {
  switch (status) {
    case 'All':
      return context.l10n.statusAll;
    case 'New':
    case 'Pending':
    case 'Unpaid':
      return context.l10n.statusNew;
    case 'Processing':
      return context.l10n.statusProcessing;
    case 'Ready to Ship':
      return context.l10n.statusReadyToShip;
    case 'Shipped':
      return context.l10n.statusShipped;
    case 'Delivered':
      return context.l10n.statusDelivered;
    case 'Cancelled':
      return context.l10n.statusCancelled;
    case 'Returned':
    case 'Review':
      return context.l10n.statusReturned;
    case 'Paid':
      return context.l10n.statusPaid;
    default:
      return status;
  }
}

String localizedSellerProductStatus(
  BuildContext context,
  ProductStatus status,
) {
  switch (status) {
    case ProductStatus.active:
      return context.l10n.statusActive;
    case ProductStatus.pendingApproval:
      return context.l10n.statusPendingApproval;
    case ProductStatus.rejected:
      return context.l10n.statusRejected;
    case ProductStatus.outOfStock:
      return context.l10n.statusOutOfStock;
    case ProductStatus.draft:
      return context.l10n.statusDraft;
    case ProductStatus.inactive:
      return context.l10n.statusInactiveProduct;
    case ProductStatus.submitted:
      return context.l10n.statusSubmittedProduct;
    case ProductStatus.automatedReview:
      return context.l10n.statusAutomatedReview;
    case ProductStatus.manualReview:
      return context.l10n.statusManualReview;
    case ProductStatus.informationRequired:
      return context.l10n.statusInformationRequired;
    case ProductStatus.restricted:
      return context.l10n.statusRestrictedProduct;
    case ProductStatus.suspended:
      return context.l10n.statusSuspendedProduct;
    case ProductStatus.recalled:
      return context.l10n.statusRecalledProduct;
    case ProductStatus.archived:
      return context.l10n.statusArchivedProduct;
    case ProductStatus.deleted:
      return context.l10n.statusDeletedProduct;
  }
}
