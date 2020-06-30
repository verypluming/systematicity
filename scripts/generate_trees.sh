#!/bin/bash

# Generate a set of parse trees by treegen.pl
#
# Usage:
#
# Use simple CFG (only relative clause)
# ./generate_trees.sh simple
#
# Use complexe CFG (relative clause +  negation + conditional)
# ./generate_trees.sh complex
#
# All results are to be stored in base_simple or base_complex directory

grammar=$1
mkdir -p base_${grammar}

function yield(){
file=$1
cat $file \
  | sed -E 's/\(S //g' \
  | sed -E 's/\(NP-SBJ //g' \
  | sed -E 's/\(NP-OBJ //g' \
  | sed -E 's/\(SBAR //g' \
  | sed -E 's/\(NEG//g' \
  | sed -E 's/\(COND//g' \
  | sed -E 's/\(N//g' \
  | sed -E 's/\(WHNP-SBJ//g' \
  | sed -E 's/\(WHNP-OBJ//g' \
  | sed -E 's/\(DET//g' \
  | sed -E 's/\(IV//g' \
  | sed -E 's/\(TV//g' \
  | sed -E 's/\(//g' \
  | sed -E 's/\)//g' \
  | sed -E 's/^[ ]*//g'
}

echo "Processing depth0..."
time swipl -s cfg_${grammar}.pl -g "gen(0,1)" -t halt --quiet > base_${grammar}/depth0.psd
echo "Processing depth1..."
time swipl -s cfg_${grammar}.pl -g "gen(1,3)" -t halt --quiet > base_${grammar}/depth1.psd
echo "Processing depth2..."
time swipl -s cfg_${grammar}.pl -g "gen(2,7)" -t halt --quiet > base_${grammar}/depth2.psd
echo "Processing depth3..."
time swipl -s cfg_${grammar}.pl -g "gen(3,12)" -t halt --quiet > base_${grammar}/depth3.psd
echo "Processing depth4..."
time swipl -s cfg_${grammar}.pl -g "gen(4,15)" -t halt --quiet > base_${grammar}/depth4.psd

wc -l base_${grammar}/depth0.psd
wc -l base_${grammar}/depth1.psd
wc -l base_${grammar}/depth2.psd
wc -l base_${grammar}/depth3.psd
wc -l base_${grammar}/depth4.psd

yield base_${grammar}/depth0.psd > base_${grammar}/depth0.txt
yield base_${grammar}/depth1.psd > base_${grammar}/depth1.txt
yield base_${grammar}/depth2.psd > base_${grammar}/depth2.txt
yield base_${grammar}/depth3.psd > base_${grammar}/depth3.txt
yield base_${grammar}/depth4.psd > base_${grammar}/depth4.txt

function count_init(){
word=$1
file=$2
num=`grep -c "^${word}" $file`
echo -e "${word}       \t${num}"
}

function count(){
word=$1
file=$2
num=`grep -c " ${word}" $file`
echo -e "${word}\t\t${num}"
}

function word_count(){
file=$1
echo "######################"
wc -l ${file}
echo "# Determiner"
count "emptydet" $file
count "every" $file
count "no" $file
count "some" $file
count "more than" $file
count "less than" $file
count "at most" $file
count "at least" $file
echo "# Connective"
count "not " $file
count "if" $file
echo "# Connective"
count "it " $file
count "if" $file
echo "# Noun"
count "bird" $file
count "rabbit" $file
count "lion" $file
count "dog" $file
count "cat" $file
echo "# Intransitive Verb"
count "ran" $file
count "walked" $file
count "cried" $file
count "slept" $file
count "swam" $file
echo "# Transitive Verb"
count "kissed" $file
count "kicked" $file
count "hit" $file
count "cleaned" $file
count "touched" $file
}

word_count base_${grammar}/depth0.txt
word_count base_${grammar}/depth1.txt
word_count base_${grammar}/depth2.txt
word_count base_${grammar}/depth3.txt
word_count base_${grammar}/depth4.txt
