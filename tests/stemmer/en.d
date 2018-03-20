module tests.valley.stemmer.en;

import fluent.asserts;
import trial.discovery.spec;

import valley.stemmer.english;

import std.file;
import std.conv;
import std.datetime;
import std.file;
import std.string;
import std.conv;

import trial.step;

private alias suite = Spec!({
  describe("english stemmer", {
    static immutable stems = [
      ["consign", "consign"],
      ["consigned", "consign"],
      ["consigning", "consign"],
      ["consignment", "consign"],
      ["consist", "consist"],
      ["consisted", "consist"],
      ["consistency", "consist"],
      ["consistent", "consist"],
      ["consistently", "consist"],
      ["consisting", "consist"],
      ["consists", "consist"],
      ["consolation", "consol"],
      ["consolations", "consol"],
      ["consolatory", "consolatori"],
      ["console", "consol"],
      ["consoled", "consol"],
      ["consoles", "consol"],
      ["consolidate", "consolid"],
      ["consolidated", "consolid"],
      ["consolidating", "consolid"],
      ["consoling", "consol"],
      ["consolingly", "consol"],
      ["consols", "consol"],
      ["consonant", "conson"],
      ["consort", "consort"],
      ["consorted", "consort"],
      ["consorting", "consort"],
      ["conspicuous", "conspicu"],
      ["conspicuously", "conspicu"],
      ["conspiracy", "conspiraci"],
      ["conspirator", "conspir"],
      ["conspirators", "conspir"],
      ["conspire", "conspir"],
      ["conspired", "conspir"],
      ["conspiring", "conspir"],
      ["constable", "constabl"],
      ["constables", "constabl"],
      ["constance", "constanc"],
      ["constancy", "constanc"],
      ["constant", "constant"],
      ["knack", "knack"],
      ["knackeries", "knackeri"],
      ["knacks", "knack"],
      ["knag", "knag"],
      ["knave", "knave"],
      ["knaves", "knave"],
      ["knavish", "knavish"],
      ["kneaded", "knead"],
      ["kneading", "knead"],
      ["knee", "knee"],
      ["kneel", "kneel"],
      ["kneeled", "kneel"],
      ["kneeling", "kneel"],
      ["kneels", "kneel"],
      ["knees", "knee"],
      ["knell", "knell"],
      ["knelt", "knelt"],
      ["knew", "knew"],
      ["knick", "knick"],
      ["knif", "knif"],
      ["knife", "knife"],
      ["knight", "knight"],
      ["knightly", "knight"],
      ["knights", "knight"],
      ["knit", "knit"],
      ["knits", "knit"],
      ["knitted", "knit"],
      ["knitting", "knit"],
      ["knives", "knive"],
      ["knob", "knob"],
      ["knobs", "knob"],
      ["knock", "knock"],
      ["knocked", "knock"],
      ["knocker", "knocker"],
      ["knockers", "knocker"],
      ["knocking", "knock"],
      ["knocks", "knock"],
      ["knopp", "knopp"],
      ["knot", "knot"],
      ["knots", "knot"],
      ["news", "news"],
      ["dying", "die"],
      ["cries", "cri"],
      ["by", "by"],
      ["say", "say"],
      ["ties", "tie"],
      ["cry", "cri"],
      ["gas", "gas"],
      ["this", "this"],
      ["kiwis", "kiwi"],
      ["gaps", "gap"],
      ["abdomen", "abdomen"],
      ["abeyance", "abey"],
      ["abed", "abe"],
      ["abe", "abe"],
      ["abilities", "abil"],
      ["added", "ad"],
      ["adulatory", "adulatori"],
      ["advance", "advanc"],
      ["aeschylus", "aeschylus"],
      ["agreement", "agreement"],
      ["zone", "zone"],
      ["accrue", "accru"],
      ["aided", "aid"],
      ["zample", "zampl"],
      ["yore", "yore"],
      ["wring", "wring"],
      ["wooed", "woo"],
      ["wooded", "wood"],
      ["wofully", "wofulli"],
      ["zoology", "zoolog"],
      ["yearly", "year"],
      ["wiolinceller", "wiolincel"],
      ["where", "where"],
      ["wexed", "wex"],
      ["weed", "weed"],
      ["vied", "vie"],
      ["die", "die"],
      ["assessor", "assessor"],
      ["awe", "awe"],
      ["being", "be"],
      ["canning", "canning"],
      ["commune", "commune"],
      ["congeners", "congen"],
      ["conversational", "convers"],
      ["eas", "ea"],
      ["fluently", "fluentli"],
      ["ied", "ie"],
      ["kinkajou", "kinkajou"]
    ];

    static foreach(words; stems) {
      it("should get the stem for '" ~ words[0] ~ "'", {
        auto stem = new EnStemmer;
        stem.get(words[0]).should.equal(words[1]);
      });
    }

    it("should process the words according the example files", {
      auto source = readText("testData/stemmer/english/voc.txt").split("\n");
      auto output = readText("testData/stemmer/english/output.txt").split("\n");

      auto stem = new EnStemmer;

      Exception lastException;
      int errors;

      foreach(size_t i, value; source) {
        Step(i.to!string ~ " " ~ value);

        try {
          stem.get(value).should.equal(output[i]);
        } catch(Exception e) {
          lastException = e;
          errors++;
        }
      }

      Step(errors.to!string ~ " bad results");
      if(lastException !is null) {
        throw lastException;
      }
    });
  });
});
