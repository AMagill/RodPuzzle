library rods;
import 'dart:convert';

abstract class Rods {
  Map<String, List<int>> selected = new Map<String, List<int>>();
  
  static List<int> get staticDims => [];
  List<int>    get dimensions => [];
  List<String> get faceLabels => [];
  List<String> get posLabels  => [];
  List<int>    get faceMap    => [];
  
  Rods() {
    for (var label in faceLabels) {
      selected[label] = new List<int>();
    }
  }
  
  List<List<int>> GetConstraints();
  
  List<List<int>> GetPairConstraints(int iFace1, int iFace2) {
    var constraints = [];
    var face1 = faceLabels[iFace1];
    var face2 = faceLabels[iFace2];

    for (var item1 in selected[face1]) {
      if (!(item1 is int)) continue;
      for (var item2 in selected[face2]) {
        // A bug in polymer is adding empty sublists, so skip over them.
        if (!(item2 is int)) continue;
        
        var rod1 = faceMap[iFace1];
        var rod2 = faceMap[iFace2];

        // The two must be in the same group
        if (item1 ~/ dimensions[rod1] != 
            item2 ~/ dimensions[rod2])
          continue;
        
        constraints.add([faceMap[iFace1], item1 % dimensions[rod1], 
                         faceMap[iFace2], item2 % dimensions[rod2]]);
      }
    }

    return constraints;
  }
  
  void Clear() {
    for (var face in selected.values) {
      face.clear();
    }
  }
  
  String GetCode() {
    var pruned = {};
    for (var face in selected.keys) {
      if (selected[face].length > 0)
        pruned[face] = selected[face];
    }
    return JSON.encode(pruned);
  }
  
  void SetCode(String code) {
    var faces = JSON.decode(code);
    
    Clear();
    for (var face in faces.keys) {
      for (var item in faces[face]) {
        selected[face].add(faces[face]);
      }
    }
    
  }
}

class RodsOneSided extends Rods {
  static List<int> get staticDims => [5, 5, 5];
  List<int>    get dimensions => [5, 5, 5];
  List<String> get faceLabels => ['A', 'B', 'C'];
  List<String> get posLabels  => ['1', '2', '3', '4', '5'];
  List<int>    get faceMap    => [0, 1, 2];
  
  RodsOneSided() : super();
  
  List<List<int>> GetConstraints(){
    var constraints = [];
    
    constraints.addAll(GetPairConstraints(0, 1));
    constraints.addAll(GetPairConstraints(0, 2));
    constraints.addAll(GetPairConstraints(1, 2));
    
    return constraints;
  }
}

class RodsThreeSided extends Rods {
  static List<int> get staticDims => [5, 5, 5];
  List<int>    get dimensions => [5, 5, 5];
  List<String> get faceLabels => ['-A', 'A', 'A-', '-B', 'B', 'B-', '-C', 'C', 'C-'];
  List<String> get posLabels  => ['1', '2', '3', '4', '5', 
                                  '1', '2', '3', '4', '5',
                                  '1', '2', '3', '4', '5'];  
  List<int>    get faceMap    => [0, 0, 0, 1, 1, 1, 2, 2, 2];
  
  RodsThreeSided() : super();
  
  List<List<int>> GetConstraints(){
    var constraints = [];
    
    constraints.addAll(GetPairConstraints(1, 4)); // AB
    constraints.addAll(GetPairConstraints(1, 7)); // AC
    constraints.addAll(GetPairConstraints(4, 7)); // BC

    constraints.addAll(GetPairConstraints(8, 0)); // C-A
    constraints.addAll(GetPairConstraints(2, 3)); // A-B
    constraints.addAll(GetPairConstraints(5, 6)); // B-C
    
    return constraints;
  }
}