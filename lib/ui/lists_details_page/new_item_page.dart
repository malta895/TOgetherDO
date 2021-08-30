import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/models/list_item.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/item_manager.dart';

class NewItemPage extends StatelessWidget {
  final ListAppList currentList;
  final ListAppUser currentUser;

  const NewItemPage({
    required this.currentList,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New item'),
      ),
      body: SingleChildScrollView(
        child: _NewItemForm(
          currentList: currentList,
          currentUser: currentUser,
        ),
      ),
    );
  }
}

class _NewItemForm extends StatefulWidget {
  final ListAppList currentList;
  final ListAppUser currentUser;

  const _NewItemForm({
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
  final _nameKey = GlobalKey();
  final _descriptionKey = GlobalKey();
  final _linkKey = GlobalKey();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  ItemType _selectedItemType = ItemType.simple;
  int _itemsCounter = 1;
  int _membersCounter = 1;

  String? _nameValidatorMessage;
  String? _descriptionValidatorMessage;
  String? _linkValidatorMessage;

  late final Map<ItemType, ExpandableController> _expandableControllers;

  @override
  void initState() {
    _expandableControllers = Map.fromIterable(
      ItemType.values,
      value: (_) => ExpandableController(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: TextFormField(
                key: _nameKey,
                onChanged: (_) {
                  if (_nameValidatorMessage != null) {
                    setState(() {
                      _nameValidatorMessage = null;
                      _formKey.currentState?.validate();
                    });
                  }
                },
                controller: _titleController,
                cursorColor: Theme.of(context).textTheme.headline1!.color!,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(5.0),
                    filled: true,
                    fillColor: Theme.of(context).splashColor,
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)),
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

                  return _nameValidatorMessage;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: TextFormField(
                key: _descriptionKey,
                onChanged: (_) {
                  if (_descriptionValidatorMessage != null) {
                    setState(() {
                      _descriptionValidatorMessage = null;
                      _formKey.currentState?.validate();
                    });
                  }
                },
                controller: _descriptionController,
                cursorColor: Theme.of(context).textTheme.headline1!.color!,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(5.0),
                    filled: true,
                    fillColor: Theme.of(context).splashColor,
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(
                          color: Theme.of(context).textTheme.headline1!.color!,
                          width: 1.0),
                    ),
                    border: InputBorder.none,
                    labelText: 'You can also enter a description',
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.headline1!.color)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: TextFormField(
                key: _linkKey,
                onChanged: (_) {
                  if (_linkValidatorMessage != null) {
                    setState(() {
                      _linkValidatorMessage = null;
                      _formKey.currentState?.validate();
                    });
                  }
                },
                controller: _linkController,
                cursorColor: Theme.of(context).textTheme.headline1!.color!,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(5.0),
                    filled: true,
                    fillColor: Theme.of(context).splashColor,
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(
                          color: Theme.of(context).textTheme.headline1!.color!,
                          width: 1.0),
                    ),
                    border: InputBorder.none,
                    labelText: 'You can also add a link to a web page',
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.headline1!.color)),
              ),
            ),

            // divider "Choose the item type
            Row(
              children: <Widget>[
                const Expanded(child: Divider()),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Choose the item type'),
                ),
                const Expanded(child: Divider()),
              ],
            ),

            _buildItemForms(context),

            //start of submit button part
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 14.0, horizontal: 6.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.pinkAccent[700],
                ),
                child: const Text('Submit'),
                onPressed: () async {
                  // Validate returns true if the form is valid, or false
                  // otherwise.
                  final itemManagerInstance =
                      ListAppItemManager.instanceForList(
                    widget.currentList.databaseId!,
                    widget.currentList.creator!.databaseId!,
                  );
                  if (await itemManagerInstance
                      .listItemNameExists(_titleController.text)) {
                    setState(() {
                      _nameValidatorMessage =
                          'An item with this name already exists';
                    });
                  }
                  if (_formKey.currentState?.validate() == true) {
                    BaseItem newItem;

                    switch (_selectedItemType) {
                      case ItemType.simple:
                        newItem = SimpleItem(
                            name: _titleController.text,
                            description: _descriptionController.text != ''
                                ? _descriptionController.text
                                : null,
                            link: _linkController.text != ''
                                ? _linkController.text
                                : null,
                            creatorUid: widget.currentUser.databaseId!,
                            usersCompletions: {});
                        break;
                      case ItemType.multiFulfillment:
                        newItem = MultiFulfillmentItem(
                            name: _titleController.text,
                            description: _descriptionController.text != ''
                                ? _descriptionController.text
                                : null,
                            link: _linkController.text != ''
                                ? _linkController.text
                                : null,
                            maxQuantity: _itemsCounter,
                            creatorUid: widget.currentUser.databaseId!,
                            usersCompletions: {});
                        break;
                      case ItemType.multiFulfillmentMember:
                        newItem = MultiFulfillmentMemberItem(
                            name: _titleController.text,
                            description: _descriptionController.text != ''
                                ? _descriptionController.text
                                : null,
                            link: _linkController.text != ''
                                ? _linkController.text
                                : null,
                            maxQuantity: _itemsCounter,
                            quantityPerMember: _membersCounter,
                            creatorUid: widget.currentUser.databaseId!,
                            usersCompletions: {});
                        break;
                    }

                    await itemManagerInstance.saveToFirestore(newItem);

                    Navigator.pop<BaseItem>(
                      context,
                      newItem,
                    );
                    print("Dopo navigator . pop");
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemForms(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: ItemType.values.map((itemType) {
            return RadioListTile<ItemType>(
              title: Text(itemType.toReadableString()),
              subtitle: Text(itemType.getDescription()),
              value: itemType,
              groupValue: _selectedItemType,
              onChanged: (selectedItemType) {
                if (selectedItemType != null) {
                  setState(() {
                    if (selectedItemType == ItemType.multiFulfillmentMember) {
                      _itemsCounter = 2;
                      _membersCounter = 2;
                    } else {
                      _itemsCounter = 1;
                      _membersCounter = 1;
                    }
                    _selectedItemType = selectedItemType;
                    _expandableControllers.forEach((key, controller) {
                      if (key != _selectedItemType) controller.expanded = false;
                    });
                    _expandableControllers.forEach((key, controller) {
                      if (key == _selectedItemType) controller.expanded = true;
                    });
                  });
                }
              },
            );
          }).toList(),
        ),
        ExpandablePanel(
          collapsed: Container(),
          expanded: _buildMultiFulfillmentForm(context),
          controller: _expandableControllers[ItemType.multiFulfillment],
        ),
        ExpandablePanel(
          collapsed: Container(),
          expanded: Column(
            children: [
              _buildMultiFulfillmentForm(context),
              _buildMultiFulfillmentMemberForm(context),
            ],
          ),
          controller: _expandableControllers[ItemType.multiFulfillmentMember],
        ),
      ],
    );
  }

  ListTile _buildMultiFulfillmentMemberForm(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(4.0),
      title: Text(
        "Maximum quantity per single member: ",
        style: TextStyle(
            fontSize: 16, color: Theme.of(context).textTheme.headline1!.color),
      ),
      trailing: Wrap(
          spacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            TextButton(
              child: Icon(
                Icons.remove,
                color: _membersCounter > 2
                    ? Theme.of(context).textTheme.headline1!.color
                    : Theme.of(context).disabledColor,
              ),
              // minWidth: 5.0,
              onPressed: () {
                setState(() {
                  if (_membersCounter > 2) _membersCounter--;
                });
              },
            ),
            Text("$_membersCounter",
                style: TextStyle(
                    color: Theme.of(context).textTheme.headline1!.color,
                    fontSize: 20.0)),
            TextButton(
              child: Icon(
                Icons.add,
                color: _membersCounter < _itemsCounter
                    ? Theme.of(context).textTheme.headline1!.color
                    : Theme.of(context).disabledColor,
              ),
              onPressed: () {
                setState(() {
                  if (_membersCounter < _itemsCounter) _membersCounter++;
                });
              },
            )
          ]),
    );
  }

  ListTile _buildMultiFulfillmentForm(BuildContext context) {
    final minItems =
        _selectedItemType == ItemType.multiFulfillmentMember ? 2 : 1;
    return ListTile(
      contentPadding: const EdgeInsets.all(5.0),
      title: Text(
        "Total number of instances: ",
        style: TextStyle(
            fontSize: 16, color: Theme.of(context).textTheme.headline1!.color),
      ),
      trailing: Wrap(
          spacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            TextButton(
                child: Icon(
                  Icons.remove,
                  color: _itemsCounter > minItems
                      ? Theme.of(context).textTheme.headline1!.color
                      : Theme.of(context).disabledColor,
                ),
                // minWidth: 5.0,
                onPressed: () {
                  setState(() {
                    if (_itemsCounter > minItems) {
                      _itemsCounter--;
                      if (_membersCounter > _itemsCounter)
                        _membersCounter = _itemsCounter;
                    }
                  });
                }),
            Text("$_itemsCounter",
                style: TextStyle(
                    color: Theme.of(context).textTheme.headline1!.color,
                    fontSize: 20.0)),
            TextButton(
              child: Icon(Icons.add,
                  color: Theme.of(context).textTheme.headline1!.color),
              onPressed: () {
                setState(() {
                  _itemsCounter++;
                });
              },
            )
          ]),
    );
  }
}
