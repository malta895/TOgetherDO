import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
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
import 'package:mobile_applications/ui/settings_ui.dart';
import 'package:mobile_applications/ui/theme.dart';
import 'package:provider/provider.dart';

import '../mock_database.dart';
import '../unit/managers_test.dart';
import '../unit/managers_test.mocks.dart';

/*Widget createHomeScreen() => MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeChanger>(
          create: (_) => ThemeChanger(),
        ),
        ChangeNotifierProvider<ListAppNavDrawerStateInfo>(
          create: (_) => ListAppNavDrawerStateInfo(),
        ),
        Provider<ListAppAuthProvider>(
            create: (_) => ListAppAuthProvider(FirebaseAuth.instance)),
        StreamProvider(
          create: (context) => context.read<ListAppAuthProvider>().authState,
          //initially no user is logged in
          initialData: null,
        )
      ],
      child: MaterialApp(home: SettingsScreen()),
    );*/
=======
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_applications/services/manager_config.dart';

import '../mock_database.dart';
import '../unit/managers_test.dart';
import '../unit/managers_test.mocks.dart';

>>>>>>> aaf32aa77b0e4c959f01eb9d626eb41f799fd248
void main() {
  // initialize here cause it could be useful in tests
  FirebaseFirestore fakeFirebaseFirestore;
  setUpAll(() {
    fakeFirebaseFirestore = TestUtils.createMockDatabase();
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

  //ThemeData currentTheme = lightTheme;
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

  Widget createSettingsScreen() {
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
      child: MaterialApp(home: SettingsScreen()),
    );
  }

  group('Settings Page Widget Tests', () {
    testWidgets(
      'Testing if theme setting works',
      (tester) async {
<<<<<<< HEAD
        await tester.pumpWidget(createSettingsScreen());
=======
        await tester.pumpWidget(TestUtils.createHomeScreen());
>>>>>>> aaf32aa77b0e4c959f01eb9d626eb41f799fd248
        await tester.tap(find.byKey(const Key("theme setting")));
        await tester.pumpAndSettle(const Duration(seconds: 3));
        final textColorFinder =
            tester.widget<Text>(find.byKey(const Key("text")));
        expect(textColorFinder.style!.color, Colors.pinkAccent[400]);
      },
      skip: true, // TODO fix this tests
    );
  });
}
