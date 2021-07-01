import 'dart:core';

import 'package:json_annotation/json_annotation.dart';
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

@JsonSerializable(createFactory: false)
abstract class ListAppNotification {
  static const String collectionName = 'notifications';

  String? databaseId;
  String? objectId;
  String? listOwner;
  final String userId;
  final String userFrom;

  final String notificationType;

  final NotificationStatus status;

  @JsonKey(ignore: true)
  ListAppUser? sender;

  ListAppNotification(
      {this.databaseId,
      this.objectId,
      this.listOwner,
      required this.userId,
      required this.userFrom,
      required this.status,
      required this.notificationType});

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
    switch (this.notificationType) {
      case 'listInvite':
        return (this as ListInviteNotification).toJson();
      case 'friendship':
        return (this as FriendshipNotification).toJson();

      default:
        throw StateError("Item type not recognized");
    }
  }
}

@JsonSerializable() // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class ListInviteNotification extends ListAppNotification {
  ListInviteNotification(
      {required userId,
      required userFrom,
      required NotificationStatus status,
      required listOwner})
      : super(
            notificationType: 'listInvite',
            userId: userId,
            listOwner: listOwner,
            userFrom: userFrom,
            status: status);

  factory ListInviteNotification.fromJson(Map<String, dynamic> json) =>
      _$ListInviteNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$ListInviteNotificationToJson(this);
}

@JsonSerializable() // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class FriendshipNotification extends ListAppNotification {
  FriendshipNotification(
      {required userId, required userFrom, required NotificationStatus status})
      : super(
            notificationType: 'friendship',
            userId: userId,
            userFrom: userFrom,
            status: status);

  factory FriendshipNotification.fromJson(Map<String, dynamic> json) =>
      _$FriendshipNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$FriendshipNotificationToJson(this);
}
