import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/models/list.dart';
import 'dart:core';
import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable(createFactory: false)
abstract class ListAppNotification {
  static const String collectionName = 'notifications';

  String? databaseId;
  String? objectId;
  final String userId;
  final bool accepted;

  final String notificationType;

  ListAppNotification(
      {this.databaseId,
      this.objectId,
      required this.userId,
      required this.accepted,
      required this.notificationType});

  factory ListAppNotification.fromJson(Map<String, dynamic> json) {
    switch (json['notificationType'] as String) {
      case 'ListInviteNotification':
        return ListInviteNotification.fromJson(json);
      case 'FriendshipNotification':
        return FriendshipNotification.fromJson(json);

      default:
        throw StateError("Item type not recognized");
    }
  }
  Map<String, dynamic> toJson() {
    switch (this.notificationType) {
      case 'ListInviteNotification':
        return (this as ListInviteNotification).toJson();
      case 'FriendshipNotification':
        return (this as FriendshipNotification).toJson();

      default:
        throw StateError("Item type not recognized");
    }
  }
}

@JsonSerializable() // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class ListInviteNotification extends ListAppNotification {
  ListInviteNotification({required userId, required bool accepted})
      : super(
            notificationType: 'ListInviteNotification',
            userId: userId,
            accepted: accepted);

  factory ListInviteNotification.fromJson(Map<String, dynamic> json) =>
      _$ListInviteNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$ListInviteNotificationToJson(this);
}

@JsonSerializable() // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class FriendshipNotification extends ListAppNotification {
  FriendshipNotification({required userId, required bool accepted})
      : super(
            notificationType: 'FriendshipNotification',
            userId: userId,
            accepted: accepted);

  factory FriendshipNotification.fromJson(Map<String, dynamic> json) =>
      _$FriendshipNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$FriendshipNotificationToJson(this);
}
