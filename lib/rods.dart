library rods;
import 'package:polymer/polymer.dart';

abstract class Rods extends Observable {
  static final List<int> dimensions = [0];
  @observable List<String> rodLabels = [];
  @observable List<String> posLabels = [];
  @observable Map<String, List<int>> selected = new Map<String, List<int>>();
  List<List<int>> GetConstraints();  
  List<List<int>> GetPairConstraints(int iRod1, int iRod2) {
    var constraints = [];
    var rod1 = rodLabels[iRod1];
    var rod2 = rodLabels[iRod2];

    for (var item1 in selected[rod1]) {
      if (!(item1 is int)) continue;
      for (var item2 in selected[rod2]) {
        if (!(item2 is int)) continue;
        constraints.add([iRod1, item1, iRod2, item2]);
      }
    }

    return constraints;
  }
}

class RodsOneSided extends Rods {
  static final List<int> dimensions   = [5, 5, 5];
  
  RodsOneSided() {
    rodLabels = ['A', 'B', 'C'];
    posLabels = ['1', '2', '3', '4', '5'];
    for (var label in rodLabels) {
      selected[label] = new List<int>();
    }
  }
  
  List<List<int>> GetConstraints(){
    var constraints = [];
    
    constraints.addAll(GetPairConstraints(0, 1));
    constraints.addAll(GetPairConstraints(0, 2));
    constraints.addAll(GetPairConstraints(1, 2));
    
    return constraints;
  }
}

class RodsThreeSided extends Rods {
  static final List<int> dimensions = [5, 5, 5];
  final List<int> dimensionMap = [0, 0, 0, 1, 1, 1, 2, 2, 2];
  
  RodsThreeSided() {
    rodLabels = ['-A', 'A', 'A-', '-B', 'B', 'B-', '-C', 'C', 'C-'];
    posLabels = ['1', '2', '3', '4', '5'];
    for (var label in rodLabels) {
      selected[label] = new List<int>();
    }
  }
  
  List<List<int>> GetConstraints(){
    var constraints = [];
    
    constraints.addAll(GetPairConstraints(1, 4)); // AB
    constraints.addAll(GetPairConstraints(1, 7)); // AC
    constraints.addAll(GetPairConstraints(4, 7)); // BC

    constraints.addAll(GetPairConstraints(8, 0)); // C-A
    constraints.addAll(GetPairConstraints(2, 3)); // A-B
    constraints.addAll(GetPairConstraints(5, 6)); // B-C
    
    for (var con in constraints) {
      con[0] = dimensionMap[con[0]];
      con[2] = dimensionMap[con[2]];
    }
    
    return constraints;
  }
}