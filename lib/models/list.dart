import 'dart:core';

import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/base_model.dart';
import 'package:mobile_applications/models/list_item.dart';
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

extension ParseToString on ListType {
  String toReadableString() {
    switch (this) {
      case ListType.public:
        return 'Public list';
      case ListType.private:
        return 'Private list';
    }
  }
}

// see https://flutter.dev/docs/development/data-and-backend/json#code-generation
/// The app list
@JsonSerializable(checked: true)
class ListAppList extends BaseModel {
  static const String collectionName = 'lists';

  final String name;
  final String? description;

  @JsonKey(
      fromJson: ModelUtils.dateTimeFromJson, toJson: ModelUtils.dateTimeToJson)
  final DateTime createdAt;
  @JsonKey(
      fromJson: ModelUtils.nullableDateTimeFromJson,
      toJson: ModelUtils.nullableDateTimeToJson)
  final DateTime? expiryDate;

  final ListType listType;

  @JsonKey(ignore: true)
  Set<ListAppUser> membersAsUsers;

  @JsonKey(defaultValue: const {})
  Set<String?> members = const {};

  @JsonKey(ignore: true)
  List<BaseItem> items = [];

  int get length => items.length;

  String? creatorUid;

  @JsonKey(ignore: true)
  ListAppUser? creator;

  ListAppList({
    String? databaseId,
    required this.name,
    DateTime? createdAt,
    this.expiryDate,
    this.creatorUid,
    this.listType = ListType
        .public, // NOTE maybe better to make it required and remove the default value
    this.description,
    Set<ListAppUser>? membersAsUsers,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.membersAsUsers = membersAsUsers ?? {},
        super(databaseId) {
    if (membersAsUsers != null)
      members = membersAsUsers.map((e) => e.databaseId).toSet();
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

  ListAppFulfillment(
      {required this.member,
      required this.quantityCompleted,
      required this.priceContribution});
}
