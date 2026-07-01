import 'package:flutter/widgets.dart';

import '../extensions/localization_extension.dart';

String localizedAuthError(BuildContext context, String? key) {
  switch (key) {
    case 'full_name_required':
      return context.tr('Full name is required', 'الاسم الكامل مطلوب');
    case 'full_name_two_words_required':
      return context.tr(
        'Please enter your first and last name',
        'الرجاء إدخال الاسم الأول واسم العائلة',
      );
    case 'invalid_phone_number':
      return context.tr('Invalid phone number', 'رقم الهاتف غير صحيح');
    case 'phone_already_registered':
      return context.tr(
        'Phone number already registered',
        'رقم الهاتف مسجل مسبقاً',
      );
    case 'phone_not_registered':
      return context.tr('Phone number not registered', 'رقم الهاتف غير مسجل');
    case 'invalid_phone_or_password':
    case 'invalid_credentials':
      return context.tr(
        'Invalid phone number or password',
        'رقم الهاتف أو الرمز السري غير صحيح',
      );
    case 'phone_not_verified':
      return context.tr(
        'Please verify your phone number before signing in',
        'يرجى التحقق من رقم الهاتف قبل تسجيل الدخول',
      );
    case 'otp_required':
      return context.tr('OTP is required', 'رمز التحقق مطلوب');
    case 'otp_must_be_6_digits':
      return context.tr(
        'OTP must be 6 digits',
        'رمز التحقق يجب أن يتكون من 6 أرقام',
      );
    case 'invalid_otp':
      return context.tr('Invalid OTP', 'رمز التحقق غير صحيح');
    case 'otp_expired':
      return context.tr(
        'OTP expired. Please resend the code.',
        'انتهت صلاحية رمز التحقق. يرجى إعادة الإرسال.',
      );
    case 'too_many_attempts':
      return context.tr('Too many attempts', 'عدد محاولات كبير');
    case 'otp_not_verified':
      return context.tr('Verify your phone first', 'تحقق من رقم الهاتف أولاً');
    case 'password_required':
      return context.tr('Password is required', 'الرمز السري مطلوب');
    case 'weak_password':
      return context.tr(
        'Password must be at least 6 characters',
        'يجب أن يكون الرمز السري 6 أحرف على الأقل',
      );
    case 'passwords_do_not_match':
      return context.tr('Passwords do not match', 'الرمزان غير متطابقين');
    case 'account_suspended':
      return context.tr('This account is suspended', 'هذا الحساب موقوف');
    case 'seller_suspended':
      return context.tr('Seller account is suspended', 'حساب البائع موقوف');
    case 'seller_pending':
      return context.tr(
        'Seller account is waiting for approval',
        'حساب البائع بانتظار الموافقة',
      );
    case 'admin_separate_app':
      return context.tr(
        'Admin access is available in the separate Admin app',
        'دخول الإدارة متاح من تطبيق الإدارة المنفصل',
      );
    case 'account_not_found':
      return context.tr('Account not found', 'الحساب غير موجود');
    default:
      return context.tr(
        'Something went wrong. Please try again.',
        'حدث خطأ. الرجاء المحاولة مرة أخرى.',
      );
  }
}
