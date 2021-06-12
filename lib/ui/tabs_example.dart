import 'package:flutter/material.dart';

class tabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Fixed Tabs'),
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xff5808e5),
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
            Center(child: Text('DOGS')),
            Center(child: Text('CATS')),
          ],
        ),
      ),
    );
  }
}
