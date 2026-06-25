import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/notification_controller.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationController>(
      builder: (context, notificationController, _) => Scaffold(
        appBar: AppHeader(
          title: context.tr('Notifications', 'الإشعارات'),
          actions: [
            if (notificationController.notifications.isNotEmpty)
              TextButton(
                onPressed: notificationController.markAllAsRead,
                child: Text(
                  context.tr('Mark All as Read', 'تحديد الكل كمقروء'),
                ),
              ),
          ],
        ),
        body: notificationController.notifications.isEmpty
            ? AppEmptyState(
                title: context.tr(
                  'No notifications yet',
                  'لا توجد إشعارات بعد',
                ),
                message: context.tr(
                  'Order updates, price drops, and app alerts appear here.',
                  'ستظهر هنا تحديثات الطلبات وانخفاض الأسعار وتنبيهات التطبيق.',
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(AppSizes.lg),
                children: notificationController.notifications
                    .map(
                      (notification) => NotificationTile(
                        notification: notification,
                        onTap: () {
                          notificationController.markAsRead(notification.id);
                          if (notification.route == AppRoutes.orderDetails) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.orderDetails,
                              arguments:
                                  notification.data['masterOrderId'] ??
                                  notification.entityId,
                            );
                            return;
                          }
                          if (notification.route ==
                              AppRoutes.sellerOrderDetails) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.sellerOrderDetails,
                              arguments:
                                  notification.data['sellerOrderId'] ??
                                  notification.entityId,
                            );
                            return;
                          }
                          if (notification.route == AppRoutes.storefront) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.storefront,
                              arguments:
                                  notification.data['storeId'] ??
                                  notification.entityId,
                            );
                          }
                        },
                        onDelete: () =>
                            notificationController.delete(notification.id),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}
