# Stemmer [![Build Status](https://travis-ci.org/gedaiu/stemmer.svg?branch=master)](https://travis-ci.org/gedaiu/stemmer)


A stemmer library for D programming language. It implements the Porter Stemming Algorithm and it's tested against the
[Snowball](http://snowball.tartarus.org/algorithms/porter/stemmer.html) examples.

It contains only an english stemmer but support for other languages will be added  in the future.

## Example

```d
  import stemmer.english;
  import stemmer.cleaner;

  auto stemmer = new EnStemmer;

  auto result = "knightly consolingly zoology kinkajou".clean.split(" ").map!(a => stem.get(a)).array;

  writeln(result);
```

## Running the tests

The tests are implemented using the [trial](http://trial.szabobogdan.com/) test runner. After installing it, you can just run the trial command:

```d
trial
```