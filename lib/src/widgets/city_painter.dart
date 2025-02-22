import 'package:city_picker_from_map/city_picker_from_map.dart';
import 'package:city_picker_from_map/src/size_controller.dart';
import 'package:flutter/material.dart';

class CityPainter extends CustomPainter {
  final City city;
  final City? selectedCity;
  final List<String>? comingSoonStates;
  final List<String>? alreadyHaveStates;
  final Color? strokeColor;
  final Color? selectedColor;
  final Color? comingSoonColor;
  final Color? defaultColor;
  final Color? dotColor;

  final sizeController = SizeController.instance;

  double _scale = 1.0;

  CityPainter(
      {this.comingSoonStates,
      this.alreadyHaveStates,
      required this.city,
      required this.selectedCity,
      this.defaultColor,
      this.selectedColor,
      this.comingSoonColor,
      this.strokeColor,
      this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()
      ..color = strokeColor ?? Colors.white60
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final selectedPen = Paint()
      ..color = selectedColor ?? Colors.blue
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    final defaultPen = Paint()
      ..color = defaultColor ?? Colors.red
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    final comingSoonPen = Paint()
      ..color = comingSoonColor ?? Colors.purple
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    final redDot = Paint()
      ..color = dotColor ?? Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.fill;

    final bounds = city.path.getBounds();

    _scale = sizeController.calculateScale(size);
    canvas.scale(_scale);

    if (comingSoonStates != null && comingSoonStates!.isNotEmpty) {
      for (var element in comingSoonStates!) {
        if (element == city.id) {
          if (selectedCity != null && city.id == selectedCity!.id) {
            return canvas.drawPath(city.path, selectedPen);
          } else {
            if (alreadyHaveStates != null) {
              for (var element2 in alreadyHaveStates!) {
                if(element2 == element){
                  return canvas.drawPath(city.path, defaultPen);
                }
              }
              return canvas.drawPath(city.path, comingSoonPen);
            
            } else {
              return canvas.drawPath(city.path, comingSoonPen);
            }
          }
        } else {
          canvas.drawPath(city.path, defaultPen);
        }
      }
    } else {
      canvas.drawPath(city.path, defaultPen);
    }

    if (selectedCity != null &&
        city.id == selectedCity!.id &&
        alreadyHaveStates != null &&
        (alreadyHaveStates!.where((element) => element == selectedCity!.id).length > 0)) {
      canvas.drawPath(city.path, selectedPen);
    } else {
      canvas.drawPath(city.path, defaultPen);
    }

    canvas.drawCircle(bounds.center, 3.0, redDot);
    canvas.drawPath(city.path, pen);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  bool hitTest(Offset position) {
    double inverseScale = sizeController.inverseOfScale(_scale);
    return city.path.contains(position.scale(inverseScale, inverseScale));
  }
}
