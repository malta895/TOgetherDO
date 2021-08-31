import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/list_item.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/item_manager.dart';
import 'package:mobile_applications/services/list_manager.dart';
import 'package:mobile_applications/services/user_manager.dart';
import 'package:mobile_applications/ui/lists_details_page/add_member_dialog.dart';
import 'package:mobile_applications/ui/lists_details_page/new_item_page.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/user.dart';

class ListDetailsPage extends StatefulWidget {
  final ListAppList listAppList;

  /// If `true`, the button to add new members will be shown
  final bool canAddNewMembers;

  /// If `true`, the button to add new list items will be shown
  final bool canAddNewItems;

  const ListDetailsPage(this.listAppList,
      {required this.canAddNewMembers, required this.canAddNewItems});

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

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _itemDetailsAlertDialog(
      BuildContext context, BaseItem item, ListAppUser creator) {
    final nameFieldController = TextEditingController(text: item.name);

    String _newName = '';
    String _newDescription = '';

    final descriptionFieldController =
        TextEditingController(text: item.description);
    return AlertDialog(
        scrollable: true,
        title: const Text("Item details"),
        content: SingleChildScrollView(
            child: Container(
                child: Column(children: [
          StatefulBuilder(builder: (context, setNameState) {
            return ListTile(
                title: TextField(
                  enabled: _loggedInListAppUser.databaseId == item.creatorUid,
                  controller: nameFieldController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(8.0),
                    border: OutlineInputBorder(
                        gapPadding: 2.0,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12.0)),
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).textTheme.headline1!.color!)),
                    labelText: "Name",
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.headline1!.color),
                    hintText: "Type here...",
                    hintStyle: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  onChanged: (value) {
                    setNameState(() {
                      _newName = value;
                    });
                  },
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: ((widget.listAppList.listStatus == ListStatus.draft ||
                            widget.listAppList.listType == ListType.public) &&
                        _loggedInListAppUser.databaseId == item.creatorUid)
                    ? ((_newName.isNotEmpty && _newName != item.name)
                        ? IconButton(
                            onPressed: () async {
                              //await _changeItemName(context, item);
                              await ListAppItemManager.instanceForList(
                                      widget.listAppList.databaseId!,
                                      _loggedInListAppUser.databaseId!)
                                  .updateItemName(_newName, item);

                              setState(() {
                                item.name = _newName;
                              });
                              FocusScope.of(context).unfocus();
                              Fluttertoast.showToast(
                                msg: "Updated item name!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            },
                            icon: const Icon(Icons.edit))
                        : const IconButton(
                            onPressed: null, icon: Icon(Icons.edit)))
                    : null);
          }),
          StatefulBuilder(builder: (context, setDescriptionState) {
            return ListTile(
                title: TextField(
                  enabled: _loggedInListAppUser.databaseId == item.creatorUid,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: descriptionFieldController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(8.0),
                    border: OutlineInputBorder(
                      gapPadding: 2.0,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(
                          color: Theme.of(context).textTheme.headline1!.color!,
                          width: 1.0),
                    ),
                    labelText: "Description",
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.headline1!.color),
                    hintText: "Type here...",
                    hintStyle: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  onChanged: (value) {
                    setDescriptionState(() {
                      _newDescription = value;
                    });
                  },
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: ((widget.listAppList.listStatus == ListStatus.draft ||
                            widget.listAppList.listType == ListType.public) &&
                        _loggedInListAppUser.databaseId == item.creatorUid)
                    ? ((_newDescription.isNotEmpty &&
                            _newDescription != item.description)
                        ? IconButton(
                            onPressed: () async {
                              //await _changeItemName(context, item);
                              await ListAppItemManager.instanceForList(
                                      widget.listAppList.databaseId!,
                                      _loggedInListAppUser.databaseId!)
                                  .updateItemDescription(_newDescription, item);

                              setState(() {
                                item.description = _newDescription;
                              });
                              FocusScope.of(context).unfocus();
                              Fluttertoast.showToast(
                                msg: "Updated item description!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            },
                            icon: const Icon(Icons.edit))
                        : const IconButton(
                            onPressed: null, icon: Icon(Icons.edit)))
                    : null);
          }),
          Card(
            color: Theme.of(context).primaryColor.withAlpha(50),
            child: ListTile(
              title: Text(creator.firstName + " " + creator.lastName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text("Creator"),
            ),
          ),
          Card(
            color: Theme.of(context).primaryColor.withAlpha(50),
            child: ListTile(
              title: Text(item.itemType.toReadableString() +
                  ((item.itemType == ItemType.multiFulfillment)
                      ? "\n-Number of instances: ${item.maxQuantity}"
                      : (item.itemType == ItemType.multiFulfillmentMember)
                          ? "\n-Number of instances: ${item.maxQuantity}\n-Max quantity per member: ${item.quantityPerMember}"
                          : "")),
              subtitle: const Text("Type"),
            ),
          ),
          ((widget.listAppList.listStatus == ListStatus.draft ||
                      widget.listAppList.listType == ListType.public) &&
                  _loggedInListAppUser.databaseId == item.creatorUid)
              ? TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.red, primary: Colors.white),
                  child: const Text('DELETE'),
                  onPressed: () async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                              "Are you sure you wish to delete this item?"),
                          actions: <Widget>[
                            TextButton(
                                style:
                                    TextButton.styleFrom(primary: Colors.red),
                                onPressed: () async {
                                  final itemManagerInstance =
                                      ListAppItemManager.instanceForList(
                                    widget.listAppList.databaseId!,
                                    widget.listAppList.creator!.databaseId!,
                                  );

                                  await itemManagerInstance
                                      .deleteInstance(item);
                                  setState(() {
                                    widget.listAppList.items.removeWhere(
                                        (element) => element == item);
                                  });

                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: const Text("DELETE")),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("CANCEL"),
                            ),
                          ],
                        );
                      },
                    );
                  })
              : (_loggedInListAppUser.databaseId != item.creatorUid)
                  ? TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.grey, primary: Colors.white),
                      child: const Text('Only the creator can delete the item'),
                      onPressed: null,
                    )
                  : TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.grey, primary: Colors.white),
                      child: const Text('You can no longer delete this item'),
                      onPressed: null,
                    ),
          item.link != null
              ? TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.cyan, primary: Colors.white),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.attach_file),
                    const Text('Link')
                  ]),
                  onPressed: () async {
                    if (item.link != null) {
                      _launchInBrowser(item.link!);
                    }
                  },
                )
              : TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.grey, primary: Colors.white),
                  child: const Text('There is no link for this item'),
                  onPressed: null,
                ),
        ]))));
  }

  Widget _buildItemRow(BuildContext context, BaseItem aListItem) {
    ListAppUser? creator;
    ListAppUserManager.instance.getByUid(aListItem.creatorUid).then((value) {
      creator = value;
    });
    if (widget.listAppList.listType == ListType.public ||
        (widget.listAppList.listType == ListType.private &&
            _loggedInListAppUser.databaseId != aListItem.creatorUid &&
            widget.listAppList.listStatus == ListStatus.saved)) {
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
              key: Key("dismissible_${aListItem.databaseId!}"),
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
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return _itemDetailsAlertDialog(
                          context, aListItem, creator!);
                    },
                  );
                },
                trailing: Container(
                  width: 40,
                  child: Checkbox(
                    activeColor: Theme.of(context).accentColor,
                    value: aListItem.isFulfilled(),
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
                ),
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
                                  color: _assignedColors[aListItem
                                      .getFulfillers()
                                      .first
                                      .databaseId],
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
                selected: aListItem.isFulfilled(),
              ),
            );
          } else {
            return ListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return _itemDetailsAlertDialog(
                        context, aListItem, creator!);
                  },
                );
              },
              trailing: Container(
                  width: 40,
                  child: Checkbox(
                    activeColor: Theme.of(context).accentColor,
                    value: aListItem.isFulfilled(),
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
                  )),
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
              selected: aListItem.isFulfilled(),
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
                key: Key("dismissible_${aListItem.databaseId!}"),
                onDismissed: (DismissDirection direction) async {
                  final itemManagerInstance =
                      ListAppItemManager.instanceForList(
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
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return _itemDetailsAlertDialog(
                            context, aListItem, creator!);
                      },
                    );
                  },
                  trailing: Container(
                      width: 40,
                      child: Checkbox(
                        activeColor: Theme.of(context).accentColor,
                        value: aListItem
                            .quantityFulfilledBy(_loggedInListAppUser)
                            .isOdd,
                        onChanged: (bool? value) async {
                          if (aListItem.isFulfilled()) {
                            if (aListItem.usersCompletions.keys
                                .contains(_loggedInListAppUser.databaseId)) {
                              if (value == true) {
                                await ListAppItemManager.instanceForList(
                                        widget.listAppList.databaseId!,
                                        _loggedInListAppUser.databaseId!)
                                    .fulfillItem(
                                        _loggedInListAppUser.databaseId!,
                                        widget.listAppList.databaseId!,
                                        aListItem,
                                        1);
                              } else {
                                await ListAppItemManager.instanceForList(
                                        widget.listAppList.databaseId!,
                                        _loggedInListAppUser.databaseId!)
                                    .unfulfillItem(
                                        _loggedInListAppUser.databaseId!,
                                        widget.listAppList.databaseId!,
                                        aListItem,
                                        1);
                              }
                              setState(() {});
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title:
                                          const Text("Item already fulfilled!"),
                                      content: const Text(
                                          "This item has been alredy fulfilled by other users."),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                              textStyle:
                                                  const TextStyle(fontSize: 16),
                                              primary: Colors.white,
                                              backgroundColor: Theme.of(context)
                                                  .accentColor),
                                          child: const Text("Got it!"),
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
                                  .fulfillItem(
                                      _loggedInListAppUser.databaseId!,
                                      widget.listAppList.databaseId!,
                                      aListItem,
                                      1);
                            } else {
                              await ListAppItemManager.instanceForList(
                                      widget.listAppList.databaseId!,
                                      _loggedInListAppUser.databaseId!)
                                  .unfulfillItem(
                                      _loggedInListAppUser.databaseId!,
                                      widget.listAppList.databaseId!,
                                      aListItem,
                                      1);
                            }
                            setState(() {});
                          }
                        },
                      )),
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
                                            color:
                                                Theme.of(context).accentColor,
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
                                            color:
                                                Theme.of(context).accentColor,
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
                  selected: aListItem.isFulfilled(),
                ));
          } else {
            return ListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return _itemDetailsAlertDialog(
                        context, aListItem, creator!);
                  },
                );
              },
              trailing: Container(
                  width: 40,
                  child: Checkbox(
                    activeColor: Theme.of(context).accentColor,
                    value: aListItem
                        .quantityFulfilledBy(_loggedInListAppUser)
                        .isOdd,
                    onChanged: (bool? value) async {
                      if (aListItem.isFulfilled()) {
                        if (aListItem.usersCompletions.keys
                            .contains(_loggedInListAppUser.databaseId)) {
                          if (value == true) {
                            await ListAppItemManager.instanceForList(
                                    widget.listAppList.databaseId!,
                                    _loggedInListAppUser.databaseId!)
                                .fulfillItem(
                                    _loggedInListAppUser.databaseId!,
                                    widget.listAppList.databaseId!,
                                    aListItem,
                                    1);
                          } else {
                            await ListAppItemManager.instanceForList(
                                    widget.listAppList.databaseId!,
                                    _loggedInListAppUser.databaseId!)
                                .unfulfillItem(
                                    _loggedInListAppUser.databaseId!,
                                    widget.listAppList.databaseId!,
                                    aListItem,
                                    1);
                          }
                          setState(() {});
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Item already fulfilled!"),
                                  content: const Text(
                                      "This item has been alredy fulfilled by other users."),
                                  actions: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                          textStyle:
                                              const TextStyle(fontSize: 16),
                                          primary: Colors.white,
                                          backgroundColor:
                                              Theme.of(context).accentColor),
                                      child: const Text("Got it!"),
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
                  )),
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
              selected: aListItem.isFulfilled(),
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
                key: Key("dismissible_${aListItem.databaseId!}"),
                onDismissed: (DismissDirection direction) async {
                  final itemManagerInstance =
                      ListAppItemManager.instanceForList(
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
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return _itemDetailsAlertDialog(
                            context, aListItem, creator!);
                      },
                    );
                  },
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
                            if (aListItem.usersCompletions.keys
                                .contains(_loggedInListAppUser.databaseId)) {
                              await _showNumberPickerDialog(context, aListItem);
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title:
                                          const Text("Item already fulfilled!"),
                                      content: const Text(
                                          "This item has been alredy fulfilled by other users."),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                              textStyle:
                                                  const TextStyle(fontSize: 16),
                                              primary: Colors.white,
                                              backgroundColor: Theme.of(context)
                                                  .accentColor),
                                          child: const Text("Got it!"),
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            }
                          } else {
                            await _showNumberPickerDialog(context, aListItem);
                          }
                        }),
                  ),
                ));
          } else {
            return ListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return _itemDetailsAlertDialog(
                        context, aListItem, creator!);
                  },
                );
              },
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
                        if (aListItem.usersCompletions.keys
                            .contains(_loggedInListAppUser.databaseId)) {
                          await _showNumberPickerDialog(context, aListItem);
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Item already fulfilled!"),
                                  content: const Text(
                                      "This item has been alredy fulfilled by other users."),
                                  actions: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                          textStyle:
                                              const TextStyle(fontSize: 16),
                                          primary: Colors.white,
                                          backgroundColor:
                                              Theme.of(context).accentColor),
                                      child: const Text("Got it!"),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                  ],
                                );
                              });
                        }
                      } else {
                        await _showNumberPickerDialog(context, aListItem);
                      }
                    }),
              ),
            );
          }
      }
    } else if (widget.listAppList.listStatus == ListStatus.draft &&
        _loggedInListAppUser.databaseId == widget.listAppList.creatorUid) {
      return ListTile(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return _itemDetailsAlertDialog(context, aListItem, creator!);
              },
            );
          },
          title: Text(aListItem.name),
          trailing: const Icon(Icons.edit));
    } else {
      return ListTile(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return _itemDetailsAlertDialog(context, aListItem, creator!);
              },
            );
          },
          title: Text(aListItem.name));
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

          int added = 0;
          int difference = 0;
          return StatefulBuilder(builder: (context, setPickerState) {
            return AlertDialog(
                title:
                    const Text("How many times have you completed this item?"),
                content: NumberPicker(
                  key: const Key("numberPickerKey"),
                  minValue: 0,
                  maxValue: (aListItem.usersCompletions.isNotEmpty &&
                          !aListItem.usersCompletions.keys
                              .contains(_loggedInListAppUser.databaseId) &&
                          aListItem.maxQuantity -
                                  aListItem.usersCompletions.values.reduce(
                                      (value, element) => value + element) <
                              aListItem.quantityPerMember)
                      ? aListItem.maxQuantity -
                          aListItem.usersCompletions.values
                              .reduce((value, element) => value + element)
                      : ((aListItem.usersCompletions.isNotEmpty &&
                              aListItem.usersCompletions.keys
                                  .contains(_loggedInListAppUser.databaseId) &&
                              aListItem.maxQuantity -
                                      aListItem.usersCompletions.values.reduce(
                                          (value, element) => value + element) <
                                  aListItem.quantityPerMember)
                          ? aListItem.maxQuantity -
                              aListItem.usersCompletions.values.reduce((value, element) => value + element) +
                              aListItem.usersCompletions[_loggedInListAppUser.databaseId]!
                          : aListItem.quantityPerMember),
                  value: _currentValue,
                  onChanged: (value) => {
                    _previousValue < value ? added = 1 : added = 0,
                    difference = value - _previousValue,
                    setPickerState(() => _currentValue = value)
                  },
                ),
                actions: <Widget>[
                  TextButton(
                      style: TextButton.styleFrom(
                          primary: Theme.of(context).primaryColor),
                      onPressed: () async {
                        if (added == 1) {
                          await ListAppItemManager.instanceForList(
                                  widget.listAppList.databaseId!,
                                  _loggedInListAppUser.databaseId!)
                              .fulfillItem(
                                  _loggedInListAppUser.databaseId!,
                                  widget.listAppList.databaseId!,
                                  aListItem,
                                  difference);
                        } else {
                          await ListAppItemManager.instanceForList(
                                  widget.listAppList.databaseId!,
                                  _loggedInListAppUser.databaseId!)
                              .unfulfillItem(
                                  _loggedInListAppUser.databaseId!,
                                  widget.listAppList.databaseId!,
                                  aListItem,
                                  difference);
                        }
                        setState(() {});
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
                                  "Are you sure you want to remove ${member.displayName} from this list?",
                                ),
                                actions: <Widget>[
                                  TextButton(
                                      style: TextButton.styleFrom(
                                          primary: Colors.red),
                                      onPressed: () {
                                        ListAppListManager.instanceForUserUid(
                                          _loggedInListAppUser.databaseId!,
                                        ).removeMemberFromList(
                                          widget.listAppList,
                                          member.databaseId!,
                                        );

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
      await ListAppListManager.instanceForUser(listAppUser).leaveList(list);
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveDraftList(ListAppList list) async {
    final listAppUser =
        await context.read<ListAppAuthProvider>().getLoggedInListAppUser();

    if (listAppUser == null) return;

    list.listStatus = ListStatus.saved;

    await ListAppListManager.instanceForUser(listAppUser).saveToFirestore(list);
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
            title: option == "save"
                ? const Text("Do you want to save and publish this list?")
                : Text(
                    "Are you sure you wish to ${doesUserOwnList ? 'delete' : 'leave'} the " +
                        widget.listAppList.name +
                        " list?"),
            content: option == "save"
                ? const Text(
                    "You will not be able to add new items or modify existing ones")
                : (doesUserOwnList
                    ? const Text(
                        "You and all the other participants will not see this list anymore")
                    : const Text(
                        "If you push LEAVE, you will abandon this list and you won't be able to join it unless someone invites you again")),
            actions: <Widget>[
              option == "save"
                  ? TextButton(
                      style: TextButton.styleFrom(primary: Colors.green),
                      onPressed: () async {
                        await _saveDraftList(widget.listAppList);
                        setState(() {
                          widget.listAppList.listStatus = ListStatus.saved;
                        });
                        Navigator.of(context).pop(true);
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('OK'))
                  : TextButton(
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
                    value:
                        "${(widget.listAppList.listStatus == ListStatus.draft && _loggedInListAppUser.databaseId == widget.listAppList.creatorUid) ? 'save' : (doesUserOwnList ? 'delete' : 'leave')}",
                    child: Text(
                        "${(widget.listAppList.listStatus == ListStatus.draft && _loggedInListAppUser.databaseId == widget.listAppList.creatorUid) ? 'Save list' : (doesUserOwnList ? 'Delete list' : 'Leave list')}"),
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
        _buildListDetails(context),
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
        Expanded(
          child: TabBarView(
            children: [
              _buildItemsListView(context),
              _buildMembersListView(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMembersListView(BuildContext context) {
    final bool isAdmin = widget.canAddNewMembers;

    final allMembers = widget.listAppList.membersAsUsers;
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
        AddMemberDialog(
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
                  leading: widget.listAppList.listType == ListType.private
                      ? const Icon(
                          FontAwesomeIcons.userSecret,
                        )
                      : const Icon(Icons.list),
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
                widget.listAppList.listStatus == ListStatus.saved
                    ? ListTile(
                        dense: true,
                        horizontalTitleGap: 0.5,
                        leading: const Icon(Icons.person_pin_rounded),
                        title: Text(widget.listAppList.creator?.displayName ??
                            'John Smith'),
                        subtitle: Text(
                            widget.listAppList.creator?.username ?? 'john21'),
                      )
                    : ListTile(
                        dense: true,
                        horizontalTitleGap: 0.5,
                        leading: const Icon(Icons.mode_edit),
                        title: const Text(
                          'This list is in draft mode',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: _loggedInListAppUser.databaseId ==
                                widget.listAppList.creatorUid
                            ? const Text(
                                'Click on the three dots on the top in order to save and publish it',
                              )
                            : const Text(
                                'Wait until the creator saves and publishes it in order to complete items',
                              ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
