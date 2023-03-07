import 'package:flutter/material.dart';
import 'package:city_picker_from_map/city_picker_from_map.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: HomeView(),
      theme: ThemeData.dark(),
    );
  }
}

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  City? selectedCity;
  final GlobalKey<CityPickerMapState> _mapKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selected City: ${selectedCity?.title ?? '(?)'}'),
        actions: [
          IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _mapKey.currentState?.clearSelect();
                setState(() {
                  selectedCity = null;
                });
              })
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: InteractiveViewer(
            scaleEnabled: true,
            panEnabled: true,
            constrained: true,
            child: CityPickerMap(
              key: _mapKey,
              width: double.infinity,
              height: double.infinity,
              map: Maps.USA,
              onChanged: (city) {
                setState(() {
                  selectedCity = city;
                });
              },
              actAsToggle: true,
              defaultColor: Colors.red,
              dotColor: Colors.transparent,
              comingSoonColor: Colors.amber,
              selectedColor: Colors.green,
              strokeColor: Colors.white24,
            ),
          ),
        ),
      ),
    );
  }
}
