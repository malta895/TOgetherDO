import 'package:json_annotation/json_annotation.dart';

// We need to specify which file the generated serialization code will be saved to
part 'user.g.dart';

/// An user of the application
@JsonSerializable() // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class ListAppUser {
  ///the name of the collection used as a table/collection name in the database
  static const String collectionName = 'users';

  /// The id provided by the data source
  String databaseId;

  String firstName;
  String lastName;
  String displayName;
  final String email;

  ///The username. By default is equal to the first part of the email, but can be changed
  String? username;
  String? phoneNumber;
  String? profilePictureURL;

  @JsonKey(defaultValue: const {})
  Set<ListAppUser> friends;

  /// A new user that needs additional signup data
  bool isNew;

  /// The FCM tokens of the devices used by the user
  @JsonKey(defaultValue: const {})
  Set<String> notificationTokens;

  ListAppUser({
    required this.databaseId,
    required this.email,
    this.notificationTokens = const {},
    this.firstName = '',
    this.lastName = '',
    String? displayName,
    String? username,
    this.phoneNumber,
    this.profilePictureURL,
    this.friends = const {},
    this.isNew = false,
  })  : this.displayName = displayName ?? firstName + ' ' + lastName,
        this.username = username ?? email.substring(0, email.indexOf('@'));

  String get fullName =>
      displayName.isNotEmpty ? displayName : firstName + ' ' + lastName;
  String get initials => firstName.substring(0, 1) + lastName.substring(0, 1);

  factory ListAppUser.fromJson(Map<String, dynamic> json) =>
      _$ListAppUserFromJson(json);

  Map<String, dynamic> toJson() => _$ListAppUserToJson(this);
}
