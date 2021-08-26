import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/notification_manager.dart';
import 'package:mobile_applications/ui/notification_page.dart';
import 'package:provider/provider.dart';

class NotificationBadge extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationBadge();
}

class _NotificationBadge extends State<NotificationBadge> {
  late Future<int> _unansweredNotificationsCountFuture;

  Future<int> _fetchNotificationCount() async {
    final listAppUser =
        await context.read<ListAppAuthProvider>().getLoggedInListAppUser();

    if (listAppUser != null) {
      return ListAppNotificationManager.instance
          .getUnansweredNotifications(listAppUser.databaseId!, "createdAt");
    }

    return Future.value(0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _unansweredNotificationsCountFuture = _fetchNotificationCount();
  }

  Widget _buildBellOnly() {
    return Stack(children: <Widget>[
      Container(height: 56),
      IconButton(
        icon: const Icon(Icons.notifications),
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationPage()),
          )
        },
      )
    ]);
  }

  Widget _buildIcon(BuildContext context) {
    return FutureBuilder<int>(
        initialData: 0,
        future: _unansweredNotificationsCountFuture,
        builder: (context, AsyncSnapshot<int> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return _buildBellOnly();
            case ConnectionState.done:
              final notificationCount = snapshot.data!;
              return notificationCount > 0
                  ? Stack(children: <Widget>[
                      Container(height: 56),
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const NotificationPage()),
                          )
                        },
                      ),
                      Positioned(
                        // draw a red marble
                        top: 7.0,
                        right: 7.0,
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            const Icon(
                              Icons.brightness_1,
                              size: 15.0,
                              color: Colors.redAccent,
                            ),
                            Text(
                              notificationCount.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textScaleFactor: 0.7,
                            ),
                          ],
                        ),
                      ),
                    ])
                  : _buildBellOnly();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return _buildIcon(context);
  }
}
