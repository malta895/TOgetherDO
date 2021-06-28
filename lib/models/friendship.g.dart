// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListAppFriendship _$ListAppFriendshipFromJson(Map<String, dynamic> json) {
  return ListAppFriendship(
    userFrom: json['userFrom'] as String,
    userTo: json['userTo'] as String,
    requestAccepted: json['requestAccepted'] as bool,
  );
}

Map<String, dynamic> _$ListAppFriendshipToJson(ListAppFriendship instance) =>
    <String, dynamic>{
      'userFrom': instance.userFrom,
      'userTo': instance.userTo,
      'requestAccepted': instance.requestAccepted,
    };
