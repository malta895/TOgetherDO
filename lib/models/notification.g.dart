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
      'updatedAt': ModelUtils.nullableDateTimeToJson(instance.updatedAt),
      'userToId': instance.userToId,
      'userFromId': instance.userFromId,
      'notificationType': _$NotificationTypeEnumMap[instance.notificationType],
      'status': _$NotificationStatusEnumMap[instance.status],
      'isRead': instance.isRead,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.friendship: 'friendship',
  NotificationType.listInvite: 'listInvite',
};

const _$NotificationStatusEnumMap = {
  NotificationStatus.pending: 'pending',
  NotificationStatus.accepted: 'accepted',
  NotificationStatus.rejected: 'rejected',
};

ListInviteNotification _$ListInviteNotificationFromJson(
    Map<String, dynamic> json) {
  return $checkedNew('ListInviteNotification', json, () {
    final val = ListInviteNotification(
      userToId: $checkedConvert(json, 'userToId', (v) => v),
      userFromId: $checkedConvert(json, 'userFromId', (v) => v),
      status: $checkedConvert(
          json, 'status', (v) => _$enumDecode(_$NotificationStatusEnumMap, v)),
      listOwnerId: $checkedConvert(json, 'listOwnerId', (v) => v as String),
      listId: $checkedConvert(json, 'listId', (v) => v as String),
      isRead: $checkedConvert(json, 'isRead', (v) => v),
      databaseId: $checkedConvert(json, 'databaseId', (v) => v),
      createdAt: $checkedConvert(
          json, 'createdAt', (v) => ModelUtils.dateTimeFromJson(v as int)),
      updatedAt: $checkedConvert(json, 'updatedAt',
          (v) => ModelUtils.nullableDateTimeFromJson(v as int?)),
    );
    return val;
  });
}

Map<String, dynamic> _$ListInviteNotificationToJson(
        ListInviteNotification instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'createdAt': ModelUtils.dateTimeToJson(instance.createdAt),
      'updatedAt': ModelUtils.nullableDateTimeToJson(instance.updatedAt),
      'userToId': instance.userToId,
      'userFromId': instance.userFromId,
      'status': _$NotificationStatusEnumMap[instance.status],
      'isRead': instance.isRead,
      'listId': instance.listId,
      'listOwnerId': instance.listOwnerId,
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
      userToId: $checkedConvert(json, 'userToId', (v) => v),
      userFromId: $checkedConvert(json, 'userFromId', (v) => v),
      friendshipRequestMethod: $checkedConvert(json, 'friendshipRequestMethod',
          (v) => _$enumDecode(_$FriendshipRequestMethodEnumMap, v)),
      status: $checkedConvert(
          json, 'status', (v) => _$enumDecode(_$NotificationStatusEnumMap, v)),
      databaseId: $checkedConvert(json, 'databaseId', (v) => v as String?),
      isRead: $checkedConvert(json, 'isRead', (v) => v),
      createdAt: $checkedConvert(
          json, 'createdAt', (v) => ModelUtils.dateTimeFromJson(v as int)),
      updatedAt: $checkedConvert(json, 'updatedAt',
          (v) => ModelUtils.nullableDateTimeFromJson(v as int?)),
    );
    return val;
  });
}

Map<String, dynamic> _$FriendshipNotificationToJson(
        FriendshipNotification instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'createdAt': ModelUtils.dateTimeToJson(instance.createdAt),
      'updatedAt': ModelUtils.nullableDateTimeToJson(instance.updatedAt),
      'userToId': instance.userToId,
      'userFromId': instance.userFromId,
      'status': _$NotificationStatusEnumMap[instance.status],
      'isRead': instance.isRead,
      'friendshipRequestMethod':
          _$FriendshipRequestMethodEnumMap[instance.friendshipRequestMethod],
    };

const _$FriendshipRequestMethodEnumMap = {
  FriendshipRequestMethod.username: 'username',
  FriendshipRequestMethod.email: 'email',
};
