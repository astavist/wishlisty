import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Mark all as read
            },
            child: Text(
              'Mark all read',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final notifications = userProvider.notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Notifications',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re all caught up! New notifications will appear here.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: notification.isRead ? Colors.white : AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: notification.isRead 
                      ? null 
                      : Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getNotificationColor(notification.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationColor(notification.type),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textGray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(notification.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  trailing: !notification.isRead 
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                  onTap: () {
                    // TODO: Handle notification tap
                    if (!notification.isRead) {
                      userProvider.markNotificationAsRead(notification.id);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getNotificationIcon(dynamic type) {
    // Convert string to enum-like logic
    switch (type.toString()) {
      case 'NotificationType.friendRequest':
        return Icons.person_add;
      case 'NotificationType.friendAccepted':
        return Icons.people;
      case 'NotificationType.wishLiked':
        return Icons.favorite;
      case 'NotificationType.wishCommented':
        return Icons.chat_bubble;
      case 'NotificationType.wishPinned':
        return Icons.bookmark;
      case 'NotificationType.mention':
        return Icons.alternate_email;
      case 'NotificationType.giftPurchased':
        return Icons.card_giftcard;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(dynamic type) {
    switch (type.toString()) {
      case 'NotificationType.friendRequest':
      case 'NotificationType.friendAccepted':
        return AppColors.primary;
      case 'NotificationType.wishLiked':
        return AppColors.error;
      case 'NotificationType.wishCommented':
      case 'NotificationType.mention':
        return AppColors.secondary;
      case 'NotificationType.wishPinned':
        return AppColors.accent;
      case 'NotificationType.giftPurchased':
        return AppColors.success;
      default:
        return AppColors.textGray;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 