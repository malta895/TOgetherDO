// This model represents a list of our application
import 'dart:collection';
import 'dart:core';

import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/base_model.dart';
// ignore: unused_import
import 'package:mobile_applications/models/utils.dart';
import 'package:mobile_applications/services/user_manager.dart';

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
@JsonSerializable(
  checked: true,
  createFactory: false,
)
abstract class BaseItem extends BaseModel {
  static const String collectionName = 'items';
  final String name;
  final String? description;
  final int maxQuantity;
  final int quantityPerMember;
  final String creatorUid;

  Map<String, int>? usersCompletions;

  final ItemType itemType;

  BaseItem({
    String? databaseId,
    Set<String>? users,
    Map<String, int>? usersCompletions,
    required this.name,
    this.description,
    required this.maxQuantity,
    required this.quantityPerMember,
    required this.itemType,
    required this.creatorUid,
    DateTime? createdAt,
  })  : this.usersCompletions = usersCompletions,
        super(databaseId: databaseId, createdAt: createdAt);

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
    final baseItemToJson = _$BaseItemToJson(this);
    switch (this.itemType) {
      case ItemType.simple:
        return _$SimpleItemToJson(this as SimpleItem)..addAll(baseItemToJson);
      case ItemType.multiFulfillment:
        return _$MultiFulfillmentItemToJson(this as MultiFulfillmentItem)
          ..addAll(baseItemToJson);
      case ItemType.multiFulfillmentMember:
        return _$MultiFulfillmentMemberItemToJson(
            this as MultiFulfillmentMemberItem)
          ..addAll(baseItemToJson);
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

  SimpleItem({
    String? databaseId,
    Set<String>? users,
    Map<String, int>? usersCompletions,
    required String name,
    String? description,
    required String creatorUid,
    createdAt,
  }) : super(
          itemType: ItemType.simple,
          databaseId: databaseId,
          usersCompletions: usersCompletions,
          name: name,
          description: description,
          maxQuantity: 1,
          quantityPerMember: 1,
          createdAt: createdAt,
          creatorUid: creatorUid,
        );

  ListAppUser? get fulfiller {
    return _fulfiller;
  }

  @override
  bool isFulfilled() {
    //TODO change it back to the general case
    return usersCompletions!['9LUBLCszUrU4mukuRWhHFS2iexL2'] == 1;
  }

  @override
  bool fulfill({required ListAppUser member, int quantityFulfilled = 0}) {
    if (_fulfiller == null) {
      _fulfiller = member;
      usersCompletions![member.databaseId!] = 1;
      return true;
    }

    return false;
  }

  @override
  bool unfulfill({required ListAppUser member, int quantityUnfulfilled = 1}) {
    //do not allow the unfulfillment of other members
    if (member == _fulfiller) {
      _fulfiller = null;
      usersCompletions!.remove(member.databaseId!);
      return true;
    }
    return false;
  }

  @override
  List<ListAppUser> getFulfillers() {
    if (_fulfiller == null) return UnmodifiableListView<ListAppUser>([]);
    return UnmodifiableListView<ListAppUser>([]);
  }

  @override
  int quantityFulfilledBy(ListAppUser member) {
    return member == _fulfiller ? 1 : 0;
  }

  factory SimpleItem.fromJson(Map<String, dynamic> json) =>
      _$SimpleItemFromJson(json);
}

/// List item with multiple fulfillments, members can fulfill once
@JsonSerializable(
  checked: true,
) // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class MultiFulfillmentItem extends BaseItem {
  Set<ListAppUser> _fulfillers = Set<ListAppUser>();

  MultiFulfillmentItem({
    String? databaseId,
    Map<String, int>? usersCompletions,
    required String name,
    String? description,
    required int maxQuantity,
    required String creatorUid,
    createdAt,
  }) : super(
            itemType: ItemType.multiFulfillment,
            databaseId: databaseId,
            usersCompletions: usersCompletions,
            name: name,
            description: description,
            maxQuantity: maxQuantity,
            quantityPerMember: 1,
            createdAt: createdAt,
            creatorUid: creatorUid);

  @override
  bool fulfill({required ListAppUser member, int quantityFulfilled = 1}) {
    usersCompletions![member.databaseId!] = quantityFulfilled;
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
    usersCompletions!.remove(member.databaseId!);
    return _fulfillers.remove(member);
  }

  factory MultiFulfillmentItem.fromJson(Map<String, dynamic> json) =>
      _$MultiFulfillmentItemFromJson(json);
}

///List item with multiple fulfillments, members can fulfill more times
@JsonSerializable(
  checked: true,
) // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class MultiFulfillmentMemberItem extends BaseItem {
  //map each member with a number representing how many times they have fulfilled
  Map<ListAppUser, int> _fulfillers = Map<ListAppUser, int>();

  MultiFulfillmentMemberItem({
    String? databaseId,
    Map<String, int>? usersCompletions,
    required String name,
    String? description,
    required int maxQuantity,
    required int quantityPerMember,
    required String creatorUid,
    createdAt,
  }) : super(
            itemType: ItemType.multiFulfillmentMember,
            databaseId: databaseId,
            usersCompletions: usersCompletions,
            name: name,
            description: description,
            maxQuantity: maxQuantity,
            quantityPerMember: quantityPerMember,
            createdAt: createdAt,
            creatorUid: creatorUid);

  @override
  bool fulfill({required ListAppUser member, int quantityFulfilled = 1}) {
    // TODO control all constraints of this item and list
    _fulfillers[member] == null
        ? _fulfillers[member] = quantityFulfilled
        : _fulfillers[member] = _fulfillers[member]! + quantityFulfilled;
    usersCompletions![member.databaseId!] == null
        ? usersCompletions![member.databaseId!] = quantityFulfilled
        : usersCompletions![member.databaseId!] =
            usersCompletions![member.databaseId!]! + quantityFulfilled;
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
    bool removed;
    if (_fulfillers[member]! + quantityUnfulfilled <= 0) {
      _fulfillers.remove(member);
      usersCompletions!.remove(member.databaseId!);
      removed = true;
    } else {
      _fulfillers[member] = _fulfillers[member]! + quantityUnfulfilled;
      usersCompletions![member.databaseId!] =
          usersCompletions![member.databaseId!]! + quantityUnfulfilled;
      removed = false;
    }
    return removed;
  }

  factory MultiFulfillmentMemberItem.fromJson(Map<String, dynamic> json) =>
      _$MultiFulfillmentMemberItemFromJson(json);
}
