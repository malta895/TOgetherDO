import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/models/list.dart';
import 'package:mobile_applications/ui/list_view_page.dart';
import 'package:mobile_applications/models/list_item.dart';

class NewListItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New item'),
      ),
      body: MyCustomForm(),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

class DropdownMenu extends StatefulWidget {
  DropdownMenu({Key? key}) : super(key: key);

  @override
  _DropdownMenuState createState() => _DropdownMenuState();
}

/* class Counter extends StatefulWidget {
  _CounterState createState() => _CounterState();
} */

// Define a corresponding State class.
// This class holds data related to the form.
class _MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();

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
                  controller: titleController,
                  cursorColor: Theme.of(context).textTheme.headline1!.color!,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(5.0),
                      filled: true,
                      fillColor: Colors.grey[200],
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).textTheme.headline1!.color!,
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
                )),
            DropdownMenu(),
            // Counter(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.pinkAccent[700],
                ),
                onPressed: () {
                  // TODO: change this to add the item to the list

                  // Validate returns true if the form is valid, or false
                  // otherwise.
                  if (_formKey.currentState?.validate() == true) {
                    final BaseItem newItem =
                        SimpleItem(name: titleController.text);
                    Navigator.pop(
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

class _DropdownMenuState extends State<DropdownMenu> {
  String dropdownValue = 'Simple item';

  void hideMultipleSelection() {
    setState(() {
      if (dropdownValue == 'Simple item') {
        visibleItem = false;
        visiblePeople = false;
      } else if (dropdownValue == 'Multiple instance item') {
        visibleItem = true;
        visiblePeople = false;
        counter = 0;
      } else if (dropdownValue == 'Multiple people item') {
        visibleItem = false;
        visiblePeople = true;
        counter = 0;
      }
    });
  }

  bool visibleItem = false;
  bool visiblePeople = false;
  int counter = 0;

  void decrementCounter() {
    setState(() {
      if (counter > 0) counter--;
    });
  }

  void incrementCounter() {
    setState(() {
      counter++;
    });
  }

  void setCounter(double val) {
    setState(() {
      counter = val.toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
        Widget>[
      Padding(
        padding: EdgeInsets.only(top: 15),
        child: DropdownButtonFormField<String>(
          value: dropdownValue,
          style: TextStyle(
            color: Theme.of(context).textTheme.headline1!.color,
            fontSize: 16.0,
          ),
          decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(
                    color: Theme.of(context).textTheme.headline1!.color!,
                    width: 1.0),
              ),
              contentPadding: EdgeInsets.all(5.0),
              filled: true,
              fillColor: Colors.grey[200],
              border: InputBorder.none,
              labelStyle: TextStyle(
                  color: Theme.of(context).textTheme.headline1!.color)),
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 24,
          elevation: 16,
          onChanged: (String? newValue) {
            setState(() {
              dropdownValue = newValue!;
            });
            hideMultipleSelection();
          },
          items: <String>[
            'Simple item',
            'Multiple instance item',
            'Multiple people item'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
      Visibility(
          visible: visibleItem,
          child: Padding(
            padding: EdgeInsets.only(top: 15),
            child: ListTile(
              contentPadding: EdgeInsets.all(5.0),
              title: Text(
                "Number of item: ",
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.headline1!.color),
              ),
              tileColor: Colors.grey[200],
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
                      onPressed: decrementCounter,
                    ),
                    Text("$counter",
                        style: TextStyle(
                            color: Theme.of(context).textTheme.headline1!.color,
                            fontSize: 20.0)),
                    TextButton(
                      child: Icon(Icons.add,
                          color: Theme.of(context).textTheme.headline1!.color),
                      onPressed: incrementCounter,
                    )
                  ]),
            ),
          )),
      Visibility(
          visible: visiblePeople,
          child: Padding(
            padding: EdgeInsets.only(top: 15),
            child: ListTile(
              contentPadding: EdgeInsets.all(5.0),
              title: Text(
                "Number of item: ",
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.headline1!.color),
              ),
              tileColor: Colors.grey[200],
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
                      onPressed: decrementCounter,
                    ),
                    Text("$counter",
                        style: TextStyle(
                            color: Theme.of(context).textTheme.headline1!.color,
                            fontSize: 20.0)),
                    TextButton(
                      child: Icon(Icons.add,
                          color: Theme.of(context).textTheme.headline1!.color),
                      onPressed: incrementCounter,
                    )
                  ]),
            ),
          ))
    ]);
  }
}

/* class _CounterState extends State<Counter> {
  int counter = 0;

  void decrementCounter() {
    setState(() {
      if (counter > 0) counter--;
    });
  }

  void incrementCounter() {
    setState(() {
      counter++;
    });
  }

  void setCounter(double val) {
    setState(() {
      counter = val.toInt();
    });
  }

  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
            child: Text('Number of item/people: ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ))),
        FlatButton(
          child: Icon(
            Icons.remove,
            color: Colors.black,
          ),
          minWidth: 5.0,
          onPressed: decrementCounter,
        ),
        Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text("$counter",
                style: TextStyle(color: Colors.black, fontSize: 20.0))),
        FlatButton(
          child: Icon(Icons.add, color: Colors.black),
          minWidth: 5.0,
          onPressed: incrementCounter,
        )
      ],
    );
  }
}
 */
