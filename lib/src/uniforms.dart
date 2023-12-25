// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// The uniform class
class Uniform {
  Uniform({
    required this.value,
    this.name,
    this.range,
    this.defaultValue,
  });
  RangeValues? range;
  double? defaultValue;
  String? name;
  double value;
}

/// The uniforms list with method helpers
class Uniforms {
  Uniforms(this.uniforms);

  final List<Uniform> uniforms;

  void setValue(String name, double value) {
    uniforms.firstWhere((element) => element.name == name).value = value;
  }

  double getValue(String name) {
    return uniforms.firstWhere((element) => element.name == name).value;
  }

  void setValueByIndex(int index, double value) {
    assert(
        index >= 0 && index < uniforms.length, 'Uniform index out of range!');
    uniforms[index].value = value;
  }

  double getValueByIndex(int index) {
    assert(
        index >= 0 && index < uniforms.length, 'Uniform index out of range!');
    return uniforms[index].value;
  }

  List<double> getDoubleList() {
    return List.generate(uniforms.length, (index) => uniforms[index].value);
  }
}
