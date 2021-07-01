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
      'notificationType': instance.notificationType,
      'status': _$NotificationStatusEnumMap[instance.status],
    };

const _$NotificationStatusEnumMap = {
  NotificationStatus.undefined: 'undefined',
  NotificationStatus.accepted: 'accepted',
  NotificationStatus.rejected: 'rejected',
};

ListInviteNotification _$ListInviteNotificationFromJson(
    Map<String, dynamic> json) {
  return ListInviteNotification(
    userId: json['userId'],
    userFrom: json['userFrom'],
    status: _$enumDecode(_$NotificationStatusEnumMap, json['status']),
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
      'status': _$NotificationStatusEnumMap[instance.status],
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

FriendshipNotification _$FriendshipNotificationFromJson(
    Map<String, dynamic> json) {
  return FriendshipNotification(
    userId: json['userId'],
    userFrom: json['userFrom'],
    status: _$enumDecode(_$NotificationStatusEnumMap, json['status']),
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
      'status': _$NotificationStatusEnumMap[instance.status],
    };
