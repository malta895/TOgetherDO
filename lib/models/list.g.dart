// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListAppList _$ListAppListFromJson(Map<String, dynamic> json) {
  return $checkedNew('ListAppList', json, () {
    final val = ListAppList(
      databaseId: $checkedConvert(json, 'databaseId', (v) => v as String?),
      name: $checkedConvert(json, 'name', (v) => v as String),
      createdAt: $checkedConvert(
          json, 'createdAt', (v) => ModelUtils.dateTimeFromJson(v as int)),
      expiryDate: $checkedConvert(json, 'expiryDate',
          (v) => ModelUtils.nullableDateTimeFromJson(v as int?)),
      creatorUid: $checkedConvert(json, 'creatorUid', (v) => v as String?),
      listType: $checkedConvert(
          json, 'listType', (v) => _$enumDecode(_$ListTypeEnumMap, v)),
      description: $checkedConvert(json, 'description', (v) => v as String?),
    );
    $checkedConvert(
        json,
        'members',
        (v) => val.members =
            (v as List<dynamic>?)?.map((e) => e as String?).toSet() ?? {});
    return val;
  });
}

Map<String, dynamic> _$ListAppListToJson(ListAppList instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'name': instance.name,
      'description': instance.description,
      'createdAt': ModelUtils.dateTimeToJson(instance.createdAt),
      'expiryDate': ModelUtils.nullableDateTimeToJson(instance.expiryDate),
      'listType': _$ListTypeEnumMap[instance.listType],
      'members': instance.members.toList(),
      'creatorUid': instance.creatorUid,
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

const _$ListTypeEnumMap = {
  ListType.public: 'public',
  ListType.private: 'private',
};
