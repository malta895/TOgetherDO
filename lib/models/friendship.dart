import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'friendship.g.dart';

/// It represents the friendship between 2 users
@JsonSerializable()
class Friendship {
  static const String COLLECTION_NAME = 'friendships';

  /// The user who sent the friend request
  final ListAppUser userFrom;

  /// The user who received the friend request
  final ListAppUser userTo;

  /// The acceptance of the request. Two users are considered friends only if this is true
  bool _requestAccepted = false;

  bool get requestAccepted => _requestAccepted;

  void acceptRequest() => _requestAccepted = true;

  Friendship({required this.userFrom, required this.userTo, requestAccepted})
      : _requestAccepted = requestAccepted;

  factory Friendship.fromJson(Map<String, dynamic> json) =>
      _$FriendshipFromJson(json);

  Map<String, dynamic> toJson() => _$FriendshipToJson(this);
}
