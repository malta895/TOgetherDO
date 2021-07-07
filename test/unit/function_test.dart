import 'package:mobile_applications/models/list_item.dart';
import 'package:mobile_applications/models/notification.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:test/test.dart';

void main() {
  var userTest = ListAppUser(
      databaseId: "123abdd",
      email: "prova@test.com",
      firstName: "testFirstName",
      lastName: "testLastName");
  group('Testing SimpleItem', () {
    var simpleTestItem = SimpleItem(name: "testing item");

    test('The item should be fulfilled', () {
      simpleTestItem.fulfill(member: userTest);
      expect(simpleTestItem.fulfiller, userTest);
    });

    test('The item should be unfulfilled', () {
      simpleTestItem.unfulfill(member: userTest);
      expect(simpleTestItem.fulfiller, null);
    });
  });
  group('Testing MultiFulfillmentItem', () {
    var multiFulfillmentTestItem =
        MultiFulfillmentItem(name: "testing item", maxQuantity: 5);

    test('The item should be fulfilled', () {
      multiFulfillmentTestItem.fulfill(member: userTest, quantityFulfilled: 4);
      expect(multiFulfillmentTestItem.getFulfillers().contains(userTest), true);
    });

    test('The item should be unfulfilled', () {
      multiFulfillmentTestItem.unfulfill(member: userTest);
      expect(
          multiFulfillmentTestItem.getFulfillers().contains(userTest), false);
    });
  });
  group('Testing MultiMemberItem', () {
    var multiMemberTestItem = MultiFulfillmentMemberItem(
        name: "testing item", quantityPerMember: 3, maxQuantity: 5);

    test('The item should be fulfilled', () {
      multiMemberTestItem.fulfill(member: userTest, quantityFulfilled: 5);
      expect(multiMemberTestItem.getFulfillers().contains(userTest), true);
    });

    test('The item should be unfulfilled', () {
      multiMemberTestItem.unfulfill(member: userTest);
      expect(multiMemberTestItem.getFulfillers().contains(userTest), false);
    });
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
  );
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
  );
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
  );
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
      userId: '123',
      userFrom: '456',
      status: NotificationStatus.undefined,
      listOwner: '123',
      listId: '5',
      databaseId: '123',
    );
    final listInviteNotificationToJson = listInviteNotification.toJson();
    group('Test list invite notification', () {
      test('list invite type consinstency', () {
        expect(listInviteNotificationToJson['notificationType'], 'listInvite');
      });

      test('list invite type consinstency', () {
        expect(listInviteNotificationToJson['userId'], '123');
      });

      test('list invite type consinstency', () {
        expect(listInviteNotificationToJson['databaseId'], '123');
      });
      test('list invite type consinstency', () {
        expect(listInviteNotificationToJson['listOwner'], '123');
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
      userId: '123',
      userFrom: '456',
      status: NotificationStatus.undefined,
      friendshipId: 'abc',
    );
    final friendshipNotificationToJson = friendshipNotification.toJson();
    group('Test list invite notification', () {
      test('list invite type consinstency', () {
        expect(friendshipNotificationToJson['notificationType'], 'friendship');
      });

      test('list invite type consinstency', () {
        expect(friendshipNotificationToJson['userId'], '123');
      });

      final ListAppNotification friendshipNotificationFromJson =
          FriendshipNotification.fromJson(friendshipNotificationToJson);
      test('list invite type consinstency after json', () {
        expect(friendshipNotificationFromJson is FriendshipNotification, true);
      });

      test('list invite has correct id', () {
        expect(
            (friendshipNotificationFromJson as FriendshipNotification)
                .friendshipId,
            'abc');
      });
    });
  });
}
