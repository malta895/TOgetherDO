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
      'userId': instance.userId,
      'accepted': instance.accepted,
      'notificationType': instance.notificationType,
    };

ListInviteNotification _$ListInviteNotificationFromJson(
    Map<String, dynamic> json) {
  return ListInviteNotification(
    userId: json['userId'],
    accepted: json['accepted'] as bool,
  )
    ..databaseId = json['databaseId'] as String?
    ..objectId = json['objectId'] as String?;
}

Map<String, dynamic> _$ListInviteNotificationToJson(
        ListInviteNotification instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'objectId': instance.objectId,
      'userId': instance.userId,
      'accepted': instance.accepted,
    };

FriendshipNotification _$FriendshipNotificationFromJson(
    Map<String, dynamic> json) {
  return FriendshipNotification(
    userId: json['userId'],
    accepted: json['accepted'] as bool,
  )
    ..databaseId = json['databaseId'] as String?
    ..objectId = json['objectId'] as String?;
}

Map<String, dynamic> _$FriendshipNotificationToJson(
        FriendshipNotification instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'objectId': instance.objectId,
      'userId': instance.userId,
      'accepted': instance.accepted,
    };
