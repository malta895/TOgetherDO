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
          .getUnreadNotificationCount(listAppUser.databaseId!);
    }

    return 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _unansweredNotificationsCountFuture = _fetchNotificationCount();
  }

  Widget _buildBell() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
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
      ],
    );
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
              return _buildBell();
            case ConnectionState.done:
              var notificationCount = snapshot.data!;
              return notificationCount > 0
                  ? Stack(children: <Widget>[
                      _buildBell(),
                      Positioned(
                        // draw a red marble
                        top: 9.0,
                        right: 7.0,
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            const Icon(
                              Icons.brightness_1,
                              size: 18.0,
                              color: Colors.redAccent,
                            ),
                            notificationCount < 100
                                ? Text(
                                    notificationCount.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textScaleFactor:
                                        notificationCount < 10 ? 0.8 : 0.7,
                                  )
                                : const Text(
                                    "99+",
                                    textScaleFactor: 0.6,
                                  ),
                          ],
                        ),
                      ),
                    ])
                  : _buildBell();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return _buildIcon(context);
  }
}
