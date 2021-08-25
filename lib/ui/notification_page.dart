import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/models/friendship.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/notification.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/friendship_manager.dart';
import 'package:mobile_applications/services/list_manager.dart';
import 'package:mobile_applications/services/notification_manager.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  static const String routeName = "/notifications";

  const NotificationPage();

  _NotificationPage createState() => _NotificationPage();
}

class _NotificationPage extends State<NotificationPage> {
  final String title = 'Notifications';

  late Future<List<ListAppNotification>> _notificationsFuture;

  Future<List<ListAppNotification>> _fetchNotifications() async {
    final listAppUser =
        await context.read<ListAppAuthProvider>().getLoggedInListAppUser();

    if (listAppUser != null) {
      return ListAppNotificationManager.instance
          .getNotificationsByUserId(listAppUser.databaseId, "createdAt");
    }

    return [];
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  bool _isManuallyRefreshing = false;

  /*final ListAppUser sender = ListAppUser(
      firstName: "Lorenzo",
      lastName: "Amici",
      email: "lorenzo.amici@mail.com",
      username: "lorenzo.amici@mail.com",
      databaseId: '',
      profilePictureURL:
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTVLqfekg_kitC_QJ5kgBUTh2tt5EIcxEnQDQ&usqp=CAU");*/

  /*final ListAppUser receiver = ListAppUser(
      firstName: "Mario",
      lastName: "Rossi",
      email: "lorenzo.amici@mail.com",
      username: "lorenzo.amici@mail.com",
      databaseId: '',
      profilePictureURL:
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTVLqfekg_kitC_QJ5kgBUTh2tt5EIcxEnQDQ&usqp=CAU");*/

  //final ListAppList list = ListAppList(name: "Birthday");

  final Set<ListAppNotification> notificationList = {};

  /*void addItemToList(ListAppUser sender, ListAppUser receiver, bool accepted) {
    setState(() {
      notificationList.add(FriendshipNotification(
          sender: sender, receiver: receiver, accepted: accepted));
    });
  }*/

  late FirebaseMessaging messaging;
  @override
  void initState() {
    super.initState();

    _notificationsFuture = _fetchNotifications();

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      if (!_isManuallyRefreshing) _refreshIndicatorKey.currentState?.show();
    });
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) => print(value));
    /*FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      final notification = event.notification;
      if (notification == null) return;
      //print("notifica ricevuta" + notification.body!);
      //COMMENTO PER PROVARE IL RETRIEVE DI FRIENDSHIP
      /*ListAppUserManager.instance.getUserByUid(data['sender']).then(
          (senderUser) => ListAppUserManager.instance
              .getUserByUid(data['receiver'])
              .then((receiverUser) =>
                  addItemToList(senderUser!, receiverUser!, false)));*/
    });*/
    /*FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });*/
  }

  Widget _buildListItems(
      BuildContext context, Set<ListAppNotification> notificationList) {
    return FutureBuilder<List<ListAppNotification>>(
      initialData: [],
      future: _notificationsFuture,
      builder: (context, AsyncSnapshot<List<ListAppNotification>> snapshot) {
        final notificationList = snapshot.data ?? [];

        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const Center(
                child: Text(
              "There are no notifications",
              style: TextStyle(fontSize: 22),
            ));
          case ConnectionState.waiting:
          case ConnectionState.active:
            return const Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.done:
            return notificationList.isNotEmpty
                ? ListView.builder(
                    itemCount: notificationList.length,
                    itemBuilder: (context, i) {
                      switch (notificationList[i].runtimeType) {
                        case FriendshipNotification:
                          return _buildFriendshipRow(context,
                              notificationList[i] as FriendshipNotification);

                        case ListInviteNotification:
                          return _buildInvitationRow(context,
                              notificationList[i] as ListInviteNotification);
                      }
                      return Container();
                    })
                : const Center(
                    child: Text(
                    "There are no notifications",
                    style: TextStyle(fontSize: 22),
                  ));
        }

        //return _buildRow(context, notificationList[i]);
      },
    );
  }

  Widget _buildFriendshipRow(
      BuildContext context, FriendshipNotification notification) {
    final _friendshipFuture =
        ListAppFriendshipManager.instance.getByUid(notification.friendshipId);

    return FutureBuilder<ListAppFriendship?>(
        future: _friendshipFuture,
        builder: (context, AsyncSnapshot<ListAppFriendship?> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return Container();
            case ConnectionState.done:
              switch (notification.status) {
                case NotificationStatus.pending:
                  return Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        color: Colors.grey,
                        width: 0.8,
                      ))),
                      child: ListTile(
                        leading: notification.sender?.profilePictureURL == null
                            ? const CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/sample-profile.png'),
                                radius: 25.0,
                              )
                            : CircleAvatar(
                                backgroundImage: NetworkImage(
                                    notification.sender!.profilePictureURL!)),
                        title: Text(
                          notification.sender!.displayName +
                              " sent you a friendship request",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle:
                            const Text("You can accept or decline the request"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                side: const BorderSide(
                                    color: Colors.green, width: 1),
                              ),
                              onPressed: () async {
                                notification.status =
                                    NotificationStatus.accepted;
                                await ListAppNotificationManager.instance
                                    .saveToFirestore(notification);
                                setState(() {
                                  _notificationsFuture = _fetchNotifications();
                                });
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
                                style: TextButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors.red, width: 1),
                                ),
                                onPressed: () async {
                                  notification.status =
                                      NotificationStatus.rejected;
                                  await ListAppNotificationManager.instance
                                      .saveToFirestore(notification);
                                  setState(() {
                                    _notificationsFuture =
                                        _fetchNotifications();
                                  });
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
                        leading: notification.sender?.profilePictureURL == null
                            ? const CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/sample-profile.png'),
                                radius: 25.0,
                              )
                            : CircleAvatar(
                                backgroundImage: NetworkImage(
                                    notification.sender!.profilePictureURL!)),
                        title: Text(
                          "You and " +
                              notification.sender!.displayName +
                              " are now friends!",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ));
                case NotificationStatus.rejected:
                  return Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        color: Colors.grey,
                        width: 0.8,
                      ))),
                      child: ListTile(
                          leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  notification.sender!.profilePictureURL!)),
                          title: Text(
                            "You rejected " +
                                notification.sender!.displayName +
                                "'s friendship request",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )));
              }
          }
        });
  }

  Widget _buildInvitationRow(
      BuildContext context, ListInviteNotification notification) {
    final notificationFuture =
        ListAppListManager.instanceForUserUid(notification.listOwner)
            .getByUid(notification.listId);
    return FutureBuilder<ListAppList?>(
        future: notificationFuture,
        builder: (context, AsyncSnapshot<ListAppList?> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              /*return Center(
                child: Text("Loading"),
              );*/
              break;
            case ConnectionState.done:
              switch (notification.status) {
                case NotificationStatus.pending:
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
                          notification.sender!.displayName +
                              " added you to the list \"" +
                              snapshot.data!.name +
                              "\"",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                            "You can accept or decline the invitation"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                                style: TextButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors.green, width: 1),
                                ),
                                onPressed: () async {
                                  await ListAppNotificationManager.instance
                                      .acceptNotification(
                                          notification.databaseId!);
                                  setState(() {
                                    _notificationsFuture =
                                        _fetchNotifications();
                                  });
                                },
                                child: const Icon(
                                  Icons.done,
                                  color: Colors.green,
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            TextButton(
                                style: TextButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors.red, width: 1),
                                ),
                                onPressed: () async {
                                  await ListAppNotificationManager.instance
                                      .rejectNotification(
                                          notification.databaseId!);
                                  setState(() {
                                    _notificationsFuture =
                                        _fetchNotifications();
                                  });
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
                        leading: const Icon(
                          Icons.list,
                          size: 30,
                        ),
                        title: Text(
                          "You are now in the \"" +
                              snapshot.data!.name +
                              " list \"",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                            "Click on this tile to explore the list!"),
                        //TODO make the onTap redirect to the list page
                        onTap: () => print("Redirect to the list page"),
                      ));

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
                          "You rejected the invitation to the \"" +
                              snapshot.data!.name +
                              "\" list",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ));
              }
          }
          return Container();
        });
  }

//COMMENTO PER PROVARE IL RETRIEVE DI FRIENDSHIP
/*Widget _buildRow(BuildContext context, ListAppNotification notification) {
    final currentListAppUser =
        context.read<ListAppAuthProvider>().loggedInListAppUser!;

    switch (notification.runtimeType) {
      case ListInviteNotification:
        return Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              color: Colors.grey,
              width: 0.8,
            ))),
            child: ListTile(
              leading: Icon(
                Icons.list,
                size: 30,
              ),
              title: Text(
                notification.sender.displayName +
                    " added you to the list \"" +
                    notification.list!.name +
                    "\"",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("You can accept or decline the invitation"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                      style: TextButton.styleFrom(
                        side: BorderSide(color: Colors.green, width: 1),
                      ),
                      onPressed: () => print("YES"),
                      child: Icon(
                        Icons.done,
                        color: Colors.green,
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                        side: BorderSide(color: Colors.red, width: 1),
                      ),
                      onPressed: () => print("NO"),
                      child: Icon(
                        Icons.close,
                        color: Colors.red,
                      ))
                ],
              ),
            ));
      case FriendshipNotification:
        return Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              color: Colors.grey,
              width: 0.8,
            ))),
            child: ListTile(
              leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(notification.sender.profilePictureURL!)),
              title: Text(
                notification.sender.displayName +
                    " sent you a friendship request",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("You can accept or decline the request"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                      style: TextButton.styleFrom(
                        side: BorderSide(color: Colors.green, width: 1),
                      ),
                      onPressed: () => print("YES"),
                      child: Icon(
                        Icons.done,
                        color: Colors.green,
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                        side: BorderSide(color: Colors.red, width: 1),
                      ),
                      onPressed: () => print("NO"),
                      child: Icon(
                        Icons.close,
                        color: Colors.red,
                      ))
                ],
              ),
            ));
    }
    //the code should never reach this point, but we need it for null check
    return ListTile(
      title: Text("Empty element"),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () async {
            _isManuallyRefreshing = true;
            setState(() {
              _notificationsFuture = _fetchNotifications();
            });
            _isManuallyRefreshing = false;
          },
          child: _buildListItems(context, notificationList)),
    );
  }
}
