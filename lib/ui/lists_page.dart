import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/list_manager.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:mobile_applications/ui/list_view_page.dart';
import 'package:mobile_applications/ui/navigation_drawer.dart';
import 'package:mobile_applications/ui/new_list.dart';
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

  late AnimationController _listsShowAnimationController;

  Future<List<ListAppList>>? _listsFuture;

  List<ListAppList> _listAppLists = [];

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  bool _isManuallyRefreshing = false;

  @override
  void initState() {
    _listsShowAnimationController = AnimationController(
        vsync: this, value: 0.0, duration: const Duration(milliseconds: 400))
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
    _listsShowAnimationController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // refresh when we get back from other pages
    // _refreshPage();
  }

  bool get _isAnimationRunningForwardsOrComplete {
    switch (_listsShowAnimationController.status) {
      case AnimationStatus.forward:
      case AnimationStatus.completed:
        return true;
      case AnimationStatus.reverse:
      case AnimationStatus.dismissed:
        return false;
    }
  }

  Future<List<ListAppList>>? _fetchLists() async {
    _listsShowAnimationController.reverse();
    final listAppUser =
        await context.read<ListAppAuthProvider>().getLoggedInListAppUser();

    if (listAppUser != null) {
      // return ListAppListManager.instanceForUser(listAppUser).getLists();
      final lists = await ListAppUserManager.instance
          .getLists(listAppUser, orderBy: 'createdAt');
      return lists;
    }

    return Future.value(null);
  }

  Future<void> _deleteOrAbandonList(ListAppList list) async {
    final listAppUser =
        await context.read<ListAppAuthProvider>().getLoggedInListAppUser();

    if (listAppUser != null && list.creatorUid == listAppUser.databaseId) {
      await ListAppListManager.instanceForUser(listAppUser).deleteList(list);
      setState(() {
        final removeItem = _listAppLists
            .indexWhere((element) => element.databaseId == list.databaseId);

        _animatedListKey.currentState?.removeItem(removeItem, (_, __) {
          // I don't want any animation other than the one of the dismissible
          // returning an empty container seems to work
          return Container();
        });

        _listAppLists.removeAt(removeItem);
      });
    } else {
      // TODO Implement abandon list
    }
  }

  final _animatedListKey = GlobalKey<AnimatedListState>();

  Widget _buildAnimated(BuildContext context) {
    return AnimatedBuilder(
        animation: _listsShowAnimationController,
        builder: (context, _) {
          return FadeScaleTransition(
            animation: _listsShowAnimationController,
            child: AnimatedList(
              key: _animatedListKey,
              initialItemCount: _listAppLists.length,
              itemBuilder: (context, i, animation) {
                return SlideTransition(
                    position: animation.drive(
                        Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
                            .chain(CurveTween(curve: Curves.ease))),
                    child: _buildRow(context, _listAppLists[i]));
                // return _buildRow(context, _listAppLists[i]);
              },
            ),
          );
        });
  }

  Future<void> _refreshPage() async {
    if (_isAnimationRunningForwardsOrComplete)
      await _listsShowAnimationController.reverse();
    _isManuallyRefreshing = true;
    final _newListsFuture = _fetchLists()
      ?..then((value) => _listsShowAnimationController.forward());
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
              _listAppLists = listAppLists;
              listsTable = _buildAnimated(context);
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

    final bool doesUserOwnList =
        listAppList.creatorUid == currentListAppUser.databaseId;

    return Dismissible(
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  "Are you sure you wish to ${doesUserOwnList ? 'delete' : 'leave'} the " +
                      listAppList.name +
                      " list?"),
              content: doesUserOwnList
                  ? Text(
                      "You and all the other participants will not see this list anymore")
                  : Text(
                      "If you push LEAVE, you will abandon this list and you won't be able to join it unless someone invites you again"),
              actions: <Widget>[
                TextButton(
                    style: TextButton.styleFrom(primary: Colors.red),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(doesUserOwnList ? 'DELETE' : 'LEAVE')),
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
            subtitle: Text((doesUserOwnList
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
            final ListAppList? newList = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewListPage()),
            );

            if (newList != null) {
              setState(() {
                _listAppLists.insert(0, newList);
                _animatedListKey.currentState
                    ?.insertItem(0, duration: Duration(milliseconds: 700));
              });
            }
          },
          icon: Icon(Icons.add),
          label: Text('NEW LIST'),
        ));
  }
}
