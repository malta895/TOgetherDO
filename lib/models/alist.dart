// This model represents a list of our application
import 'dart:collection';
import 'dart:core';

class AList {
  // A at the start to avoid confusion with Dart List
  // TODO make sure everything's here

  final int id;
  final String name;
  final String description;
  final int maxMembers = 5;
  final int maxItems = 5;

  //Set and not List because Sets have unique elements
  Set<AListMember> members;

  AList(this.id, this.name, this.description);
}

// a member of a list
class AListMember {
  // TODO make sure everything's here
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

class AListItem {
  // TODO maybe is better to make this a base class and subclass with the other types of items (purchasable, with quantity, without quantity etc)

  final int id;
  final String name;
  final String description;
  final bool isPurchasable;
  final int price;
  final int quantity;
  final bool isShareable;

  // members who completed this item. the int is the quantity of fulfilled items
  HashMap<AListMember, int> _fulfillments;

  AListItem(this.id, this.name, this.description, this.isPurchasable,
      this.price, this.quantity, this.isShareable);

  bool isCompleted() {
    // do the cumulative sum of all the fullfillments, if it equals the quantity the element is complete
    int fulfilledQuantity =
        _fulfillments.values.reduce((value, element) => value + element);

    return fulfilledQuantity >= quantity;
  }

  AListItem.constructSimpleItem(int id, String name, String description)
      : this.id = id,
        this.name = name,
        this.description = description,
        isPurchasable = false,
        price = null,
        quantity = 0,
        isShareable = false;

  void fulfillSingle(AListMember member) => fulfill(member, 1);
  void fulfill(AListMember member, int fulfilledQuantity) {
    // fulfill this element with a quantity. check the constraints on the quantity
    _fulfillments.update(member, (previousQuantity) {
      if (previousQuantity + fulfilledQuantity <= quantity) {
        return previousQuantity + fulfilledQuantity;
      } else {
        return quantity; // TODO throw an error instead
      }
    }, ifAbsent: () {
      if (fulfilledQuantity <= quantity) {
        return fulfilledQuantity;
      } else {
        return quantity; // TODO throw an error instead
      }
    });
  }

  void unFulfill(AListMember member) {
    // completely remove member from the fulfillments
    _fulfillments.remove(member);
  }
}
