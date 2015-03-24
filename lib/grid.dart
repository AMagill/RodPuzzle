library grid;
import 'package:polymer/polymer.dart';

class Grid extends Observable {
  final List<int> dims;
  
  @observable List<List<String>> axisLabels;
  
  @observable Map<String, Cell> cells;
  @observable List<List<Set<Cell>>> slices;
  
  Grid(this.dims) {
    slices = new List<List<Set<Cell>>>(dims.length);
    axisLabels = new List<List<String>>(dims.length);
    for (int i = 0; i < dims.length; i++) {
      slices[i] = new List<Set<Cell>>(dims[i]);
      axisLabels[i] = new List<String>(dims[i]);
      for (int j = 0; j < dims[i]; j++) {
        slices[i][j] = new Set<Cell>();
        axisLabels[i][j] = j.toString();
      }
    }
    
    cells = {};
    for (int z = 0; z < dims[2]; z++) {
      for (int y = 0; y < dims[1]; y++) {
        for (int x = 0; x < dims[0]; x++) {
          var newCell = new Cell();
          cells['$x-$y-$z'] = newCell;
          slices[0][x].add(newCell);
          slices[1][y].add(newCell);
          slices[2][z].add(newCell);
        }
      }
    }
  }
  
  void Reset(List<List<int>> constraints) {
    // Clear values
    for (var cell in cells.values) {
      cell.cssClass = "";
      cell.text = "!";
    }
    
    // Apply constraints
    for (var con in constraints) {
      var axis1  = con[0];
      var index1 = con[1];
      var axis2  = con[2];
      var index2 = con[3];
      
      var set = slices[axis1][index1].intersection(slices[axis2][index2]);
      for (var item in set) {
        item.cssClass = "nf";
        item.text = "Q";
      }      
    }
    
    // Find path lengths
    
  }
}

class Cell extends Observable {
  @observable String cssClass = "";
  @observable var text = "!";
}