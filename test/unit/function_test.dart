import 'package:mobile_applications/models/list_item.dart';
import 'package:test/test.dart';
import 'package:mobile_applications/models/user.dart';

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
}