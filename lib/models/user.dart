import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/base_model.dart';

// We need to specify which file the generated serialization code will be saved to
part 'user.g.dart';

/// An user of the application
@JsonSerializable(
  checked: true,
) // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class ListAppUser extends BaseModel {
  ///the name of the collection used as a table/collection name in the database
  static const String collectionName = 'users';

  String firstName;
  String lastName;
  String displayName;

  ///The username. By default is equal to the first part of the email, but can be changed
  String? username;

  String? profilePictureURL;

  @JsonKey(defaultValue: {})
  Set<ListAppUser> friends;

  /// A new user that needs additional signup data
  bool isNew;

  /// The FCM tokens of the devices used by the user
  @JsonKey(defaultValue: {})
  Set<String> notificationTokens;

  @JsonKey(ignore: true)
  String? email;

  ListAppUser({
    this.email,
    String? databaseId,
    this.notificationTokens = const {},
    this.firstName = '',
    this.lastName = '',
    String? displayName,
    String? username,
    this.profilePictureURL,
    this.friends = const {},
    this.isNew = false,
  })  : this.displayName = displayName ?? firstName + ' ' + lastName,
        this.username = username ?? '',
        super(databaseId: databaseId);

  String get fullName =>
      displayName.isNotEmpty ? displayName : firstName + ' ' + lastName;
  String get initials => firstName.substring(0, 1) + lastName.substring(0, 1);

  factory ListAppUser.fromJson(Map<String, dynamic> json) =>
      _$ListAppUserFromJson(json);

  Map<String, dynamic> toJson() => _$ListAppUserToJson(this);
}
