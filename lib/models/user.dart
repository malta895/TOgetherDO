import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/base_model.dart';
// ignore: unused_import
import 'package:mobile_applications/models/utils.dart';

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
  String? _displayName;

  ///The username. By default is equal to the first part of the email, but can be changed
  String username;

  String? profilePictureURL;

  Map<String, bool> friends;

  /// A new user that needs additional signup data
  bool isNew;

  /// The FCM tokens of the devices used by the user
  Set<String> notificationTokens = Set<String>();

  /// The email is ignored because not needed outside of the app, it is populated only for current user
  @JsonKey(ignore: true)
  String? email;

  ListAppUser({
    this.email,
    String? databaseId,
    Set<String>? notificationTokens,
    this.firstName = '',
    this.lastName = '',
    String? displayName,
    String? username,
    this.profilePictureURL,
    this.friends = const <String, bool>{},
    this.isNew = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this._displayName = displayName,
        this.username = username ?? '',
        this.notificationTokens = notificationTokens ?? Set<String>(),
        super(
          databaseId: databaseId,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  String get fullName => firstName + ' ' + lastName;
  String get displayName => _displayName ?? fullName;
  String get initials => firstName.substring(0, 1) + lastName.substring(0, 1);

  set displayName(String? displayName) => _displayName = displayName;

  factory ListAppUser.fromJson(Map<String, dynamic> json) =>
      _$ListAppUserFromJson(json);

  Map<String, dynamic> toJson() => _$ListAppUserToJson(this);
}
