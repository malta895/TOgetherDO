// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListAppList _$ListAppListFromJson(Map<String, dynamic> json) {
  return ListAppList(
    databaseId: json['databaseId'] as String?,
    name: json['name'] as String,
    description: json['description'] as String?,
  )..members = (json['members'] as List<dynamic>)
      .map((e) => ListAppUser.fromJson(e as Map<String, dynamic>))
      .toSet();
}

Map<String, dynamic> _$ListAppListToJson(ListAppList instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'name': instance.name,
      'description': instance.description,
      'members': instance.members.toList(),
    };
