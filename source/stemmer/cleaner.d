module valley.stemmer.cleaner;

import std.uni;
import std.utf;
import std.array;
import std.conv;
import std.algorithm;

bool isClean(const dchar ch) pure {
  return ch.isAlphaNum;
}

bool isBetweenNumberAndText(dchar a, dchar b) pure {
  return (a.isAlpha && b.isNumber) || (b.isAlpha && a.isNumber);
}

string clean(string data) pure {
  enum dchar space = ' ';

  auto tmp = data.byDchar
    .map!(a => a.isClean ? a : space)
    .array
    .splitter(space)
    .filter!(a => a.length > 0)
    .array
    .joiner(" ")
    .array;

  dchar[] result;
  if(tmp.length > 0) {
    result = [ tmp[0] ];

    foreach(size_t i; 1..tmp.length) {
      auto a = tmp[i-1];
      auto b = tmp[i];

      if(isBetweenNumberAndText(a, b)) {
        result ~= [' ', b];
      } else {
        result ~= b;
      }
    }
  }

  return result.to!string;
}