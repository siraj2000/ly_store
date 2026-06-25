import 'package:flutter/material.dart';

import '../../controllers/admin_seller_controller.dart';
import '../../l10n/generated/app_localizations.dart';

String localizedAdminSellerMessage(BuildContext context, String key) {
  final l10n = AppLocalizations.of(context)!;
  switch (key) {
    case 'adminUnableToLoadSellers':
      return l10n.adminUnableToLoadSellers;
    case 'adminSellerPermissionDenied':
      return l10n.adminSellerPermissionDenied;
    case 'adminSellerValidationFailed':
      return l10n.adminSellerValidationFailed;
    case 'adminSellerCreateFailed':
      return l10n.adminSellerCreateFailed;
    case 'adminSellerNotFound':
      return l10n.adminSellerNotFound;
    case 'adminSellerUpdateFailed':
      return l10n.adminSellerUpdateFailed;
    case 'adminSellerUpdatedSuccessfully':
      return l10n.adminSellerUpdatedSuccessfully;
    case 'adminSellerStatusChangeFailed':
      return l10n.adminSellerStatusChangeFailed;
    case 'adminSellerPasswordResetFailed':
      return l10n.adminSellerPasswordResetFailed;
    case 'adminSellerPasswordResetSuccess':
      return l10n.adminSellerPasswordResetSuccess;
    case 'validationSellerNameRequired':
      return l10n.validationSellerNameRequired;
    case 'validationSellerNameMin':
      return l10n.validationSellerNameMin;
    case 'validationSellerEmailRequired':
      return l10n.validationSellerEmailRequired;
    case 'validationSellerEmailInvalid':
      return l10n.validationSellerEmailInvalid;
    case 'validationSellerPhoneRequired':
      return l10n.validationSellerPhoneRequired;
    case 'validationSellerPasswordMin':
      return l10n.validationSellerPasswordMin;
    case 'validationSellerConfirmPasswordRequired':
      return l10n.validationSellerConfirmPasswordRequired;
    case 'validationStoreNameArRequired':
      return l10n.validationStoreNameArRequired;
    case 'validationStoreNameEnRequired':
      return l10n.validationStoreNameEnRequired;
    case 'validationStorePhoneRequired':
      return l10n.validationStorePhoneRequired;
    case 'validationStoreAddressArRequired':
      return l10n.validationStoreAddressArRequired;
    case 'validationStoreAddressEnRequired':
      return l10n.validationStoreAddressEnRequired;
    case 'validationCityRequired':
      return l10n.validationCityRequired;
    case 'validationCountryRequired':
      return l10n.validationCountryRequired;
    case 'validationEmailAlreadyExists':
      return l10n.validationEmailAlreadyExists;
    case 'validationSelectBusinessActivity':
      return l10n.validationSelectBusinessActivity;
    case 'validationPasswordsDoNotMatch':
      return l10n.validationPasswordsDoNotMatch;
    case 'validationInvalidCommission':
      return l10n.validationInvalidCommission;
    case 'seller_suspended':
      return l10n.authErrorSellerSuspended;
    case 'seller_pending':
      return l10n.authErrorSellerPending;
    case 'invalid_credentials':
      return l10n.authErrorInvalidCredentials;
    case 'admin_separate_app':
      return Localizations.localeOf(context).languageCode == 'ar'
          ? 'دخول الإدارة متاح من خلال تطبيق الإدارة المنفصل.'
          : 'Admin access is available in the separate Admin application.';
    default:
      return key;
  }
}

String localizedSellerAccountStatus(
  BuildContext context,
  SellerAccountStatus status,
) {
  final l10n = AppLocalizations.of(context)!;
  switch (status) {
    case SellerAccountStatus.active:
      return l10n.adminStatusActive;
    case SellerAccountStatus.pending:
      return l10n.adminStatusPending;
    case SellerAccountStatus.suspended:
      return l10n.adminStatusSuspended;
  }
}

String localizedSellerAccountStatusId(BuildContext context, String statusId) {
  return localizedSellerAccountStatus(
    context,
    SellerAccountStatusX.fromId(statusId),
  );
}
