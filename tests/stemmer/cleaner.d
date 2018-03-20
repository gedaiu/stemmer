module tests.valley.stemmer.cleaner;

import fluent.asserts;
import trial.discovery.spec;

import valley.stemmer.cleaner;

import std.file;
import std.conv;
import std.datetime;
import std.file;
import std.string;
import std.conv;

import trial.step;

private alias suite = Spec!({
  describe("textCleaner", {
    it("should clean diamond bullets", {
      "♦ belisarius".clean.should.equal("belisarius");
    });

    it("should not clean cyrilic letters", {
      "языка".clean.should.equal("языка");
    });

    it("should clean quotes and special chars", {
      "“!##$%^&*()_+popup-close-question”".clean.should.equal("popup close question");
    });

    it("should clean punctuations", {
      "stop.question?exclamation!".clean.should.equal("stop question exclamation");
    });

    it("should clean a tag", {
      "windows × 40".clean.should.equal("windows 40");
    });

    it("should clean new lines", {
      "line\nline".clean.should.equal("line line");
    });

    it("should clean tabs", {
      "word\tword".clean.should.equal("word word");
    });

    it("should sepparate words from numbers", {
      "answers223k".clean.should.equal("answers 223 k");
    });
  });
});
