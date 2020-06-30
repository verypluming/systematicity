#!/bin/bash

# Usage
# ./is_center_emb.sh <sentence> <depth>
#
# $ ./is_center_emb.sh "No rabbit few elephants which licked few bears accepted dawdled." 2
# yes
# $ ./is_center_emb.sh "Less than three dogs that loved every monkey rushed." 1
# no
#
# "polite"のように元のCFGにはない表現（操作で追加された表現）がある場合もnoを返す
# $ ./is_center_emb.sh "Several lions a few foxes every polite bear loved kicked escaped." 2
# no

cfg="cfg_simple_4_reltag.pl"

input=$1
depth=$2

sentence=$(echo $input \
  | sed -e 's/^/[/g' \
  | sed -e 's/.$/]/g' \
  | sed 's/ /,/g')

tree=$(swipl -s ${cfg} -g "parse(${depth},${sentence})" -t halt --quiet)

if [ $(echo ${tree} | grep -E "rel[2|3]") ]; then
  echo "yes"
else
  echo "no"
fi
