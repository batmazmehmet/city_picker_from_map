import 'package:flutter/material.dart';
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
  final Color? strokeColor;
  final Color? selectedColor;
  final Color? comingSoonColor;
  final Color? defaultColor;
  final double? dx;
  final double? dy;
  final Widget? selectedWindow;
  final Color? dotColor;
  final bool? actAsToggle;

  CityPickerMap(
      {Key? key,
      required this.map,
      required this.onChanged,
      this.width,
      this.height,
      this.dx,
      this.dy,
      this.strokeColor,
      this.selectedWindow,
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

/*  if (city.title == '49') {
      canvas.drawPath(city.path, selectedPen);
    } else if (city.title == '46' || city.title == '43' || city.title == '41')  */
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (var city in _cityList) _buildStackItem(city),
        if (selectedCity != null)
          Transform.translate(
              offset: Offset(localPosition!.dx - 100, localPosition!.dy - 125),
              child: selectedCity != null &&
                      (selectedCity!.title == '49' )//|| selectedCity!.title == '46' || selectedCity!.title == '43' || selectedCity!.title == '41'
                  ? widget.selectedWindow
                  : SizedBox())
      ],
    );
  }

  Widget _buildStackItem(City city) {
    return GestureDetector(
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
            selectedCity: selectedCity,
            comingSoonColor: widget.comingSoonColor,
            defaultColor: widget.defaultColor,
            dotColor: widget.dotColor,
            selectedColor: widget.selectedColor,
            strokeColor: widget.strokeColor),
      ),
    );
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
