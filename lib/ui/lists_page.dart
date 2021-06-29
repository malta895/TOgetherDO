import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/list_manager.dart';

import 'package:mobile_applications/ui/list_view_page.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/new_list.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/ui/notification_page.dart';
import 'package:provider/provider.dart';

class ListsPage extends StatefulWidget {
  static final String routeName = "/home";
  static final String humanReadableName = "My Lists";

  @override
  _ListsPageState createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  final String title = 'ListApp';

  Future<List<ListAppList>>? _listsFuture;

  Future<List<ListAppList>>? _fetchLists() async {
    final listAppUser =
        await context.read<ListAppAuthProvider>().getLoggedInListAppUser();

    if (listAppUser != null) {
      return ListAppListManager.instanceForUser(listAppUser).getLists();
    }
    return Future.value(null);
  }

  Future<void> _deleteList(ListAppList list) async {
    final listAppUser =
        await context.read<ListAppAuthProvider>().getLoggedInListAppUser();

    if (listAppUser != null) {
      ListAppListManager.instanceForUser(listAppUser).deleteList(list);
    }
    return;
  }

  @override
  void initState() {
    super.initState();

    _listsFuture = _fetchLists();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _listsFuture = _fetchLists();
  }

  Widget _buildListItems(BuildContext context) {
    return FutureBuilder<List<ListAppList>>(
        initialData: [],
        future: _listsFuture,
        builder: (context, AsyncSnapshot<List<ListAppList>> snapshot) {
          final listAppList = snapshot.data ?? [];

          return ListView.builder(
            itemCount: listAppList.length,
            itemBuilder: (context, i) {
              return _buildRow(context, listAppList[i]);
            },
          );
        });
  }

  Widget _buildRow(BuildContext context, ListAppList listAppList) {
    final currentListAppUser =
        context.read<ListAppAuthProvider>().loggedInListAppUser!;

    final creatorUsernameOrMe =
        listAppList.creatorUsername == currentListAppUser.username
            ? 'Me'
            : currentListAppUser.username;
    return Dismissible(
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Are you sure you wish to delete the " +
                  "\"${listAppList.name}\"" +
                  " list?"),
              content: Text(
                  "If you push DELETE, you will abandon this list and it won't show on your homepage"),
              actions: <Widget>[
                TextButton(
                    style: TextButton.styleFrom(primary: Colors.red),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("DELETE")),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("CANCEL"),
                ),
              ],
            );
          },
        );
      },
      dismissThresholds: {DismissDirection.endToStart: 0.3},
      direction: DismissDirection.endToStart,
      background: Container(
          color: Colors.red,
          child: Align(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
            alignment: Alignment.centerLeft,
          )),
      key: UniqueKey(),
      onDismissed: (DismissDirection direction) {
        setState(() {
          _deleteList(listAppList);
          _listsFuture = _fetchLists();
        });
      },
      child: Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
            //                   <--- left side
            color: Colors.grey,
            width: 0.8,
          ))),
          child: ListTile(
            key: Key("Item tile"),
            title: Text(
              listAppList.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            isThreeLine: true,
            subtitle: Text(
                "$creatorUsernameOrMe\n${listAppList.length} element${listAppList.length == 1 ? '' : 's'}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ListViewRoute(listAppList)),
              );
            },
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage()),
                )
              },
            ),
          ],
        ),
        drawer: ListAppNavDrawer(ListsPage.routeName),
        body: _buildListItems(context),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            // wait for the new list page to be popped,
            //in order to be able to update the state with the new list afterwards
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewListPage()),
            );

            setState(() {
              _listsFuture = _fetchLists();
            });
          },
          icon: Icon(Icons.add),
          label: Text('NEW LIST'),
        ));
  }
}
