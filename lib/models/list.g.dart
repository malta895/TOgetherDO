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
      expiryDate: $checkedConvert(json, 'expiryDate',
          (v) => ModelUtils.nullableDateTimeFromJson(v as int?)),
      creatorUid: $checkedConvert(json, 'creatorUid', (v) => v as String?),
      listType: $checkedConvert(
          json, 'listType', (v) => _$enumDecode(_$ListTypeEnumMap, v)),
      description: $checkedConvert(json, 'description', (v) => v as String?),
      createdAt: $checkedConvert(
          json, 'createdAt', (v) => ModelUtils.dateTimeFromJson(v as int)),
      updatedAt: $checkedConvert(json, 'updatedAt',
          (v) => ModelUtils.nullableDateTimeFromJson(v as int?)),
      listStatus: $checkedConvert(
          json, 'listStatus', (v) => _$enumDecode(_$ListStatusEnumMap, v)),
    );
    $checkedConvert(
        json,
        'members',
        (v) => val.members = (v as Map<String, dynamic>?)?.map(
              (k, e) => MapEntry(k, e as bool),
            ) ??
            {});
    return val;
  });
}

Map<String, dynamic> _$ListAppListToJson(ListAppList instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'createdAt': ModelUtils.dateTimeToJson(instance.createdAt),
      'updatedAt': ModelUtils.nullableDateTimeToJson(instance.updatedAt),
      'name': instance.name,
      'description': instance.description,
      'expiryDate': ModelUtils.nullableDateTimeToJson(instance.expiryDate),
      'listType': _$ListTypeEnumMap[instance.listType],
      'listStatus': _$ListStatusEnumMap[instance.listStatus],
      'members': instance.members,
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

const _$ListStatusEnumMap = {
  ListStatus.draft: 'draft',
  ListStatus.saved: 'saved',
};
