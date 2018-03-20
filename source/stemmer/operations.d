module valley.stemmer.operations;

import std.string;
import std.conv;
import std.algorithm;
import std.array;

immutable interface IStemOperation {
  string get(const string value) pure;
}

immutable class Invariant : IStemOperation {
  immutable(string[]) list;

  this(immutable(string[]) list) pure {
    this.list = list;
  }

  static immutable(IStemOperation) opCall(immutable(string[]) list) pure {
    return new immutable Invariant(list);
  }

  string get(const string value) pure {
    if(list.canFind(value)) {
      return value;
    }

    return "";
  }
}

immutable class ReplaceWord : IStemOperation {

  immutable(string[2][]) list;

  this(immutable(string[2][]) list) {
    this.list = list;
  }

  static immutable(IStemOperation) opCall(immutable(string[2][]) list) {
    return new immutable ReplaceWord(list);
  }

  string get(const string value) pure {

    foreach(pair; list) {
      if(pair[0] == value) {
        return pair[1];
      }
    }

    return "";
  }
}

immutable class ReplaceAfter : IStemOperation {
  immutable(string[2][]) list;

  this(immutable(string[2][]) list) pure {
    this.list = list;
  }

  static immutable(IStemOperation) opCall(immutable(string[2][]) list) pure {
    return new immutable ReplaceAfter(list);
  }

  string get(const string value) pure {
    foreach(pair; list) {
      auto pos = value.indexOf(pair[0]);

      if(pos != -1) {
        return value[0..pos] ~ pair[1];
      }
    }

    return "";
  }
}

immutable class ReplacePostfix : IStemOperation {
  immutable(string[2][]) list;
  immutable size_t minLength;


  this(immutable(string[2][]) list, size_t minLength = 0) pure {
    this.list = list;
    this.minLength = minLength;
  }

  static immutable(IStemOperation) opCall(immutable(string[2][]) list, size_t minLength = 0) pure {
    return new immutable ReplacePostfix(list, minLength);
  }

  string get(const string value) pure {
    if(value.length <= minLength) {
      return "";
    }

    foreach(pair; list) {
      if(value.endsWith(pair[0])) {
        return value[0..$-pair[0].length] ~ pair[1];
      }
    }

    return "";
  }
}

immutable class InlineReplace : IStemOperation {

  immutable(string[2][]) list;

  this(immutable(string[2][]) list) pure {
    this.list = list;
  }

  static immutable(IStemOperation) opCall(const(string[2][]) list) pure {
    return new immutable InlineReplace(list.idup);
  }

  static immutable(IStemOperation) opCall(immutable(string[2][]) list) pure {
    return new immutable InlineReplace(list);
  }

  static immutable(IStemOperation) opCall(immutable(string) from, immutable(string) to) pure {
    return new immutable InlineReplace([[from, to]]);
  }

  string get(const string value) pure {
    string result = value.dup;

    foreach(pair; list) {
      result = result.replace(pair[0], pair[1]);

      if(result != value) {
        return result;
      }
    }

    return "";
  }
}

immutable class RemovePostfix : IStemOperation {
  immutable(string[]) list;

  this(immutable(string[]) list) pure {
    this.list = list;
  }

  static immutable(IStemOperation) opCall(immutable(string[]) list) pure {
    return new immutable RemovePostfix(list);
  }

  string get(const string value) pure {
    foreach(element; list) {
      if(value.endsWith(element)) {
        return value[0 .. $ - element.length];
      }
    }

    return "";
  }
}

immutable class And : IStemOperation {
  immutable(IStemOperation[]) list;

  this(immutable(IStemOperation[]) list) pure {
    this.list = list;
  }

  static immutable(IStemOperation) opCall(immutable(IStemOperation[]) list) pure {
    return new immutable And(list);
  }

  string get(const string value) pure {
    auto result = value.dup.to!string;
    bool gotResult;

    foreach(operation; list) {
      auto tmp = operation.get(result);

      if(tmp != "") {
        gotResult = true;
        result = tmp;
      }
    }

    return gotResult ? result : "";
  }
}

immutable class Or : IStemOperation {
  immutable(IStemOperation[][]) list;

  this(immutable(IStemOperation[][]) list) pure {
    this.list = list;
  }

  static immutable(IStemOperation) opCall(immutable(IStemOperation[][]) list) pure {
    return new immutable Or(list);
  }

  static immutable(IStemOperation) opCall(immutable(IStemOperation[]) list) pure {
    return new immutable Or(list.map!(a => [a]).array.idup);
  }

  string get(const string value) pure {
    foreach(andList; list) {
      auto result = And(andList).get(value);

      if(result != "") {
        return result;
      }
    }

    return "";
  }
}

immutable abstract class StemOperationFromRegion(T) : IStemOperation {
  immutable {
    size_t region;
  }

  this(size_t region) pure {
    this.region = region;
  }

  string getRegion(const string value) pure {
    if(region == 0) {
      return value;
    }

    if(region == 1) {
      return T.region1(value);
    }

    if(region == 2) {
      return T.region2(value);
    }

    throw new Exception("Undefined region");
  }
}

immutable class RemovePostifixFromRegion(T) : StemOperationFromRegion!T {
  string[] list;

  this(size_t region, immutable string[] list) pure {
    super(region);

    this.list = list;
  }

  static immutable(IStemOperation) opCall(size_t region, immutable string postfix) pure {
    return new immutable RemovePostifixFromRegion!T(region, [ postfix ]);
  }

  static immutable(IStemOperation) opCall(size_t region, immutable string[] list) pure {
    return new immutable RemovePostifixFromRegion!T(region, list);
  }

  string get(const string value) pure {
    string strRegion = getRegion(value);

    foreach(postfix; list) {
      if(strRegion.endsWith(postfix)) {
        return value[0..$ - postfix.length];
      }

      if(value.endsWith(postfix)) {
        return "";
      }
    }

    return "";
  }
}

immutable class ReplacePostifixFromRegion(T) : StemOperationFromRegion!T {
  immutable {
    string[][] list;
  }

  this(size_t region, immutable(string[][]) list) pure {
    super(region);

    this.list = list;
  }

  static immutable(IStemOperation) opCall(size_t region, immutable string from, immutable string to) pure {
    return new immutable ReplacePostifixFromRegion!T(region, [[ from, to ]]);
  }

  static immutable(IStemOperation) opCall(size_t region, string[][] list) pure {
    return new immutable ReplacePostifixFromRegion!T(region, list.map!(a => a.idup).array.idup);
  }

  string get(const string value) pure {
    string strRegion = getRegion(value);

    foreach(item; list) {
      if(strRegion.endsWith(item[0])) {
        return value[0..$ - strRegion.length] ~ strRegion.replaceLast(item[0], item[1]);
      }

      if(value.endsWith(item[0])) {
        return "";
      }
    }

    return "";
  }
}

immutable class ReplaceFromRegion(T) : StemOperationFromRegion!T {
  immutable {
    string[][] list;
  }

  this(size_t region, immutable(string[][]) list) pure {
    super(region);

    this.list = list;
  }

  static immutable(IStemOperation) opCall(size_t region, immutable string from, immutable string to) pure {
    return new immutable ReplaceFromRegion!T(region, [[ from, to ]]);
  }

  static immutable(IStemOperation) opCall(size_t region, string[][] list) pure {
    return new immutable ReplaceFromRegion!T(region, list.map!(a => a.idup).array.idup);
  }

  string get(const string value) pure {
    string strRegion = getRegion(value);

    foreach(item; list) {
      if(strRegion.canFind(item[0])) {
        return value[0..$ - strRegion.length] ~ strRegion.replaceLast(item[0], item[1]);
      }
    }

    return "";
  }
}

immutable class ReplaceAfterFromRegion(T) : StemOperationFromRegion!T {
  immutable(string[2][]) list;

  this(size_t region, immutable(string[2][]) list) pure {
    super(region);

    this.list = list;
  }

  static immutable(IStemOperation) opCall(size_t region, immutable(string[2][]) list) pure {
    return new immutable ReplaceAfterFromRegion(region, list);
  }

  string get(const string value) pure {
    auto strRegion = getRegion(value);

    if(strRegion == "") {
      return "";
    }

    foreach(pair; list) {
      auto pos = strRegion.indexOf(pair[0]);

      if(pos != -1) {
        return value[0 .. $ - strRegion.length] ~ strRegion[0..pos] ~ pair[1];
      }
    }

    return "";
  }
}
