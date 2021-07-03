import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/ui/notification_page.dart';
import 'package:mobile_applications/services/notification_manager.dart';

class NotificationBadge extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationBadge();
}

class _NotificationBadge extends State<NotificationBadge> {
  late Future<int> unansweredNotifications;

  Future<int> getNotificationNumber() async {
    final listAppUser =
        await context.read<ListAppAuthProvider>().getLoggedInListAppUser();

    if (listAppUser != null) {
      print("GETNOTIFICATIONNUMBER" + listAppUser.databaseId);
      return ListAppNotificationManager.instance
          .getUnansweredNotifications(listAppUser.databaseId, "createdAt");
    }

    return Future.value(0);
  }

  @override
  void initState() {
    super.initState();

    unansweredNotifications = getNotificationNumber();
    getNotificationNumber().then((value) => print(value));
  }

  Widget _buildIcon(BuildContext context) {
    return FutureBuilder<int>(
        initialData: 0,
        future: unansweredNotifications,
        builder: (context, AsyncSnapshot<int> snapshot) {
          if (snapshot.data != null) {
            if (snapshot.data! > 0)
              return Stack(children: <Widget>[
                Container(height: 56),
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationPage()),
                    )
                  },
                ),
                Positioned(
                  // draw a red marble
                  top: 7.0,
                  right: 7.0,
                  child: new Icon(Icons.brightness_1,
                      size: 15.0, color: Colors.redAccent),
                )
              ]);
          }

          return Stack(children: <Widget>[
            Container(height: 56),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage()),
                )
              },
            )
          ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return _buildIcon(context);
  }
}
