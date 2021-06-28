import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/notification.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/user_manager.dart';

//users/lGmqaAgJZqVIdqXt3GmQFNC9E3D3
//users/9LUBLCszUrU4mukuRWhHFS2iexL2

class NotificationPage extends StatefulWidget {
  static final String routeName = "/settings";
  _NotificationPage createState() => _NotificationPage();
}

class _NotificationPage extends State<NotificationPage> {
  final String title = 'Notifications';

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

  final ListAppList list = ListAppList(name: "Birthday");

  final Set<ListAppNotification> notificationList = {};

  void addItemToList(ListAppUser sender, ListAppUser receiver, bool accepted) {
    setState(() {
      notificationList.add(FriendshipNotification(
          sender: sender, receiver: receiver, accepted: accepted));
    });
  }

  late FirebaseMessaging messaging;
  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      print(value);
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      final notification = event.notification;
      final data = event.data;
      if (notification == null) return;
      /*showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(notification.title ?? ''),
              content: Text(notification.body ?? ''),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });*/
      /*FriendshipNotification newNotification = FriendshipNotification(
          sender: ListAppUser(
              databaseId: sender.get("databaseId"), email: sender.get("email")),
          receiver: ListAppUser(
              databaseId: receiver.get("databaseId"),
              email: receiver.get("email")),
          accepted: false);*/
      ListAppUserManager.instance.getUserByUid(data['sender']).then(
          (senderUser) => ListAppUserManager.instance
              .getUserByUid(data['receiver'])
              .then((receiverUser) =>
                  addItemToList(senderUser!, receiverUser!, false)));
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  Widget _buildListItems(
      BuildContext context, Set<ListAppNotification> notificationList) {
    return ListView.builder(
      itemCount: notificationList.length,
      itemBuilder: (context, i) {
        return _buildRow(context, notificationList.elementAt(i));
      },
    );
  }

  Widget _buildRow(BuildContext context, ListAppNotification notification) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: _buildListItems(context, notificationList));
  }
}
