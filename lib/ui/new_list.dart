import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NewList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New list'),
      ),
      body: MyCustomForm(),
    );
  }
}

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
                color: Theme.of(context).textTheme.headline1!.color,
                fontSize: 16.0,
              ),
            )
          ],
        ),
        Column(
          children: <Widget>[
            IconButton(
                // TODO: IconButton actually adds a member
                icon: Icon(Icons.person_add,
                    color: Theme.of(context).accentColor),
                tooltip: 'Add a participant',
                onPressed: () => {print("Member added")})
          ],
        ),
      ],
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
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).textTheme.headline1!.color!,
                            width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).textTheme.headline1!.color!,
                            width: 1.0),
                      ),
                      labelText: 'Enter the list title',
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
            AddMember(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).accentColor,
                ),
                onPressed: () {
                  // TODO: change this to add the item to the list

                  // Validate returns true if the form is valid, or false
                  // otherwise.
                  if (_formKey.currentState?.validate() == true) {
                    // If the form is valid, display a Snackbar.
                    ScaffoldMessenger.of(context).showSnackBar(
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
  String? dropdownValue = 'Public list';
  bool? checkBoxValue = false;

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
              color: Theme.of(context).textTheme.headline1!.color,
              fontSize: 16.0,
            ),
            underline: Container(
              height: 2,
              color: Theme.of(context).textTheme.headline1!.color,
            ),
            onChanged: (newValue) {
              setState(() {
                dropdownValue = newValue;
              });
            },
            items: <String>['Public list', 'Private list']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Row(
            children: [
              Text("I am the only one who can add participants",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headline1!.color,
                    fontSize: 16.0,
                  )),
              Checkbox(
                  value: checkBoxValue,
                  activeColor: Theme.of(context).accentColor,
                  onChanged: (newValue) {
                    setState(() {
                      checkBoxValue = newValue;
                    });
                  })
            ],
          )
        ]);
  }
}
