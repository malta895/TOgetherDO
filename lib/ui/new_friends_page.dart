import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_applications/models/user.dart';
import 'package:mobile_applications/services/authentication.dart';
import 'package:mobile_applications/services/friendship_manager.dart';
import 'package:provider/provider.dart';

class NewFriendPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a friend'),
      ),
      body: MyCustomForm(),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds data related to the form.
class _MyCustomFormState extends State<MyCustomForm> {
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();

  String dropdownValue = 'Add a friend by email';

  String parameter = "email";

  late ListAppUser _loggedInListAppUser;

  @override
  void initState() {
    super.initState();
    _loggedInListAppUser =
        context.read<ListAppAuthProvider>().loggedInListAppUser!;
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: DropdownButtonFormField<String>(
                value: dropdownValue,
                style: TextStyle(
                  color: Theme.of(context).textTheme.headline1!.color,
                  fontSize: 16.0,
                ),
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(
                          color: Theme.of(context).textTheme.headline1!.color!,
                          width: 1.0),
                    ),
                    contentPadding: const EdgeInsets.all(5.0),
                    filled: true,
                    fillColor: Theme.of(context).splashColor,
                    border: InputBorder.none,
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.headline1!.color)),
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                onChanged: (String? newValue) {
                  setState(() {
                    parameter =
                        newValue!.substring(newValue.lastIndexOf(' ') + 1);
                  });
                },
                items: <String>[
                  'Add a friend by email',
                  'Add a friend by username'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: TextFormField(
                  controller: titleController,
                  cursorColor: Theme.of(context).textTheme.headline1!.color!,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(5.0),
                      filled: true,
                      fillColor: Theme.of(context).splashColor,
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12.0)),
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).textTheme.headline1!.color!,
                            width: 1.0),
                      ),
                      border: InputBorder.none,
                      labelText: "Enter the friend's " + parameter,
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
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.pinkAccent[700],
                ),
                onPressed: () async {
                  if (_formKey.currentState?.validate() == true) {
                    if (parameter == 'email') {
                      bool completed = await ListAppFriendshipManager.instance
                          .addFriendByEmail(titleController.text,
                              _loggedInListAppUser.databaseId);
                      if (completed == true) {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text(
                              'Success!',
                              style: TextStyle(color: Colors.green),
                            ),
                            content: const Text('Friend successfully added!'),
                            actions: [
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          ),
                        );
                      } else {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text(
                              'Error',
                              style: TextStyle(color: Colors.red),
                            ),
                            content: Text('The ' +
                                parameter +
                                ' you inserted is invalid, please retry'),
                            actions: [
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          ),
                        );
                      }
                    } else if (parameter == 'username') {
                      bool completed = await ListAppFriendshipManager.instance
                          .addFriendByUsername(titleController.text,
                              _loggedInListAppUser.username!);
                      if (completed == true) {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text(
                              'Success!',
                              style: TextStyle(color: Colors.green),
                            ),
                            content: const Text('Friend successfully added!'),
                            actions: [
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          ),
                        );
                      } else {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text(
                              'Error',
                              style: TextStyle(color: Colors.red),
                            ),
                            content: Text('The ' +
                                parameter +
                                ' you inserted is invalid, please retry'),
                            actions: [
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
