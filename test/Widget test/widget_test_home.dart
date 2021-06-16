import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/home_lists.dart';
import 'package:provider/provider.dart';
import 'package:mobile_applications/ui/theme.dart';

Widget createHomeScreen() => MultiProvider(
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
      child: MaterialApp(home: ListHomePage()),
    );

void main() {
  group('Home Page Widget Tests', () {
    testWidgets('Testing if ListView shows up', (tester) async {
      await tester.pumpWidget(createHomeScreen());
      expect(find.byType(ListView), findsOneWidget);
    });
    /*testWidgets('Testing Scrolling', (tester) async {
      await tester.pumpWidget(createHomeScreen());
      expect(find.text('Item 0'), findsOneWidget);
      await tester.fling(find.byType(ListView), Offset(0, -200), 3000);
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsNothing);
    });*/
    testWidgets('Testing tap on list', (tester) async {
      await tester.pumpWidget(createHomeScreen());
      await tester.tap(find.byKey(Key("Item tile")).first);
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text("Buy groceries"), findsOneWidget);
    });
    testWidgets('Testing tap on "New List" button', (tester) async {
      await tester.pumpWidget(createHomeScreen());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.textContaining("I am the only one"), findsOneWidget);
    });
    /*testWidgets('Testing IconButtons', (tester) async {
      await tester.pumpWidget(createHomeScreen());
      expect(find.byIcon(Icons.favorite), findsNothing);
      await tester.tap(find.byIcon(Icons.favorite_border).first);
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text('Added to favorites.'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsWidgets);
      await tester.tap(find.byIcon(Icons.favorite).first);
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text('Removed from favorites.'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });*/
  });
}
