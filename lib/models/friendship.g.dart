// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListAppFriendship _$ListAppFriendshipFromJson(Map<String, dynamic> json) {
  return $checkedNew('ListAppFriendship', json, () {
    final val = ListAppFriendship(
      databaseId: $checkedConvert(json, 'databaseId', (v) => v as String?),
      userFrom: $checkedConvert(json, 'userFrom', (v) => v as String),
      userTo: $checkedConvert(json, 'userTo', (v) => v as String),
      requestedBy: $checkedConvert(json, 'requestedBy',
          (v) => _$enumDecode(_$FriendshipRequestMethodEnumMap, v)),
      requestAccepted:
          $checkedConvert(json, 'requestAccepted', (v) => v as bool),
      createdAt: $checkedConvert(
          json, 'createdAt', (v) => ModelUtils.dateTimeFromJson(v as int)),
    );
    return val;
  });
}

Map<String, dynamic> _$ListAppFriendshipToJson(ListAppFriendship instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'createdAt': ModelUtils.dateTimeToJson(instance.createdAt),
      'userFrom': instance.userFrom,
      'userTo': instance.userTo,
      'requestedBy': _$FriendshipRequestMethodEnumMap[instance.requestedBy],
      'requestAccepted': instance.requestAccepted,
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

const _$FriendshipRequestMethodEnumMap = {
  FriendshipRequestMethod.username: 'username',
  FriendshipRequestMethod.email: 'email',
};
