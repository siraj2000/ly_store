import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../models/user_role.dart';
import '../services/mock_data_service.dart';
import 'auth_controller.dart';

class NotificationController extends ChangeNotifier {
  NotificationController({required MockDataService mockDataService})
    : _mockDataService = mockDataService {
    _mockDataService.addListener(_handleServiceChanged);
  }

  final MockDataService _mockDataService;
  AuthController? _authController;
  List<NotificationModel> _notifications = [];
  String? _boundUserId;
  UserRole? _boundRole;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((item) => !item.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get hasUnreadNotifications => unreadCount > 0;

  void bind({required AuthController authController}) {
    _authController = authController;
    final nextUserId = authController.currentUser?.id;
    final nextRole = authController.currentRole;
    if (_boundUserId != nextUserId || _boundRole != nextRole) {
      _boundUserId = nextUserId;
      _boundRole = nextRole;
      loadForCurrentUser();
      return;
    }
    notifyListeners();
  }

  void loadForCurrentUser() {
    final currentUser = _authController?.currentUser;
    if (currentUser == null || currentUser.role == UserRole.guest) {
      _notifications = _mockDataService.notificationsForUser('');
    } else {
      _notifications = _mockDataService.notificationsForUser(currentUser.id);
    }
    notifyListeners();
  }

  void createForUser(NotificationModel notification) {
    _mockDataService.createNotification(notification);
    if (notification.recipientUserId ==
        (_authController?.currentUser?.id ?? '')) {
      loadForCurrentUser();
    }
  }

  void markAsRead(String id) {
    _mockDataService.markNotificationRead(id);
    _notifications = _notifications
        .map(
          (item) => item.id == id
              ? item.copyWith(isRead: true, readAt: DateTime.now())
              : item,
        )
        .toList();
    notifyListeners();
  }

  void markAllAsRead() {
    final currentUser = _authController?.currentUser;
    _mockDataService.markAllNotificationsRead(currentUser?.id ?? '');
    loadForCurrentUser();
  }

  void delete(String id) {
    _mockDataService.deleteNotification(id);
    _notifications = _notifications.where((item) => item.id != id).toList();
    notifyListeners();
  }

  void clearAll() {
    final currentUser = _authController?.currentUser;
    _mockDataService.clearNotifications(currentUser?.id ?? '');
    _notifications = const [];
    notifyListeners();
  }

  void _handleServiceChanged() {
    if (_boundUserId == (_authController?.currentUser?.id)) {
      loadForCurrentUser();
    }
  }

  @override
  void dispose() {
    _mockDataService.removeListener(_handleServiceChanged);
    super.dispose();
  }
}
