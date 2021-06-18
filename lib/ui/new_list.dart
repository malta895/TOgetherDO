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
    String? dropdownValue = 'Public list';
    bool? checkBoxValue = false;
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
                },
                items: <String>['Public list', 'Private list']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            DropdownMenu(),
            AddMember(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 0),
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

class AddMember extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 15),
      child: ListTile(
          contentPadding: EdgeInsets.all(5.0),
          title: Text(
            "Add a participant",
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.headline1!.color),
          ),
          tileColor: Colors.grey[200],
          trailing: IconButton(
              icon:
                  Icon(Icons.person_add, color: Theme.of(context).accentColor),
              onPressed: () {
                print("Member added");
              })),
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
          Padding(
            padding: EdgeInsets.only(top: 15),
            child: CheckboxListTile(
                contentPadding: EdgeInsets.all(5.0),
                title: Text(
                  'I am the only one who can add participants',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headline1!.color,
                    fontSize: 16.0,
                  ),
                ),
                value: checkBoxValue,
                tileColor: Colors.grey[200],
                activeColor: Theme.of(context).accentColor,
                onChanged: (newValue) {
                  setState(() {
                    checkBoxValue = newValue;
                  });
                }),
          ),
        ]);
  }
}
