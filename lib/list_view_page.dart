import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'new_item.dart';
import 'models/alist.dart';

class ListViewRoute extends StatefulWidget {
  final AList aList;

  ListViewRoute(this.aList);

  @override
  _ListViewRouteState createState() => _ListViewRouteState();
}

class _ListViewRouteState extends State<ListViewRoute> {
  AListMember _member = AListMember(1, "foo", "Mario", "Rossi");

  final List<BaseItem> _listItems = [
    SimpleItem(1, "Simple element - undone", "A simple undone element"),
    SimpleItem(2, "Simple element - done", "A simple done element"),
    SimpleItem(3, "Buy groceries", "go to buy some groceries"),
  ];

  Widget _buildListItems() {
    return ListView.builder(
      itemCount: _listItems.length,
      itemBuilder: (context, i) {
        return _buildRow(_listItems[i]);
      },
    );
  }

  Widget _buildRow(BaseItem aListItem) {
    //depending on the quantity of selectable items, we return a checkbox or a normal ListTile
    if (aListItem.maxQuantity() == 1)
      return CheckboxListTile(
        title: Text(aListItem.name),
        value: aListItem.isFulfilled(),
        selected: aListItem.isFulfilled(),
        onChanged: (bool value) {
          setState(() {
            if (value) {
              aListItem.fulfill(_member, 1);
            } else {
              aListItem.unfulfill(_member);
            }
          });
        },
      );
    else
      throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.aList.name),
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
