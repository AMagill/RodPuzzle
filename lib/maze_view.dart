import 'dart:html';
import 'package:polymer/polymer.dart';
import 'rods.dart';
import 'grid.dart';

@CustomTag('maze-view')
class MazeView extends PolymerElement {
  @observable Map<String, Cell> cells = new Map<String, Cell>();
  @observable String code = "";
  
  Rods rods = new RodsThreeSided();
  Grid grid = new Grid(RodsThreeSided.staticDims);
  
  MazeView.created() : super.created() {
  }
  
  void select(Event e, var detail, Element target) {
    var constraints = rods.GetConstraints();
    grid.Reset(constraints);
    code = rods.GetCode();
  }
  
  void setCode(Event e, var detail, Element target) {
    rods.SetCode(code);
  }
  
  Cell getCell(String x, String y, String z) {
    var foo = grid.cells['$x-$y-$z'];
    return foo;
  }

}
