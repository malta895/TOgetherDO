import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/notification_manager.dart';
import 'package:mobile_applications/ui/notification_page.dart';
import 'package:provider/provider.dart';

class NotificationBadge extends StatelessWidget {
  final bool showNotificationPageWhenPressed;

  const NotificationBadge({
    Key? key,
    this.showNotificationPageWhenPressed: true,
  }) : super(key: key);

  Widget _buildBadge(BuildContext context) {
    return StreamBuilder<int>(
      initialData: 0,
      stream: ListAppNotificationManager.instance
          .getUnreadNotificationCountStream(context
                  .read<ListAppAuthProvider>()
                  .loggedInListAppUser
                  ?.databaseId ??
              ''),
      builder: (context, AsyncSnapshot<int> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Container();
          case ConnectionState.active:
          case ConnectionState.done:
            final notificationCount = snapshot.data ?? 0;
            return notificationCount > 0
                ? Positioned(
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
                  )
                : Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(height: 56),
        showNotificationPageWhenPressed
            ? IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationPage()),
                      )
                    })
            : const Icon(Icons.notifications),
        _buildBadge(context),
      ],
    );
  }
}
