// This model represents a list of our application
import 'dart:collection';
import 'dart:core';

import 'package:flutter/material.dart';

class AList {
  // A at the start to avoid confusion with Dart List

  final int id;
  final String name;
  final String description;
  final int maxMembers = 5;
  final int maxItems = 5;

  //Set and not List because Sets have unique elements
  Set<AListMember> members;

  Set<BaseItem> items;

  AList(this.id, this.name, this.description);
}

// a member of a list
class AListMember {
  final int id;
  final String username;
  final String firstName;
  final String lastName;

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

abstract class BaseItem {
  final int id;
  final String name;
  final String description;

  BaseItem(this.id, this.name, this.description);

  bool isFulfilledBy(AListMember member);

  bool isFulfilled();

  void fulfill(AListMember member, int quantityFulfilled);

  void unfulfill(AListMember member);

  List<AListMember> getFulfillers();

  int maxQuantity();

  int quantityPerMember();
}

//This item can have just one fulfiller
class SimpleItem extends BaseItem {
  AListMember _fulfiller;

  SimpleItem(int id, String name, String description)
      : super(id, name, description);

  @override
  bool isFulfilled() {
    return _fulfiller != null;
  }

  @override
  void fulfill(AListMember member, int quantityFulfilled) {
    if (_fulfiller == null) {
      _fulfiller = member;
    }

    assert(isFulfilled());
  }

  @override
  void unfulfill(AListMember member) {
    //do not allow the unfulfillment of other members
    if (member == _fulfiller) {
      _fulfiller = null;
    }

    assert(!isFulfilledBy(member));
  }

  @override
  int maxQuantity() {
    return 1;
  }

  @override
  int quantityPerMember() {
    return 1;
  }

  @override
  List<AListMember> getFulfillers() {
    return [_fulfiller];
  }

  @override
  bool isFulfilledBy(AListMember member) {
    return member == _fulfiller;
  }
}
