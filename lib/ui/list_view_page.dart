import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/list_item.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/ui/new_item.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class ListViewPage extends StatefulWidget {
  final ListAppList listAppList;

  ListViewPage(this.listAppList) {
    _createMockItems();
  }

  void _createMockItems() {
    if (listAppList.membersAsUsers != null &&
        listAppList.membersAsUsers.isNotEmpty) return;

    listAppList.membersAsUsers = Set<ListAppUser>();

    //TODO fetch from backend instead
    listAppList.membersAsUsers.addAll([
      ListAppUser(
          databaseId: "siaodkjasd",
          username: "lawfriends",
          firstName: "Lorenzo",
          lastName: "Amici",
          email: "lawfriends12@gmail.com"),
      ListAppUser(
          databaseId: "asdjhfka",
          username: "malta.95",
          firstName: "Luca",
          lastName: "Maltagliati",
          email: "malta95@gmail.com"),
      ListAppUser(
          databaseId: "asdjhfka",
          username: "malta.95",
          firstName: "Luca",
          lastName: "Maltagliati",
          email: "malta95@gmail.com"),
      ListAppUser(
          databaseId: "asdjhfka",
          username: "malta.95",
          firstName: "Luca",
          lastName: "Maltagliati",
          email: "malta95@gmail.com"),
      ListAppUser(
          databaseId: "asdjhfka",
          username: "malta.95",
          firstName: "Luca",
          lastName: "Maltagliati",
          email: "malta95@gmail.com"),
    ]);

    listAppList.items = Set<BaseItem>();
    /* aList.items.addAll([
      SimpleItem(1, "Simple element - undone", "A simple undone element"),
      SimpleItem(2, "Simple element - done", "A simple done element"),
      SimpleItem(3, "Buy groceries", "go to buy some groceries"),
      MultiFulfillmentItem(
          4, "Buy movie tickets", "go to buy some movie tickets", 5),
      MultiFulfillmentMemberItem(5, "Lord of the rings trilogy",
          "the complete lord of the rings trilogy", 5, 3),
    ]); */
    listAppList.items.addAll([
      SimpleItem(name: "Simple element - undone"),
      SimpleItem(name: "Simple element - done"),
      SimpleItem(name: "Buy groceries"),
      SimpleItem(
          name:
              "This is a very long item title to see how it fits in the screen"),
      MultiFulfillmentItem(name: "Take out old sofa", maxQuantity: 5),
      MultiFulfillmentMemberItem(
          name: "Buy movie tickets", maxQuantity: 5, quantityPerMember: 3),
    ]);
    listAppList.items
        .elementAt(1)
        .fulfill(member: listAppList.membersAsUsers.elementAt(0));
    listAppList.items.elementAt(5).fulfill(
        member: listAppList.membersAsUsers.elementAt(1), quantityFulfilled: 2);
    listAppList.items
        .elementAt(4)
        .fulfill(member: listAppList.membersAsUsers.elementAt(0));
    listAppList.items
        .elementAt(4)
        .fulfill(member: listAppList.membersAsUsers.elementAt(1));
    listAppList.items
        .elementAt(4)
        .fulfill(member: listAppList.membersAsUsers.elementAt(2));
    listAppList.items
        .elementAt(4)
        .fulfill(member: listAppList.membersAsUsers.elementAt(3));
  }

  @override
  _ListViewPageState createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  late ListAppUser _loggedInListAppUser;
  late final HashMap<ListAppUser, Color> _assignedColors =
      HashMap<ListAppUser, Color>();

  @override
  void initState() {
    super.initState();

    if (widget.listAppList.membersAsUsers.isNotEmpty) {
      var it = widget.listAppList.membersAsUsers.iterator;
      int index = 0;
      while (index <= Colors.primaries.length && it.moveNext()) {
        _assignedColors[it.current] = Colors.primaries[index];
        ++index;
      }
      index = 0;
      while (index <= Colors.accents.length && it.moveNext()) {
        _assignedColors[it.current] = Colors.accents[index];
        ++index;
      }
      // if at this point we still have members just take random colors
      while (it.moveNext()) {
        _assignedColors[it.current] =
            Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                .withOpacity(1.0);
      }
    }

    _loggedInListAppUser =
        context.read<ListAppAuthProvider>().loggedInListAppUser!;
  }

  _addListItem(BaseItem item) {
    setState(() {
      widget.listAppList.items.add(item);
    });
  }

  Widget _buildAlertDialogMembers(
      int membersNum, Set<ListAppUser> itemMembers) {
    return Container(
      height: 300,
      width: 300,
      child: ListView.builder(
        itemCount: membersNum,
        itemBuilder: (context, i) {
          return _buildMemberRow(context, itemMembers.elementAt(i));
        },
      ),
    );
  }

  Widget _buildAlertDialogMembersAndQuantity(
      int membersNum, Set<ListAppUser> itemMembers, List<int> quantities) {
    return Container(
      height: 300,
      width: 300,
      child: ListView.builder(
        itemCount: membersNum,
        itemBuilder: (context, i) {
          return _buildMemberRowAndQuantity(
              context, itemMembers.elementAt(i), quantities.elementAt(i));
        },
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, BaseItem aListItem) {
    switch (aListItem.itemType) {
      case ItemType.simple:
        return Dismissible(
          confirmDismiss: (DismissDirection direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title:
                      const Text("Are you sure you wish to delete this item?"),
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
                      color: Colors.white,
                    ),
                  ],
                ),
                alignment: Alignment.centerLeft,
              )),
          key: UniqueKey(),
          onDismissed: (DismissDirection direction) {
            setState(() {
              widget.listAppList.items
                  .removeWhere((element) => element == aListItem);
            });
          },
          child: CheckboxListTile(
            activeColor: Theme.of(context).accentColor,
            title: aListItem.isFulfilled()
                ? Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          aListItem.name,
                          style: TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person,
                              color:
                                  _assignedColors[aListItem.getFulfillers()[0]],
                            ),
                            Text(
                              aListItem.getFulfillers()[0].firstName,
                              textScaleFactor: 0.7,
                            )
                          ],
                        ),
                      ),
                    ],
                  )
                : Text(aListItem.name),
            value: aListItem.isFulfilled(),
            selected: aListItem.isFulfilled(),
            onChanged: (bool? value) {
              // TODO make async, make not selectable until the server has responded
              setState(() {
                if (value == true) {
                  aListItem.fulfill(member: _loggedInListAppUser);
                } else {
                  aListItem.unfulfill(
                      member: _loggedInListAppUser, quantityUnfulfilled: 1);
                }
              });
            },
          ),
        );
      case ItemType.multiFulfillment:
        return Dismissible(
            confirmDismiss: (DismissDirection direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                        "Are you sure you wish to delete this item?"),
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
                        color: Colors.white,
                      ),
                    ],
                  ),
                  alignment: Alignment.centerLeft,
                )),
            key: UniqueKey(),
            onDismissed: (DismissDirection direction) {
              setState(() {
                widget.listAppList.items
                    .removeWhere((element) => element == aListItem);
              });
            },
            child: CheckboxListTile(
              activeColor: Theme.of(context).accentColor,
              title: aListItem.isFulfilled()
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Expanded(
                              flex: 5,
                              child: Text(aListItem.name,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough))),
                          Expanded(
                              flex: 2,
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                    side: BorderSide(
                                        color: Theme.of(context).accentColor,
                                        width: 1),
                                  ),
                                  onPressed: () => showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(aListItem.name),
                                          content: _buildAlertDialogMembers(
                                              aListItem.getFulfillers().length,
                                              aListItem
                                                  .getFulfillers()
                                                  .toSet()),
                                        );
                                      }),
                                  child: Text(
                                    "${aListItem.getFulfillers().length}" +
                                        " / " +
                                        "${aListItem.maxQuantity}",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                    textScaleFactor: 1.2,
                                  ))
                              /*],
                        ),*/
                              )
                        ])
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Expanded(flex: 5, child: Text(aListItem.name)),
                          Expanded(
                              flex: 2,
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                    side: BorderSide(
                                        color: Theme.of(context).accentColor,
                                        width: 1),
                                  ),
                                  onPressed: () => showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(aListItem.name),
                                          content: _buildAlertDialogMembers(
                                              aListItem.getFulfillers().length,
                                              aListItem
                                                  .getFulfillers()
                                                  .toSet()),
                                        );
                                      }),
                                  child: Text(
                                    "${aListItem.getFulfillers().length}" +
                                        " / " +
                                        "${aListItem.maxQuantity}",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                    textScaleFactor: 1.2,
                                  )))
                        ]),
              value: aListItem.quantityFulfilledBy(_loggedInListAppUser).isOdd,
              selected: aListItem.isFulfilled(),
              onChanged: (bool? value) {
                // TODO make async, make not selectable until the server has responded

                setState(() {
                  if (value == true) {
                    aListItem.fulfill(member: _loggedInListAppUser);
                  } else {
                    aListItem.unfulfill(
                        member: _loggedInListAppUser, quantityUnfulfilled: 1);
                  }
                });
              },
            ));

      case ItemType.multiFulfillmentMember:
        return Dismissible(
            confirmDismiss: (DismissDirection direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                        "Are you sure you wish to delete this item?"),
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
                        color: Colors.white,
                      ),
                    ],
                  ),
                  alignment: Alignment.centerLeft,
                )),
            key: UniqueKey(),
            onDismissed: (DismissDirection direction) {
              setState(() {
                widget.listAppList.items
                    .removeWhere((element) => element == aListItem);
              });
            },
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(aListItem.name,
                        style: aListItem.isFulfilled()
                            ? TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough)
                            : TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .headline1!
                                    .color)),
                  ),
                  Expanded(
                      flex: 2,
                      child: _buildMultiFulfillmentMemberItemButton(
                          context, aListItem)),
                ],
              ),
              selected: aListItem.isFulfilled(),
              trailing: Container(
                width: 40,
                child: IconButton(
                  padding: EdgeInsets.all(0),
                  icon: Icon(Icons.add_circle,
                      color: Theme.of(context).accentColor),
                  onPressed: () async =>
                      await _showNumberPickerDialog(context, aListItem),
                ),
              ),
            ));
    }
  }

  Future<void> _showNumberPickerDialog(
      BuildContext context, BaseItem aListItem) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          int _currentValue =
              aListItem.quantityFulfilledBy(_loggedInListAppUser);
          int _previousValue =
              aListItem.quantityFulfilledBy(_loggedInListAppUser);
          int _added = 0;
          int _difference = 0;
          return StatefulBuilder(builder: (context, setPickerState) {
            //we need it to be stateful because the widget state can change while the dialog is opened
            return AlertDialog(
                title: Text("How many times have you completed this item?"),
                content: NumberPicker(
                  minValue: 0,
                  maxValue: aListItem.quantityPerMember,
                  value: _currentValue,
                  onChanged: (value) => {
                    _previousValue < value ? _added = 1 : _added = 0,
                    _difference = value - _previousValue,
                    print(_difference),
                    setPickerState(() => _currentValue = value)
                  },
                ),
                actions: <Widget>[
                  TextButton(
                      style: TextButton.styleFrom(
                          primary: Theme.of(context).primaryColor),
                      onPressed: () async {
                        print("quantity prima setstate");
                        print(aListItem
                            .quantityFulfilledBy(_loggedInListAppUser));
                        print(aListItem.getFulfillers());
                        print(_difference);
                        setState(() {
                          if (_added == 1) {
                            aListItem.fulfill(
                                member: _loggedInListAppUser,
                                quantityFulfilled: _difference);
                          } else {
                            aListItem.unfulfill(
                                member: _loggedInListAppUser,
                                quantityUnfulfilled: _difference);
                          }
                        });
                        print("quantity dopo setstate");
                        print(aListItem
                            .quantityFulfilledBy(_loggedInListAppUser));
                        Navigator.of(context).pop();
                      },
                      child: const Text("CHANGE")),
                ]);
          });
        });
  }

  Widget _buildMemberRow(BuildContext context, ListAppUser member) {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Colors.grey,
          width: 0.8,
        ))),
        child: ListTile(
            leading: Icon(Icons.person, color: _assignedColors[member]),
            title: Text(
              member.firstName + ' ' + member.lastName,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: _assignedColors[member]),
            )));
  }

  Widget _buildMemberRowAndQuantity(
      BuildContext context, ListAppUser member, int quantity) {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Colors.grey,
          width: 0.8,
        ))),
        child: ListTile(
            leading: Icon(Icons.person, color: _assignedColors[member]),
            title: Text(
              member.firstName + ' ' + member.lastName,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: _assignedColors[member]),
            ),
            trailing: Text(
              quantity.toString(),
              style: TextStyle(fontSize: 16),
            )));
  }

  Widget _buildMultiFulfillmentMemberItemButton(
      BuildContext context, BaseItem aListItem) {
    return TextButton(
        style: TextButton.styleFrom(
          side: BorderSide(color: Theme.of(context).accentColor, width: 1),
        ),
        onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text(aListItem.name),
                  content: _buildAlertDialogMembersAndQuantity(
                    aListItem.getFulfillers().length,
                    aListItem.getFulfillers().toSet(),
                    aListItem
                        .getFulfillers()
                        .map((member) => aListItem.quantityFulfilledBy(member))
                        .toList(),
                  ));
            }),
        child: Text(
          aListItem.getFulfillers().length == 0
              ? "0" + " / " + "${aListItem.maxQuantity}"
              : "${aListItem.getFulfillers().map((member) => aListItem.quantityFulfilledBy(member)).reduce((value, element) => value + element)}" +
                  " / " +
                  "${aListItem.maxQuantity}",
          style: TextStyle(color: Theme.of(context).primaryColor),
          textScaleFactor: 1.2,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(),
        body: _buildScaffoldBody(context),
      ),
    );
  }

  Widget _buildScaffoldBody(BuildContext context) {
    return Column(
      children: [
        // list details, in the higher part of the page
        _buildListDetails(context),

        // here begins the tab bar at the middle, to switch between items and members
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    offset: const Offset(
                      10.0,
                      10.0,
                    ),
                    blurRadius: 5.0,
                    spreadRadius: 8.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              height:
                  74, //this is to remove the space of the title, we dont need it
              child: AppBar(
                // in order to have a TabBar, we need to have an AppBar
                // the sizedBox is needed to remove the title space
                elevation: 0,
                automaticallyImplyLeading: false,
                bottom: TabBar(
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(text: 'ITEMS', icon: Icon(Icons.done)),
                    Tab(text: 'MEMBERS', icon: Icon(Icons.person)),
                  ],
                ),
              ),
            ),
          ],
        ),

        // tab bar contents
        Expanded(
          child: TabBarView(
            children: [
              // list of items
              _buildItemsListView(context),

              // list of members
              _buildMembersListView(context),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showAddMemberRoute(BuildContext context) async {
    // TODO Implement add member to list logic
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewItemPage()),
    );
    if (result != null) {
      _addListItem(result);
    }
  }

  Widget _buildMembersListView(BuildContext context) {
    // put the add element at first, then followed by the list members
    return Column(
      children: [
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add_rounded,
                color: Theme.of(context).disabledColor,
              ),
              Padding(padding: EdgeInsets.all(5)),
              Text(
                'Add new member...',
                style: TextStyle(
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ],
          ),
          onTap: () async {
            await _showAddMemberRoute(context);
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.listAppList.membersAsUsers.length,
            itemBuilder: (context, i) {
              return _buildMemberRow(
                  context, widget.listAppList.membersAsUsers.elementAt(i));
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showNewItemRoute(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewItemPage()),
    );
    if (result != null) {
      _addListItem(result);
    }
  }

  Widget _buildItemsListView(BuildContext context) {
    // put the add element at first, then followed by the list items
    return Column(
      children: [
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).disabledColor,
              ),
              Padding(padding: EdgeInsets.all(5)),
              Text(
                'Add new element...',
                style: TextStyle(
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ],
          ),
          onTap: () async {
            await _showNewItemRoute(context);
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.listAppList.items.length,
            itemBuilder: (context, i) {
              return _buildItemRow(
                  context, widget.listAppList.items.elementAt(i));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListDetails(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/list_default.png'),
          //TODO image: aList.imageURL != null && alist.imageURL.isNotEmpy ? NetworkImage(aList.imageURL) :AssetImage('assets/list_default.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.10), BlendMode.dstATop),
        ),
      ),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
            child: Column(
              children: [
                ListTile(
                  dense: true,
                  horizontalTitleGap: 0.5,
                  leading: Icon(Icons.list),
                  title: Text(widget.listAppList.name,
                      style: TextStyle(fontSize: 20)),
                  subtitle: Text(widget.listAppList.description ?? ''),
                ),
                ListTile(
                  dense: true,
                  horizontalTitleGap: 0.5,
                  leading: Icon(Icons.date_range),
                  title: Text(DateFormat('MMM dd')
                      .format(widget.listAppList.createdAt)),
                  subtitle: Text(
                      DateFormat.jm().format(widget.listAppList.createdAt)),
                ),
                ListTile(
                  dense: true,
                  horizontalTitleGap: 0.5,
                  leading: Icon(Icons.person_pin_rounded),
                  title: Text(
                      widget.listAppList.creator?.displayName ?? 'John Smith'),
                  subtitle:
                      Text(widget.listAppList.creator?.username ?? 'john21'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
