import 'dart:core';

import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/base_model.dart';
import 'package:mobile_applications/models/list_item.dart';
// ignore: unused_import
import 'package:mobile_applications/models/utils.dart';

import 'user.dart';

part 'list.g.dart';

/// The list type
enum ListType {
  /// Anyone can see the completed items and who completed them
  public,

  /// The list is 'hidden' to the creator, only the other participants can see who completed what
  private
}

enum ListStatus {
  draft,
  saved,
  //TODO add completed?
}

extension ParseToString on ListType {
  String toReadableString() {
    switch (this) {
      case ListType.public:
        return 'Public list';
      case ListType.private:
        return 'Private list';
    }
  }

  String getDescription() {
    switch (this) {
      case ListType.public:
        return 'A public list can be seen and '
            ' managed by the creator, who can see and complete the items like the other members.';
      case ListType.private:
        return 'The items of a private list are added by the creator, '
            'but it can be completed by the members only and the creator is not able to see who completed them.';
    }
  }
}

// see https://flutter.dev/docs/development/data-and-backend/json#code-generation
/// The app list
@JsonSerializable(checked: true)
class ListAppList extends BaseModel {
  static const String collectionName = 'lists';

  /// The name of the list
  final String name;

  /// Optional. A brief description of the list.
  final String? description;

  /// The expiry date, if set, describes the deadline of the list completion
  @JsonKey(
      fromJson: ModelUtils.nullableDateTimeFromJson,
      toJson: ModelUtils.nullableDateTimeToJson)
  final DateTime? expiryDate;

  /// The type of this list
  final ListType listType;

  /// The status of the list
  ListStatus listStatus;

  /// The members of the list
  @JsonKey(defaultValue: {})
  Map<String, bool> members = {};

  /// the number of items in the list
  int get length => items.length;

  String? creatorUid;

  // fields to add when querying
  @JsonKey(ignore: true)
  List<ListAppUser> membersAsUsers;
  @JsonKey(ignore: true)
  List<BaseItem> items = [];
  @JsonKey(ignore: true)
  ListAppUser? creator;

  ListAppList(
      {String? databaseId,
      required this.name,
      this.expiryDate,
      this.creatorUid,
      required this.listType, // NOTE maybe better to make it required and remove the default value
      this.description,
      List<ListAppUser>? membersAsUsers,
      DateTime? createdAt,
      DateTime? updatedAt,
      required this.listStatus})
      : this.membersAsUsers = membersAsUsers ?? [],
        super(
          databaseId: databaseId,
          createdAt: createdAt,
          updatedAt: updatedAt,
        ) {
    if (membersAsUsers != null)
      members = Map<String, bool>.fromIterable(
        membersAsUsers,
        key: (k) => k.databaseId,
        value: (_) => false,
      );
  }

  factory ListAppList.fromJson(Map<String, dynamic> json) =>
      _$ListAppListFromJson(json);

  Map<String, dynamic> toJson() {
    return _$ListAppListToJson(this);
  }
}

class ListAppFulfillment {
  /// the user who completed the list item
  final ListAppUser member;

  /// The quantity completed by the user. At least can be 1
  final int quantityCompleted;

  /// if the list item has a price, this contains the amount countributed by the user
  final double priceContribution;

  ListAppFulfillment({
    required this.member,
    required this.quantityCompleted,
    required this.priceContribution,
  });
}
