import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import './city_painter.dart';
import '../models/city.dart';
import '../parser.dart';
import '../size_controller.dart';

// ignore: must_be_immutable
class CityPickerMap extends StatefulWidget {
  final double? width;
  final double? height;
  final String map;
  final Function(City? city) onChanged;
  final Widget? markerWidget;
  final Widget? selectedMarkerWidget;
  final List<String>? comingSoonStates;
  final List<String>? alreadyHaveStates;
  final Color? strokeColor;
  final Color? selectedColor;
  final Color? comingSoonColor;
  final Color? defaultColor;
  final double? dx;
  final double? dy;
  final Color? dotColor;
  final bool? actAsToggle;

  CityPickerMap(
      {Key? key,
      required this.map,
      required this.onChanged,
      this.comingSoonStates,
      this.alreadyHaveStates,
      this.markerWidget,
      this.selectedMarkerWidget,
      this.width,
      this.height,
      this.dx,
      this.dy,
      this.strokeColor,
      this.selectedColor,
      this.comingSoonColor,
      this.defaultColor,
      this.dotColor,
      this.actAsToggle})
      : super(key: key);

  @override
  CityPickerMapState createState() => CityPickerMapState();
}

class CityPickerMapState extends State<CityPickerMap> {
  final List<City> _cityList = [];
  City? selectedCity;
  Offset? localPosition;
  final _sizeController = SizeController.instance;
  Size? mapSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCityList();
    });
  }

  _loadCityList() async {
    final list = await Parser.instance.svgToCityList(widget.map);
    _cityList.clear();
    setState(() {
      _cityList.addAll(list);
      mapSize = _sizeController.mapSize;
    });
  }

  void clearSelect() {
    setState(() {
      selectedCity = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (var city in _cityList) _buildStackItem(city),
        for (int i = 0; i < _cityList.length; i++) _buildStackMarkers(_cityList[i], i),
      ],
    );
  }

  Widget _buildStackItem(City city) {
    return Stack(
      children: [
        GestureDetector(
          onTapDown: (details) {
            selectedCity = null;
            localPosition = details.localPosition;
            setState(() {});
          },
          behavior: HitTestBehavior.deferToChild,
          onTap: () => (widget.actAsToggle ?? false) ? _toggleButton(city) : _useButton(city),
          child: CustomPaint(
            child: Container(
              width: widget.width ?? double.infinity,
              height: widget.height ?? double.infinity,
              constraints: BoxConstraints(maxWidth: mapSize?.width ?? 0, maxHeight: mapSize?.height ?? 0),
              alignment: Alignment.center,
            ),
            isComplex: true,
            foregroundPainter: CityPainter(
                city: city,
                alreadyHaveStates: widget.alreadyHaveStates,
                comingSoonStates: widget.comingSoonStates,
                selectedCity: selectedCity,
                comingSoonColor: widget.comingSoonColor,
                defaultColor: widget.defaultColor,
                dotColor: widget.dotColor,
                selectedColor: widget.selectedColor,
                strokeColor: widget.strokeColor),
          ),
        ),
        //widget.markerWidget != null ? Positioned(top: ortaOffset.dy - 5, left: ortaOffset.dx - 5, child: widget.markerWidget!) : SizedBox()
      ],
    );
  }

  Widget _buildStackMarkers(City city, int _gelenIndex) {
    final bounds = city.path.getBounds();
    Offset ortaOffset = bounds.center;
    int index = -1;
    if (widget.alreadyHaveStates != null && selectedCity != null) {
      for (int i = 0; i < widget.alreadyHaveStates!.length; i++) {
        if (widget.alreadyHaveStates!.contains(selectedCity!.title)) {
          index = _cityList.indexOf(selectedCity!);
          if (_gelenIndex != index) {
            index = -1;
          }
        }
      }
    }
    return (widget.markerWidget != null && widget.alreadyHaveStates!.contains(city.title))
        ? (selectedCity != null && index != -1 && widget.selectedMarkerWidget != null)
            ? Positioned(top: ortaOffset.dy - 45, left: ortaOffset.dx - 25, child: InkWell(
              onTap: (() {
                  setState(() {
                    selectedCity = null;
                  });
                }),
              child: widget.selectedMarkerWidget!))
            : Positioned(top: ortaOffset.dy - 45, left: ortaOffset.dx - 25, child: InkWell(
              onTap: () {
                  _useButton(city);
                },
              child: widget.markerWidget!))
        : SizedBox();
  }

  void _toggleButton(City city) {
    setState(() {
      if (selectedCity == city)
        selectedCity = null;
      else {
        selectedCity = city;
      }
      widget.onChanged.call(selectedCity);
    });
  }

  void _useButton(City city) {
    setState(() {
      selectedCity = city;
      widget.onChanged.call(selectedCity);
    });
  }
}
