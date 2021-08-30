import 'dart:core';

import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/base_model.dart';
import 'package:mobile_applications/models/list.dart';
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

enum NotificationType {
  /// A friendship request notification
  friendship,

  /// A notification sent after being invited to a list
  listInvite,
}

enum NotificationReadStatus {
  /// The notification has never been viewed in the notification page
  unread,

  /// The notification is opened on screen
  opened,

  /// The notification has been read, and is not shown anymore among the new ones
  read
}

enum FriendshipRequestMethod {
  /// the friendship has been requested by username
  username,

  /// the friendship has been requested by email
  email
}

@JsonSerializable(checked: true, createFactory: false)
abstract class ListAppNotification extends BaseModel {
  static const String collectionName = 'notifications';
  final String userToId;
  final String userFromId;

  final NotificationType notificationType;

  /// The status of the notification regarding its acceptance
  NotificationStatus status;

  NotificationReadStatus readStatus;

  //fields to be injected
  @JsonKey(ignore: true)
  ListAppUser? userTo;

  @JsonKey(ignore: true)
  ListAppUser? userFrom;

  ListAppNotification({
    String? databaseId,
    required this.userToId,
    required this.userFromId,
    this.status = NotificationStatus.pending,
    required this.notificationType,
    this.readStatus = NotificationReadStatus.unread,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          databaseId: databaseId,
          createdAt: createdAt,
          updatedAt: updatedAt,
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
  String listOwnerId;

  @JsonKey(ignore: true)
  ListAppList? list;

  ListInviteNotification({
    required userToId,
    required userFromId,
    required NotificationStatus status,
    required this.listOwnerId,
    required this.listId,
    databaseId,
    NotificationReadStatus? readStatus,
    createdAt,
    updatedAt,
  }) : super(
          databaseId: databaseId,
          notificationType: NotificationType.listInvite,
          userToId: userToId,
          userFromId: userFromId,
          status: status,
          readStatus: readStatus ?? NotificationReadStatus.unread,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory ListInviteNotification.fromJson(Map<String, dynamic> json) =>
      _$ListInviteNotificationFromJson(json);
}

@JsonSerializable(
  checked: true,
)
class FriendshipNotification extends ListAppNotification {
  FriendshipRequestMethod friendshipRequestMethod;

  FriendshipNotification({
    required userToId,
    required userFromId,
    required this.friendshipRequestMethod,
    NotificationStatus status = NotificationStatus.pending,
    String? databaseId,
    NotificationReadStatus? readStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          createdAt: createdAt,
          databaseId: databaseId,
          notificationType: NotificationType.friendship,
          userToId: userToId,
          userFromId: userFromId,
          status: status,
          readStatus: readStatus ?? NotificationReadStatus.unread,
          updatedAt: updatedAt,
        );

  factory FriendshipNotification.fromJson(Map<String, dynamic> json) =>
      _$FriendshipNotificationFromJson(json);
}
