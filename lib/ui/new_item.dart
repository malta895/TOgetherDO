import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/models/list_item.dart';

class NewItemPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New item'),
      ),
      body: _NewItemForm(),
    );
  }
}

class _NewItemForm extends StatefulWidget {
  @override
  _NewItemFormState createState() => _NewItemFormState();
}

/* class Counter extends StatefulWidget {
  _CounterState createState() => _CounterState();
} */

// Define a corresponding State class.
// This class holds data related to the form.
class _NewItemFormState extends State<_NewItemForm> {
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
                      fillColor: Theme.of(context).splashColor,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
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
            _ItemTypeDropdownMenu(),
            // Counter(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.pinkAccent[700],
                ),
                onPressed: () async {
                  // Validate returns true if the form is valid, or false
                  // otherwise.
                  if (_formKey.currentState?.validate() == true) {
                    final BaseItem newItem =
                        SimpleItem(name: titleController.text);

                    // TODO: add the item to the list on the backend

                    Navigator.pop<BaseItem>(
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

class _ItemTypeDropdownMenu extends StatefulWidget {
  _ItemTypeDropdownMenu({Key? key}) : super(key: key);

  @override
  _ItemTypeDropdownMenuState createState() => _ItemTypeDropdownMenuState();
}

class _ItemTypeDropdownMenuState extends State<_ItemTypeDropdownMenu> {
  String dropdownValue = 'Simple item';

  void _hideMultipleSelection() {
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

  void _decrementCounter() {
    setState(() {
      if (counter > 0) counter--;
    });
  }

  void _incrementCounter() {
    setState(() {
      counter++;
    });
  }

  void _setCounter(double val) {
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
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                borderSide: BorderSide(
                    color: Theme.of(context).textTheme.headline1!.color!,
                    width: 1.0),
              ),
              contentPadding: EdgeInsets.all(5.0),
              filled: true,
              fillColor: Theme.of(context).splashColor,
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
            _hideMultipleSelection();
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
                "Number of items: ",
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.headline1!.color),
              ),
              tileColor: Theme.of(context).splashColor,
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
                      onPressed: _decrementCounter,
                    ),
                    Text("$counter",
                        style: TextStyle(
                            color: Theme.of(context).textTheme.headline1!.color,
                            fontSize: 20.0)),
                    TextButton(
                      child: Icon(Icons.add,
                          color: Theme.of(context).textTheme.headline1!.color),
                      onPressed: _incrementCounter,
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
                "Number of items: ",
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.headline1!.color),
              ),
              tileColor: Theme.of(context).splashColor,
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
                      onPressed: _decrementCounter,
                    ),
                    Text("$counter",
                        style: TextStyle(
                            color: Theme.of(context).textTheme.headline1!.color,
                            fontSize: 20.0)),
                    TextButton(
                      child: Icon(Icons.add,
                          color: Theme.of(context).textTheme.headline1!.color),
                      onPressed: _incrementCounter,
                    )
                  ]),
            ),
          ))
    ]);
  }
}
