import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/settings_ui.dart';
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
      child: MaterialApp(home: SettingsScreen()),
    );
void main() {
  //ThemeData currentTheme = lightTheme;
  group('Settings Page Widget Tests', () {
    testWidgets('Testing if theme setting works', (tester) async {
      await tester.pumpWidget(createHomeScreen());
      await tester.tap(find.byKey(Key("theme setting")));
      await tester.pumpAndSettle(Duration(seconds: 1));
      final textColorFinder = tester.widget<Text>(find.byType(Text));
      expect(textColorFinder.style!.color, Colors.pinkAccent[400]);
      //expect(find.text("Dark theme").style.color, findsOneWidget);
    });
  });
}
