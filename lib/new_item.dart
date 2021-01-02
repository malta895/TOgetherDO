import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
  DropdownMenu({Key key}) : super(key: key);

  @override
  _DropdownMenuState createState() => _DropdownMenuState();
}

/* class Counter extends StatefulWidget {
  _CounterState createState() => _CounterState();
} */

class AddMember extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Text(
              "Add participant",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
              ),
            )
          ],
        ),
        Column(
          children: <Widget>[
            IconButton(
                // TODO: IconButton actually adds a member
                icon: Icon(Icons.person_add),
                tooltip: 'Add a participant',
                onPressed: () => {print("Member added")})
          ],
        ),
      ],
    );
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class _MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

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
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(5.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 1.0),
                      ),
                      labelText: 'Enter the item title',
                      labelStyle: TextStyle(color: Colors.black)),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                )),
            DropdownMenu(),
            // Counter(),
            AddMember(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: change this to add the item to the list

                  // Validate returns true if the form is valid, or false
                  // otherwise.
                  if (_formKey.currentState.validate()) {
                    // If the form is valid, display a Snackbar.
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')));
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
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DropdownButton<String>(
            value: dropdownValue,
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),
            underline: Container(
              height: 2,
              color: Colors.black,
            ),
            onChanged: (String newValue) {
              setState(() {
                dropdownValue = newValue;
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
          Visibility(
              visible: visibleItem,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      child: Text('Number of item: ',
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
                          style:
                              TextStyle(color: Colors.black, fontSize: 20.0))),
                  FlatButton(
                    child: Icon(Icons.add, color: Colors.black),
                    minWidth: 5.0,
                    onPressed: incrementCounter,
                  )
                ],
              )),
          Visibility(
              visible: visiblePeople,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      child: Text('Number of people: ',
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
                          style:
                              TextStyle(color: Colors.black, fontSize: 20.0))),
                  FlatButton(
                    child: Icon(Icons.add, color: Colors.black),
                    minWidth: 5.0,
                    onPressed: incrementCounter,
                  )
                ],
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
