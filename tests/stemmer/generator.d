module tests.valley.stemmer.generator.d;

import fluent.asserts;
import trial.discovery.spec;

import valley.stemmer.english;
import valley.stemmer.stemmer;

import std.file;
import std.conv;
import std.datetime;

private alias suite = Spec!({
  describe("stemmer", {
    describe("the alphabet", {
      it("should replace the vowels in a pattern", {
        auto generator = new Alphabet!(["a", "e", "i", "u", "o", "y"]);

        generator.get("Vdfg").should.equal([
          "adfg","edfg","idfg","udfg","odfg","ydfg",
        ]);
      });

      it("should generate the combination vowels in a pattern", {
        auto generator = new Alphabet!(["a", "e", "i", "u", "o", "y"]);

        generator.get("VdVfg").should.containOnly([
          "adafg","edafg","idafg","udafg","odafg","ydafg",
          "adefg","edefg","idefg","udefg","odefg","ydefg",
          "adifg","edifg","idifg","udifg","odifg","ydifg",
          "adufg","edufg","idufg","udufg","odufg","ydufg",
          "adofg","edofg","idofg","udofg","odofg","ydofg",
          "adyfg","edyfg","idyfg","udyfg","odyfg","ydyfg",
        ]);
      });
    });

    describe("english alphabet", {

      it("should get the regions for 'consignment'", {
        EnglishAlphabet.region1("consignment").should.equal("signment");
        EnglishAlphabet.region2("consignment").should.equal("nment");
      });

      it("should get the regions for 'beautiful'", {
        EnglishAlphabet.region1("beautiful").should.equal("iful");
        EnglishAlphabet.region2("beautiful").should.equal("ul");
      });

      it("should get the regions for 'beauty'", {
        EnglishAlphabet.region1("beauty").should.equal("y");
        EnglishAlphabet.region2("beauty").should.equal("");
      });

      it("should get the regions for 'congener'", {
        EnglishAlphabet.region1("congener").should.equal("gener");
        EnglishAlphabet.region2("congener").should.equal("er");
      });

      it("should get the regions for 'beau'", {
        EnglishAlphabet.region1("beau").should.equal("");
        EnglishAlphabet.region2("beau").should.equal("");
      });

      it("should get the regions for 'animadversion'", {
        EnglishAlphabet.region1("animadversion").should.equal("imadversion");
        EnglishAlphabet.region2("animadversion").should.equal("adversion");
      });

      it("should get the regions for 'sprinkled'", {
        EnglishAlphabet.region1("sprinkled").should.equal("kled");
        EnglishAlphabet.region2("sprinkled").should.equal("");
      });

      it("should get the regions for 'eucharist'", {
        EnglishAlphabet.region1("eucharist").should.equal("harist");
        EnglishAlphabet.region2("eucharist").should.equal("ist");
      });

      it("should detect the end short syllable for 'rap'", {
        EnglishAlphabet.endsWithShortSylable("rap").should.equal(true);
      });

      it("should detect the end short syllable for 'trap'", {
        EnglishAlphabet.endsWithShortSylable("trap").should.equal(true);
      });


      it("should detect the end short syllable for 'vi'", {
        EnglishAlphabet.endsWithShortSylable("vi").should.equal(true);
      });

      it("should detect the end short syllable for 'entrap'", {
        EnglishAlphabet.endsWithShortSylable("entrap").should.equal(true);
      });

      it("should detect the end short syllable for 'ow'", {
        EnglishAlphabet.endsWithShortSylable("ow").should.equal(true);
      });

      it("should detect the end short syllable for 'on'", {
        EnglishAlphabet.endsWithShortSylable("on").should.equal(true);
      });

      it("should detect the end short syllable for 'at'", {
        EnglishAlphabet.endsWithShortSylable("at").should.equal(true);
      });

      it("should not detect the end short syllable for 'uproot'", {
        EnglishAlphabet.endsWithShortSylable("uproot").should.equal(false);
      });

      it("should not detect the end short syllable for 'bestow'", {
        EnglishAlphabet.endsWithShortSylable("bestow").should.equal(false);
      });

      it("should not detect the end short syllable for 'disturb'", {
        EnglishAlphabet.endsWithShortSylable("disturb").should.equal(false);
      });

      it("should detect the 'bed' as short word", {
        EnglishAlphabet.isShortWord("bed").should.equal(true);
      });

      it("should detect the 'shed' as short word", {
        EnglishAlphabet.isShortWord("shed").should.equal(true);
      });

      it("should detect the 'shred' as short word", {
        EnglishAlphabet.isShortWord("shred").should.equal(true);
      });

      it("should detect the 'hop' as short word", {
        EnglishAlphabet.isShortWord("hop").should.equal(true);
      });

      it("should detect the 'bead' as short word", {
        EnglishAlphabet.isShortWord("bead").should.equal(false);
      });

      it("should detect the 'embed' as short word", {
        EnglishAlphabet.isShortWord("embed").should.equal(false);
      });

      it("should detect the 'beds' as short word", {
        EnglishAlphabet.isShortWord("beds").should.equal(false);
      });
    });
  });
});