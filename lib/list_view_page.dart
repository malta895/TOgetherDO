import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'new_item.dart';
import 'models/alist.dart';

class ListViewRoute extends StatelessWidget {

  final AList aList;

  ListViewRoute(this.aList);

  //TODO fetch from backend
  final List<AListItem> _listItems = [
    AListItem.constructSimpleItem(
        1, "Simple element - undone", "A simple undone element"),
    AListItem.constructSimpleItem(
        2, "Simple element - done", "A simple done element"),
    AListItem.constructSimpleItem(
        3, "Buy groceries", "go to buy some groceries"),
  ];

  Widget _buildListItems() {
    return ListView.builder(
      itemCount: _listItems.length,
      itemBuilder: (context, i) {
        return _buildRow(_listItems[i]);
      },
    );
  }

  Widget _buildRow(AListItem aListItem) {
    return CheckboxListTile(
      title: Text(aListItem.name),
      value: false,
      onChanged: (bool value) {
        // TODO implement fullfillment logic
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(aList.name),
      ),
      body: _buildListItems(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewListItem()),
          )
        },
        icon: Icon(Icons.add),
        label: Text('NEW ITEM'),
      ),
    );
  }
}
