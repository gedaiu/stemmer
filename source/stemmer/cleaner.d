module stemmer.cleaner;

import std.uni;
import std.utf;
import std.array;
import std.conv;
import std.algorithm;

/// Check if the char can be properly handled by a stemmer
bool isClean(const dchar ch) pure {
  return ch.isAlphaNum;
}

/// Check if a sequence of two letters are between a number and a character
bool isBetweenNumberAndText(dchar a, dchar b) pure {
  return (a.isAlpha && b.isNumber) || (b.isAlpha && a.isNumber);
}

struct SpecialChar {
  char latin;
  string variants;
}

enum SpecialChar[] SpecialCharList = [
  SpecialChar('a', "ĀāĂăĄąȦȧǍǎǞǟǠǡǢǣȀȁȂȃǺǻǼǽȺɅȡ"),
  SpecialChar('b', "ƀƁƂƃƄƅɃ"),
  SpecialChar('c', "ĆćĈĉĊċČčƆƇƈȻȼ"),
  SpecialChar('d', "ĎďĐđƉƊƋƌƍǄǅǆǱǲǳȸ"),
  SpecialChar('e', "ĒēĔĕĖėĘęĚěƎƏƐƷƸƹƺƻƼƽƾɆɇȄȅȆȇǝǮǯȜȝȨȩ"),
  SpecialChar('f', "Ƒƒ"),
  SpecialChar('g', "ĜĝĞğĠġĢģƓƔǤǥǦǧǴǵɁɂ"),
  SpecialChar('h', "ĤĥĦħƕǶ"),
  SpecialChar('i', "ĨĩĪīĬĭĮįİıƗǏȈȉȊȋǐǀǁǂǃ"),
  SpecialChar('j', "ĲĳĴĵƖƚǇǈǉǊǋǌɈɉǰȷ"),
  SpecialChar('k', "ĶķĸƘƙǨǩ"),
  SpecialChar('l', "ĹĺĻļĽľĿŀŁłƛȽȴȶ"),
  SpecialChar('w', "Ɯ"),
  SpecialChar('n', "ŃńŅņŇňŉŊŋƝƞǸǹȠȵ"),
  SpecialChar('o', "ŌōŎŏŐőŒœƟƠơƢƣǑǒǪǫǬǭȪȫȬȭȮȯȌȍȎȏȰȱǾǿȣ"),
  SpecialChar('p', "ƤƥƿǷ"),
  SpecialChar('q', "Ɋɋȹ"),
  SpecialChar('r', "ŔŕŖŗŘřƦɌȐȑȒȓɌɍ"),
  SpecialChar('s', "ŚśŜŝŞşŠšƩƪȘșȿ"),
  SpecialChar('t', "ŢţŤťŦŧƫƬƭƮȚțȾ"),
  SpecialChar('u', "ŨũŪūŬŭŮůŰűŲųƯưƱƲǓǔǕǖǗǘǙǚǛǜɄȔȕȖȗ"),
  SpecialChar('w', "Ŵŵ"),
  SpecialChar('y', "ŶŷŸƳƴȲȳɎɏ"),
  SpecialChar('z', "ŹźŻżŽžſƵƶȤȥɀ"),
];

/// Removes special chars and prepares the text for stemming
string clean(string data) pure {

  static foreach (list; SpecialCharList) {
    static foreach (ch; list.variants.byDchar) {
      data = data.replace(ch, list.latin);
    }
  }

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