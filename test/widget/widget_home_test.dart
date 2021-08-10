import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/manager_config.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:mobile_applications/ui/list_details_page.dart';
import 'package:mobile_applications/ui/lists_page.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/new_list.dart';
import 'package:mobile_applications/ui/theme.dart';
import 'package:provider/provider.dart';

import '../mock_database.dart';
import '../unit/managers_test.dart';
import '../unit/managers_test.mocks.dart';

void main() {
  // initialize here cause it could be useful in tests
  FirebaseFirestore fakeFirebaseFirestore;
  setUpAll(() {
    fakeFirebaseFirestore = MockDatabase.createMockDatabase();
    final fakeFirebaseStorage = MockFirebaseStorage();
    final fakeFirebaseFunctions = MockFirebaseFunctions();
    final fakeHttpsCallable = MockHttpsCallableResult();
    final fakeHttpsCallableResult = MockHttpsCallableResult();

    ManagerConfig.initialize(
      firebaseStorage: fakeFirebaseStorage,
      firebaseFirestore: fakeFirebaseFirestore,
      firebaseFunctions: fakeFirebaseFunctions,
    );
  });

  Widget createHomeScreen() {
    final mockUser = MockUser(
      uid: 'user1_id',
      email: "john@doe.com",
      displayName: 'John Doe',
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeChanger>(
          create: (_) => ThemeChanger(),
        ),
        ChangeNotifierProvider<ListAppNavDrawerStateInfo>(
          create: (_) => ListAppNavDrawerStateInfo(),
        ),
        ChangeNotifierProvider(
          create: (_) => ListAppAuthProvider(
            MockFirebaseAuth(
              signedIn: true,
              mockUser: mockUser,
            ),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ListAppUserManager.instance),
      ],
      child: MaterialApp(home: ListsPage()),
    );
  }

  group('Home Page Widget Tests', () {
    testWidgets('ListView should show up and show the lists in the database',
        (tester) async {
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();

      // the owned list should be shown
      expect(find.text("Nuova lista"), findsOneWidget);

      //the list in which the user is member should be shown
      expect(find.text("Fare la spesa"), findsOneWidget);
    });

    testWidgets('Tap on list should show list details', (tester) async {
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();
      // the key of the list is the database id of the list
      await tester.tap(find.byKey(const Key("list1_id")));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // we should be in the list details page, and not anymore in lists page
      expect(find.byType(ListDetailsPage), findsOneWidget);
      expect(find.byType(ListsPage), findsNothing);

      // we should find the description and title of the list
      expect(find.text("Nuova lista"), findsOneWidget);
      expect(find.text("Lista numero 1"), findsOneWidget);
    });

    testWidgets('Testing tap on "New List" button', (tester) async {
      await tester.pumpWidget(createHomeScreen());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // we should be in the create list page, and not anymore in lists page
      expect(find.byType(NewListPage), findsOneWidget);
      expect(find.byType(ListsPage), findsNothing);
    });

    // TODO add other tests (drawer, notifications, ...)
  });
}
