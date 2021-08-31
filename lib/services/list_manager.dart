import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/database_manager.dart';
import 'package:mobile_applications/services/item_manager.dart';
import 'package:mobile_applications/services/manager_config.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:mobile_applications/services/utils.dart';

/// Implemented as a Multiton
class ListAppListManager extends DatabaseManager<ListAppList> {
  static Query? _collectionGroup;
  static Query<ListAppList?>? _collectionGroupConverted;
  final String _userUid;

  static Query getCollectionGroup() {
    _collectionGroup ??= ManagerConfig.firebaseFirestoreInstance
        .collectionGroup(ListAppList.collectionName);
    return _collectionGroup!;
  }

  static Query<ListAppList?> getCollectionGroupConverted() {
    _collectionGroupConverted ??= ManagerConfig.firebaseFirestoreInstance
        .collectionGroup(ListAppList.collectionName)
        .withConverter<ListAppList?>(
            fromFirestore: (snapshots, _) {
              final snapshotsData = snapshots.data();
              if (snapshotsData == null) return null;
              return ListAppList.fromJson(snapshotsData);
            },
            toFirestore: (list, _) => list!.toJson());
    return _collectionGroupConverted!;
  }

  static final Map<String, ListAppListManager> _cachedInstances = {};

  ListAppListManager._privateConstructor(this._userUid)
      : super(ManagerConfig.firebaseFirestoreInstance
            .collection(ListAppUser.collectionName)
            .doc(_userUid)
            .collection(ListAppList.collectionName)
            .withConverter<ListAppList?>(
                fromFirestore: (snapshots, _) {
                  final snapshotsData = snapshots.data();
                  if (snapshotsData == null) return null;
                  return ListAppList.fromJson(snapshotsData);
                },
                toFirestore: (list, _) => list!.toJson()));

  static ListAppListManager instanceForUser(ListAppUser user) =>
      instanceForUserUid(user.databaseId!);
  static ListAppListManager instanceForUserUid(String userUid) {
    if (_cachedInstances.containsKey(userUid)) {
      return _cachedInstances[userUid]!;
    }

    ListAppListManager newInstance =
        ListAppListManager._privateConstructor(userUid);

    _cachedInstances[userUid] = newInstance;

    return newInstance;
  }

  final FirebaseFirestore firestoreInstance =
      ManagerConfig.firebaseFirestoreInstance;

  /// Get all the lists the user is in, as owner or as member
  Future<List<ListAppList>> getUserLists(ListAppUser user,
      {String? orderBy}) async {
    // the owned lists are already in this instance of the manager
    final queryResultOwnedLists = await this.firebaseCollection.get();

    final queryResultMemberLists = await getCollectionGroupConverted()
        .where('members.' + user.databaseId!, isEqualTo: true)
        .get();

    final combinedQueryResult =
        queryResultMemberLists.docs.followedBy(queryResultOwnedLists.docs);

    final listAppLists = combinedQueryResult
        .where((element) => ManagerUtils.doesElementConvertFromJson(element))
        .map((listDocumentSnapshot) async {
      final ListAppList listAppList = listDocumentSnapshot.data()!;

      await populateObjects(listAppList);

      return listAppList;
    }).toList();

    final awaitedLists = await Future.wait(listAppLists);

    switch (orderBy) {
      case 'createdAt':
        awaitedLists.sort((a, b) {
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
    }

    return awaitedLists;
  }

  /// Retrieves and injects objects by id in the list
  @override
  Future<void> populateObjects(ListAppList listAppList) async {
    // inject creator
    listAppList.creator =
        await ListAppUserManager.instance.getByUid(listAppList.creatorUid!);

    // inject users
    for (final entry in listAppList.members.entries) {
      final listAppUser = await ListAppUserManager.instance.getByUid(entry.key);

      if (listAppUser != null && entry.value == true) {
        listAppList.membersAsUsers.add(listAppUser);
      }
    }

    //inject items
    listAppList.items = await ListAppItemManager.instanceForList(
      listAppList.databaseId!,
      listAppList.creatorUid!,
    ).getItems();
  }

  Future<bool> addMemberToList(String listId, String userId) async {
    firebaseCollection.doc(listId).update({"members.$userId": false});

    return true;
  }

  Future<bool> removeMemberFromList(ListAppList list, String userId) async {
    list.members.remove(userId);
    for (final item in list.items) {
      item.usersCompletions.remove(userId);
      await ListAppItemManager.instanceForList(list.databaseId!, userId)
          .saveToFirestore(item);
    }

    await ListAppListManager.instanceForUserUid(list.creatorUid!)
        .saveToFirestore(list);

    return true;
  }

  /// The current user leaves the passed list
  Future<bool> leaveList(ListAppList list) async {
    try {
      return removeMemberFromList(list, _userUid);
    } on CheckedFromJsonException catch (_) {
      return false;
    }
  }
}
