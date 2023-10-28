import 'package:flutter/material.dart';



class AnimatedSid extends StatefulWidget {
  const AnimatedSid({Key? key}) : super(key: key);

  @override
  State<AnimatedSid> createState() => _AnimatedSidState();
}

class _AnimatedSidState extends State<AnimatedSid> {

  bool _isSidebarOpened = false;
  double _sidebarWidth = 200.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Center(
            child: Text('Hello, world!'),
          ),

          // Sidebar
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: _sidebarWidth,
            child: Material(
              elevation: 4.0,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: Text('Header'),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                  ),
                  ListTile(
                    title: Text('Item 1'),
                    onTap: () {
                      // Do something
                    },
                  ),
                  ListTile(
                    title: Text('Item 2'),
                    onTap: () {
                      // Do something
                    },
                  ),
                  ListTile(
                    title: Text('Item 3'),
                    onTap: () {
                      // Do something
                    },
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Close'),
                    onTap: () {
                      setState(() {
                        _isSidebarOpened = false;
                        _sidebarWidth = 0.0;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Sidebar toggle button
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                setState(() {
                  _isSidebarOpened = !_isSidebarOpened;
                  _sidebarWidth = _isSidebarOpened ? 200.0 : 0.0;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}