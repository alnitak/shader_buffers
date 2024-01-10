// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// The uniform class
class Uniform {
  Uniform({
    required this.value,
    required this.name,
    required this.range,
    required this.defaultValue,
  });
  final RangeValues range;
  final double defaultValue;
  final String name;
  double value;

  @override
  String toString() => 'Uniform [$name]: $value';
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
      index >= 0 && index < uniforms.length,
      'Uniform index out of range!',
    );
    uniforms[index].value = value;
  }

  double getValueByIndex(int index) {
    assert(
      index >= 0 && index < uniforms.length,
      'Uniform index out of range!',
    );
    return uniforms[index].value;
  }

  List<double> getDoubleList() {
    return List.generate(uniforms.length, (index) => uniforms[index].value);
  }

  void setDoubleList(List<double> values) {
    assert(values.length == uniforms.length, "Uniform length doesn't match!");
    for (var i = 0; i < values.length; i++) {
      uniforms[i].value = values[i];
    }
  }

  Uniform getUniformByName(String name) {
    return uniforms.firstWhere((element) => element.name == name);
  }
}
