// This model represents a list of our application
import 'dart:core';

import 'package:mobile_applications/models/list_item.dart';

import 'user.dart';

/// The list. Can be of various inherited types
class ListAppList {
  static const String collectionName = 'lists';

  /// the id provided by the data source
  final String? databaseId;
  final String name;
  final String? description;

  //Set and not List because Sets have unique elements
  late Set<ListAppUser> members;

  late Set<BaseItem> items;

  ListAppList({this.databaseId, required this.name, this.description});

  factory ListAppList.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();

  Map<String, dynamic> toJson() => throw UnimplementedError();
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
