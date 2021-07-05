// This model represents a list of our application
import 'dart:collection';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'list_item.g.dart';

enum ItemType { simple, multiFulfillment, multiFulfillmentMember }

extension ParseToString on ItemType {
  String toReadableString() {
    switch (this) {
      case ItemType.simple:
        return 'Simple item';
      case ItemType.multiFulfillment:
        return 'Multiple instance item';
      case ItemType.multiFulfillmentMember:
        return 'Multiple People item';
    }
  }

  String getDescription() {
    switch (this) {
      case ItemType.simple:
        return 'The simple item can only be completed by one person';
      case ItemType.multiFulfillment:
        return 'The multiFulfillment item can be completed once by each person in the list.';
      case ItemType.multiFulfillmentMember:
        return 'The mumultiFulfillmentMember item can be completed more times by any member in the list';
    }
  }
}

///Any type of item. the specific types will implement in different ways the methods
@JsonSerializable(checked: true, createFactory: false)
abstract class BaseItem with ChangeNotifier {
  static const String collectionName = 'items';
  String? databaseId;
  final String name;
  final String? description;
  final int maxQuantity;
  final int quantityPerMember;

  final ItemType itemType;

  BaseItem({
    this.databaseId,
    required this.name,
    this.description,
    required this.maxQuantity,
    required this.quantityPerMember,
    required this.itemType,
  });

  int quantityFulfilledBy(ListAppUser member);

  bool isFulfilled();

  //fulfill, aka complete, this list item, with a quantity. returns false if the item was fulfilled already
  bool fulfill({required ListAppUser member, int quantityFulfilled = 0});

  bool unfulfill({required ListAppUser member, int quantityUnfulfilled = 0});

  List<ListAppUser> getFulfillers();

  factory BaseItem.fromJson(Map<String, dynamic> json) {
    switch (json['itemType'] as String) {
      case 'simple':
        return SimpleItem.fromJson(json);
      case 'multiFulfillment':
        return MultiFulfillmentItem.fromJson(json);
      case 'multiFulfillmentMember':
        return MultiFulfillmentMemberItem.fromJson(json);

      default:
        throw StateError("Item type not recognized");
    }
  }

  Map<String, dynamic> toJson() {
    switch (this.itemType) {
      case ItemType.simple:
        return (this as SimpleItem).toJson();
      case ItemType.multiFulfillment:
        return (this as MultiFulfillmentItem).toJson();
      case ItemType.multiFulfillmentMember:
        return (this as MultiFulfillmentMemberItem).toJson();

      default:
        throw StateError("Item type not recognized");
    }
  }
}

///This item can have just one fulfiller
@JsonSerializable(
  checked: true,
) // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class SimpleItem extends BaseItem {
  ListAppUser? _fulfiller;

  SimpleItem({String? databaseId, required String name, String? description})
      : super(
            itemType: ItemType.simple,
            databaseId: databaseId,
            name: name,
            description: description,
            maxQuantity: 1,
            quantityPerMember: 1);

  ListAppUser? get fulfiller {
    return _fulfiller;
  }

  @override
  bool isFulfilled() {
    return _fulfiller != null;
  }

  @override
  bool fulfill({required ListAppUser member, int quantityFulfilled = 0}) {
    if (_fulfiller == null) {
      _fulfiller = member;
      return true;
    }

    return false;
  }

  @override
  bool unfulfill({required ListAppUser member, int quantityUnfulfilled = 1}) {
    //do not allow the unfulfillment of other members
    if (member == _fulfiller) {
      _fulfiller = null;
      return true;
    }
    return false;
  }

  @override
  List<ListAppUser> getFulfillers() {
    if (_fulfiller == null) return UnmodifiableListView<ListAppUser>([]);

    return UnmodifiableListView<ListAppUser>([_fulfiller!]);
  }

  @override
  int quantityFulfilledBy(ListAppUser member) {
    return member == _fulfiller ? 1 : 0;
  }

  factory SimpleItem.fromJson(Map<String, dynamic> json) =>
      _$SimpleItemFromJson(json);

  Map<String, dynamic> toJson() => _$SimpleItemToJson(this)
    ..addAll({
      'itemType': _$ItemTypeEnumMap[this.itemType],
      "quantityPerMember": this.quantityPerMember,
      "maxQuantity": this.maxQuantity
    });
}

//List item with multiple fulfillments, members can fulfill once
@JsonSerializable(
  checked: true,
) // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class MultiFulfillmentItem extends BaseItem {
  Set<ListAppUser> _fulfillers = Set<ListAppUser>();

  MultiFulfillmentItem(
      {String? databaseId,
      required String name,
      String? description,
      required int maxQuantity})
      : super(
            itemType: ItemType.multiFulfillment,
            databaseId: databaseId,
            name: name,
            description: description,
            maxQuantity: maxQuantity,
            quantityPerMember: 1);

  @override
  bool fulfill({required ListAppUser member, int quantityFulfilled = 1}) {
    return _fulfillers.add(member);
  }

  @override
  List<ListAppUser> getFulfillers() {
    return UnmodifiableListView<ListAppUser>(_fulfillers);
  }

  @override
  bool isFulfilled() {
    return _fulfillers.length == maxQuantity;
  }

  @override
  int quantityFulfilledBy(ListAppUser member) {
    return _fulfillers.contains(member) ? 1 : 0;
  }

  @override
  bool unfulfill({required ListAppUser member, int quantityUnfulfilled = 1}) {
    return _fulfillers.remove(member);
  }

  factory MultiFulfillmentItem.fromJson(Map<String, dynamic> json) =>
      _$MultiFulfillmentItemFromJson(json);

  Map<String, dynamic> toJson() => _$MultiFulfillmentItemToJson(this)
    ..addAll({
      'itemType': _$ItemTypeEnumMap[this.itemType],
      "quantityPerMember": this.quantityPerMember,
    });
}

///List item with multiple fulfillments, members can fulfill more times
@JsonSerializable(
  checked: true,
) // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class MultiFulfillmentMemberItem extends BaseItem {
  //map each member with a number representing how many times they have fulfilled
  Map<ListAppUser, int> _fulfillers = Map<ListAppUser, int>();

  MultiFulfillmentMemberItem(
      {String? databaseId,
      required String name,
      String? description,
      required int maxQuantity,
      required int quantityPerMember})
      : super(
            itemType: ItemType.multiFulfillmentMember,
            databaseId: databaseId,
            name: name,
            description: description,
            maxQuantity: maxQuantity,
            quantityPerMember: quantityPerMember);

  @override
  bool fulfill({required ListAppUser member, int quantityFulfilled = 1}) {
    // TODO control all constraints of this item and list
    _fulfillers[member] == null
        ? _fulfillers[member] = quantityFulfilled
        : _fulfillers[member] = _fulfillers[member]! + quantityFulfilled;
    return quantityFulfilled > 0;
  }

  @override
  List<ListAppUser> getFulfillers() {
    return UnmodifiableListView<ListAppUser>(_fulfillers.keys);
  }

  @override
  bool isFulfilled() {
    // the item is complete when the max quantity has been reached.
    return _fulfillers.isEmpty
        ? false
        : _fulfillers.values.reduce((total, element) => total + element) >=
            maxQuantity;
  }

  @override
  int quantityFulfilledBy(ListAppUser member) {
    return _fulfillers[member] == null ? 0 : _fulfillers[member]!;
  }

  @override
  bool unfulfill({required ListAppUser member, int quantityUnfulfilled = 1}) {
    _fulfillers[member]! + quantityUnfulfilled <= 0
        ? _fulfillers.remove(member)
        : _fulfillers[member] = _fulfillers[member]! + quantityUnfulfilled;
    return _fulfillers.remove(member) != null;
  }

  factory MultiFulfillmentMemberItem.fromJson(Map<String, dynamic> json) =>
      _$MultiFulfillmentMemberItemFromJson(json);

  Map<String, dynamic> toJson() => _$MultiFulfillmentMemberItemToJson(this)
    ..addAll({
      'itemType': _$ItemTypeEnumMap[this.itemType],
    });
}
