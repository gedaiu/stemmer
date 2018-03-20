module valley.stemmer.english;

import std.string;
import std.conv;
import std.algorithm;
import std.array;

import valley.stemmer.operations;
import valley.stemmer.stemmer;

alias EnglishAlphabet = Alphabet!(["a", "e", "i", "o", "u", "y"], [ "Y" ]);

immutable class EnglishRule1b : IStemOperation {
  static immutable(IStemOperation) opCall() pure {
    return new immutable EnglishRule1b();
  }

  string get(const string value) pure {
    if(value.endsWith("eed") || value.endsWith("eedly")) {
      auto r1 = EnglishAlphabet.region1(value);

      if(r1.endsWith("eed")){
        return value[0..$-1];
      }

      if(r1.endsWith("eedli")){
        return value[0..$-3];
      }

      return "";
    }

    auto result = Or([
      RemovePostfix([ "ed", "ing" ]),
      ReplaceAfter([
        ["edly", ""],
        ["ingly", ""]
      ])
    ]).get(value);

    if(result == "") {
      return "";
    }

    if(!result.map!(a => EnglishAlphabet.isVowel(a)).canFind(true)) {
      return "";
    }

    if(result.endsWith("at") || result.endsWith("bl") || result.endsWith("iz")) {
      return result ~ "e";
    }

    auto replaceDouble = ReplacePostfix([
      ["bb", "b"],
      ["dd", "d"],
      ["ff", "f"],
      ["gg", "g"],
      ["mm", "m"],
      ["nn", "n"],
      ["pp", "p"],
      ["rr", "r"],
      ["tt", "t"]
    ]).get(result);

    if(replaceDouble != "") {
      return replaceDouble;
    }

    if(EnglishAlphabet.isShortWord(result)) {
      result ~= "e";
    }

    return result;
  }
}

immutable class EnglishIonPostfix : IStemOperation {
  static immutable(IStemOperation) opCall() pure {
    return new immutable EnglishIonPostfix();
  }

  string get(const string value) pure {
    auto r2 = EnglishAlphabet.region2(value);

    if(!r2.endsWith("ion")) {
      return "";
    }

    if(value.endsWith("tion") || value.endsWith("sion")) {
      return value[0..$-3];
    }

    return "";
  }
}

immutable class EnglishRule5 : IStemOperation {
  static immutable(IStemOperation) opCall() pure {
    return new immutable EnglishRule5();
  }

  string get(const string value) pure {
    auto r1 = EnglishAlphabet.region1(value);
    auto r2 = EnglishAlphabet.region1(r1);

    if(r2.endsWith('l') && value.endsWith("ll")) {
      return value[0..$-1];
    }

    if(r2.endsWith('e')) {
      return value[0..$-1];
    }

    if(r1.endsWith('e')) {
      string beforeE = value[0..value.lastIndexOf('e')];

      if(!EnglishAlphabet.endsWithShortSylable(beforeE)) {
        return value[0..$-1];
      }
    }

    return "";
  }
}

immutable class ReplaceEnglishLiEnding : IStemOperation {
  static immutable(IStemOperation) opCall() pure {
    return new immutable ReplaceEnglishLiEnding();
  }

  string get(const string value) pure {
    if(value.length <= 2) {
      return "";
    }

    if(value.endsWith("ousli") ||
       value.endsWith("abli") ||
       value.endsWith("lessli") ||
       value.endsWith("alli") ||
       value.endsWith("fulli") ||
       value.endsWith("bli") ||
       value.endsWith("entli") ) {
         return "";
    }

    auto r1 = EnglishAlphabet.region1(value);

    if(!r1.endsWith("li")) {
      return "";
    }

    if("cdeghkmnrt".indexOf(value[value.length - 3]) == -1) {
      return "";
    }

    return value[0..$-2];
  }
}

immutable class RemoveEnglishPlural : IStemOperation {
  static immutable(IStemOperation) opCall() pure {
    return new immutable RemoveEnglishPlural();
  }

  string get(const string value) pure {
    if(value.length <= 2) {
      return "";
    }

    if(!value.endsWith('s')) {
      return "";
    }

    if(value.endsWith("ss")) {
      return "";
    }

    if(value.endsWith("us")) {
      return "";
    }

    auto format = value.map!(a => EnglishAlphabet.isVowel(a)).array;

    if(format[0..$-2].canFind(true)) {
      return value[0..$-1];
    }

    return "";
  }
}

class EnStemmer {
  static immutable operations = [
    Or([
      [ Invariant(["sky", "news", "howe", "atlas", "cosmos", "bias", "andes"]) ], // exception 1 or
      [
        InlineReplace(EnglishAlphabet.get!"*Y"("Vy")),
        InlineReplace([ // step 0
          ["'s'", "s"],
          ["'s", ""],
          ["'''", "'"],
          ["''", "'"],
          ["'", ""]
        ]),
        Or([[
              ReplaceWord([
                ["skis", "ski"],
                ["skies", "sky"],
                ["dying", "die"],
                ["lying", "lie"],
                ["tying", "tie"],
                ["idly", "idl"],
                ["gently", "gentl"],
                ["ugly", "ugli"],
                ["early", "earli"],
                ["only", "onli"],
                ["singly", "singl"]
              ])
            ],[
              Or([ // step 1a
                ReplacePostfix([["sses", "ss"]]),
                ReplacePostfix(EnglishAlphabet.get!"**i"("**ied") ~ EnglishAlphabet.get!"**i"("**ies")),
                ReplacePostfix([["ies", "ie"]]),
                RemoveEnglishPlural()
              ]),
              Or([[
                Invariant([ "inning", "outing", "canning", "herring", "earring", "proceed", "exceed", "succeed"])
              ], [
                EnglishRule1b(),
                ReplacePostfix(EnglishAlphabet.get!"*i"("Ny"), 2), // step 1c

                Or([ // Step 2
                  ReplacePostifixFromRegion!EnglishAlphabet(1, [
                    ["ization", "ize"],
                    ["ational", "ate"],
                    ["fulness", "ful"],
                    ["ousness", "ous"],
                    ["iveness", "ive"],
                    ["tional", "tion"],
                    ["lessli", "less"],
                    ["biliti", "ble"],
                    ["iviti", "ive"],
                    ["ousli", "ous"],
                    ["entli", "ent"],
                    ["ation", "ate"],
                    ["fulli", "ful"],
                    ["aliti", "al"],
                    ["alism", "al"],
                    ["enci", "ence"],
                    ["anci", "ance"],
                    ["abli", "able"],
                    ["izer", "ize"],
                    ["ator", "ate"],
                    ["alli", "al"],
                    ["ogi", "og"],
                    ["logi", "log"],
                    ["bli", "ble"]
                  ]),
                  ReplaceEnglishLiEnding()
                ]),

                Or([// Step 3
                  ReplacePostifixFromRegion!EnglishAlphabet(1, [
                    ["ational", "ate"],
                    ["tional", "tion"],
                    ["alize", "al"],
                    ["icate", "ic"],
                    ["iciti", "ic"],
                    ["ical", "ic"],
                    ["ness", ""],
                    ["ful", ""],
                  ]),
                  ReplacePostifixFromRegion!EnglishAlphabet(2, "ative", "")
                ]),

                Or([ // Step 4
                  RemovePostifixFromRegion!EnglishAlphabet(2,
                    ["ement",
                    "ance", "ence", "able", "ible", "ment",
                    "ant" , "ent", "ism", "ate", "iti", "ous", "ive", "ize",
                    "er", "ic", "al"]),
                  EnglishIonPostfix()
                ]),
                EnglishRule5(),
                InlineReplace([["Y", "y"]]),
              ]])
        ]]),
      ]
    ])
  ];

  string get(const string value) pure {
    if(value.length < 3) {
      return value;
    }

    string tmpValue;
    if(value[0] == 'y') {
      tmpValue = "Y" ~ value[1..$];
    } else {
      tmpValue = value;
    }

    auto result = And(operations).get(tmpValue);

    if(result == "") {
      return value;
    }

    return result;
  }
}