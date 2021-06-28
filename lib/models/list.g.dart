// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListAppList _$ListAppListFromJson(Map<String, dynamic> json) {
  return ListAppList(
    name: json['name'] as String,
    databaseId: json['databaseId'] as String?,
    listType: _$enumDecode(_$ListTypeEnumMap, json['listType']),
    description: json['description'] as String?,
    items: (json['items'] as List<dynamic>?)
            ?.map((e) => BaseItem.fromJson(e as Map<String, dynamic>))
            .toSet() ??
        {},
    members: (json['members'] as List<dynamic>?)
            ?.map((e) => ListAppUser.fromJson(e as Map<String, dynamic>))
            .toSet() ??
        {},
  );
}

Map<String, dynamic> _$ListAppListToJson(ListAppList instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'name': instance.name,
      'description': instance.description,
      'listType': _$ListTypeEnumMap[instance.listType],
      'members': instance.members.toList(),
      'items': instance.items.toList(),
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
