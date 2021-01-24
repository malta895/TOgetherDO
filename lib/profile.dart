import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Your profile'),
        ),
        body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          'http://www.bbk.ac.uk/mce/wp-content/uploads/2015/03/8327142885_9b447935ff.jpg'),
                      radius: 40.0,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('John Reed',
                          style: Theme.of(context).textTheme.headline5),
                      Text('john.reed@mail.com'),
                    ],
                  ),
                ],
              )
            ]));
  }
}
