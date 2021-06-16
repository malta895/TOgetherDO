// This model represents a list of our application
import 'dart:core';

import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/list_item.dart';

import 'user.dart';

part 'list.g.dart';

/// The list. Can be of various inherited types
@JsonSerializable() // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class ListAppList {
  static const String collectionName = 'lists';

  /// the id provided by the data source
  final String? databaseId;
  final String name;
  final String? description;

  //Set and not List because Sets have unique elements
  late Set<ListAppUser> members;

  @JsonKey(ignore: true)
  late Set<BaseItem> items;

  ListAppList({this.databaseId, required this.name, this.description});

  factory ListAppList.fromJson(Map<String, dynamic> json) =>
      _$ListAppListFromJson(json);

  Map<String, dynamic> toJson() => _$ListAppListToJson(this);
}

class ListAppFulfillment {
  // the user who completed the list item
  final ListAppUser member;

  // The quantity completed by the user. At least can be 1
  final int quantityCompleted;
  // if the list item has a price, this contains the amount countributed by the user
  final double priceContribution;

  ListAppFulfillment(
      {required this.member,
      required this.quantityCompleted,
      required this.priceContribution});
}
