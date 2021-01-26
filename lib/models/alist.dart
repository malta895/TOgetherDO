// This model represents a list of our application
import 'dart:collection';
import 'dart:core';

import 'package:flutter/material.dart';

class AList {
  // A at the start to avoid confusion with Dart List

  final int id;
  final String name;
  final String description;

  //Set and not List because Sets have unique elements
  Set<AListMember> members;

  Set<BaseItem> items;

  AList(this.id, this.name, this.description);
}

class FriendList {
  final String name;
  final String email;

  FriendList(this.name, this.email);
}

// a member of a list
class AListMember {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final bool isAdmin = false;

  AListMember(this.id, this.username, this.firstName, this.lastName);

  @override
  bool operator ==(other) => other.id == id;
  @override
  int get hashCode => id;
}

class AListFulfillment {
  // the user who completed the list item
  final AListMember member;

  // The quantity completed by the user. At least can be 1
  final int quantityCompleted;
  // if the list item has a price, this contains the amount countributed by the user
  final double priceContribution;

  AListFulfillment(this.member, this.quantityCompleted, this.priceContribution);
}

//Any type of item. the specific types will implement in different ways the methods
abstract class BaseItem extends ChangeNotifier {
  final int id;
  final String name;
  final String description;
  final int maxQuantity;
  final int quantityPerMember;

  BaseItem(this.id, this.name, this.description, this.maxQuantity,
      this.quantityPerMember);

  int isFulfilledBy(AListMember member);

  bool isFulfilled();

  //fulfill, aka complete, this list item, with a quantity. returns false if the item was fulfilled already
  bool fulfill(AListMember member, int quantityFulfilled);

  bool unfulfill(AListMember member);

  List<AListMember> getFulfillers();
}

//This item can have just one fulfiller
class SimpleItem extends BaseItem {
  AListMember _fulfiller;

  SimpleItem(int id, String name, String description)
      : super(id, name, description, 1, 1);

  AListMember get fulfiller {
    return _fulfiller;
  }

  @override
  bool isFulfilled() {
    return _fulfiller != null;
  }

  @override
  bool fulfill(AListMember member, int quantityFulfilled) {
    if (_fulfiller == null) {
      _fulfiller = member;
      notifyListeners();
      return true;
    }

    return false;
  }

  @override
  bool unfulfill(AListMember member) {
    //do not allow the unfulfillment of other members
    if (member == _fulfiller) {
      _fulfiller = null;
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  List<AListMember> getFulfillers() {
    return UnmodifiableListView<AListMember>([_fulfiller]);
  }

  @override
  int isFulfilledBy(AListMember member) {
    return member == _fulfiller ? 1 : 0;
  }
}

//List item with multiple fulfillments, members can fulfill once
class MultiFulfillmentItem extends BaseItem {
  Set<AListMember> _fulfillers = Set<AListMember>();

  MultiFulfillmentItem(int id, String name, String description, int maxQuantity)
      : super(id, name, description, maxQuantity, 1);

  @override
  bool fulfill(AListMember member, int quantityFulfilled) {
    return _fulfillers.add(member);
  }

  @override
  List<AListMember> getFulfillers() {
    return UnmodifiableListView<AListMember>(_fulfillers);
  }

  @override
  bool isFulfilled() {
    return _fulfillers.length == maxQuantity;
  }

  @override
  int isFulfilledBy(AListMember member) {
    return _fulfillers.contains(member) ? 1 : 0;
  }

  @override
  bool unfulfill(AListMember member) {
    return _fulfillers.remove(member);
  }
}

//List item with multiple fulfillments, members can fulfill more times
class MultiFulfillmentMemberItem extends BaseItem {
  //map each member with a number representing how many times they have fulfilled
  Map<AListMember, int> _fulfillers = Map<AListMember, int>();

  MultiFulfillmentMemberItem(int id, String name, String description,
      int maxQuantity, int maxItemsPerMember)
      : super(id, name, description, maxQuantity, maxItemsPerMember);

  @override
  bool fulfill(AListMember member, int quantityFulfilled) {
    // TODO control all constraints of this item and list
    _fulfillers[member] = quantityFulfilled;
    return quantityFulfilled > 0;
  }

  @override
  List<AListMember> getFulfillers() {
    return UnmodifiableListView<AListMember>(_fulfillers.keys);
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
  int isFulfilledBy(AListMember member) {
    return _fulfillers[member] == null ? 0 : _fulfillers[member];
  }

  @override
  bool unfulfill(AListMember member) {
    return _fulfillers.remove(member) != null;
  }
}
