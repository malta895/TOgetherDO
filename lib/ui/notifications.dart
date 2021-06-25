import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/models/notification.dart';

class NotificationPage extends StatefulWidget {
  static final String routeName = "/settings";
  _NotificationPage createState() => _NotificationPage();
}

class _NotificationPage extends State<NotificationPage> {
  final String title = 'Notifications';

  late FirebaseMessaging messaging;
  @override
  void initState() {
    super.initState();
    print("hello");
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      print(value);
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("user added");
      print(event.notification!.body);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(event.notification!.title!),
              content: Text(event.notification!.body!),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  final Set<ListAppNotification> notificationList = {
    ListAppNotification("Lorenzo", false),
    ListAppNotification("Luca", false),
  };

  Widget _buildListItems(BuildContext context) {
    return ListView.builder(
      itemCount: notificationList.length,
      itemBuilder: (context, i) {
        return _buildRow(context, notificationList.elementAt(i));
      },
    );
  }

  Widget _buildRow(BuildContext context, ListAppNotification notification) {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Colors.grey,
          width: 0.8,
        ))),
        child: ListTile(
          title: Text(
            notification.displayName.toString() + " added you to a list!",
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
  }

  @override
  Widget build(BuildContext context) {
    // ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: _buildListItems(context));
  }
}
