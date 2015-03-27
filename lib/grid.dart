library grid;
import 'package:polymer/polymer.dart';
import 'dart:collection';

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
          
          if (x > 0) {
            var other = cells['${x-1}-$y-$z'];
            newCell.neighbors.add(other);
            other.neighbors.add(newCell);
          }
          if (y > 0) {
            var other = cells['$x-${y-1}-$z'];
            newCell.neighbors.add(other);
            other.neighbors.add(newCell);
          }
          if (z > 0) {
            var other = cells['$x-$y-${z-1}'];
            newCell.neighbors.add(other);
            other.neighbors.add(newCell);
          }
        }
      }
    }
    
    Reset([]);
  }
  
  void Reset(List<List<int>> constraints) {
    // Clear values
    for (var cell in cells.values) {
      cell.cssClass = "unreachable";
      cell.text     = "∞";
      cell.distance = 999999999;
      cell.shortestPath = false;
      cell.blocked  = false;
      cell.deadEnd  = false;
    }

    var start  = cells['0-0-0'];
    var finish = cells['${dims[0]-1}-${dims[1]-1}-${dims[2]-1}'];
    
    start.text     = 'S';
    start.distance = 0;
    start.cssClass = "path";

    // Apply constraints
    for (var con in constraints) {
      var axis1  = con[0];
      var index1 = con[1];
      var axis2  = con[2];
      var index2 = con[3];
      
      var set = slices[axis1][index1].intersection(slices[axis2][index2]);
      for (var item in set) {
        item.blocked = true;
        item.cssClass = "block";
        item.text = "";
      }      
    }
    
    // Find path lengths.  Dijkstra’s algorithm, more or less.
    Queue<Cell> todo = new Queue<Cell>();
    Queue<Cell> deadTodo = new Queue<Cell>();
    todo.add(start);
    while (todo.isNotEmpty) {
      var cell = todo.removeFirst();
      var dist  = cell.distance + 1; 

      int reachable = 0;
      for (var neighbor in cell.neighbors) {
        if (neighbor.blocked) continue;
        reachable++;
        if (neighbor.distance > dist) {
          neighbor.text     = dist.toString();
          neighbor.distance = dist;
          neighbor.cssClass = "";
          todo.add(neighbor);
        }
      }
      if (reachable == 1 && cell != start)
        deadTodo.add(cell);
    }
    
    // Grow dead ends into dead paths
    while (deadTodo.isNotEmpty) {
      var cell = deadTodo.removeFirst();
      Cell other = null;

      for (var neighbor in cell.neighbors) {
        if (neighbor.blocked) continue;
        if (neighbor.deadEnd) continue;
        if (other != null) {
          other = null;
          break;
        }
        other = neighbor;
      }
      if (other != null) {
        cell.cssClass = "deadend";
        cell.deadEnd = true;
        deadTodo.add(other);
      }
    }
    
    // Highlight the shortest paths
    if (finish.distance < 999999) {
      Queue<Cell> todo = new Queue<Cell>();
      todo.add(finish);
      
      while (todo.isNotEmpty) {
        var cell = todo.removeFirst();
        List<Cell> minNeighbors = new List<Cell>();
        int min = cell.distance;
        for (var neighbor in cell.neighbors) {
          if (neighbor.blocked) continue;
          if (neighbor.shortestPath) continue;
          if (neighbor.distance > min) continue;
          if (neighbor.distance < min) {
            minNeighbors.clear();
            min = neighbor.distance;
          }
          minNeighbors.add(neighbor);
        }
        
        cell.cssClass = "path";
        cell.shortestPath = true;
        todo.addAll(minNeighbors);
      }
    }

  }
  
  void RotateR() {
  }

  void RotateL() {    
  }
}

class Cell extends Observable {
  @observable String cssClass;
  @observable var text;
  int distance;
  bool shortestPath, blocked, deadEnd;
  List<Cell> neighbors = new List<Cell>();
}
