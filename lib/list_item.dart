import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// TODO remove this file?

abstract class ListItem {
  Widget buildTitle(BuildContext context);
  Widget buildSubtitle(BuildContext context);
}

/// A ListItem that contains data to display a heading.
class HeadingItem with ListItem {
  final String heading;

  HeadingItem(this.heading);

  Widget buildTitle(BuildContext context) {
    return Text(
      heading,
      style: Theme.of(context).textTheme.headline5,
    );
  }

  Widget buildSubtitle(BuildContext context) => null;
}

/// A ListItem that contains data to display a message. We use it to display the list of lists in the home page
class TitleSubtitleItem implements ListItem {
  // the id refers to external id, given by backend. We need it here to keep track of the tapped list id
  final int id;
  final String listName;
  final String listDescription;

  TitleSubtitleItem(this.id, this.listName, this.listDescription);

  Widget buildTitle(BuildContext context) {
    return Text(
      listName,
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget buildSubtitle(BuildContext context) => Text(listDescription);
}

//This list item is used to display the actual list items, and to add it when needed
class ListDetailedItem {
  final int id;
  final String name;

  bool isSelected;
  // the people who filled this item of the list. If allowed, each person has the number of times they have fulfilled the list.
  Map<String, int> fulfillers;

  ListDetailedItem(this.id, this.name);
}
