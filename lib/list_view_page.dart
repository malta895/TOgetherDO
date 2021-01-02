import 'dart:math' as math;
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'new_item.dart';
import 'models/alist.dart';

class ListViewRoute extends StatefulWidget {
  final AList aList;
  //the member currently logged in, TODO make it final and get it from session
  AListMember currentMember;

  ListViewRoute(this.aList) {
    aList.members = Set<AListMember>();

    //TODO fetch from backend instead
    aList.members.addAll([
      AListMember(1, "lawfriends", "Lorenzo", "Amici"),
      AListMember(2, "malta.95", "Luca", "Maltagliati"),
    ]);
    currentMember = aList.members.elementAt(1);

    aList.items = Set<BaseItem>();
    aList.items.addAll([
      SimpleItem(1, "Simple element - undone", "A simple undone element"),
      SimpleItem(2, "Simple element - done", "A simple done element"),
      SimpleItem(3, "Buy groceries", "go to buy some groceries"),
    ]);
    aList.items.elementAt(1).fulfill(aList.members.elementAt(0), 1);
  }

  @override
  _ListViewRouteState createState() =>
      _ListViewRouteState(currentMember, aList);
}

class _ListViewRouteState extends State<ListViewRoute> {
  final AListMember _member;
  final AList _aList;

  final HashMap<AListMember, Color> _assignedColors =
      HashMap<AListMember, Color>();

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
        return _buildRow(_aList.items.elementAt(i));
      },
    );
  }

  Widget _buildRow(BaseItem aListItem) {
    //depending on the quantity of selectable items, we return a checkbox or a normal ListTile
    if (aListItem.maxQuantity == 1)
      return CheckboxListTile(
        title: aListItem.isFulfilled()
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(aListItem.name),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person,
                        color: _assignedColors[aListItem.getFulfillers()[0]],
                      ),
                      Text(
                        aListItem.getFulfillers()[0].firstName,
                        textScaleFactor: 0.7,
                      )
                    ],
                  )
                ],
              )
            : Text(aListItem.name),
        value: aListItem.isFulfilled(),
        selected: aListItem.isFulfilled(),
        onChanged: (bool value) {
          // TODO make async, make not selectable until the server has responded
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
