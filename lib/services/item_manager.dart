import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/list_item.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/database_manager.dart';
import 'package:mobile_applications/services/manager_config.dart';
import 'package:mobile_applications/services/user_manager.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_applications/models/exception.dart';

/// The item manager. This is not a singleton as a new instance is created for each subcollection
class ListAppItemManager extends DatabaseManager<BaseItem> {
  final String listUid;
  final String userUid;
  //cache the instances to avoid creating new ones every time we operate on the same list
  static final Map<String, ListAppItemManager> _cachedInstances = {};

  ListAppItemManager._privateConstructor(this.listUid, this.userUid)
      : super(ManagerConfig.firebaseFirestoreInstance
            .collection(ListAppUser.collectionName)
            .doc(userUid)
            .collection(ListAppList.collectionName)
            .doc(listUid)
            .collection(BaseItem.collectionName)
            .withConverter<BaseItem>(
                fromFirestore: (snapshots, _) =>
                    BaseItem.fromJson(snapshots.data()!),
                toFirestore: (instance, _) => instance.toJson()));

  static ListAppItemManager instanceForList(String listUid, String userUid) {
    if (_cachedInstances.containsKey(listUid)) {
      return _cachedInstances[listUid]!;
    }

    ListAppItemManager newInstance =
        ListAppItemManager._privateConstructor(listUid, userUid);

    _cachedInstances[listUid] = newInstance;

    return newInstance;
  }

  Future<BaseItem?> getItemByUid(String uid) async {
    try {
      final queryResult = await this.firebaseCollection.doc(uid).get();
      return queryResult.data();
    } on CheckedFromJsonException catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<BaseItem>> getItems() async {
    final queryResult = await this.firebaseCollection.get();

    final listWithNulls = queryResult.docs.map((e) {
      try {
        return e.data();
      } on CheckedFromJsonException catch (e) {
        print(e);
        return null;
      }
    }).toList();

    listWithNulls.removeWhere((element) => element == null);

    return listWithNulls.cast<BaseItem>();
  }

  Future<bool> listItemNameExists(String name) async {
    final queryResult =
        await this.firebaseCollection.where("name", isEqualTo: name).get();
    //print(queryResult.docs.first.data());
    return queryResult.docs.isNotEmpty;
  }

  Future<void> updateItemName(String itemName, BaseItem aListItem) async {
    try {
      await this
          .firebaseCollection
          .doc(aListItem.databaseId)
          .update({'name': itemName});
      //notifyListeners();
    } on FirebaseException catch (e) {
      print(e.message);
      throw ListAppException('An error occurred. Please try again later.');
    } on CheckedFromJsonException catch (e) {
      print(e.message);
      throw ListAppException('An error occurred. Please try again later.');
    }
  }

  Future<void> updateItemDescription(
      String itemDescription, BaseItem aListItem) async {
    try {
      await this
          .firebaseCollection
          .doc(aListItem.databaseId)
          .update({'description': itemDescription});
      //notifyListeners();
    } on FirebaseException catch (e) {
      print(e.message);
      throw ListAppException('An error occurred. Please try again later.');
    } on CheckedFromJsonException catch (e) {
      print(e.message);
      throw ListAppException('An error occurred. Please try again later.');
    }
  }

  Future<bool> fulfillItem(
      String uid, String lid, BaseItem item, int completions) async {
    switch (item.itemType) {
      case ItemType.simple:
        if (item.usersCompletions.isEmpty) {
          final simpleItem = item as SimpleItem;
          simpleItem.usersCompletions[uid] = 1;
          simpleItem.fulfiller =
              await ListAppUserManager.instance.getByUid(uid);
          await ListAppItemManager.instanceForList(lid, uid)
              .saveToFirestore(simpleItem);
          return true;
        }
        return false;

      case ItemType.multiFulfillment:
        if (!item.usersCompletions.keys.toList().contains(uid)) {
          final multiFulfillmentItem = item as MultiFulfillmentItem;
          multiFulfillmentItem.usersCompletions[uid] = 1;
          final fulfiller = await ListAppUserManager.instance.getByUid(uid);
          if (fulfiller != null) {
            multiFulfillmentItem.fulfillers!.add(fulfiller);
          }

          await ListAppItemManager.instanceForList(lid, uid)
              .saveToFirestore(multiFulfillmentItem);
          return true;
        }
        return false;

      case ItemType.multiFulfillmentMember:
        if (!item.usersCompletions.keys.toList().contains(uid)) {
          final multiFulfillmentMemberItem = item as MultiFulfillmentMemberItem;
          multiFulfillmentMemberItem.usersCompletions[uid] = completions;
          final fulfiller = await ListAppUserManager.instance.getByUid(uid);
          if (fulfiller != null) {
            multiFulfillmentMemberItem.fulfillers!.add(fulfiller);
          }
          print(multiFulfillmentMemberItem.fulfillers!);
          await ListAppItemManager.instanceForList(lid, uid)
              .saveToFirestore(multiFulfillmentMemberItem);
          return true;
        } else if (item.usersCompletions.keys.toList().contains(uid)) {
          final multiFulfillmentMemberItem = item as MultiFulfillmentMemberItem;
          multiFulfillmentMemberItem.usersCompletions[uid] =
              multiFulfillmentMemberItem.usersCompletions[uid]! + completions;
          await ListAppItemManager.instanceForList(lid, uid)
              .saveToFirestore(multiFulfillmentMemberItem);
          return true;
        }
        return false;
    }
  }

  Future<bool> unfulfillItem(
      String uid, String lid, BaseItem item, int uncompletions) async {
    switch (item.itemType) {
      case ItemType.simple:
        if (item.usersCompletions.keys.toList()[0] == uid) {
          final simpleItem = item as SimpleItem;
          simpleItem.usersCompletions.remove(uid);
          simpleItem.fulfiller = null;
          await ListAppItemManager.instanceForList(lid, uid)
              .saveToFirestore(simpleItem);
          return true;
        }
        return false;

      case ItemType.multiFulfillment:
        if (item.usersCompletions.keys.toList().contains(uid)) {
          final multiFulfillmentItem = item as MultiFulfillmentItem;
          multiFulfillmentItem.usersCompletions.remove(uid);
          final fulfiller = await ListAppUserManager.instance.getByUid(uid);
          if (fulfiller != null) {
            multiFulfillmentItem.fulfillers!.removeWhere(
                (element) => element.databaseId == fulfiller.databaseId);
          }
          await ListAppItemManager.instanceForList(lid, uid)
              .saveToFirestore(multiFulfillmentItem);
          return true;
        }
        return false;

      case ItemType.multiFulfillmentMember:
        if (item.usersCompletions.keys.toList().contains(uid)) {
          final multiFulfillmentMemberItem = item as MultiFulfillmentMemberItem;
          if (multiFulfillmentMemberItem.usersCompletions[uid]! +
                  uncompletions <=
              0) {
            multiFulfillmentMemberItem.usersCompletions.remove(uid);
            final fulfiller = await ListAppUserManager.instance.getByUid(uid);
            if (fulfiller != null) {
              multiFulfillmentMemberItem.fulfillers!.removeWhere(
                  (element) => element.databaseId == fulfiller.databaseId);
            }
          } else {
            multiFulfillmentMemberItem.usersCompletions[uid] =
                multiFulfillmentMemberItem.usersCompletions[uid]! +
                    uncompletions;
          }
          await ListAppItemManager.instanceForList(lid, uid)
              .saveToFirestore(multiFulfillmentMemberItem);
          return true;
        }
        return false;
    }
  }

  Future<Set<ListAppUser>> getFulfillers(String lid, BaseItem item) async {
    final members = Set<ListAppUser>();

    item.usersCompletions.keys.map((e) async {
      final member = await ListAppUserManager.instance.getByUid(e);
      print("MEMBER IN MULTIMEMBER GETFULFILLERS MANAGER");
      print(member!.firstName);
      members.add(member);
    });
    return members;
  }

  /*Future<bool> checkCompletionsForItem(String itemId) async {
    final queryResult = await ManagerConfig.firebaseFirestoreInstance
        .collection(ListAppUser.collectionName)
        .doc(userUid)
        .collection(ListAppList.collectionName)
        .doc(listUid)
        .collection("completions")
        .where(itemId, isEqualTo: itemId)
        .get();

    print("COMPLETIONS");
    print(queryResult.docs.first.data());

    return queryResult.docs.isNotEmpty;
  }*/
}
