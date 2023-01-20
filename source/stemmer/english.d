module stemmer.english;

import std.string;
import std.conv;
import std.algorithm;
import std.array;

import stemmer.operations;
import stemmer.stemmer;

alias EnglishAlphabet = Alphabet!(["a", "e", "i", "o", "u", "y"], [ "Y" ]);

/**
  Search for the longest among the following suffixes, and perform the action indicated.

  eed   eedly+
      replace by ee if in R1

  ed   edly+   ing   ingly+
      delete if the preceding word part contains a vowel, and after the deletion:
      if the word ends at, bl or iz add e (so luxuriat -> luxuriate), or
      if the word ends with a double remove the last letter (so hopp -> hop), or
      if the word is short, add e (so hop -> hope)
*/
class EnglishRule1b : IStemOperation {
  immutable:
    /// Instantiate the rule
    static immutable(IStemOperation) opCall() pure {
      return new immutable EnglishRule1b();
    }

    /// Apply the rule to a word
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

/**
  Search for the longest among the following suffixes, and, if found and in R2, delete if preceded by s or t
*/
class EnglishIonPostfix : IStemOperation {
  immutable:
    /// Instantiate the rule
    static immutable(IStemOperation) opCall() pure {
      return new immutable EnglishIonPostfix();
    }

    /// Apply the rule to a word
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

/**
  Search for the the following suffixes, and, if found, perform the action indicated.
    `e` delete if in R2, or in R1 and not preceded by a short syllable
    `l` delete if in R2 and preceded by l
*/
class EnglishRule5 : IStemOperation {
  immutable:

    /// Instantiate the rule
    static immutable(IStemOperation) opCall() pure {
      return new immutable EnglishRule5();
    }

    /// Apply the rule to a word
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

/**
  Define a valid li-ending as one of
    c   d   e   g   h   k   m   n   r   t

  Search for the longest among the following suffixes, and, if found and in R1, delete if preceded by a valid li-ending.
*/
class ReplaceEnglishLiEnding : IStemOperation {
  immutable:
    /// Instantiate the rule
    static immutable(IStemOperation) opCall() pure {
      return new immutable ReplaceEnglishLiEnding();
    }

    /// Apply the rule to a word
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

/**
  Search for the longest among the suffixes,

  '
  's
  's'
      and remove if found.
*/
class RemoveEnglishPlural : IStemOperation {
  immutable:
    /// Instantiate the rule
    static immutable(IStemOperation) opCall() pure {
      return new immutable RemoveEnglishPlural();
    }

    /// Apply the rule to a word
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


/// The stemmer operations
static immutable englishOperations = [
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

/// English Porter2 stemmer implementation
class EnStemmer {
  /// Apply the algorithm to a word
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

    auto result = And(englishOperations).get(tmpValue);

    if(result == "") {
      return value;
    }

    return result;
  }
}