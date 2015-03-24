import 'dart:html';
import 'package:polymer/polymer.dart';
import 'rods.dart';
import 'grid.dart';

@CustomTag('maze-view')
class MazeView extends PolymerElement {
  @observable Map<String, Cell> cells = new Map<String, Cell>();
  
  Rods rods = new RodsThreeSided();
  Grid grid = new Grid(RodsThreeSided.dimensions);
  
  MazeView.created() : super.created();
  
  void select(Event e, var detail, Element target) {
    var constraints = rods.GetConstraints();
    grid.Reset(constraints);
  }
  
  Cell getCell(String x, String y, String z) {
    var foo = grid.cells['$x-$y-$z'];
    return foo;
  }

}
