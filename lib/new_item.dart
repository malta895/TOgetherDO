import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class new_item extends StatelessWidget {
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
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class DropdownMenu extends StatefulWidget {
  DropdownMenu({Key key}) : super(key: key);

  @override
  _DropdownMenuState createState() => _DropdownMenuState();
}

class Counter extends StatefulWidget {
  _CounterState createState() => _CounterState();
}

// Define a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
                border: InputBorder.none, labelText: 'Enter the item title'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          DropdownMenu(),
          Counter(),
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
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Processing Data')));
                }
              },
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownMenuState extends State<DropdownMenu> {
  String dropdownValue = 'Simple item';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.black),
      underline: Container(
        height: 2,
        color: Colors.black,
      ),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
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
    );
  }
}

class _CounterState extends State<Counter> {
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            child: Text('Number of item/people: ',
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.black))),
        FlatButton(
          child: Icon(Icons.remove),
          onPressed: decrementCounter,
        ),
        Text("$counter"),
        FlatButton(
          child: Icon(Icons.add),
          onPressed: incrementCounter,
        )
      ],
    );
  }
}
