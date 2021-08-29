import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_cloud_functions_mock/firebase_cloud_functions_mock.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_applications/models/notification.dart';
import 'package:mobile_applications/services/manager_config.dart';
import 'package:mobile_applications/services/notification_manager.dart';
import 'package:mobile_applications/ui/lists_page.dart';
import 'package:mobile_applications/ui/notification_badge.dart';

import '../mock_database.dart';

void main() {
  // initialize here cause it could be useful in tests
  FirebaseFirestore fakeFirebaseFirestore;
  setUpAll(() {
    fakeFirebaseFirestore = TestUtils.createMockDatabase();
    final fakeFirebaseStorage = MockFirebaseStorage();
    final fakeFirebaseFunctions = MockCloudFunctions();

    ManagerConfig.initialize(
      firebaseStorage: fakeFirebaseStorage,
      firebaseFirestore: fakeFirebaseFirestore,
      firebaseFunctions: fakeFirebaseFunctions,
    );
  });

  group('Home Page Widget Tests', () {
    testWidgets(
      'Notifications page should show up',
      (tester) async {
        // let's start from the home page
        await tester
            .pumpWidget(TestUtils.createScreen(screen: const ListsPage()));
        await tester.pumpAndSettle();

        ListAppNotificationManager.instance
            .saveToFirestore(FriendshipNotification(
          userFromId: "user4_id",
          userToId: "user1_id",
          friendshipRequestMethod: FriendshipRequestMethod.email,
        ));
        await tester.pumpAndSettle();
        // there's a pending notification, it should be shown on the badge
        expect(
            find.byWidgetPredicate((widget) =>
                widget is Text &&
                widget.key == const Key("notification_count_text") &&
                widget.data == '1'),
            findsOneWidget);

        await tester.tap(find.byType(NotificationBadge));
        await tester.pumpAndSettle();

        expect(find.text("NEW"), findsOneWidget);
        expect(find.text("READ"), findsOneWidget);
        expect(find.text('John DoeFriend4 sent you a friendship request'),
            findsOneWidget);

        // check the read notifications tab
        await tester.tap(find.byWidgetPredicate(
            (widget) => widget is Tab && widget.text == 'READ'));
        await tester.pumpAndSettle();
        expect(find.text('John DoeFriend4 sent you a friendship request'),
            findsNothing);
        expect(find.textContaining('There are no notifications.\n'),
            findsOneWidget);

        // go back to the unread and accept the notification
        // check the read notifications tab
        await tester.tap(find.byWidgetPredicate(
            (widget) => widget is Tab && widget.text == 'NEW'));
        await tester.pumpAndSettle();
        expect(find.text('John DoeFriend4 sent you a friendship request'),
            findsOneWidget);

        await tester.tap(find.byKey(const Key("accept_text_button_user4_id")));
        await tester.pumpAndSettle();

        expect(find.textContaining('There are no notifications.\n'),
            findsOneWidget);

        await tester.tap(find.byWidgetPredicate(
            (widget) => widget is Tab && widget.text == 'READ'));
        await tester.pumpAndSettle();
        expect(find.text("You and John DoeFriend4 are now friends!"),
            findsOneWidget);
      },
    );
  });
}
