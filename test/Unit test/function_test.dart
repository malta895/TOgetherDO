import 'package:mobile_applications/models/list_item.dart';
import 'package:test/test.dart';
import 'package:mobile_applications/models/user.dart';

void main() {
  var userTest = ListAppUser(
      email: "prova@test.com",
      firstName: "testFirstName",
      lastName: "testLastName");
  group('Testing SimpleItem', () {
    var simpleTestItem = SimpleItem(name: "testing item");

    test('The item should be fulfilled', () {
      simpleTestItem.fulfill(userTest, 1);
      expect(simpleTestItem.fulfiller, userTest);
    });

    test('The item should be unfulfilled', () {
      simpleTestItem.unfulfill(userTest);
      expect(simpleTestItem.fulfiller, null);
    });
  });
  group('Testing MultiFulfillmentItem', () {
    var multiFulfillmentTestItem =
        MultiFulfillmentItem(name: "testing item", maxQuantity: 5);

    test('The item should be fulfilled', () {
      multiFulfillmentTestItem.fulfill(userTest, 4);
      expect(multiFulfillmentTestItem.getFulfillers().contains(userTest), true);
    });

    test('The item should be unfulfilled', () {
      multiFulfillmentTestItem.unfulfill(userTest);
      expect(
          multiFulfillmentTestItem.getFulfillers().contains(userTest), false);
    });
  });
  group('Testing MultiMemberItem', () {
    var multiMemberTestItem = MultiFulfillmentMemberItem(
        name: "testing item", maxItemsPerMember: 3, maxQuantity: 5);

    test('The item should be fulfilled', () {
      multiMemberTestItem.fulfill(userTest, 3);
      expect(multiMemberTestItem.getFulfillers().contains(userTest), true);
    });

    test('The item should be unfulfilled', () {
      multiMemberTestItem.unfulfill(userTest);
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
}
