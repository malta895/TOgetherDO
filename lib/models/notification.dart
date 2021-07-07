import 'dart:core';

import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/base_model.dart';
import 'package:mobile_applications/models/user.dart';

part 'notification.g.dart';

/// The notification status
enum NotificationStatus { undefined, accepted, rejected }

extension ParseToString on NotificationStatus {
  String toReadableString() {
    switch (this) {
      case NotificationStatus.undefined:
        return 'undefined';
      case NotificationStatus.accepted:
        return 'accepted';
      case NotificationStatus.rejected:
        return 'rejected';
    }
  }
}

@JsonSerializable(checked: true, createFactory: false)
abstract class ListAppNotification extends BaseModel {
  static const String collectionName = 'notifications';
  final String userId;
  final String userFrom;

  int? createdAt;

  final String notificationType;

  final NotificationStatus status;

  @JsonKey(ignore: true)
  ListAppUser? sender;

  ListAppNotification({
    String? databaseId,
    required this.userId,
    this.createdAt,
    required this.userFrom,
    required this.status,
    required this.notificationType,
  }) : super(databaseId);

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
      case 'listInvite':
        return _$ListInviteNotificationToJson(this as ListInviteNotification)
          ..addAll(baseNotificationToJson);
      case 'friendship':
        return _$FriendshipNotificationToJson(this as FriendshipNotification)
          ..addAll(baseNotificationToJson);

      default:
        throw StateError("Item type not recognized");
    }
  }
}

@JsonSerializable(
  checked: true,
) // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class ListInviteNotification extends ListAppNotification {
  String listId;
  String listOwner;

  ListInviteNotification(
      {required userId,
      required userFrom,
      required NotificationStatus status,
      required this.listOwner,
      required this.listId,
      databaseId,
      createdAt})
      : super(
            databaseId: databaseId,
            createdAt: createdAt,
            notificationType: 'listInvite',
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

  FriendshipNotification(
      {required userId,
      required userFrom,
      required NotificationStatus status,
      required this.friendshipId,
      databaseId,
      createdAt})
      : super(
            databaseId: databaseId,
            createdAt: createdAt,
            notificationType: 'friendship',
            userId: userId,
            userFrom: userFrom,
            status: status);

  factory FriendshipNotification.fromJson(Map<String, dynamic> json) =>
      _$FriendshipNotificationFromJson(json);
}
