// This model represents a list of our application
import 'dart:collection';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'list_item.g.dart';

//Any type of item. the specific types will implement in different ways the methods
@JsonSerializable() // bsee https://flutter.dev/docs/development/data-and-backend/json#code-generation
abstract class BaseItem extends ChangeNotifier {
  final String? databaseId;
  final String name;
  final String? description;
  final int maxQuantity;
  final int quantityPerMember;

  BaseItem(
      {this.databaseId,
      required this.name,
      this.description,
      required this.maxQuantity,
      required this.quantityPerMember});

  int quantityFulfilledBy(ListAppUser member);

  bool isFulfilled();

  //fulfill, aka complete, this list item, with a quantity. returns false if the item was fulfilled already
  bool fulfill(ListAppUser member, int quantityFulfilled);

  bool unfulfill(ListAppUser member);

  List<ListAppUser> getFulfillers();

    factory BaseItem.fromJson(Map<String, dynamic> json) =>
      _$BaseItemFromJson(json);

  Map<String, dynamic> toJson() => _$BaseItemToJson(this);

}

//This item can have just one fulfiller
class SimpleItem extends BaseItem {
  ListAppUser? _fulfiller;

  SimpleItem({String? databaseId, required String name, String? description})
      : super(
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

  //QUESTION: why do we have quantityFulfilled for SimpleItem?
  @override
  bool fulfill(ListAppUser member, int quantityFulfilled) {
    if (_fulfiller == null) {
      _fulfiller = member;
      notifyListeners();
      return true;
    }

    return false;
  }

  @override
  bool unfulfill(ListAppUser member) {
    //do not allow the unfulfillment of other members
    if (member == _fulfiller) {
      _fulfiller = null;
      notifyListeners();
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
}

//List item with multiple fulfillments, members can fulfill once
class MultiFulfillmentItem extends BaseItem {
  Set<ListAppUser> _fulfillers = Set<ListAppUser>();

  MultiFulfillmentItem(
      {String? databaseId,
      required String name,
      String? description,
      required int maxQuantity})
      : super(
            databaseId: databaseId,
            name: name,
            description: description,
            maxQuantity: maxQuantity,
            quantityPerMember: 1);

  @override
  bool fulfill(ListAppUser member, int quantityFulfilled) {
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
  bool unfulfill(ListAppUser member) {
    return _fulfillers.remove(member);
  }
}

//List item with multiple fulfillments, members can fulfill more times
class MultiFulfillmentMemberItem extends BaseItem {
  //map each member with a number representing how many times they have fulfilled
  Map<ListAppUser, int> _fulfillers = Map<ListAppUser, int>();

  MultiFulfillmentMemberItem(
      {String? databaseId,
      required String name,
      String? description,
      required int maxQuantity,
      required int maxItemsPerMember})
      : super(
            databaseId: databaseId,
            name: name,
            description: description,
            maxQuantity: maxQuantity,
            quantityPerMember: maxItemsPerMember);

  @override
  bool fulfill(ListAppUser member, int quantityFulfilled) {
    // TODO control all constraints of this item and list
    _fulfillers[member] = quantityFulfilled;
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
  bool unfulfill(ListAppUser member) {
    return _fulfillers.remove(member) != null;
  }
}
