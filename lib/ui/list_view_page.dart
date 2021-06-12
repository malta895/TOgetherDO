import 'dart:math' as math;
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:mobile_applications/ui/new_item.dart';
import 'package:mobile_applications/models/alist.dart';
import 'package:numberpicker/numberpicker.dart';

class ListViewRoute extends StatefulWidget {
  final AList aList;
  //the member currently logged in, TODO make it final and get it from session
  late AListMember currentMember;

  ListViewRoute(this.aList) {
    aList.members = Set<AListMember>();

    //TODO fetch from backend instead
    aList.members.addAll([
      AListMember(1, "lawfriends", "Lorenzo", "Amici"),
      AListMember(2, "malta.95", "Luca", "Maltagliati"),
    ]);
    currentMember = aList.members.elementAt(1);

    aList.items = Set<BaseItem>();
    /* aList.items.addAll([
      SimpleItem(1, "Simple element - undone", "A simple undone element"),
      SimpleItem(2, "Simple element - done", "A simple done element"),
      SimpleItem(3, "Buy groceries", "go to buy some groceries"),
      MultiFulfillmentItem(
          4, "Buy movie tickets", "go to buy some movie tickets", 5),
      MultiFulfillmentMemberItem(5, "Lord of the rings trilogy",
          "the complete lord of the rings trilogy", 5, 3),
    ]); */
    aList.items.addAll([
      SimpleItem(1, "Simple element - undone"),
      SimpleItem(2, "Simple element - done"),
      SimpleItem(3, "Buy groceries"),
      SimpleItem(
          3, "This is a very long item title to see how it fits in the screen"),
      MultiFulfillmentItem(4, "Buy movie tickets", 5),
      MultiFulfillmentMemberItem(5, "Lord of the rings trilogy", 5, 3),
    ]);
    aList.items.elementAt(1).fulfill(aList.members.elementAt(0), 1);
    aList.items.elementAt(5).fulfill(aList.members.elementAt(0), 3);
    aList.items.elementAt(5).fulfill(aList.members.elementAt(1), 2);
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
        return _buildRow(context, _aList.items.elementAt(i));
      },
    );
  }

  Widget _buildListMembers() {
    return ListView.builder(
      itemCount: _aList.members.length,
      itemBuilder: (context, i) {
        return _buildMemberRow(context, _aList.members.elementAt(i));
      },
    );
  }

  _addListItem(BaseItem item) {
    setState(() {
      _aList.items.add(item);
    });
  }

  void _showNumberPicker(BuildContext context, BaseItem aListItem, int minValue,
      int initialValue) {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          int _currentValue = initialValue;
          return StatefulBuilder(builder: (context, setState) {
            //we need it to be stateful because the widget state can change while the dialog is opened
            return AlertDialog(
              title: Text("How many times have you completed this item?"),
              content: NumberPicker(
                minValue: minValue,
                maxValue: 50,
                value: _currentValue,
                onChanged: (value) => setState(() {
                  //TODO Maybe better to put the buttons
                  aListItem.fulfill(_member, value);
                  _currentValue = value;
                }),
              ),
            );
          });
        });
  }

  Widget _buildRow(BuildContext context, BaseItem aListItem) {
    switch (aListItem.runtimeType) {
      case SimpleItem:
        return CheckboxListTile(
          title: aListItem.isFulfilled()
              ? Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        aListItem.name,
                        style: TextStyle(
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
                            color:
                                _assignedColors[aListItem.getFulfillers()[0]],
                          ),
                          Text(
                            aListItem.getFulfillers()[0].firstName,
                            textScaleFactor: 0.7,
                          )
                        ],
                      ),
                    ),
                  ],
                )
              : Text(aListItem.name),
          value: aListItem.isFulfilled(),
          selected: aListItem.isFulfilled(),
          onChanged: (bool? value) {
            // TODO make async, make not selectable until the server has responded
            setState(() {
              if (value == true) {
                aListItem.fulfill(_member, 1);
              } else {
                aListItem.unfulfill(_member);
              }
            });
          },
        );
      case MultiFulfillmentItem:
        return CheckboxListTile(
          title: aListItem.isFulfilled()
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Expanded(flex: 5, child: Text(aListItem.name)),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person,
                              color:
                                  _assignedColors[aListItem.getFulfillers()[0]],
                            ),
                            Text(
                              "${aListItem.getFulfillers()[0].firstName} ${aListItem.quantityFulfilledBy(_member)}",
                              textScaleFactor: 0.7,
                            )
                          ],
                        ),
                      )
                    ])
              : Text(aListItem.name),
          value: aListItem.isFulfilled(),
          selected: aListItem.isFulfilled(),
          onChanged: (bool? value) {
            // TODO make async, make not selectable until the server has responded
            setState(() {
              if (value == true) {
                aListItem.fulfill(_member, 1);
              } else {
                aListItem.unfulfill(_member);
              }
            });
          },
        );

      case MultiFulfillmentMemberItem:
        List<Widget> itemColumns = [];
        for (AListMember member in aListItem.getFulfillers()) {
          {
            itemColumns.add(Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person,
                  color: _assignedColors[member],
                ),
                Text(
                  "${member.firstName} ${aListItem.quantityFulfilledBy(member)}",
                  textScaleFactor: 0.7,
                )
              ],
            ));
          }
          return ListTile(
            title: aListItem.getFulfillers().length > 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 5, child: Text(aListItem.name)),
                      Expanded(
                        flex: 2,
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: itemColumns),
                      ),
                    ],
                  )
                : Text(aListItem.name),
            selected: aListItem.isFulfilled(),
            onTap: () => _showNumberPicker(
                context, aListItem, 0, aListItem.quantityFulfilledBy(_member)),
          );
        }
    }
    //the code should never reach this point, but we need it for null check
    return ListTile(
      title: Text("Empty element"),
    );
  }

  Widget _buildMemberRow(BuildContext context, AListMember member) {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: Colors.grey,
          width: 0.8,
        ))),
        child: ListTile(
            leading: Icon(Icons.person, color: _assignedColors[member]),
            title: Text(
              member.firstName + ' ' + member.lastName,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: _assignedColors[member]),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.aList.name),
            bottom: TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'ITEMS', icon: Icon(Icons.done)),
                Tab(text: 'MEMBERS', icon: Icon(Icons.person)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildListItems(),
              _buildListMembers(),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            /*onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewListItem()),
              )
            },*/
            onPressed: () {
              _navigateAndDisplaySelection(context);
            },
            icon: Icon(Icons.add),
            label: Text('NEW ITEM'),
          ),
        ));
  }

  void _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewListItem()),
    );
    if (result != null) {
      _addListItem(result);
    }
  }
}
