import 'package:flutter/material.dart';

getColor(int index, int rowCount, bool solved) {
  if (solved) {
    return Colors.green;
  }

  if (rowCount * rowCount * 3 <= Colors.primaries.length) {
    return Colors.primaries[index * 3];
  } else if (rowCount * rowCount * 2 <= Colors.primaries.length) {
    return Colors.primaries[index * 2];
  } else if (rowCount * rowCount <= Colors.primaries.length) {
    return Colors.primaries[index];
  } else if (index < Colors.primaries.length) {
    return Colors.primaries[index];
  } else {
    return Colors.primaries[index % Colors.primaries.length];
  }
}
