import 'package:mobile_applications/models/list_item.dart';
import 'dart:math' as math;
import 'dart:collection';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_applications/services/authentication.dart';

import 'package:mobile_applications/ui/new_item.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:numberpicker/numberpicker.dart';

import '../models/user.dart';

class ListViewRoute extends StatefulWidget {
  final ListAppList aList;
  //the member currently logged in, TODO make it final and get it from session
  late ListAppUser currentMember;

  ListViewRoute(this.aList) {
    aList.members = Set<ListAppUser>();

    //TODO fetch from backend instead
    aList.members.addAll([
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
    currentMember = aList.members.elementAt(0);

    aList.items = Set<BaseItem>();
    /* aList.items.addAll([
      SimpleItem(1, "Simple element - undone", "A simple undone element"),
      SimpleItem(2, "Simple element - done", "A simple done element"),
      SimpleItem(3, "Buy groceries", "go to buy some groceries"),
      MultiFulfillmentItem(
          4, "Buy movie tickets", "go to buy some movie tickets", 5),
      MultiFulfillmentMemberItem(5, "Lord of the rings trilogy",
          "the complete lord of the rings trilogy", 5, 3),
    ]); */
    aList.items.addAll([
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
    aList.items.elementAt(1).fulfill(member: aList.members.elementAt(0));
    aList.items
        .elementAt(5)
        .fulfill(member: aList.members.elementAt(1), quantityFulfilled: 2);
    aList.items.elementAt(4).fulfill(member: aList.members.elementAt(0));
    aList.items.elementAt(4).fulfill(member: aList.members.elementAt(1));
    aList.items.elementAt(4).fulfill(member: aList.members.elementAt(2));
    aList.items.elementAt(4).fulfill(member: aList.members.elementAt(3));
  }

  @override
  _ListViewRouteState createState() =>
      _ListViewRouteState(currentMember, aList);
}

class _ListViewRouteState extends State<ListViewRoute> {
  final ListAppUser _member;
  final ListAppList _aList;

  late ListAppUser _loggedInListAppUser;

  @override
  void initState() {
    super.initState();
    _loggedInListAppUser =
        context.read<ListAppAuthProvider>().loggedInListAppUser!;
  }

  final HashMap<ListAppUser, Color> _assignedColors =
      HashMap<ListAppUser, Color>();

  _ListViewRouteState(this._member, this._aList) {
    var it = _aList.members.iterator;
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

  Widget _buildListItems() {
    return ListView.builder(
      itemCount: _aList.items.length,
      itemBuilder: (context, i) {
        return _buildRow(context, _aList.items.elementAt(i));
      },
    );
  }

  Widget _buildListMembers() {
    return ListView.builder(
      itemCount: _aList.members.length,
      itemBuilder: (context, i) {
        return _buildMemberRow(context, _aList.members.elementAt(i));
      },
    );
  }

  _addListItem(BaseItem item) {
    setState(() {
      _aList.items.add(item);
    });
  }

  void _showNumberPicker(ListAppUser user, BuildContext context,
      BaseItem aListItem, int minValue, int maxValue, int initialValue) {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          int _currentValue = initialValue;
          int _previousValue = initialValue;
          int _added = 0;
          int _difference = 0;
          return StatefulBuilder(builder: (context, setNumberPickerState) {
            //we need it to be stateful because the widget state can change while the dialog is opened
            return AlertDialog(
                title: Text("How many times have you completed this item?"),
                content: NumberPicker(
                  minValue: minValue,
                  maxValue: maxValue,
                  value: _currentValue,
                  onChanged: (value) => {
                    _previousValue < value ? _added = 1 : _added = 0,
                    _difference = value - _previousValue,
                    print(_difference),
                    setNumberPickerState(() => _currentValue = value)
                  },
                  /*onChanged: (newValue) => setState(() {
                  newValue > _currentValue
                      ?
                      //TODO Maybe better to put the buttons
                      aListItem.fulfill(
                          member: _member, quantityFulfilled: newValue)
                      : aListItem.unfulfill(
                          member: _member, quantityUnfulfilled: newValue);
                  _currentValue = newValue;
                }),*/
                ),
                actions: <Widget>[
                  TextButton(
                      style: TextButton.styleFrom(
                          primary: Theme.of(context).primaryColor),
                      onPressed: () => {
                            setState(() {
                              if (_added == 1) {
                                aListItem.fulfill(
                                    member: user,
                                    quantityFulfilled: _difference);
                              } else {
                                aListItem.unfulfill(
                                    member: user,
                                    quantityUnfulfilled: _difference);
                              }
                            }),
                            /*_added == 1
                                ? {
                                    setState(() => aListItem.fulfill(
                                        member: user,
                                        quantityFulfilled: _difference))
                                  }
                                : {
                                    setState(() => aListItem.unfulfill(
                                        member: user,
                                        quantityUnfulfilled: _difference))
                                  },*/
                            Navigator.pop(context)
                          },
                      child: const Text("CHANGE")),
                ]);
          });
        });
  }

  Widget setupAlertDialogContainer(ListAppUser member) {
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

  Widget _buildRow(BuildContext context, BaseItem aListItem) {
    switch (aListItem.runtimeType) {
      case SimpleItem:
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
                    /*Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.left,
                    ),*/
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
              _aList.items.removeWhere((element) => element == aListItem);
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
      case MultiFulfillmentItem:
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
                      /*Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.left,
                      ),*/
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
                _aList.items.removeWhere((element) => element == aListItem);
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

      case MultiFulfillmentMemberItem:
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
                      /*Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.left,
                      ),*/
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
                _aList.items.removeWhere((element) => element == aListItem);
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
                      child: _buildMultifulfillmentMemberItemButton(
                          context, aListItem)
                      /*Column(
                            mainAxisSize: MainAxisSize.min,
                            children: itemColumns),*/
                      ),
                ],
              )
              /*: //Text(aListItem.name),
                  Row(
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
                                    "${aListItem.getFulfillers().map((member) => aListItem.quantityFulfilledBy(member)).reduce((value, element) => value + element)}" +
                                        " / " +
                                        "${aListItem.maxQuantity}",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                    textScaleFactor: 1.2,
                                  )))
                        ])*/
              ,
              selected: aListItem.isFulfilled(),
              onTap: () =>
                  {} /*_showNumberPicker(
                  _member,
                  context,
                  aListItem,
                  0,
                  aListItem.quantityPerMember,
                  aListItem.quantityFulfilledBy(_member))*/
              ,
              trailing: Container(
                width: 40,
                child: IconButton(
                  padding: EdgeInsets.all(0),
                  icon: Icon(Icons.add_circle,
                      color: Theme.of(context).accentColor),
                  onPressed: () =>
                      /*_showNumberPicker(
                      _member,
                      context,
                      aListItem,
                      0,
                      aListItem.quantityPerMember,
                      aListItem.quantityFulfilledBy(_member)),*/
                      showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            int _currentValue = aListItem
                                .quantityFulfilledBy(_loggedInListAppUser);
                            int _previousValue = aListItem
                                .quantityFulfilledBy(_loggedInListAppUser);
                            int _added = 0;
                            int _difference = 0;
                            return StatefulBuilder(
                                builder: (context, setPickerState) {
                              //we need it to be stateful because the widget state can change while the dialog is opened
                              return AlertDialog(
                                  title: Text(
                                      "How many times have you completed this item?"),
                                  content: NumberPicker(
                                    minValue: 0,
                                    maxValue: aListItem.quantityPerMember,
                                    value: _currentValue,
                                    onChanged: (value) => {
                                      _previousValue < value
                                          ? _added = 1
                                          : _added = 0,
                                      _difference = value - _previousValue,
                                      print(_difference),
                                      setPickerState(
                                          () => _currentValue = value)
                                    },
                                    /*onChanged: (newValue) => setState(() {
                  newValue > _currentValue
                      ?
                      //TODO Maybe better to put the buttons
                      aListItem.fulfill(
                          member: _member, quantityFulfilled: newValue)
                      : aListItem.unfulfill(
                          member: _member, quantityUnfulfilled: newValue);
                  _currentValue = newValue;
                }),*/
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                        style: TextButton.styleFrom(
                                            primary:
                                                Theme.of(context).primaryColor),
                                        onPressed: () => {
                                              print("quantity prima setstate"),
                                              print(
                                                  aListItem.quantityFulfilledBy(
                                                      _loggedInListAppUser)),
                                              print(aListItem.getFulfillers()),
                                              print(_difference),
                                              setState(() {
                                                if (_added == 1) {
                                                  aListItem.fulfill(
                                                      member:
                                                          _loggedInListAppUser,
                                                      quantityFulfilled:
                                                          _difference);
                                                } else {
                                                  aListItem.unfulfill(
                                                      member:
                                                          _loggedInListAppUser,
                                                      quantityUnfulfilled:
                                                          _difference);
                                                }
                                              }),
                                              print("quantity dopo setstate"),
                                              print(
                                                  aListItem.quantityFulfilledBy(
                                                      _loggedInListAppUser)),
                                              /*_added == 1
                                ? {
                                    setState(() => aListItem.fulfill(
                                        member: user,
                                        quantityFulfilled: _difference))
                                  }
                                : {
                                    setState(() => aListItem.unfulfill(
                                        member: user,
                                        quantityUnfulfilled: _difference))
                                  },*/
                                              Navigator.of(context).pop()
                                            },
                                        child: const Text("CHANGE")),
                                  ]);
                            });
                          }),
                ),
              ),
            ));
    }
    //the code should never reach this point, but we need it for null check
    return ListTile(
      title: Text("Empty element"),
    );
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

  Widget _buildMultifulfillmentMemberItemButton(
      BuildContext context, BaseItem aListItem) {
    /*int totalFulfilled = aListItem
        .getFulfillers()
        .map((member) => aListItem.quantityFulfilledBy(member))
        .reduce((value, element) => value + element);
    print("questo è totalFulfilled");
    print(totalFulfilled);*/
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
    /*SimpleItem itemFromDB = SimpleItem(name: collectionReference.data['name'])
    _addListItem(collectionReference)*/
    return DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.aList.name),
            bottom: TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'ITEMS', icon: Icon(Icons.done)),
                Tab(text: 'MEMBERS', icon: Icon(Icons.person)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildListItems(),
              _buildListMembers(),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            /*onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewListItem()),
              )
            },*/
            onPressed: () {
              _navigateAndDisplaySelection(context);
            },
            icon: Icon(Icons.add),
            label: Text('NEW ITEM'),
          ),
        ));
  }

  void _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewListItem()),
    );
    if (result != null) {
      _addListItem(result);
    }
  }
}
