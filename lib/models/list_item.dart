// This model represents a list of our applicationrt 'package:json_annotation/json_annotation.dart';

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
        return 'It can only be completed by one person';
      case ItemType.multiFulfillment:
        return 'It can be completed once by each person in the list.';
      case ItemType.multiFulfillmentMember:
        return 'It can be completed more times by any member in the list';
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
  String name;
  String? description;
  final String? link;
  final int maxQuantity;
  final int quantityPerMember;
  final String creatorUid;

  Map<String, int> usersCompletions = {};

  final ItemType itemType;

  BaseItem({
    String? databaseId,
    Set<String>? users,
    Map<String, int>? usersCompletions,
    required this.name,
    this.description,
    this.link,
    required this.maxQuantity,
    required this.quantityPerMember,
    required this.itemType,
    required this.creatorUid,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this.usersCompletions = usersCompletions ?? <String, int>{},
        super(
          databaseId: databaseId,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  int quantityFulfilledBy(ListAppUser member);

  bool isFulfilled();

  //fulfill, aka complete, this list item, with a quantity. returns false if the item was fulfilled already
  /*bool fulfill({required ListAppUser member, int quantityFulfilled = 0});

  bool unfulfill({required ListAppUser member, int quantityUnfulfilled = 0});*/

  Set<ListAppUser> getFulfillers();

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
  @JsonKey(ignore: true)
  ListAppUser? fulfiller;

  SimpleItem({
    String? databaseId,
    Set<String>? users,
    Map<String, int>? usersCompletions,
    required String name,
    String? description,
    String? link,
    required String creatorUid,
    createdAt,
    DateTime? updatedAt,
  }) : super(
          itemType: ItemType.simple,
          databaseId: databaseId,
          usersCompletions: usersCompletions,
          name: name,
          description: description,
          link: link,
          maxQuantity: 1,
          quantityPerMember: 1,
          createdAt: createdAt,
          updatedAt: updatedAt,
          creatorUid: creatorUid,
        ) {
    if (usersCompletions != null && usersCompletions.isNotEmpty) {
      ListAppUserManager.instance
          .getByUid(usersCompletions.keys.first)
          .then((value) {
        fulfiller = value;
      });
    }
  }

  @override
  bool isFulfilled() {
    return usersCompletions.isNotEmpty;
  }

  @override
  int quantityFulfilledBy(ListAppUser member) {
    return member == fulfiller ? 1 : 0;
  }

  factory SimpleItem.fromJson(Map<String, dynamic> json) =>
      _$SimpleItemFromJson(json);

  @override
  Set<ListAppUser> getFulfillers() {
    if (fulfiller == null) return {};
    return Set.from([fulfiller]);
  }
}

/// List item with multiple fulfillments, members can fulfill once
@JsonSerializable(
  checked: true,
) // see https://flutter.dev/docs/development/data-and-backend/json#code-generation
class MultiFulfillmentItem extends BaseItem {
  @JsonKey(ignore: true)
  Set<ListAppUser> fulfillers = Set<ListAppUser>();

  MultiFulfillmentItem({
    String? databaseId,
    Map<String, int>? usersCompletions,
    required String name,
    String? description,
    String? link,
    required int maxQuantity,
    required String creatorUid,
    createdAt,
    DateTime? updatedAt,
  }) : super(
          itemType: ItemType.multiFulfillment,
          databaseId: databaseId,
          usersCompletions: usersCompletions,
          name: name,
          description: description,
          link: link,
          maxQuantity: maxQuantity,
          quantityPerMember: 1,
          createdAt: createdAt,
          creatorUid: creatorUid,
          updatedAt: updatedAt,
        ) {
    if (usersCompletions != null && usersCompletions.isNotEmpty) {
      usersCompletions.forEach((key, value) {
        ListAppUserManager.instance
            .getByUid(key)
            .then((value) => fulfillers.add(value!));
      });
    }
  }

  @override
  Set<ListAppUser> getFulfillers() {
    /*final members = Set<ListAppUser>();
    fulfillers!.map((e) async {
      final member = await ListAppUserManager.instance.getByUid(e);
      members.add(member!);
    });*/
    if (fulfillers.isEmpty) return Set<ListAppUser>();
    return Set<ListAppUser>.from(fulfillers);
  }

  @override
  bool isFulfilled() {
    return usersCompletions.length == maxQuantity;
  }

  @override
  int quantityFulfilledBy(ListAppUser member) {
    return usersCompletions.keys.contains(member.databaseId) ? 1 : 0;
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
  @JsonKey(ignore: true)
  Set<ListAppUser> fulfillers = Set<ListAppUser>();

  MultiFulfillmentMemberItem({
    String? databaseId,
    Map<String, int>? usersCompletions,
    required String name,
    String? description,
    String? link,
    required int maxQuantity,
    required int quantityPerMember,
    required String creatorUid,
    createdAt,
    DateTime? updatedAt,
  }) : super(
          itemType: ItemType.multiFulfillmentMember,
          databaseId: databaseId,
          usersCompletions: usersCompletions,
          name: name,
          description: description,
          link: link,
          maxQuantity: maxQuantity,
          quantityPerMember: quantityPerMember,
          createdAt: createdAt,
          updatedAt: updatedAt,
          creatorUid: creatorUid,
        ) {
    if (usersCompletions != null && usersCompletions.isNotEmpty) {
      usersCompletions.forEach((key, value) {
        ListAppUserManager.instance
            .getByUid(key)
            .then((value) => fulfillers.add(value!));
      });
    }
  }

  @override
  Set<ListAppUser> getFulfillers() {
    if (fulfillers.isEmpty) return Set<ListAppUser>();
    return Set<ListAppUser>.from(fulfillers);
  }

  @override
  bool isFulfilled() {
    // the item is complete when the max quantity has been reached.
    return usersCompletions.isEmpty
        ? false
        : usersCompletions.values.reduce((total, element) => total + element) >=
            maxQuantity;
  }

  @override
  int quantityFulfilledBy(ListAppUser member) {
    return usersCompletions[member.databaseId] == null
        ? 0
        : usersCompletions[member.databaseId]!;
  }

  factory MultiFulfillmentMemberItem.fromJson(Map<String, dynamic> json) =>
      _$MultiFulfillmentMemberItemFromJson(json);
}
