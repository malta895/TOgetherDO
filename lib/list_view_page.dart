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

  _ListViewRouteState(this._member, this._aList);

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
    if (aListItem.maxQuantity() == 1)
      return CheckboxListTile(
        title: () {
          if (aListItem.isFulfilled())
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(aListItem.name),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors
                          .red, // TODO randomize and assign a color to each member of the current list
                    ),
                    Text(
                      aListItem.getFulfillers()[0].firstName,
                      textScaleFactor: 0.7,
                    )
                  ],
                )
              ],
            );
          else
            return Text(aListItem.name);
        }(),
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
