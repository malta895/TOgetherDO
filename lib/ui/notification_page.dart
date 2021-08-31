import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/notification.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/list_manager.dart';
import 'package:mobile_applications/services/notification_manager.dart';
import 'package:mobile_applications/ui/lists_details_page/list_details_page.dart';
import 'package:mobile_applications/ui/notification_badge.dart';
import 'package:mobile_applications/ui/widgets/empty_list_widget.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class NotificationPage extends StatefulWidget {
  static const String routeName = "/notifications";

  const NotificationPage();

  _NotificationPage createState() => _NotificationPage();
}

class _NotificationPage extends State<NotificationPage> {
  static const String title = 'Notifications';

  late final Stream<List<ListAppNotification>> _unreadNotificationsStream;
  late final Stream<List<ListAppNotification>> _readNotificationsStream;
  final StreamController<List<ListAppNotification>>
      _unreadNotificationsStreamController = BehaviorSubject();
  final StreamController<List<ListAppNotification>>
      _readNotificationsStreamController = BehaviorSubject();

  final Map<Timer, ListAppNotification> _readTimers = {};

  @override
  void dispose() {
    _readTimers.forEach((timer, notification) {
      timer.cancel();
      ListAppNotificationManager.instance.saveToFirestore(notification);
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _unreadNotificationsStream = ListAppNotificationManager.instance
        .getNotificationsStream(
            context.read<ListAppAuthProvider>().getLoggedInListAppUser(), true);
    _unreadNotificationsStreamController.addStream(_unreadNotificationsStream);

    _readNotificationsStream = ListAppNotificationManager.instance
        .getNotificationsStream(
            context.read<ListAppAuthProvider>().getLoggedInListAppUser(),
            false);
    _readNotificationsStreamController.addStream(_readNotificationsStream);
  }

  Widget _buildNotificationItems(
    BuildContext context,
    bool showUnread,
  ) {
    return StreamBuilder<List<ListAppNotification>>(
      initialData: [],
      stream: showUnread
          ? _unreadNotificationsStreamController.stream
          : _readNotificationsStreamController.stream,
      builder: (context, AsyncSnapshot<List<ListAppNotification>> snapshot) {
        final notificationList = snapshot.data ?? [];
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            return notificationList.isNotEmpty
                ? ListView.builder(
                    itemCount: notificationList.length,
                    itemBuilder: (context, i) {
                      if (notificationList[i].readStatus ==
                          NotificationReadStatus.opened) {
                        notificationList[i].readStatus =
                            NotificationReadStatus.read;

                        Timer t = Timer(
                            const Duration(seconds: 6),
                            () async => await ListAppNotificationManager
                                .instance
                                .saveToFirestore(notificationList[i]));
                        _readTimers[t] = notificationList[i];
                      }

                      switch (notificationList[i].notificationType) {
                        case NotificationType.friendship:
                          return _buildFriendshipRow(
                            context,
                            notificationList[i] as FriendshipNotification,
                          );
                        case NotificationType.listInvite:
                          return _buildInvitationRow(
                            context,
                            notificationList[i] as ListInviteNotification,
                          );
                      }
                    })
                : const EmptyListRefreshable(
                    "There are no notifications.\nCome back again!",
                  );
        }
      },
    );
  }

  Widget _buildFriendshipRow(
    BuildContext context,
    FriendshipNotification notification,
  ) {
    switch (notification.status) {
      case NotificationStatus.pending:
        return Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                  width: 0.8,
                ),
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: notification.userFrom?.profilePictureURL ==
                        null
                    ? const AssetImage('assets/sample-profile.png')
                        as ImageProvider
                    : NetworkImage(notification.userFrom!.profilePictureURL!),
                radius: 25.0,
              ),
              title: Text(
                "${notification.userFrom!.displayName} sent you a friendship request",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("You can accept or decline the request"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    key: Key(
                        "accept_friend_text_button_${notification.userFromId}"),
                    style: TextButton.styleFrom(
                      side: const BorderSide(color: Colors.green, width: 1),
                    ),
                    onPressed: () async {
                      await ListAppNotificationManager.instance
                          .answerNotification(
                              notification, NotificationStatus.accepted);
                    },
                    child: const Icon(
                      Icons.done,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  TextButton(
                      key: Key(
                          "refuse_friend_text_button_${notification.userFromId}"),
                      style: TextButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1),
                      ),
                      onPressed: () async {
                        await ListAppNotificationManager.instance
                            .answerNotification(
                                notification, NotificationStatus.rejected);
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                      ))
                ],
              ),
            ));
      case NotificationStatus.accepted:
        return Container(
          decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(
            color: Colors.grey,
            width: 0.8,
          ))),
          child: ListTile(
            leading: notification.userFrom?.profilePictureURL == null
                ? const CircleAvatar(
                    backgroundImage: AssetImage('assets/sample-profile.png'),
                    radius: 25.0,
                  )
                : CircleAvatar(
                    backgroundImage: NetworkImage(
                        notification.userFrom!.profilePictureURL!)),
            title: Text(
              "You and ${notification.userFrom!.displayName} are now friends!",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      case NotificationStatus.rejected:
        return Container(
          decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(
            color: Colors.grey,
            width: 0.8,
          ))),
          child: ListTile(
            leading: notification.userFrom?.profilePictureURL == null
                ? const CircleAvatar(
                    backgroundImage: AssetImage('assets/sample-profile.png'),
                    radius: 25.0,
                  )
                : CircleAvatar(
                    backgroundImage: NetworkImage(
                        notification.userFrom!.profilePictureURL!)),
            title: Text(
              "You rejected ${notification.userFrom!.displayName}'s friendship request.",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
    }
  }

  Widget _buildInvitationRow(
    BuildContext context,
    ListInviteNotification notification,
  ) {
    switch (notification.status) {
      case NotificationStatus.pending:
        return Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 0.8,
              ),
            ),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.list,
              size: 30,
            ),
            title: Text(
              "${notification.userFrom!.displayName} added you to the list ${notification.list!.name}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("You can accept or decline the invitation"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  key:
                      Key("accept_list_text_button_${notification.userFromId}"),
                  style: TextButton.styleFrom(
                    side: const BorderSide(color: Colors.green, width: 1),
                  ),
                  onPressed: () async {
                    await ListAppNotificationManager.instance
                        .answerNotification(
                      notification,
                      NotificationStatus.accepted,
                    );
                  },
                  child: const Icon(
                    Icons.done,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                  key:
                      Key("refuse_list_text_button_${notification.userFromId}"),
                  style: TextButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 1),
                  ),
                  onPressed: () async {
                    await ListAppNotificationManager.instance
                        .answerNotification(
                      notification,
                      NotificationStatus.rejected,
                    );
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                )
              ],
            ),
          ),
        );

      case NotificationStatus.accepted:
        return Container(
          decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(
            color: Colors.grey,
            width: 0.8,
          ))),
          child: ListTile(
            leading: const Icon(
              Icons.list,
              size: 30,
            ),
            title: Text(
              "You are now in the ${notification.list!.name} list!",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Tap here to explore the list!"),
            onTap: () async {
              await ListAppListManager.instanceForUserUid(
                      notification.userFromId)
                  .populateObjects(notification.list!);

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ListDetailsPage(
                      notification.list!,
                      // the list comes from the invitation from someone else, so the current user is not the owner for sure
                      canAddNewMembers: false,
                      canAddNewItems:
                          (notification.list!.listType == ListType.private)
                              ? false
                              : true),
                ),
              );
            },
          ),
        );

      case NotificationStatus.rejected:
        return Container(
          decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(
            color: Colors.grey,
            width: 0.8,
          ))),
          child: ListTile(
            leading: const Icon(
              Icons.list,
              size: 30,
            ),
            title: Text(
              "You rejected the invitation to the ${notification.list!.name} list",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(title),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                text: "NEW",
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 6.3),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 56,
                      maxHeight: 30,
                    ),
                    child: NotificationBadge(
                      showNotificationPageWhenPressed: false,
                    ),
                  ),
                ),
              ),
              const Tab(text: "READ", icon: Icon(Icons.notifications_none)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNotificationItems(context, true),
            _buildNotificationItems(context, false),
          ],
        ),
      ),
    );
  }
}
