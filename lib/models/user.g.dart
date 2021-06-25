// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListAppUser _$ListAppUserFromJson(Map<String, dynamic> json) {
  return ListAppUser(
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    displayName: json['displayName'] as String?,
    email: json['email'] as String,
    username: json['username'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    profilePictureURL: json['profilePictureURL'] as String?,
    friends: (json['friends'] as List<dynamic>?)
            ?.map((e) => ListAppUser.fromJson(e as Map<String, dynamic>))
            .toSet() ??
        {},
  );
}

Map<String, dynamic> _$ListAppUserToJson(ListAppUser instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'displayName': instance.displayName,
      'email': instance.email,
      'username': instance.username,
      'phoneNumber': instance.phoneNumber,
      'profilePictureURL': instance.profilePictureURL,
      'friends': instance.friends.toList(),
    };
