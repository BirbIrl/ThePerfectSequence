#!/usr/bin/env bash
#love
cd ../src
rm ../build/ThePerfectSequence.love
zip -r ../build/ThePerfectSequence.love * 
#web
cd ../web
python build.py ../build/ThePerfectSequence.love ../docs
echo "# This isn't actually the docs, this is the game, but github pages will only (realisitically) run from this folder without a headache so for now - good enough" > ../docs/README.md
cd ../build
#windows
cp -r ../windows ./ThePerfectSequence
cat ./ThePerfectSequence/love.exe ./ThePerfectSequence.love > ./ThePerfectSequence/ThePerfectSequence.exe
cd ThePerfectSequence
rm ./love.exe
rm ../ThePerfectSequenceWin64.zip 
zip -r ../ThePerfectSequenceWin64.zip *
cd ..
rm -r ./ThePerfectSequence
