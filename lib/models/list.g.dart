// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListAppList _$ListAppListFromJson(Map<String, dynamic> json) {
  return ListAppList(
    name: json['name'] as String,
    createdAt: ModelUtils.dateTimeFromJson(json['createdAt'] as int),
    expiryDate: ModelUtils.nullableDateTimeFromJson(json['expiryDate'] as int?),
    databaseId: json['databaseId'] as String?,
    creatorUsername: json['creatorUsername'] as String?,
    listType: _$enumDecode(_$ListTypeEnumMap, json['listType']),
    description: json['description'] as String?,
    items: (json['items'] as List<dynamic>?)
            ?.map((e) => BaseItem.fromJson(e as Map<String, dynamic>))
            .toSet() ??
        {},
  );
}

Map<String, dynamic> _$ListAppListToJson(ListAppList instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'name': instance.name,
      'description': instance.description,
      'createdAt': ModelUtils.dateTimeToJson(instance.createdAt),
      'expiryDate': ModelUtils.nullableDateTimeToJson(instance.expiryDate),
      'listType': _$ListTypeEnumMap[instance.listType],
      'items': instance.items.toList(),
      'creatorUsername': instance.creatorUsername,
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
