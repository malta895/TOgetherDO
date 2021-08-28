// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListAppUser _$ListAppUserFromJson(Map<String, dynamic> json) {
  return $checkedNew('ListAppUser', json, () {
    final val = ListAppUser(
      databaseId: $checkedConvert(json, 'databaseId', (v) => v as String?),
      notificationTokens: $checkedConvert(json, 'notificationTokens',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()),
      firstName: $checkedConvert(json, 'firstName', (v) => v as String),
      lastName: $checkedConvert(json, 'lastName', (v) => v as String),
      displayName: $checkedConvert(json, 'displayName', (v) => v as String?),
      username: $checkedConvert(json, 'username', (v) => v as String?),
      profilePictureURL:
          $checkedConvert(json, 'profilePictureURL', (v) => v as String?),
      friends: $checkedConvert(
          json, 'friends', (v) => Map<String, bool>.from(v as Map)),
      isNew: $checkedConvert(json, 'isNew', (v) => v as bool),
      createdAt: $checkedConvert(
          json, 'createdAt', (v) => ModelUtils.dateTimeFromJson(v as int)),
      updatedAt: $checkedConvert(json, 'updatedAt',
          (v) => ModelUtils.nullableDateTimeFromJson(v as int?)),
    );
    return val;
  });
}

Map<String, dynamic> _$ListAppUserToJson(ListAppUser instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'createdAt': ModelUtils.dateTimeToJson(instance.createdAt),
      'updatedAt': ModelUtils.nullableDateTimeToJson(instance.updatedAt),
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'username': instance.username,
      'profilePictureURL': instance.profilePictureURL,
      'friends': instance.friends,
      'isNew': instance.isNew,
      'notificationTokens': instance.notificationTokens.toList(),
      'displayName': instance.displayName,
    };
