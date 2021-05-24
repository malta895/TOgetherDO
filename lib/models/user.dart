import 'dart:collection';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// An user of the application
@JsonSerializable() // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class ListAppUser {
  ///the name of the collection used as a table/collection name in the database
  static const String COLLECTION_NAME = 'users';

  String firstName;
  String lastName;
  final String email;
  final String? username;

  @JsonKey(ignore: true)
  Set<Friendship> _friendships = {};

  ListAppUser(
      {required this.firstName,
      required this.lastName,
      required this.email,
      this.username});

  String get fullName => firstName + ' ' + lastName;
  String get initials => firstName.substring(0, 1) + lastName.substring(0,1);

  UnmodifiableSetView<Friendship> get friendships =>
      UnmodifiableSetView(_friendships);

  bool addFriendship(Friendship friendship) => _friendships.add(friendship);

  factory ListAppUser.fromJson(Map<String, dynamic> json) =>
      _$ListAppUserFromJson(json);

  Map<String, dynamic> toJson() => _$ListAppUserToJson(this);
}

/// It represents the friendship among more users
class Friendship {
  final ListAppUser _user;

  final bool _accepted;

  ListAppUser get user => _user;
  bool get accepted => _accepted;

  Friendship(this._user, this._accepted);
}
