import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/list_item.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/item_manager.dart';

class NewItemPage extends StatelessWidget {
  final ListAppList currentList;
  final ListAppUser currentUser;

  NewItemPage({
    required this.currentList,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New item'),
      ),
      body: _NewItemForm(
        currentList: currentList,
        currentUser: currentUser,
      ),
    );
  }
}

class _NewItemForm extends StatefulWidget {
  final ListAppList currentList;
  final ListAppUser currentUser;

  _NewItemForm({
    required this.currentList,
    required this.currentUser,
  });
  @override
  _NewItemFormState createState() => _NewItemFormState();
}

// Define a corresponding State class.
// This class holds data related to the form.
class _NewItemFormState extends State<_NewItemForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();

  ItemType _selectedItemType = ItemType.simple;
  int _itemCounter = 0;
  int _membersCounter = 0;

  Widget _switchItemForm(BuildContext context, ItemType itemType) {
    switch (itemType) {
      case ItemType.simple:
        // TODO: Handle this case.
        return Text(itemType.toReadableString());
      case ItemType.multiFulfillment:
        return _buildMultiItemForm(context);
      case ItemType.multiFulfillmentMember:
        // TODO: Handle this case.
        return Text(itemType.toReadableString());
    }
  }

  // TODO Widget _buildSimpleItemForm() {}

  Widget _buildMultiItemForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 15),
      child: ListTile(
        contentPadding: EdgeInsets.all(5.0),
        title: Text(
          "Number of items: ",
          style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.headline1!.color),
        ),
        tileColor: Theme.of(context).splashColor,
        trailing: Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              TextButton(
                  child: Icon(
                    Icons.remove,
                    color: Theme.of(context).textTheme.headline1!.color,
                  ),
                  // minWidth: 5.0,
                  onPressed: () {
                    setState(() {
                      if (_itemCounter > 0) _itemCounter--;
                    });
                  }),
              Text("$_itemCounter",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.headline1!.color,
                      fontSize: 20.0)),
              TextButton(
                child: Icon(Icons.add,
                    color: Theme.of(context).textTheme.headline1!.color),
                onPressed: () {
                  setState(() {
                    _itemCounter++;
                  });
                },
              )
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: TextFormField(
                controller: _titleController,
                cursorColor: Theme.of(context).textTheme.headline1!.color!,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(5.0),
                    filled: true,
                    fillColor: Theme.of(context).splashColor,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(
                          color: Theme.of(context).textTheme.headline1!.color!,
                          width: 1.0),
                    ),
                    border: InputBorder.none,
                    labelText: 'Enter the item title',
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.headline1!.color)),
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
            // the Expansion panels for the different types
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpansionPanelList.radio(
                dividerColor: Theme.of(context).primaryColor,
                elevation: 0,
                initialOpenPanelValue: ItemType.simple,
                expansionCallback: (int index, bool isClosed) {
                  if (isClosed) {
                    setState(() {
                      _selectedItemType = ItemType.values[index];
                    });
                    // TODO remove switch if not needed
                    switch (index) {
                      case 0:
                        break;
                      case 1:
                        break;
                      case 2:
                        break;
                    }
                  }
                },
                children: ItemType.values.map((itemType) {
                  return ExpansionPanelRadio(
                    backgroundColor: Theme.of(context).splashColor,
                    canTapOnHeader: true,
                    value: itemType,
                    headerBuilder: (context, isOpen) {
                      return Text(
                        itemType.toReadableString(),
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Theme.of(context).textTheme.headline5!.color,
                          fontWeight:
                              isOpen ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    },
                    body: _switchItemForm(context, itemType),
                  );
                }).toList(),
              ),
            ),

            //start of submit button part
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.pinkAccent[700],
                ),
                onPressed: () async {
                  // Validate returns true if the form is valid, or false
                  // otherwise.
                  if (_formKey.currentState?.validate() == true) {
                    BaseItem newItem;

                    switch (_selectedItemType) {
                      case ItemType.simple:
                        newItem = SimpleItem(
                          name: _titleController.text,
                        );
                        break;
                      case ItemType.multiFulfillment:
                        newItem = MultiFulfillmentItem(
                          name: _titleController.text,
                          maxQuantity: _itemCounter,
                        );
                        break;
                      case ItemType.multiFulfillmentMember:
                        newItem = MultiFulfillmentMemberItem(
                          name: _titleController.text,
                          maxQuantity: _itemCounter,
                          quantityPerMember: _membersCounter,
                        );
                        break;
                    }

                    // TODO: add the item to the list on the backend

                    await ListAppItemManager.instanceForList(
                      widget.currentList.databaseId!,
                      widget.currentUser.databaseId,
                    ).saveInstance(newItem);

                    print(newItem.databaseId!);

                    Navigator.pop<BaseItem>(
                      context,
                      newItem,
                    );
                  }
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemTypeDropdownMenu extends StatefulWidget {
  _ItemTypeDropdownMenu({Key? key}) : super(key: key);

  @override
  _ItemTypeDropdownMenuState createState() => _ItemTypeDropdownMenuState();
}

class _ItemTypeDropdownMenuState extends State<_ItemTypeDropdownMenu> {
  ItemType _dropdownValue = ItemType.simple;

  bool _visibleItem = false;
  bool _visibleMembers = false;
  int _itemCounter = 0;
  int _membersCounter = 0;

  void _hideMultipleSelection(ItemType newDropdownValue) {
    setState(() {
      _dropdownValue = newDropdownValue;
      switch (_dropdownValue) {
        case ItemType.simple:
          _visibleItem = false;
          _visibleMembers = false;
          break;
        case ItemType.multiFulfillment:
          _visibleItem = true;
          _visibleMembers = false;
          _itemCounter = 0;
          break;
        case ItemType.multiFulfillmentMember:
          _visibleItem = false;
          _visibleMembers = true;
          _itemCounter = 0;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
        Widget>[
      Padding(
        padding: EdgeInsets.only(top: 15),
        child: DropdownButtonFormField<ItemType>(
          value: _dropdownValue,
          style: TextStyle(
            color: Theme.of(context).textTheme.headline1!.color,
            fontSize: 16.0,
          ),
          decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                borderSide: BorderSide(
                    color: Theme.of(context).textTheme.headline1!.color!,
                    width: 1.0),
              ),
              contentPadding: EdgeInsets.all(5.0),
              filled: true,
              fillColor: Theme.of(context).splashColor,
              border: InputBorder.none,
              labelStyle: TextStyle(
                  color: Theme.of(context).textTheme.headline1!.color)),
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 24,
          elevation: 16,
          onChanged: (ItemType? newValue) {
            if (newValue == null) return;
            _hideMultipleSelection(newValue);
          },
          items:
              ItemType.values.map<DropdownMenuItem<ItemType>>((ItemType value) {
            return DropdownMenuItem<ItemType>(
              value: value,
              child: Text(value.toReadableString()),
            );
          }).toList(),
        ),
      ),
      Visibility(
          visible: _visibleItem,
          child: Padding(
            padding: EdgeInsets.only(top: 15),
            child: ListTile(
              contentPadding: EdgeInsets.all(5.0),
              title: Text(
                "Number of items: ",
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.headline1!.color),
              ),
              tileColor: Theme.of(context).splashColor,
              trailing: Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    TextButton(
                        child: Icon(
                          Icons.remove,
                          color: Theme.of(context).textTheme.headline1!.color,
                        ),
                        // minWidth: 5.0,
                        onPressed: () {
                          setState(() {
                            if (_itemCounter > 0) _itemCounter--;
                          });
                        }),
                    Text("$_itemCounter",
                        style: TextStyle(
                            color: Theme.of(context).textTheme.headline1!.color,
                            fontSize: 20.0)),
                    TextButton(
                      child: Icon(Icons.add,
                          color: Theme.of(context).textTheme.headline1!.color),
                      onPressed: () {
                        setState(() {
                          _itemCounter++;
                        });
                      },
                    )
                  ]),
            ),
          )),
      Visibility(
          visible: _visibleMembers,
          child: Padding(
            padding: EdgeInsets.only(top: 15),
            child: ListTile(
              contentPadding: EdgeInsets.all(5.0),
              title: Text(
                "Number of people: ",
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.headline1!.color),
              ),
              tileColor: Theme.of(context).splashColor,
              trailing: Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    TextButton(
                      child: Icon(
                        Icons.remove,
                        color: Theme.of(context).textTheme.headline1!.color,
                      ),
                      // minWidth: 5.0,
                      onPressed: () {
                        setState(() {
                          if (_membersCounter > 0) _membersCounter--;
                        });
                      },
                    ),
                    Text("$_membersCounter",
                        style: TextStyle(
                            color: Theme.of(context).textTheme.headline1!.color,
                            fontSize: 20.0)),
                    TextButton(
                      child: Icon(Icons.add,
                          color: Theme.of(context).textTheme.headline1!.color),
                      onPressed: () {
                        setState(() {
                          _membersCounter++;
                        });
                      },
                    )
                  ]),
            ),
          ))
    ]);
  }
}
