import 'package:mobile_applications/models/list_item.dart';
import 'package:mobile_applications/models/notification.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:test/test.dart';

void main() {
  var userTest = ListAppUser(
      databaseId: "123abdd",
      firstName: "testFirstName",
      lastName: "testLastName");
  group('Testing SimpleItem', () {
    var simpleTestItem =
        SimpleItem(name: "testing item", creatorUid: userTest.databaseId!);

    test(
      'The item should be fulfilled',
      () {
        simpleTestItem.fulfill(member: userTest);
        expect(simpleTestItem.fulfiller!.databaseId!, userTest.databaseId!);
      },
      skip: "TODO restore when item fulfillment is fixed",
    );

    test('The item should be unfulfilled', () {
      simpleTestItem.unfulfill(member: userTest);
      expect(simpleTestItem.fulfiller, null);
    });
  });
  group('Testing MultiFulfillmentItem', () {
    var multiFulfillmentTestItem = MultiFulfillmentItem(
        name: "testing item", maxQuantity: 5, creatorUid: userTest.databaseId!);

    test(
      'The item should be fulfilled',
      () {
        multiFulfillmentTestItem.fulfill(
            member: userTest, quantityFulfilled: 4);
        expect(
            multiFulfillmentTestItem.getFulfillers().contains(userTest), true);
      },
      skip: "TODO restore when item fulfillment is fixed",
    );

    test('The item should be unfulfilled', () {
      multiFulfillmentTestItem.unfulfill(member: userTest);
      expect(
          multiFulfillmentTestItem.getFulfillers().contains(userTest), false);
    });
  });
  group('Testing MultiMemberItem', () {
    var multiMemberTestItem = MultiFulfillmentMemberItem(
        name: "testing item",
        quantityPerMember: 3,
        maxQuantity: 5,
        creatorUid: userTest.databaseId!);

    test(
      'The item should be fulfilled',
      () {
        multiMemberTestItem.fulfill(member: userTest, quantityFulfilled: 5);
        expect(multiMemberTestItem.getFulfillers().contains(userTest), true);
      },
      skip: "TODO restore when item fulfillment is fixed",
    );

    test(
      'The item should be unfulfilled',
      () {
        // TODO fix this, it does not work because fullfils are not stored anywhere
        multiMemberTestItem.unfulfill(
            member: userTest, quantityUnfulfilled: -5);
        expect(multiMemberTestItem.getFulfillers().contains(userTest), false);
      },
      skip: "TODO restore when item fulfillment is fixed",
    );
  });
  group('Testing User functions', () {
    test('The full name should be returned', () {
      expect(userTest.fullName, "testFirstName testLastName");
    });

    test('The initials should be returned', () {
      expect(userTest.initials, "tt");
    });
  });

  final BaseItem simpleItem = SimpleItem(
      databaseId: '123',
      name: 'testSimpleItem',
      creatorUid: userTest.databaseId!);
  final simpleItemJson = simpleItem.toJson();

  group('Testing simpleItem to json', () {
    test('The item json should have type', () {
      expect(simpleItem.itemType, ItemType.simple);
      expect(simpleItem.toJson().containsKey('itemType'), true);
    });

    test('The item json should have type simple', () {
      expect(simpleItem.toJson()['itemType'], 'simple');
    });
    test('The simple item should have quantityPerMember = 1', () {
      expect(simpleItem.toJson()['quantityPerMember'] == 1, true);
    });
    test('The simple item should have maxQuantity = 1', () {
      expect(simpleItem.toJson()['maxQuantity'] == 1, true);
    });

    final simpleItemFromJson = SimpleItem.fromJson(simpleItemJson);
    test('The item should  have type simple', () {
      expect(simpleItemFromJson.itemType, ItemType.simple);
    });
  });

  final BaseItem multiFulfillmentItem = MultiFulfillmentItem(
      databaseId: '123',
      name: 'testMultiFulfillmentItem',
      maxQuantity: 3,
      creatorUid: userTest.databaseId!);
  final multiFulfillmentItemJson = multiFulfillmentItem.toJson();
  group('Testing multiFulfillmentItem to json', () {
    test('The item json should have type', () {
      expect(multiFulfillmentItem.toJson().containsKey('itemType'), true);
    });
    test('The simple item should have quantityPerMember = 1', () {
      expect(multiFulfillmentItem.toJson()['quantityPerMember'] == 1, true);
    });
    test('The simple item should have maxQuantity = 1', () {
      expect(multiFulfillmentItem.toJson()['maxQuantity'] == 3, true);
    });

    final multiFulfillmentItemFromJson =
        MultiFulfillmentItem.fromJson(multiFulfillmentItemJson);
    test('The item should  have type simple', () {
      expect(multiFulfillmentItemFromJson.itemType, ItemType.multiFulfillment);
    });
  });

  final BaseItem multiFulfillmentItemMember = MultiFulfillmentMemberItem(
      databaseId: '123',
      name: 'testmultiFulfillmentItemMember',
      maxQuantity: 3,
      quantityPerMember: 2,
      creatorUid: userTest.databaseId!);
  final multiFulfillmentItemMemberJson = multiFulfillmentItemMember.toJson();
  group('Testing multiFulfillmentItemMember to json', () {
    test('The item json should have type', () {
      expect(multiFulfillmentItemMember.toJson().containsKey('itemType'), true);
    });

    test('The simple item should have maxQuantity = 1', () {
      expect(multiFulfillmentItemMember.toJson()['maxQuantity'] == 3, true);
    });

    final BaseItem multiFulfillmentItemMemberFromJson =
        MultiFulfillmentMemberItem.fromJson(multiFulfillmentItemMemberJson);
    test('The item should  have type simple', () {
      expect(multiFulfillmentItemMemberFromJson.itemType,
          ItemType.multiFulfillmentMember);
    });
    test('The item should  have type simple', () {
      expect(
          (multiFulfillmentItemMemberFromJson as MultiFulfillmentMemberItem)
                  .quantityPerMember ==
              2,
          true);
    });

    final ListAppNotification listInviteNotification = ListInviteNotification(
      userToId: '123',
      userFromId: '456',
      status: NotificationStatus.pending,
      listOwnerId: '123',
      listId: '5',
      databaseId: '123',
    );
    final listInviteNotificationToJson = listInviteNotification.toJson();
    group('Test list invite notification', () {
      test('list invite type consinstency', () {
        expect(listInviteNotificationToJson['notificationType'], 'listInvite');
      });

      test('list invite type consinstency', () {
        expect(listInviteNotificationToJson['userToId'], '123');
      });

      test('list invite type consinstency', () {
        expect(listInviteNotificationToJson['databaseId'], '123');
      });
      test('list invite type consinstency', () {
        expect(listInviteNotificationToJson['listOwnerId'], '123');
      });

      final ListAppNotification listInviteNotificationFromJson =
          ListInviteNotification.fromJson(listInviteNotificationToJson);
      test('list invite type consinstency after json', () {
        expect(listInviteNotificationFromJson is ListInviteNotification, true);
      });
      test('list invite has correct id', () {
        expect(
            (listInviteNotificationFromJson as ListInviteNotification).listId,
            '5');
      });
    });

    final ListAppNotification friendshipNotification = FriendshipNotification(
      userToId: '123',
      userFromId: '456',
      status: NotificationStatus.pending,
      friendshipRequestMethod: FriendshipRequestMethod.email,
    );
    final friendshipNotificationToJson = friendshipNotification.toJson();
    group('Test list invite notification', () {
      test('list invite type consinstency', () {
        expect(friendshipNotificationToJson['notificationType'], 'friendship');
      });

      test('list invite type consinstency', () {
        expect(friendshipNotificationToJson['userToId'], '123');
      });

      final ListAppNotification friendshipNotificationFromJson =
          FriendshipNotification.fromJson(friendshipNotificationToJson);
      test('list invite type consinstency after json', () {
        expect(friendshipNotificationFromJson is FriendshipNotification, true);
      });

      test('list invite has correct id', () {
        expect(
            (friendshipNotificationFromJson as FriendshipNotification).userToId,
            '123');
        expect((friendshipNotificationFromJson).userFromId, '456');
      });
    });
  });
}
