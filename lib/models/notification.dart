import 'dart:core';

import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/user.dart';

part 'notification.g.dart';

@JsonSerializable(createFactory: false)
abstract class ListAppNotification {
  static const String collectionName = 'notifications';

  String? databaseId;
  String? objectId;
  String? listOwner;
  final String userId;
  final String userFrom;
  final bool accepted;

  final String notificationType;

  @JsonKey(ignore: true)
  ListAppUser? sender;

  ListAppNotification(
      {this.databaseId,
      this.objectId,
      this.listOwner,
      required this.userId,
      required this.userFrom,
      required this.accepted,
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
      required bool accepted,
      required listOwner})
      : super(
            notificationType: 'listInvite',
            userId: userId,
            listOwner: listOwner,
            userFrom: userFrom,
            accepted: accepted);

  factory ListInviteNotification.fromJson(Map<String, dynamic> json) =>
      _$ListInviteNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$ListInviteNotificationToJson(this);
}

@JsonSerializable() // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class FriendshipNotification extends ListAppNotification {
  FriendshipNotification(
      {required userId, required userFrom, required bool accepted})
      : super(
            notificationType: 'friendship',
            userId: userId,
            userFrom: userFrom,
            accepted: accepted);

  factory FriendshipNotification.fromJson(Map<String, dynamic> json) =>
      _$FriendshipNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$FriendshipNotificationToJson(this);
}
