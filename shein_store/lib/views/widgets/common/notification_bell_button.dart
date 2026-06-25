import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/notification_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';

class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Selector<NotificationController, int>(
      selector: (_, controller) => controller.unreadCount,
      builder: (context, unreadCount, _) {
        final label = unreadCount > 99 ? '99+' : '$unreadCount';
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: context.tr('Notifications', 'الإشعارات'),
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.notifications),
              icon: const Icon(Icons.notifications_none_outlined),
            ),
            if (unreadCount > 0)
              PositionedDirectional(
                top: 6,
                end: 6,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    constraints: const BoxConstraints(minWidth: 18),
                    decoration: BoxDecoration(
                      color: colors.discount,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
