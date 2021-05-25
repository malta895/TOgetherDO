import 'package:json_annotation/json_annotation.dart';

// We need to specify which file the generated serialization code will be saved to
part 'user.g.dart';

/// An user of the application
@JsonSerializable() // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class ListAppUser {
  ///the name of the collection used as a table/collection name in the database
  static const String COLLECTION_NAME = 'users';

  String firstName;
  String lastName;
  final String email;

  ///The username. It is not mandatory as the email is the current authentication method
  String? username;
  String? phoneNumber;
  String? profilePictureURL;

  @JsonKey(defaultValue: const {})
  final Set<ListAppUser> friends;
  
  ListAppUser(
      {required this.firstName,
      required this.lastName,
      required this.email,
      this.username,
      this.phoneNumber,
      this.profilePictureURL,
      this.friends = const {},
  });

  String get fullName => firstName + ' ' + lastName;
  String get initials => firstName.substring(0, 1) + lastName.substring(0, 1);

  factory ListAppUser.fromJson(Map<String, dynamic> json) =>
      _$ListAppUserFromJson(json);

  Map<String, dynamic> toJson() => _$ListAppUserToJson(this);
}
