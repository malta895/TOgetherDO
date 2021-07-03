import 'package:json_annotation/json_annotation.dart';

part 'friendship.g.dart';

/// It represents the friendship between 2 users
@JsonSerializable(checked: true)
class ListAppFriendship {
  static const String collectionName = 'friendships';

  /// The user who sent the friend request
  final String userFrom;

  /// The user who received the friend request
  final String userTo;

  /// The acceptance of the request. Two users are considered friends only if this is true
  bool requestAccepted = false;

  //bool get requestAccepted => _requestAccepted;

  void acceptRequest() => requestAccepted = true;

  ListAppFriendship(
      {required this.userFrom,
      required this.userTo,
      this.requestAccepted = false});

  factory ListAppFriendship.fromJson(Map<String, dynamic> json) =>
      _$ListAppFriendshipFromJson(json);

  Map<String, dynamic> toJson() => _$ListAppFriendshipToJson(this);
}
