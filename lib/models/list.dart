// This model represents a list of our application
import 'dart:core';

import 'package:json_annotation/json_annotation.dart';
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

/// The list. Can be of various inherited types
@JsonSerializable() // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class ListAppList {
  static const String collectionName = 'lists';

  /// the id provided by the data source
  String? databaseId;
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

  //Set and not List because Sets have unique elements
  @JsonKey(defaultValue: const {})
  Set<ListAppUser> members;

  @JsonKey(defaultValue: const {})
  Set<BaseItem> items;

  int get length => items.length;

  String? creatorUsername;

  ListAppList(
      {required this.name,
      DateTime? createdAt,
      this.expiryDate,
      this.databaseId,
      this.creatorUsername,
      this.listType = ListType
          .public, // NOTE maybe better to make it required and remove the default value
      this.description,
      this.items = const {},
      this.members = const {}})
      : this.createdAt = createdAt ?? DateTime.now().toUtc();

  factory ListAppList.fromJson(Map<String, dynamic> json) =>
      _$ListAppListFromJson(json);

  Map<String, dynamic> toJson() => _$ListAppListToJson(this);
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
