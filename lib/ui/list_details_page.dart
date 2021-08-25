import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/list_item.dart';
import 'package:mobile_applications/services/authentication.dart';

import 'package:mobile_applications/services/item_manager.dart';
import 'package:mobile_applications/services/list_manager.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:mobile_applications/ui/new_item_page.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class ListDetailsPage extends StatefulWidget {
  final ListAppList listAppList;

  /// If `true`, the button to add new members will be shown
  final bool canAddNewMembers;

  /// If `true`, the button to add new list items will be shown
  final bool canAddNewItems;

  const ListDetailsPage(
    this.listAppList, {
    required this.canAddNewMembers,
    this.canAddNewItems = true,
  });

  @override
  _ListDetailsPageState createState() => _ListDetailsPageState();
}

class _ListDetailsPageState extends State<ListDetailsPage> {
  late ListAppUser _loggedInListAppUser;
  late final HashMap<String, Color> _assignedColors = HashMap<String, Color>();

  @override
  void initState() {
    super.initState();
    var allUsers = widget.listAppList.membersAsUsers;
    allUsers.insert(0, widget.listAppList.creator!);

    if (allUsers.isNotEmpty) {
      var it = allUsers.iterator;
      int index = 0;
      while (index <= Colors.primaries.length && it.moveNext()) {
        _assignedColors[it.current.databaseId!] = Colors.primaries[index];
        ++index;
      }
      index = 0;
      while (index <= Colors.accents.length && it.moveNext()) {
        _assignedColors[it.current.databaseId!] = Colors.accents[index];
        ++index;
      }
      // if at this point we still have members just take random colors
      while (it.moveNext()) {
        _assignedColors[it.current.databaseId!] =
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
          return _buildMemberRow(context, itemMembers.elementAt(i), false);
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
        if (aListItem.creatorUid == _loggedInListAppUser.databaseId) {
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
                      const SizedBox(
                        width: 20,
                      ),
                      const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  alignment: Alignment.centerLeft,
                )),
            key: UniqueKey(),
            onDismissed: (DismissDirection direction) async {
              final itemManagerInstance = ListAppItemManager.instanceForList(
                widget.listAppList.databaseId!,
                widget.listAppList.creator!.databaseId!,
              );

              await itemManagerInstance.deleteInstance(aListItem);
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
                            style: const TextStyle(
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
                                color: _assignedColors[
                                    aListItem.getFulfillers().first.databaseId],
                              ),
                              Text(
                                aListItem.getFulfillers().first.firstName,
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
              onChanged: (bool? value) async {
                if (value == true) {
                  await ListAppItemManager.instanceForList(
                          widget.listAppList.databaseId!,
                          _loggedInListAppUser.databaseId!)
                      .fulfillItem(_loggedInListAppUser.databaseId!,
                          widget.listAppList.databaseId!, aListItem, 1);
                  print(aListItem.isFulfilled());
                } else {
                  await ListAppItemManager.instanceForList(
                          widget.listAppList.databaseId!,
                          _loggedInListAppUser.databaseId!)
                      .unfulfillItem(_loggedInListAppUser.databaseId!,
                          widget.listAppList.databaseId!, aListItem, 1);
                }
                setState(() {});
              },
            ),
          );
        } else {
          return CheckboxListTile(
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
                          style: const TextStyle(
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
                              color: _assignedColors[
                                  aListItem.getFulfillers().first.databaseId],
                            ),
                            Text(
                              aListItem.getFulfillers().first.firstName,
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
            onChanged: (bool? value) async {
              if (value == true) {
                await ListAppItemManager.instanceForList(
                        widget.listAppList.databaseId!,
                        _loggedInListAppUser.databaseId!)
                    .fulfillItem(_loggedInListAppUser.databaseId!,
                        widget.listAppList.databaseId!, aListItem, 1);
              } else {
                await ListAppItemManager.instanceForList(
                        widget.listAppList.databaseId!,
                        _loggedInListAppUser.databaseId!)
                    .unfulfillItem(_loggedInListAppUser.databaseId!,
                        widget.listAppList.databaseId!, aListItem, 1);
              }
              setState(() {});
            },
          );
        }
      case ItemType.multiFulfillment:
        if (aListItem.creatorUid == _loggedInListAppUser.databaseId) {
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
                        const SizedBox(
                          width: 20,
                        ),
                        const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    alignment: Alignment.centerLeft,
                  )),
              key: UniqueKey(),
              onDismissed: (DismissDirection direction) async {
                final itemManagerInstance = ListAppItemManager.instanceForList(
                  widget.listAppList.databaseId!,
                  widget.listAppList.creator!.databaseId!,
                );

                await itemManagerInstance.deleteInstance(aListItem);
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
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        decoration:
                                            TextDecoration.lineThrough))),
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
                                                aListItem
                                                    .getFulfillers()
                                                    .length,
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
                                          color:
                                              Theme.of(context).primaryColor),
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
                                                aListItem
                                                    .getFulfillers()
                                                    .length,
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
                                          color:
                                              Theme.of(context).primaryColor),
                                      textScaleFactor: 1.2,
                                    )))
                          ]),
                value:
                    aListItem.quantityFulfilledBy(_loggedInListAppUser).isOdd,
                selected: aListItem.isFulfilled(),
                onChanged: (bool? value) async {
                  if (aListItem.isFulfilled()) {
                    if (aListItem.usersCompletions.keys
                        .contains(_loggedInListAppUser.databaseId)) {
                      if (value == true) {
                        await ListAppItemManager.instanceForList(
                                widget.listAppList.databaseId!,
                                _loggedInListAppUser.databaseId!)
                            .fulfillItem(_loggedInListAppUser.databaseId!,
                                widget.listAppList.databaseId!, aListItem, 1);
                      } else {
                        await ListAppItemManager.instanceForList(
                                widget.listAppList.databaseId!,
                                _loggedInListAppUser.databaseId!)
                            .unfulfillItem(_loggedInListAppUser.databaseId!,
                                widget.listAppList.databaseId!, aListItem, 1);
                      }
                      setState(() {});
                    } else {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Item already fulfilled!"),
                              content: Text(
                                  "This item has been alredy fulfilled by other users."),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                      textStyle: const TextStyle(fontSize: 16),
                                      primary: Colors.white,
                                      backgroundColor:
                                          Theme.of(context).accentColor),
                                  child: Text("Got it!"),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          });
                    }
                  } else {
                    if (value == true) {
                      await ListAppItemManager.instanceForList(
                              widget.listAppList.databaseId!,
                              _loggedInListAppUser.databaseId!)
                          .fulfillItem(_loggedInListAppUser.databaseId!,
                              widget.listAppList.databaseId!, aListItem, 1);
                    } else {
                      await ListAppItemManager.instanceForList(
                              widget.listAppList.databaseId!,
                              _loggedInListAppUser.databaseId!)
                          .unfulfillItem(_loggedInListAppUser.databaseId!,
                              widget.listAppList.databaseId!, aListItem, 1);
                    }
                    setState(() {});
                  }
                },
              ));
        } else {
          return CheckboxListTile(
            activeColor: Theme.of(context).accentColor,
            title: aListItem.isFulfilled()
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Expanded(
                            flex: 5,
                            child: Text(aListItem.name,
                                style: const TextStyle(
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
                                            aListItem.getFulfillers().toSet()),
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
                                            aListItem.getFulfillers().toSet()),
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
            onChanged: (bool? value) async {
              if (aListItem.isFulfilled()) {
                if (aListItem.usersCompletions.keys
                    .contains(_loggedInListAppUser.databaseId)) {
                  if (value == true) {
                    await ListAppItemManager.instanceForList(
                            widget.listAppList.databaseId!,
                            _loggedInListAppUser.databaseId!)
                        .fulfillItem(_loggedInListAppUser.databaseId!,
                            widget.listAppList.databaseId!, aListItem, 1);
                  } else {
                    await ListAppItemManager.instanceForList(
                            widget.listAppList.databaseId!,
                            _loggedInListAppUser.databaseId!)
                        .unfulfillItem(_loggedInListAppUser.databaseId!,
                            widget.listAppList.databaseId!, aListItem, 1);
                  }
                  setState(() {});
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Item already fulfilled!"),
                          content: Text(
                              "This item has been alredy fulfilled by other users."),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 16),
                                  primary: Colors.white,
                                  backgroundColor:
                                      Theme.of(context).accentColor),
                              child: Text("Got it!"),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        );
                      });
                }
              } else {
                if (value == true) {
                  await ListAppItemManager.instanceForList(
                          widget.listAppList.databaseId!,
                          _loggedInListAppUser.databaseId!)
                      .fulfillItem(_loggedInListAppUser.databaseId!,
                          widget.listAppList.databaseId!, aListItem, 1);
                } else {
                  await ListAppItemManager.instanceForList(
                          widget.listAppList.databaseId!,
                          _loggedInListAppUser.databaseId!)
                      .unfulfillItem(_loggedInListAppUser.databaseId!,
                          widget.listAppList.databaseId!, aListItem, 1);
                }
                setState(() {});
              }
            },
          );
        }

      case ItemType.multiFulfillmentMember:
        if (aListItem.creatorUid == _loggedInListAppUser.databaseId) {
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
                        const SizedBox(
                          width: 20,
                        ),
                        const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    alignment: Alignment.centerLeft,
                  )),
              key: UniqueKey(),
              onDismissed: (DismissDirection direction) async {
                final itemManagerInstance = ListAppItemManager.instanceForList(
                  widget.listAppList.databaseId!,
                  widget.listAppList.creator!.databaseId!,
                );

                await itemManagerInstance.deleteInstance(aListItem);
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
                              ? const TextStyle(
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
                      padding: const EdgeInsets.all(0),
                      icon: Icon(Icons.add_circle,
                          color: Theme.of(context).accentColor),
                      onPressed: () async {
                        if (aListItem.isFulfilled()) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Item already fulfilled!"),
                                  content: Text(
                                      "This item has been alredy fulfilled by other users."),
                                  actions: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                          textStyle:
                                              const TextStyle(fontSize: 16),
                                          primary: Colors.white,
                                          backgroundColor:
                                              Theme.of(context).accentColor),
                                      child: Text("Got it!"),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                  ],
                                );
                              });
                        } else {
                          await _showNumberPickerDialog(context, aListItem);
                        }
                      }),
                ),
              ));
        } else {
          return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 5,
                  child: Text(aListItem.name,
                      style: aListItem.isFulfilled()
                          ? const TextStyle(
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
                  padding: const EdgeInsets.all(0),
                  icon: Icon(Icons.add_circle,
                      color: Theme.of(context).accentColor),
                  onPressed: () async {
                    if (aListItem.isFulfilled()) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Item already fulfilled!"),
                              content: Text(
                                  "This item has been alredy fulfilled by other users."),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                      textStyle: const TextStyle(fontSize: 16),
                                      primary: Colors.white,
                                      backgroundColor:
                                          Theme.of(context).accentColor),
                                  child: Text("Got it!"),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          });
                    } else {
                      await _showNumberPickerDialog(context, aListItem);
                    }
                  }),
            ),
          );
        }
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
                title:
                    const Text("How many times have you completed this item?"),
                content: NumberPicker(
                  minValue: 0,
                  maxValue: (aListItem.maxQuantity -
                              aListItem.usersCompletions.values
                                  .reduce((value, element) => value + element) <
                          aListItem.quantityPerMember)
                      ? aListItem.maxQuantity -
                          aListItem.usersCompletions.values
                              .reduce((value, element) => value + element)
                      : aListItem.quantityPerMember,
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
                        print("fulfiller prima" +
                            aListItem.getFulfillers().toString());
                        print("difference" + _difference.toString());
                        // TODO make async, make not selectable until the server has responded
                        if (_added == 1) {
                          await ListAppItemManager.instanceForList(
                                  widget.listAppList.databaseId!,
                                  _loggedInListAppUser.databaseId!)
                              .fulfillItem(
                                  _loggedInListAppUser.databaseId!,
                                  widget.listAppList.databaseId!,
                                  aListItem,
                                  _difference);
                          print(aListItem.isFulfilled());
                        } else {
                          await ListAppItemManager.instanceForList(
                                  widget.listAppList.databaseId!,
                                  _loggedInListAppUser.databaseId!)
                              .unfulfillItem(
                                  _loggedInListAppUser.databaseId!,
                                  widget.listAppList.databaseId!,
                                  aListItem,
                                  _difference);
                        }
                        setState(() {});
                        /*setState(() {
                          if (_added == 1) {
                            aListItem.fulfill(
                                member: _loggedInListAppUser,
                                quantityFulfilled: _difference);
                          } else {
                            aListItem.unfulfill(
                                member: _loggedInListAppUser,
                                quantityUnfulfilled: _difference);
                          }
                          /*ListAppItemManager.instanceForList(
                                  widget.listAppList.databaseId!,
                                  _loggedInListAppUser.databaseId!)
                              .saveToFirestore(aListItem);*/
                        });*/
                        print("fulfiller dopo" +
                            aListItem.getFulfillers().toString());
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

  Widget _buildMemberRow(BuildContext context, ListAppUser member, bool admin) {
    final chosenWidget = !admin
        ? Container(
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              color: Colors.grey,
              width: 0.8,
            ))),
            child: ListTile(
                leading: Icon(Icons.person,
                    color: _assignedColors[member.databaseId]),
                title: Text(
                  member.firstName + ' ' + member.lastName,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _assignedColors[member.databaseId]),
                )))
        : Container(
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(
              color: Colors.grey,
              width: 0.8,
            ))),
            child: ListTile(
              leading:
                  Icon(Icons.person, color: _assignedColors[member.databaseId]),
              title: Text(
                member.firstName + ' ' + member.lastName,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _assignedColors[member.databaseId]),
              ),
              trailing: member.databaseId == _loggedInListAppUser.databaseId
                  ? IconButton(
                      icon: const Icon(Icons.person_off_rounded),
                      onPressed: () => null,
                    )
                  : IconButton(
                      icon: const Icon(Icons.person_remove_alt_1_rounded),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Delete member"),
                                content: Text(
                                    "Are you sure you want to remove " +
                                        member.displayName +
                                        " from this list?"),
                                actions: <Widget>[
                                  TextButton(
                                      style: TextButton.styleFrom(
                                          primary: Colors.red),
                                      onPressed: () {
                                        ListAppListManager.instanceForUserUid(
                                                _loggedInListAppUser
                                                    .databaseId!)
                                            .removeMemberFromList(
                                                widget.listAppList.databaseId!,
                                                member.databaseId!);

                                        setState(() {
                                          widget.listAppList.membersAsUsers
                                              .remove(member);
                                        });

                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text('REMOVE')),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("CANCEL"),
                                  ),
                                ],
                              );
                            });
                      },
                    ),
            ));
    return chosenWidget;
  }

  Widget _buildMemberRowAndQuantity(
      BuildContext context, ListAppUser member, int quantity) {
    return Container(
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Colors.grey,
          width: 0.8,
        ))),
        child: ListTile(
            leading:
                Icon(Icons.person, color: _assignedColors[member.databaseId]),
            title: Text(
              member.firstName + ' ' + member.lastName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _assignedColors[member.databaseId]),
            ),
            trailing: Text(
              quantity.toString(),
              style: const TextStyle(fontSize: 16),
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

  Future<void> _deleteOrAbandonList(ListAppList list) async {
    final listAppUser =
        await context.read<ListAppAuthProvider>().getLoggedInListAppUser();

    if (listAppUser == null) return;

    if (list.creatorUid == listAppUser.databaseId) {
      await ListAppListManager.instanceForUser(listAppUser)
          .deleteInstance(list);
      Navigator.of(context).pop();
    } else {
      await ListAppListManager.instanceForUser(listAppUser)
          .leaveList(list.creatorUid ?? '', list);
      Navigator.of(context).pop();
    }
  }

  void popupMenuFunction(String option) {
    final currentListAppUser =
        context.read<ListAppAuthProvider>().loggedInListAppUser!;

    final bool doesUserOwnList =
        widget.listAppList.creatorUid == currentListAppUser.databaseId;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                "Are you sure you wish to ${doesUserOwnList ? 'delete' : 'leave'} the " +
                    widget.listAppList.name +
                    " list?"),
            content: doesUserOwnList
                ? const Text(
                    "You and all the other participants will not see this list anymore")
                : const Text(
                    "If you push LEAVE, you will abandon this list and you won't be able to join it unless someone invites you again"),
            actions: <Widget>[
              TextButton(
                  style: TextButton.styleFrom(primary: Colors.red),
                  onPressed: () {
                    _deleteOrAbandonList(widget.listAppList);
                    Navigator.of(context).pop(true);
                  },
                  child: Text(doesUserOwnList ? 'DELETE' : 'LEAVE')),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("CANCEL"),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final currentListAppUser =
        context.read<ListAppAuthProvider>().loggedInListAppUser!;

    final bool doesUserOwnList =
        widget.listAppList.creatorUid == currentListAppUser.databaseId;
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: popupMenuFunction,
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: "leave",
                    child: Text(
                        "${doesUserOwnList ? 'Delete list' : 'Leave list'}"),
                  )
                ];
              },
            )
          ],
        ),
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
                bottom: const TabBar(
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

  // Future<void> _showAddMemberRoute(BuildContext context) async {
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) {}),
  //   );
  //   if (result != null) {
  //     _addListItem(result);
  //   }
  // }

  Widget _buildMembersListView(BuildContext context) {
    bool isAdmin;
    if (!widget.canAddNewMembers)
      isAdmin = false;
    else
      isAdmin = true;

    final allMembers = widget.listAppList.membersAsUsers;
    // insert the creator as first member
    /*if (allMembers.length == widget.listAppList.membersAsUsers.length) {
      allMembers.insert(0, widget.listAppList.creator!);
    }*/
    // put the add element at first, then followed by the list members
    final membersListView = ListView.builder(
      itemCount: allMembers.length,
      itemBuilder: (context, i) {
        return _buildMemberRow(
          context,
          allMembers.elementAt(i),
          isAdmin,
        );
      },
    );

    // if the user is not allowed to add new members just show them the list
    if (!widget.canAddNewMembers) return membersListView;

    return Column(
      children: [
        _AddMemberDialog(
          widget.listAppList,
        ),
        Expanded(
          child: membersListView,
        ),
      ],
    );
  }

  Future<void> _showNewItemRoute(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NewItemPage(
                currentList: widget.listAppList,
                currentUser: _loggedInListAppUser,
              )),
    );
    if (result != null) {
      _addListItem(result);
    }
  }

  Widget _buildItemsListView(BuildContext context) {
    // put the add element at first, then followed by the list items
    final itemsListView = ListView.builder(
      itemCount: widget.listAppList.items.length,
      itemBuilder: (context, i) {
        return _buildItemRow(context, widget.listAppList.items.elementAt(i));
      },
    );

    // if the user is not allowed to add items just show them the list
    if (!widget.canAddNewItems) return itemsListView;

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
              const Padding(padding: EdgeInsets.all(5)),
              Text(
                'Add new list item...',
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
          child: itemsListView,
        ),
      ],
    );
  }

  Widget _buildListDetails(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/list_default.png'),
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
                  leading: const Icon(Icons.list),
                  title: Text(widget.listAppList.name,
                      style: const TextStyle(fontSize: 20)),
                  subtitle: widget.listAppList.description != null
                      ? Text(widget.listAppList.description!)
                      : null,
                ),
                ListTile(
                  dense: true,
                  horizontalTitleGap: 0.5,
                  leading: const Icon(Icons.date_range),
                  title: Text(DateFormat('MMM dd')
                      .format(widget.listAppList.createdAt)),
                  subtitle: Text(
                      DateFormat.jm().format(widget.listAppList.createdAt)),
                ),
                ListTile(
                  dense: true,
                  horizontalTitleGap: 0.5,
                  leading: const Icon(Icons.person_pin_rounded),
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

class _AddMemberDialog extends StatefulWidget {
  final ListAppList list;
  const _AddMemberDialog(this.list);
  @override
  _AddMemberDialogState createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<ListAppAuthProvider>().loggedInListAppUser;

    /* final Future<List<ListAppUser?>> friendsFrom = ListAppFriendshipManager
        .instance
        .getFriendsFromByUid(currentUser!.databaseId!);

    final Future<List<ListAppUser?>> friendsTo = ListAppFriendshipManager
        .instance
        .getFriendsToByUid(currentUser.databaseId!); */

    final Future<List<ListAppUser?>> friends =
        ListAppUserManager.instance.getFriends(currentUser!);

    return ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).disabledColor,
            ),
            const Padding(padding: EdgeInsets.all(5)),
            Text(
              'Add new member...',
              style: TextStyle(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
        onTap: () async {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(builder: (context, setState) {
                  return FutureBuilder<List<ListAppUser?>>(
                      future: friends,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<ListAppUser?>> snapshot) {
                        if (snapshot.hasData) {
                          /*final allFriends = snapshot.data![0]
                                  .where((element) => !widget
                                      .list.membersAsUsers
                                      .contains(element))
                                  .toList() +
                              snapshot.data![1]
                                  .where((element) => !widget
                                      .list.membersAsUsers
                                      .contains(element))
                                  .toList(); */

                          final onlyNonPresentFriends = snapshot.data!;

                          print(onlyNonPresentFriends[0]!.email ==
                              widget.list.membersAsUsers[1].email);

                          widget.list.membersAsUsers.forEach((element) {
                            onlyNonPresentFriends.removeWhere(
                                (e) => e!.username == element.username);
                          });
                          /*friends.removeWhere((element) =>
                              widget.list.membersAsUsers.contains(element));*/

                          return AlertDialog(
                            title: const Text("Choose members to add"),
                            content: StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return Container(
                                  height: 300,
                                  width: 300,
                                  child: ListView.builder(
                                    itemCount: onlyNonPresentFriends.length,
                                    itemBuilder: (context, i) {
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
                                                    onlyNonPresentFriends
                                                        .elementAt(i)!
                                                        .profilePictureURL!),
                                              ),
                                              onTap: () {},
                                              title: Text(
                                                onlyNonPresentFriends
                                                        .elementAt(i)!
                                                        .firstName +
                                                    ' ' +
                                                    onlyNonPresentFriends
                                                        .elementAt(i)!
                                                        .lastName,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              trailing: IconButton(
                                                  icon: const Icon(
                                                    Icons
                                                        .person_add_alt_rounded,
                                                  ),
                                                  onPressed: () {
                                                    ListAppListManager
                                                            .instanceForUserUid(
                                                                currentUser
                                                                    .databaseId!)
                                                        .addMemberToList(
                                                            widget.list
                                                                .databaseId!,
                                                            onlyNonPresentFriends
                                                                .elementAt(i)!
                                                                .databaseId!);

                                                    // not awaited because we let the dialog pop in the meantime
                                                    Fluttertoast.showToast(
                                                      msg: onlyNonPresentFriends
                                                              .elementAt(i)!
                                                              .fullName +
                                                          " was added to the list!",
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.CENTER,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor:
                                                          Colors.green,
                                                      textColor: Colors.white,
                                                      fontSize: 16.0,
                                                    );
                                                  })));
                                    },
                                  ));
                            }),
                          );
                        }
                        return const AlertDialog(
                          title: Text("ALLA FINE"),
                        );
                      });
                });
              });
        });
  }
}
