import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TabScreen extends StatefulWidget {
  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  // Map<int, Widget> _tabs = {
  //   0: Text('Tab 1'),
  //   1: Text('Tab 2'),
  //   2: Text('Tab 3'),
  // };

  Map<int, Widget> _tabs = {
    0: Tab(child: Icon(Icons.bike_scooter)),
    1: Tab(child: Icon(Icons.car_rental)),
    2: Tab(child: Icon(Icons.airline_seat_flat)),
  };

  var _selectedIndex = 0;

  void _tabChanged(int index) {
    setState(() {
      _selectedIndex = index;
      print("Selected Index: $index");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CupertinoSegmentedControl(
        padding: EdgeInsets.all(15),
        children: _tabs,
        onValueChanged: _tabChanged,
        borderColor: Colors.teal,
        selectedColor: Colors.teal,
        unselectedColor: Colors.white,
        groupValue: _selectedIndex,
      ),
      Expanded(child: _showSelectedView()),
    ]);
  }

  Widget _showSelectedView() {
    var _selectedView;
    switch (_selectedIndex) {
      case 0:
        _selectedView = Bike();
        break;
      case 1:
        _selectedView = Car();
        break;
      default:
        _selectedView = Plane();
        break;
    }
    return _selectedView;
  }
}

class Bike extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Bike'));
  }
}

class Car extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Car'));
  }
}

class Plane extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Plane'));
  }
}
