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
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()) ??
          {},
      firstName: $checkedConvert(json, 'firstName', (v) => v as String),
      lastName: $checkedConvert(json, 'lastName', (v) => v as String),
      displayName: $checkedConvert(json, 'displayName', (v) => v as String?),
      username: $checkedConvert(json, 'username', (v) => v as String?),
      profilePictureURL:
          $checkedConvert(json, 'profilePictureURL', (v) => v as String?),
      friends: $checkedConvert(
              json,
              'friends',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => ListAppUser.fromJson(e as Map<String, dynamic>))
                  .toSet()) ??
          {},
      isNew: $checkedConvert(json, 'isNew', (v) => v as bool),
    );
    return val;
  });
}

Map<String, dynamic> _$ListAppUserToJson(ListAppUser instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'displayName': instance.displayName,
      'username': instance.username,
      'profilePictureURL': instance.profilePictureURL,
      'friends': instance.friends.toList(),
      'isNew': instance.isNew,
      'notificationTokens': instance.notificationTokens.toList(),
    };
