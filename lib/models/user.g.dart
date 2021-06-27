// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListAppUser _$ListAppUserFromJson(Map<String, dynamic> json) {
  return ListAppUser(
    databaseId: json['databaseId'] as String,
    email: json['email'] as String,
    notificationTokens: (json['notificationTokens'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toSet() ??
        {},
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    displayName: json['displayName'] as String?,
    username: json['username'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    profilePictureURL: json['profilePictureURL'] as String?,
    friends: (json['friends'] as List<dynamic>?)
            ?.map((e) => ListAppUser.fromJson(e as Map<String, dynamic>))
            .toSet() ??
        {},
    isNew: json['isNew'] as bool,
  );
}

Map<String, dynamic> _$ListAppUserToJson(ListAppUser instance) =>
    <String, dynamic>{
      'databaseId': instance.databaseId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'displayName': instance.displayName,
      'email': instance.email,
      'username': instance.username,
      'phoneNumber': instance.phoneNumber,
      'profilePictureURL': instance.profilePictureURL,
      'friends': instance.friends.toList(),
      'isNew': instance.isNew,
      'notificationTokens': instance.notificationTokens.toList(),
    };
