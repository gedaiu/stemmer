module valley.stemmer.stemmer;

import std.string;
import std.conv;
import std.algorithm;
import std.array;

interface IStemmer {
  string get(string) pure;
}


private immutable(string[]) removeLetters(const string[] letters, const string[] extra) pure {
  return letters.filter!(a => !extra.canFind(a)).array.idup;
}

private string change(const string source, const string reference) pure {
  char[] result;
  result.length = source.length;

  foreach(index, char c; source) {
    if(c == '*') {
      result[index] = reference[index];
    } else {
      result[index] = source[index];
    }
  }

  return result.to!string;
}

struct Alphabet(string[] vowels, string[] extraLetters = []) {
  static:
    immutable {
      string[] alphabet =
      ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"] ~
      extraLetters;

      string[] nonVowels = removeLetters(alphabet, vowels);
    }

    bool isVowel(dchar ch) {
      return vowels.map!"a[0]".canFind(ch);
    }

    bool isShortWord(string data) pure {
      return endsWithShortSylable(data) && region1(data) == "";
    }

    bool endsWithShortSylable(string data) pure {
      if(data.length < 2) {
        return true;
      }

      auto result = data.map!(a => isVowel(a)).array;

      if(result == [true, false]) {
        return true;
      }

      if(result == [false, true] && data[1] == 'i') {
        return true;
      }

      if(data.length == 2) {
        return false;
      }

      auto lastChar = data[data.length - 1];
      auto vowelsXWY = vowels.join ~ "wxY";

      if(result.endsWith([false, true, false]) && vowelsXWY.indexOf(lastChar) == -1) {
        return true;
      }

      return false;
    }

    string[] replaceVowels(const string value) pure {
      if(!value.canFind!"a == 'V'") {
        return [ value ];
      }

      string[] list = [];

      foreach(vowel; vowels) {
        list ~= value.replaceFirst("V", vowel);
      }

      if(list[0].canFind!"a == 'V'") {
        list = list.map!(a => replaceVowels(a)).joiner.array;
      }

      return list;
    }

    string[] replaceNonVowels(const string value) pure {
      if(!value.canFind!"a == 'N'") {
        return [ value ];
      }

      string[] list = [];

      foreach(vowel; nonVowels) {
        list ~= value.replaceFirst("N", vowel);
      }

      if(list[0].canFind!"a == 'N'") {
        list = list.map!(a => replaceNonVowels(a)).joiner.array;
      }

      return list;
    }

    string[] replaceAny(const string value) pure {
      if(!value.canFind!"a == '*'") {
        return [ value ];
      }

      string[] list = [];

      foreach(ch; alphabet) {
        list ~= value.replaceFirst("*", ch);
      }

      if(list[0].canFind!"a == '*'") {
        list = list.map!(a => replaceAny(a)).joiner.array;
      }

      return list;
    }

    immutable(string[]) get(const string value) pure {
      return replaceVowels(value)
          .map!(a => replaceNonVowels(a))
          .joiner
          .map!(a => replaceAny(a))
          .joiner
          .filter!(a => !a.canFind("*")).array.idup;
    }

    immutable(string[2][]) get(string replace)(const string value) pure {
      return get(value)
        .map!(a => cast(string[2])[a, change(replace, a)])
          .array;
    }

    alias region1 = region!true;

    string region(bool useExceptions)(string word) pure {
      if(word.length < 2) {
        return "";
      }

      static if(useExceptions) {
        static foreach(prefix; [ "gener", "commun", "arsen"]) {
          if(word.startsWith(prefix)) {
            return word[prefix.length .. $];
          }
        }
      }

      foreach(i; 0..word.length - 1) {
        if(vowels.map!"a[0]".canFind(word[i]) && nonVowels.map!"a[0]".canFind(word[i+1])) {
          return word[i+2..$];
        }
      }

      return "";
    }

    string region2(string word) pure {
      return region!false(region1(word));
    }
}
