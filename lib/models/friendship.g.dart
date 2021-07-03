// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListAppFriendship _$ListAppFriendshipFromJson(Map<String, dynamic> json) {
  return $checkedNew('ListAppFriendship', json, () {
    final val = ListAppFriendship(
      userFrom: $checkedConvert(json, 'userFrom', (v) => v as String),
      userTo: $checkedConvert(json, 'userTo', (v) => v as String),
      requestAccepted:
          $checkedConvert(json, 'requestAccepted', (v) => v as bool),
    );
    return val;
  });
}

Map<String, dynamic> _$ListAppFriendshipToJson(ListAppFriendship instance) =>
    <String, dynamic>{
      'userFrom': instance.userFrom,
      'userTo': instance.userTo,
      'requestAccepted': instance.requestAccepted,
    };
