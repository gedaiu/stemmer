#!/bin/bash
set -e -x -o pipefail

# test for successful 32-bit build
if [ "$DC" == "dmd" ]; then
	dub build --arch=x86
fi

# test for successful release build
dub build -b release --compiler=$DC

# run unit tests
# dub test :runner --compiler=$DC
dub run :runner --compiler=$DC -- :lifecycle --coverage -v

# install trial
dub fetch -v trial --version 0.6.2 --cache=local
dub build :runner --root ./trial-0.6.2/trial/ -v

# run the tests
./trial-0.6.2/trial/trial --coverage