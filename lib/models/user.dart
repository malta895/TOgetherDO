import 'package:json_annotation/json_annotation.dart';

// We need to specify which file the generated serialization code will be saved to
part 'user.g.dart';

/// An user of the application
@JsonSerializable() // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class ListAppUser {
  ///the name of the collection used as a table/collection name in the database
  static const String collectionName = 'users';

  /// The id provided by the data source
  @JsonKey(name: "id")
  final String? databaseId;

  String firstName;
  String lastName;
  final String email;

  ///The username. By default is equal to the first part of the email, but can be changed
  String? username;
  String? phoneNumber;
  String? profilePictureURL;

  // @JsonKey(defaultValue: const {})
  @JsonKey(ignore: true)
  final Set<ListAppUser> friends;

  ListAppUser({
    this.databaseId,
    this.firstName = '',
    this.lastName = '',
    required this.email,
    username,
    this.phoneNumber,
    this.profilePictureURL,
    this.friends = const {},
  }) {
    this.username ??= email.substring(0, email.indexOf('@'));
  }

  String get fullName => firstName + ' ' + lastName;
  String get initials => firstName.substring(0, 1) + lastName.substring(0, 1);

  factory ListAppUser.fromJson(Map<String, dynamic> json) =>
      _$ListAppUserFromJson(json);

  Map<String, dynamic> toJson() => _$ListAppUserToJson(this);
}
