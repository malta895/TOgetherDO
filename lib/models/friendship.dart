import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/base_model.dart';
// ignore: unused_import
import 'package:mobile_applications/models/utils.dart';

part 'friendship.g.dart';

/// It represents the friendship between 2 users
@JsonSerializable(checked: true)
class ListAppFriendship extends BaseModel {
  static const String collectionName = 'friendships';

  /// The user who sent the friend request
  final String userFrom;

  /// The user who received the friend request
  final String userTo;

  /// The acceptance of the request. Two users are considered friends only if this is true
  bool requestAccepted = false;

  void acceptRequest() => requestAccepted = true;

  ListAppFriendship({
    String? databaseId,
    required this.userFrom,
    required this.userTo,
    this.requestAccepted = false,
  }) : super(databaseId: databaseId);

  factory ListAppFriendship.fromJson(Map<String, dynamic> json) =>
      _$ListAppFriendshipFromJson(json);

  Map<String, dynamic> toJson() {
    return _$ListAppFriendshipToJson(this);
  }
}
