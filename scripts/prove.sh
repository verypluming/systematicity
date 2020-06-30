#!/bin/bash

vampire_dir=`cat vampire_location.txt`

txtfile=$1
depth=$2

mkdir -p tptp

basename=${txtfile##*/}

mkdir -p tptp/${basename/.txt/}

if [ -f tptp/${basename/.txt/}/results.txt ]; then
  rm tptp/${basename/.txt/}/results.txt
fi

function mapping_to_fol(){
  list=$1
  swipl -s cfg_simple_semantics.pl -g "semparse(${depth},${list})" -t halt --quiet
}

function str_to_list(){
 str=$1
 cat $str \
   | sed 's/ /,/g' \
   | sed -e 's/^/[/g' \
   | sed -e 's/$/]/g'
}

function call_vampire(){
  tptp=$1
  ${vampire_dir}/vampire $tptp \
    | head -n 1 \
    | awk '{if($0 ~ "Refutation found"){ans="yes"} else {ans="unk"} print ans}'
  }

IFS=$'\n'

id=0
yes=0
unk=0

while read line; do \
  let id++
  sent1=$(echo $line | awk -F'\t' '{print $1}' | str_to_list)
  sent2=$(echo $line | awk -F'\t' '{print $2}' | str_to_list)

  sem1=$(mapping_to_fol $sent1)
  sem2=$(mapping_to_fol $sent2)

  if [ "`echo ${basename} | grep 'lex.n.'`" ]; then
    cat tptp.n.axioms >> tptp/${basename/.txt/}/${id}.tptp
  fi
  if [ "`echo ${basename} | grep 'lex.iv.'`" ]; then
    cat tptp.iv.axioms >> tptp/${basename/.txt/}/${id}.tptp
  fi

  echo -e "fof(t,axiom, ${sem1})." \
    >> tptp/${basename/.txt/}/${id}.tptp
  echo -e "fof(h,conjecture, ${sem2})." \
    >> tptp/${basename/.txt/}/${id}.tptp

  answer=$(call_vampire tptp/${basename/.txt/}/${id}.tptp)

  if [ ${answer} == "yes" ]; then
     let yes++
  elif [ ${answer} == "unk" ]; then
     let unk++
  fi
  echo ${id} ${answer} >> tptp/${basename/.txt/}/results.txt
done < $txtfile

echo "yes/unk/total: ${yes}/${unk}/${id}" >> tptp/${basename/.txt/}/results.txt
echo "scale=2; ${yes} / ${id}" | bc >> tptp/${basename/.txt/}/results.txt

echo ${basename}
echo "yes/unk/total: ${yes}/${unk}/${id}"

if [ "`echo ${basename} | grep 'yes'`" ] && [ "${yes}" == "${id}" ]; then
  judge="success"
elif [ "`echo ${basename} | grep 'unk'`" ] && [ "${unk}" == "${id}" ]; then
  judge="success"
else
  judge="fail"
fi

echo $judge

