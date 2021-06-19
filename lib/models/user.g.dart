// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListAppUser _$ListAppUserFromJson(Map<String, dynamic> json) {
  return ListAppUser(
    databaseId: json['id'] as String?,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    email: json['email'] as String,
    username: json['username'],
    phoneNumber: json['phoneNumber'] as String?,
    profilePictureURL: json['profilePictureURL'] as String?,
  );
}

Map<String, dynamic> _$ListAppUserToJson(ListAppUser instance) =>
    <String, dynamic>{
      'id': instance.databaseId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'username': instance.username,
      'phoneNumber': instance.phoneNumber,
      'profilePictureURL': instance.profilePictureURL,
    };
