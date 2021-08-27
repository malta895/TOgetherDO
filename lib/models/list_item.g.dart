// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$BaseItemToJson(BaseItem instance) => <String, dynamic>{
      'databaseId': instance.databaseId,
      'createdAt': ModelUtils.dateTimeToJson(instance.createdAt),
      'updatedAt': ModelUtils.nullableDateTimeToJson(instance.updatedAt),
      'name': instance.name,
      'description': instance.description,
      'link': instance.link,
      'maxQuantity': instance.maxQuantity,
      'quantityPerMember': instance.quantityPerMember,
      'creatorUid': instance.creatorUid,
      'usersCompletions': instance.usersCompletions,
      'itemType': _$ItemTypeEnumMap[instance.itemType],
    };

const _$ItemTypeEnumMap = {
  ItemType.simple: 'simple',
  ItemType.multiFulfillment: 'multiFulfillment',
  ItemType.multiFulfillmentMember: 'multiFulfillmentMember',
};

SimpleItem _$SimpleItemFromJson(Map<String, dynamic> json) {
  return $checkedNew('SimpleItem', json, () {
    final val = SimpleItem(
      databaseId: $checkedConvert(json, 'databaseId', (v) => v as String?),
      usersCompletions: $checkedConvert(
          json,
          'usersCompletions',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as int),
              )),
      name: $checkedConvert(json, 'name', (v) => v as String),
      description: $checkedConvert(json, 'description', (v) => v as String?),
      link: $checkedConvert(json, 'link', (v) => v as String?),
      creatorUid: $checkedConvert(json, 'creatorUid', (v) => v as String),
      createdAt: $checkedConvert(
          json, 'createdAt', (v) => ModelUtils.dateTimeFromJson(v as int)),
      updatedAt: $checkedConvert(json, 'updatedAt',
          (v) => ModelUtils.nullableDateTimeFromJson(v as int?)),
    );
    return val;
  });
}

Map<String, dynamic> _$SimpleItemToJson(SimpleItem instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'createdAt': ModelUtils.dateTimeToJson(instance.createdAt),
      'updatedAt': ModelUtils.nullableDateTimeToJson(instance.updatedAt),
      'name': instance.name,
      'description': instance.description,
      'link': instance.link,
      'creatorUid': instance.creatorUid,
      'usersCompletions': instance.usersCompletions,
    };

MultiFulfillmentItem _$MultiFulfillmentItemFromJson(Map<String, dynamic> json) {
  return $checkedNew('MultiFulfillmentItem', json, () {
    final val = MultiFulfillmentItem(
      databaseId: $checkedConvert(json, 'databaseId', (v) => v as String?),
      usersCompletions: $checkedConvert(
          json,
          'usersCompletions',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as int),
              )),
      name: $checkedConvert(json, 'name', (v) => v as String),
      description: $checkedConvert(json, 'description', (v) => v as String?),
      link: $checkedConvert(json, 'link', (v) => v as String?),
      maxQuantity: $checkedConvert(json, 'maxQuantity', (v) => v as int),
      creatorUid: $checkedConvert(json, 'creatorUid', (v) => v as String),
      createdAt: $checkedConvert(
          json, 'createdAt', (v) => ModelUtils.dateTimeFromJson(v as int)),
      updatedAt: $checkedConvert(json, 'updatedAt',
          (v) => ModelUtils.nullableDateTimeFromJson(v as int?)),
    );
    return val;
  });
}

Map<String, dynamic> _$MultiFulfillmentItemToJson(
        MultiFulfillmentItem instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'createdAt': ModelUtils.dateTimeToJson(instance.createdAt),
      'updatedAt': ModelUtils.nullableDateTimeToJson(instance.updatedAt),
      'name': instance.name,
      'description': instance.description,
      'link': instance.link,
      'maxQuantity': instance.maxQuantity,
      'creatorUid': instance.creatorUid,
      'usersCompletions': instance.usersCompletions,
    };

MultiFulfillmentMemberItem _$MultiFulfillmentMemberItemFromJson(
    Map<String, dynamic> json) {
  return $checkedNew('MultiFulfillmentMemberItem', json, () {
    final val = MultiFulfillmentMemberItem(
      databaseId: $checkedConvert(json, 'databaseId', (v) => v as String?),
      usersCompletions: $checkedConvert(
          json,
          'usersCompletions',
          (v) => (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as int),
              )),
      name: $checkedConvert(json, 'name', (v) => v as String),
      description: $checkedConvert(json, 'description', (v) => v as String?),
      link: $checkedConvert(json, 'link', (v) => v as String?),
      maxQuantity: $checkedConvert(json, 'maxQuantity', (v) => v as int),
      quantityPerMember:
          $checkedConvert(json, 'quantityPerMember', (v) => v as int),
      creatorUid: $checkedConvert(json, 'creatorUid', (v) => v as String),
      createdAt: $checkedConvert(
          json, 'createdAt', (v) => ModelUtils.dateTimeFromJson(v as int)),
      updatedAt: $checkedConvert(json, 'updatedAt',
          (v) => ModelUtils.nullableDateTimeFromJson(v as int?)),
    );
    return val;
  });
}

Map<String, dynamic> _$MultiFulfillmentMemberItemToJson(
        MultiFulfillmentMemberItem instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'createdAt': ModelUtils.dateTimeToJson(instance.createdAt),
      'updatedAt': ModelUtils.nullableDateTimeToJson(instance.updatedAt),
      'name': instance.name,
      'description': instance.description,
      'link': instance.link,
      'maxQuantity': instance.maxQuantity,
      'quantityPerMember': instance.quantityPerMember,
      'creatorUid': instance.creatorUid,
      'usersCompletions': instance.usersCompletions,
    };
