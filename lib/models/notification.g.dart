// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$ListAppNotificationToJson(
        ListAppNotification instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'objectId': instance.objectId,
      'listOwner': instance.listOwner,
      'userId': instance.userId,
      'userFrom': instance.userFrom,
      'accepted': instance.accepted,
      'notificationType': instance.notificationType,
    };

ListInviteNotification _$ListInviteNotificationFromJson(
    Map<String, dynamic> json) {
  return ListInviteNotification(
    userId: json['userId'],
    userFrom: json['userFrom'],
    accepted: json['accepted'] as bool,
    listOwner: json['listOwner'],
  )
    ..databaseId = json['databaseId'] as String?
    ..objectId = json['objectId'] as String?;
}

Map<String, dynamic> _$ListInviteNotificationToJson(
        ListInviteNotification instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'objectId': instance.objectId,
      'listOwner': instance.listOwner,
      'userId': instance.userId,
      'userFrom': instance.userFrom,
      'accepted': instance.accepted,
    };

FriendshipNotification _$FriendshipNotificationFromJson(
    Map<String, dynamic> json) {
  return FriendshipNotification(
    userId: json['userId'],
    userFrom: json['userFrom'],
    accepted: json['accepted'] as bool,
  )
    ..databaseId = json['databaseId'] as String?
    ..objectId = json['objectId'] as String?
    ..listOwner = json['listOwner'] as String?;
}

Map<String, dynamic> _$FriendshipNotificationToJson(
        FriendshipNotification instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'objectId': instance.objectId,
      'listOwner': instance.listOwner,
      'userId': instance.userId,
      'userFrom': instance.userFrom,
      'accepted': instance.accepted,
    };
