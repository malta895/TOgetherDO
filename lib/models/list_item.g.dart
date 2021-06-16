// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseItem _$BaseItemFromJson(Map<String, dynamic> json) {
  return BaseItem(
    databaseId: json['databaseId'] as String?,
    name: json['name'] as String,
    description: json['description'] as String?,
    maxQuantity: json['maxQuantity'] as int,
    quantityPerMember: json['quantityPerMember'] as int,
  );
}

Map<String, dynamic> _$BaseItemToJson(BaseItem instance) => <String, dynamic>{
      'databaseId': instance.databaseId,
      'name': instance.name,
      'description': instance.description,
      'maxQuantity': instance.maxQuantity,
      'quantityPerMember': instance.quantityPerMember,
    };
