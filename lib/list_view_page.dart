import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'list_item.dart';
import 'new_item.dart';

class ListViewRoute extends StatelessWidget {
  final ListItem listItem;

  ListViewRoute(this.listItem);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: listItem.buildTitle(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => new_item()),
          )
        },
        icon: Icon(Icons.add),
        label: Text('NEW ITEM'),
      ),
    );
  }
}
