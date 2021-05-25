// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Friendship _$FriendshipFromJson(Map<String, dynamic> json) {
  return Friendship(
    userFrom: ListAppUser.fromJson(json['userFrom'] as Map<String, dynamic>),
    userTo: ListAppUser.fromJson(json['userTo'] as Map<String, dynamic>),
    requestAccepted: json['requestAccepted'],
  );
}

Map<String, dynamic> _$FriendshipToJson(Friendship instance) =>
    <String, dynamic>{
      'userFrom': instance.userFrom,
      'userTo': instance.userTo,
      'requestAccepted': instance.requestAccepted,
    };
