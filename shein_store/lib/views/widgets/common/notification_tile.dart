import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
  });

  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isRead = notification.isRead;
    final title = _title(context);
    final message = _message(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isRead
                ? colors.surfaceSoft
                : colors.discount.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isRead
                ? Icons.mark_email_read_outlined
                : Icons.notifications_active_outlined,
            size: 20,
            color: isRead ? colors.icon : colors.discount,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: colors.primaryText,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '$message\n${formatShortDate(notification.createdAt)}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              height: 1.35,
              color: colors.secondaryText,
              fontSize: 12,
            ),
          ),
        ),
        isThreeLine: true,
        trailing: IconButton(
          onPressed: onDelete,
          icon: Icon(Icons.delete_outline, color: colors.inactiveIcon),
        ),
      ),
    );
  }

  String _title(BuildContext context) {
    switch (notification.type) {
      case NotificationType.orderPlacedCustomer:
        return context.tr('Order placed', 'تم إنشاء الطلب');
      case NotificationType.newOrderSeller:
        return context.tr('New seller order', 'طلب جديد للبائع');
      case NotificationType.orderProcessing:
        return context.tr('Order is processing', 'الطلب قيد المعالجة');
      case NotificationType.orderShipped:
        return context.tr('Order shipped', 'تم شحن الطلب');
      case NotificationType.orderDelivered:
        return context.tr('Order delivered', 'تم تسليم الطلب');
      case NotificationType.orderCancelled:
        return context.tr('Order cancelled', 'تم إلغاء الطلب');
      case NotificationType.storeReviewed:
        return context.tr('New store review', 'تقييم جديد للمتجر');
      case NotificationType.productApproved:
        return context.tr('Product approved', 'تمت الموافقة على المنتج');
      case NotificationType.productRejected:
        return context.tr('Product rejected', 'تم رفض المنتج');
      case NotificationType.orderConfirmed:
      case NotificationType.returnRequested:
      case NotificationType.refundCompleted:
      case NotificationType.lowStock:
      case NotificationType.genericPromotion:
      case NotificationType.generic:
        return context.isArabic
            ? (notification.data['title_ar'] as String? ??
                  notification.legacyTitle ??
                  'إشعار')
            : (notification.data['title_en'] as String? ??
                  notification.legacyTitle ??
                  'Notification');
    }
  }

  String _message(BuildContext context) {
    switch (notification.type) {
      case NotificationType.orderPlacedCustomer:
        return context.tr(
          'Your order ${notification.data['orderNumber'] ?? notification.entityId} was placed successfully.',
          'تم إنشاء طلبك ${notification.data['orderNumber'] ?? notification.entityId} بنجاح.',
        );
      case NotificationType.newOrderSeller:
        return context.tr(
          'A new order was assigned to your store.',
          'تم تعيين طلب جديد لمتجرك.',
        );
      case NotificationType.storeReviewed:
        return context.tr(
          'A customer added a fresh store rating.',
          'أضاف أحد العملاء تقييماً جديداً للمتجر.',
        );
      case NotificationType.productApproved:
        return context.tr(
          'The product is now live in the public catalog.',
          'المنتج أصبح متاحاً الآن في الكتالوج العام.',
        );
      case NotificationType.productRejected:
        return context.tr(
          'Review the note and update the product before publishing again.',
          'راجع الملاحظة وحدّث المنتج قبل النشر مرة أخرى.',
        );
      case NotificationType.orderProcessing:
      case NotificationType.orderShipped:
      case NotificationType.orderDelivered:
      case NotificationType.orderCancelled:
      case NotificationType.orderConfirmed:
      case NotificationType.returnRequested:
      case NotificationType.refundCompleted:
      case NotificationType.lowStock:
      case NotificationType.genericPromotion:
      case NotificationType.generic:
        return context.isArabic
            ? (notification.data['message_ar'] as String? ??
                  notification.legacyMessage ??
                  'هناك تحديث جديد.')
            : (notification.data['message_en'] as String? ??
                  notification.legacyMessage ??
                  'There is a new update.');
    }
  }
}
