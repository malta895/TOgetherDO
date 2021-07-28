// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$ListAppNotificationToJson(
        ListAppNotification instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'createdAt': ModelUtils.dateTimeToJson(instance.createdAt),
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
  return $checkedNew('ListInviteNotification', json, () {
    final val = ListInviteNotification(
      userId: $checkedConvert(json, 'userId', (v) => v),
      userFrom: $checkedConvert(json, 'userFrom', (v) => v),
      status: $checkedConvert(
          json, 'status', (v) => _$enumDecode(_$NotificationStatusEnumMap, v)),
      listOwner: $checkedConvert(json, 'listOwner', (v) => v as String),
      listId: $checkedConvert(json, 'listId', (v) => v as String),
      databaseId: $checkedConvert(json, 'databaseId', (v) => v),
      createdAt: $checkedConvert(
          json, 'createdAt', (v) => ModelUtils.dateTimeFromJson(v as int)),
    );
    return val;
  });
}

Map<String, dynamic> _$ListInviteNotificationToJson(
        ListInviteNotification instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'createdAt': ModelUtils.dateTimeToJson(instance.createdAt),
      'userId': instance.userId,
      'userFrom': instance.userFrom,
      'status': _$NotificationStatusEnumMap[instance.status],
      'listId': instance.listId,
      'listOwner': instance.listOwner,
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
  return $checkedNew('FriendshipNotification', json, () {
    final val = FriendshipNotification(
      userId: $checkedConvert(json, 'userId', (v) => v),
      userFrom: $checkedConvert(json, 'userFrom', (v) => v),
      status: $checkedConvert(
          json, 'status', (v) => _$enumDecode(_$NotificationStatusEnumMap, v)),
      friendshipId: $checkedConvert(json, 'friendshipId', (v) => v as String),
      databaseId: $checkedConvert(json, 'databaseId', (v) => v),
      createdAt: $checkedConvert(
          json, 'createdAt', (v) => ModelUtils.dateTimeFromJson(v as int)),
    );
    return val;
  });
}

Map<String, dynamic> _$FriendshipNotificationToJson(
        FriendshipNotification instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'createdAt': ModelUtils.dateTimeToJson(instance.createdAt),
      'userId': instance.userId,
      'userFrom': instance.userFrom,
      'status': _$NotificationStatusEnumMap[instance.status],
      'friendshipId': instance.friendshipId,
    };
