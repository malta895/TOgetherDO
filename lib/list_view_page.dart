import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'list_item.dart';

class ListViewRoute extends StatelessWidget {
  final ListItem listItem;

  ListViewRoute(this.listItem);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: listItem.buildTitle(context),
      ),
    );
  }
}
