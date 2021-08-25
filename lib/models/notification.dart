import 'dart:core';

import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/base_model.dart';
import 'package:mobile_applications/models/user.dart';
// ignore: unused_import
import 'package:mobile_applications/models/utils.dart';

part 'notification.g.dart';

/// The notification status
enum NotificationStatus {
  /// The notification has been sent to the recipient, but no action has been taken yet
  pending,

  /// The notification has been accepted by the recipient
  accepted,

  /// The notification has been rejected by the recipient
  rejected
}

extension ParseToString on NotificationStatus {
  String toReadableString() {
    switch (this) {
      case NotificationStatus.pending:
        return 'Pending';
      case NotificationStatus.accepted:
        return 'Accepted';
      case NotificationStatus.rejected:
        return 'Rejected';
    }
  }
}

enum NotificationType { friendship, listInvite }

@JsonSerializable(checked: true, createFactory: false)
abstract class ListAppNotification extends BaseModel {
  static const String collectionName = 'notifications';
  final String userId;
  final String userFrom;

  final NotificationType notificationType;

  NotificationStatus status;

  @JsonKey(ignore: true)
  ListAppUser? sender;

  ListAppNotification({
    String? databaseId,
    required this.userId,
    required this.userFrom,
    this.status = NotificationStatus.pending,
    required this.notificationType,
    DateTime? createdAt,
  }) : super(
          databaseId: databaseId,
          createdAt: createdAt,
        );

  factory ListAppNotification.fromJson(Map<String, dynamic> json) {
    switch (json['notificationType'] as String) {
      case 'listInvite':
        return ListInviteNotification.fromJson(json);
      case 'friendship':
        return FriendshipNotification.fromJson(json);

      default:
        throw StateError("Item type not recognized");
    }
  }

  Map<String, dynamic> toJson() {
    final baseNotificationToJson = _$ListAppNotificationToJson(this);
    switch (this.notificationType) {
      case NotificationType.listInvite:
        return _$ListInviteNotificationToJson(this as ListInviteNotification)
          ..addAll(baseNotificationToJson);
      case NotificationType.friendship:
        return _$FriendshipNotificationToJson(this as FriendshipNotification)
          ..addAll(baseNotificationToJson);
    }
  }
}

@JsonSerializable(
  checked: true,
) // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class ListInviteNotification extends ListAppNotification {
  String listId;
  String listOwner;

  ListInviteNotification({
    required userId,
    required userFrom,
    required NotificationStatus status,
    required this.listOwner,
    required this.listId,
    databaseId,
    createdAt,
  }) : super(
            createdAt: createdAt,
            databaseId: databaseId,
            notificationType: NotificationType.listInvite,
            userId: userId,
            userFrom: userFrom,
            status: status);

  factory ListInviteNotification.fromJson(Map<String, dynamic> json) =>
      _$ListInviteNotificationFromJson(json);
}

@JsonSerializable(
  checked: true,
) // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class FriendshipNotification extends ListAppNotification {
  String friendshipId;

  FriendshipNotification({
    required userId,
    required userFrom,
    NotificationStatus status = NotificationStatus.pending,
    required this.friendshipId,
    databaseId,
    DateTime? createdAt,
  }) : super(
            createdAt: createdAt,
            databaseId: databaseId,
            notificationType: NotificationType.friendship,
            userId: userId,
            userFrom: userFrom,
            status: status);

  factory FriendshipNotification.fromJson(Map<String, dynamic> json) =>
      _$FriendshipNotificationFromJson(json);
}
