import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/list_manager.dart';
import 'package:mobile_applications/services/user_manager.dart';

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

class _ListsPageState extends State<ListsPage>
    with SingleTickerProviderStateMixin {
  final String title = 'ListApp';

  late AnimationController _animationController;

  Future<List<ListAppList>>? _listsFuture;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  bool _isManuallyRefreshing = false;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, value: 0.0, duration: const Duration(milliseconds: 150))
      ..addStatusListener((AnimationStatus status) {
        setState(() {});
      });
    super.initState();

    _listsFuture = _fetchLists();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      if (!_isManuallyRefreshing) _refreshIndicatorKey.currentState?.show();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _listsFuture = _fetchLists();
  }

  bool get _isAnimationRunningForwardsOrComplete {
    switch (_animationController.status) {
      case AnimationStatus.forward:
      case AnimationStatus.completed:
        return true;
      case AnimationStatus.reverse:
      case AnimationStatus.dismissed:
        return false;
    }
  }

  Future<List<ListAppList>>? _fetchLists() async {
    _animationController.reverse();
    final listAppUser =
        await context.read<ListAppAuthProvider>().getLoggedInListAppUser();

    if (listAppUser != null) {
      // return ListAppListManager.instanceForUser(listAppUser).getLists();
      final lists = await ListAppUserManager.instance.getLists(listAppUser);
      return lists;
    }

    return Future.value(null);
  }

  Future<void> _deleteOrAbandonList(ListAppList list) async {
    final listAppUser =
        await context.read<ListAppAuthProvider>().getLoggedInListAppUser();

    if (listAppUser != null && list.creatorUid == listAppUser.username) {
      await ListAppListManager.instanceForUser(listAppUser).deleteList(list);
    } else {}
  }

  Widget _buildAnimated(BuildContext context, List<ListAppList> listAppLists) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, _) {
          return FadeScaleTransition(
            animation: _animationController,
            child: ListView.builder(
              itemCount: listAppLists.length,
              itemBuilder: (context, i) {
                return _buildRow(context, listAppLists[i]);
              },
            ),
          );
        });
  }

  Future<void> _refreshPage() async {
    if (_isAnimationRunningForwardsOrComplete)
      await _animationController.reverse();
    _isManuallyRefreshing = true;
    final _newListsFuture = _fetchLists()
      ?..then((value) => _animationController.forward());
    setState(() {
      _listsFuture = _newListsFuture;
    });
    _isManuallyRefreshing = false;
  }

  Widget _buildListItems(BuildContext context) {
    return FutureBuilder<List<ListAppList>>(
        initialData: [],
        future: _listsFuture,
        builder: (context, AsyncSnapshot<List<ListAppList>> snapshot) {
          final listAppLists = snapshot.data ?? [];

          late Widget listsTable;

          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              listsTable = Container();
              break;
            case ConnectionState.done:
              listsTable = _buildAnimated(context, listAppLists);
          }

          //The refresh indicator is shown when we swipe from the upper side of the screen
          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refreshPage,
            child: listsTable,
          );
        });
  }

  Widget _buildRow(BuildContext context, ListAppList listAppList) {
    final currentListAppUser =
        context.read<ListAppAuthProvider>().loggedInListAppUser!;

    final bool userOwnsList =
        listAppList.creatorUid == currentListAppUser.databaseId;

    return Dismissible(
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  "Are you sure you wish to ${userOwnsList ? 'delete' : 'leave'} the " +
                      listAppList.name +
                      " list?"),
              content: userOwnsList
                  ? Text(
                      "You and all the other participants will not see this list anymore")
                  : Text(
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
      dismissThresholds: {DismissDirection.startToEnd: 0.3},
      direction: DismissDirection.startToEnd,
      background: Container(
          color: Colors.red,
          child: Align(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 20,
                ),
                Icon(
                  Icons.delete,
                ),
              ],
            ),
            alignment: Alignment.centerLeft,
          )),
      key: UniqueKey(),
      onDismissed: (DismissDirection direction) async {
        await _deleteOrAbandonList(listAppList);
        setState(() {
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
            leading: Icon(
              Icons.list,
              size: 40,
            ),
            trailing: Column(
              children: [
                Icon(
                  Icons.date_range,
                  size: 20,
                ),
                // see https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html
                Text(DateFormat('MMM dd').format(listAppList.createdAt)),
                Text(DateFormat.jm().format(listAppList.createdAt)),
              ],
            ),
            title: Text(
              listAppList.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            isThreeLine: true,
            subtitle: Text((userOwnsList
                    ? 'Me'
                    : listAppList.creator?.username ?? 'unknown') +
                "\n${listAppList.length} element${listAppList.length == 1 ? '' : 's'}"),
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
            await _refreshPage();
          },
          icon: Icon(Icons.add),
          label: Text('NEW LIST'),
        ));
  }
}
