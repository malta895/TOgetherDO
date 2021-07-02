// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$BaseItemToJson(BaseItem instance) => <String, dynamic>{
      'hasListeners': instance.hasListeners,
      'databaseId': instance.databaseId,
      'name': instance.name,
      'description': instance.description,
      'maxQuantity': instance.maxQuantity,
      'quantityPerMember': instance.quantityPerMember,
      'itemType': _$ItemTypeEnumMap[instance.itemType],
    };

const _$ItemTypeEnumMap = {
  ItemType.simple: 'simple',
  ItemType.multiFulfillment: 'multiFulfillment',
  ItemType.multiFulfillmentMember: 'multiFulfillmentMember',
};

SimpleItem _$SimpleItemFromJson(Map<String, dynamic> json) {
  return SimpleItem(
    databaseId: json['databaseId'] as String?,
    name: json['name'] as String,
    description: json['description'] as String?,
  );
}

Map<String, dynamic> _$SimpleItemToJson(SimpleItem instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'name': instance.name,
      'description': instance.description,
    };

MultiFulfillmentItem _$MultiFulfillmentItemFromJson(Map<String, dynamic> json) {
  return MultiFulfillmentItem(
    databaseId: json['databaseId'] as String?,
    name: json['name'] as String,
    description: json['description'] as String?,
    maxQuantity: json['maxQuantity'] as int,
  );
}

Map<String, dynamic> _$MultiFulfillmentItemToJson(
        MultiFulfillmentItem instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'name': instance.name,
      'description': instance.description,
      'maxQuantity': instance.maxQuantity,
    };

MultiFulfillmentMemberItem _$MultiFulfillmentMemberItemFromJson(
    Map<String, dynamic> json) {
  return MultiFulfillmentMemberItem(
    databaseId: json['databaseId'] as String?,
    name: json['name'] as String,
    description: json['description'] as String?,
    maxQuantity: json['maxQuantity'] as int,
    quantityPerMember: json['quantityPerMember'] as int,
  );
}

Map<String, dynamic> _$MultiFulfillmentMemberItemToJson(
        MultiFulfillmentMemberItem instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'name': instance.name,
      'description': instance.description,
      'maxQuantity': instance.maxQuantity,
      'quantityPerMember': instance.quantityPerMember,
    };
