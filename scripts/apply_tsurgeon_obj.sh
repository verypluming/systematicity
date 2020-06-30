#!/bin/bash

# Set tregex path:
# $ cat tregex_location.txt
# /Users/kojimineshima/stanford-tregex-2018-10-16
tregex_dir=`cat tregex_location.txt`
export CLASSPATH=$tregex_dir/stanford-tregex.jar:$CLASSPATH

function tsurgeon_cmd() {
  treefile=$1
  pattern=$2
  operation=$3
  java -mx100m edu.stanford.nlp.trees.tregex.tsurgeon.Tsurgeon -s -treeFile $treefile -po "${pattern}" "${operation}"
}

function string(){
file=$1
cat $file \
  | sed -E 's/\(S //g' \
  | sed -E 's/\(NP-SBJ //g' \
  | sed -E 's/\(NP-OBJ //g' \
  | sed -E 's/\(SBAR //g' \
  | sed -E 's/\(N//g' \
  | sed -E 's/\(WHNP-SBJ//g' \
  | sed -E 's/\(WHNP-OBJ//g' \
  | sed -E 's/\(DET//g' \
  | sed -E 's/\(IV//g' \
  | sed -E 's/\(TV//g' \
  | sed -E 's/\(MOD//g' \
  | sed -E 's/\(//g' \
  | sed -E 's/\)//g' \
  | sed -E 's/^[ ]*//g'
}

# $1: kinds of determiners
det=$1

# results directory
results="results_simple_"${det}
base="base_simple_"${det}


if [ -d cache ]; then
   echo "Clear up cache directory"
   rm -rf cache
fi

mkdir -p cache

## Shortcut for Monotonicity Markers ##

NP="/NP-OBJ/"

# Left upward determiner
LU="(${NP} < (DET < /emptydet|some|more|least/ | < /a/ < /few/))"
# Right upward determiner
RU="(${NP} < (DET < /emptydet|every|each|all|some|more|least/ | < /a/ < /few/))"

# Left downward determiner
LD="(${NP} < (DET < /every|each|all|no|less|most/ | !< /a/ < /few/))"
# Left downward determiner
RD="(${NP} < (DET < /no|less|most/ | !< /a/ < /few/))"


##### Tsurgeon functions #####

### Depth 0 ###

# Lexical Replacement: Noun
function replace_lex_n_depth0(){
  polarity=$1
  tmp="${input##*/}.lex.n.tmp"
  # singular
  tsurgeon_cmd ${base}/depth0.psd \
    "S < ${polarity} < (NP-SBJ < (N < !/s$|TARGET/=x))" \
    "relabel x TARGET" \
    > cache/$tmp
  # plural
  tsurgeon_cmd cache/$tmp \
    "S < ${polarity} < (NP-SBJ < (N < /s$/=x !< /TARGET-plur/))" \
    "relabel x TARGET-plur"
}

# Lexical Replacement: Noun Obj
function replace_lex_obj_depth0(){
  polarity=$1
  tmp="${input##*/}.lex.n.tmp"
  # singular
  tsurgeon_cmd ${base}/depth0.psd \
    "S < ${polarity} < (NP-OBJ < (N < !/s$|TARGET/=x))" \
    "relabel x TARGET" \
    > cache/$tmp
  # plural
  tsurgeon_cmd cache/$tmp \
    "S < ${polarity} < (NP-OBJ < (N < /s$/=x !< /TARGET-plur/))" \
    "relabel x TARGET-plur"
}

# Lexical Replacement: IV
function replace_lex_iv_depth0(){
  polarity=$1
  tsurgeon_cmd ${base}/depth0.psd \
    "S < ${polarity} < (IV < !/TARGET/=x)" \
    "relabel x TARGET"
}

# Adding adjectives
function add_adj_depth0(){
  polarity=$1
  tsurgeon_cmd ${base}/depth0.psd \
    "S < ${polarity} < (NP-SBJ < (N=x !< MOD))" \
    "insert (MOD TARGET) >1 x"
}

function add_adj_obj_depth0(){
  polarity=$1
  tsurgeon_cmd ${base}/depth0.psd \
    "S < ${polarity} < (NP-OBJ < (N=x !< MOD))" \
    "insert (MOD TARGET) >1 x"
}

# Adding PPs
function add_pp_n_depth0(){
  polarity=$1
  tsurgeon_cmd ${base}/depth0.psd \
    "S < ${polarity} < (NP-SBJ < (N=x !< MOD))" \
    "insert (MOD TARGET) >2 x"
}

function add_pp_obj_depth0(){
  polarity=$1
  tsurgeon_cmd ${base}/depth0.psd \
    "S < ${polarity} < (NP-OBJ < (N=x !< MOD))" \
    "insert (MOD TARGET) >2 x"
}

function add_pp_iv_depth0(){
  polarity=$1
  tsurgeon_cmd ${base}/depth0.psd \
    "S < ${polarity} < (IV=x !< MOD)" \
    "insert (MOD TARGET) >2 x"
}

# Adding adverbs
function add_adv_depth0(){
  polarity=$1
  tsurgeon_cmd ${base}/depth0.psd \
    "S < ${polarity} < (IV=x !< MOD)" \
    "insert (MOD TARGET) >2 x"
}

# Adding relative clauses
function add_rc_depth0(){
  polarity=$1
  tsurgeon_cmd ${base}/depth0.psd \
    "S < ${polarity} < (NP-SBJ < (N=x !< MOD))" \
    "insert (MOD TARGET) >2 x"
}

function add_rc_obj_depth0(){
  polarity=$1
  tsurgeon_cmd ${base}/depth0.psd \
    "S < ${polarity} < (NP-OBJ < (N=x !< MOD))" \
    "insert (MOD TARGET) >2 x"
}

# Adding conjunction
function add_conj_depth0(){
  polarity=$1
  tsurgeon_cmd ${base}/depth0.psd \
    "S < ${polarity} < (IV=x !< MOD)" \
    "insert (MOD TARGET) >2 x"
}

# Adding disjunction
function add_disj_depth0(){
  polarity=$1
  tsurgeon_cmd ${base}/depth0.psd \
    "S < ${polarity} < (IV=x !< MOD)" \
    "insert (MOD TARGET) >2 x"
}

#

##### Main scripts #####

### Depth 0 ###

# Lexical replacement for Noun
# ..to N_subj
# echo "Processing replace_lex_n_depth0"
# # Left upward context
# replace_lex_n_depth0 "${LU}" \
#   > cache/depth0.lex.n.up.yes.psd
# # Left downward context
# replace_lex_n_depth0 "${LD}" \
#   > cache/depth0.lex.n.down.unk.psd

# ..to N_obj
echo "Processing replace_lex_obj_depth0"
# Left upward context
replace_lex_obj_depth0 "${LU}" \
  > cache/depth0.lex_obj.up.yes.psd
# Left downward context
replace_lex_obj_depth0 "${LD}" \
  > cache/depth0.lex_obj.down.unk.psd

# Lexical replacement for IV
# echo "Processing replace_lex_iv_depth0"
# # Right upward context
# replace_lex_iv_depth0 "${RU}" \
#   > cache/depth0.lex.iv.up.yes.psd
# # Right downward context
# replace_lex_iv_depth0 "${RD}" \
#   > cache/depth0.lex.iv.down.unk.psd

# Adding adjectives
# ..to N_subj
# echo "Processing add_adj_depth0"
# # Left upward context
# add_adj_depth0 "${LU}" \
#   > cache/depth0.adj.up.unk.psd
# # Left downward context
# add_adj_depth0 "${LD}" \
#   > cache/depth0.adj.down.yes.psd

# ..to N_obj
echo "Processing add_adj_obj_depth0"
# Left upward context
add_adj_obj_depth0 "${LU}" \
  > cache/depth0.adj_obj.up.unk.psd
# Left downward context
add_adj_obj_depth0 "${LD}" \
  > cache/depth0.adj_obj.down.yes.psd

# Adding PP
# ..to N_subj
# echo "Processing add_pp_n_depth0"
# # Left upward context
# add_pp_n_depth0 "${LU}" \
#   > cache/depth0.pp.n.up.unk.psd
# # Left downward context
# add_pp_n_depth0 "${LD}" \
#   > cache/depth0.pp.n.down.yes.psd

# ..to N_obj
echo "Processing add_pp_obj_depth0"
# Left upward context
add_pp_obj_depth0 "${LU}" \
  > cache/depth0.pp_obj.up.unk.psd
# Left downward context
add_pp_obj_depth0 "${LD}" \
  > cache/depth0.pp_obj.down.yes.psd

# # ..to IV
# echo "Processing add_pp_iv_depth0"
# # Right upward context
# add_pp_iv_depth0 "${RU}" \
#   > cache/depth0.pp.iv.up.unk.psd
# # Right downward context
# add_pp_iv_depth0 "${RD}" \
#   > cache/depth0.pp.iv.down.yes.psd

# # Adding adverbs
# echo "Processing add_adv_depth0"
# # Right upward context
# add_adv_depth0 "${RU}" \
#   > cache/depth0.adv.up.unk.psd
# # Right downward context
# add_adv_depth0 "${RD}" \
#   > cache/depth0.adv.down.yes.psd

# Adding relative clauses
# ..to N_subj
# echo "Processing add_rc_depth0"
# # Left upward context
# add_rc_depth0 "${LU}" \
#   > cache/depth0.rc.up.unk.psd
# # Left downward context
# add_rc_depth0 "${LD}" \
#   > cache/depth0.rc.down.yes.psd

# ..to N_obj
echo "Processing add_rc_obj_depth0"
# Left upward context
add_rc_obj_depth0 "${LU}" \
  > cache/depth0.rc_obj.up.unk.psd
# Left downward context
add_rc_obj_depth0 "${LD}" \
  > cache/depth0.rc_obj.down.yes.psd

# # Adding conjunction
# echo "Processing add_conj_depth0"
# # Right upward context
# add_conj_depth0 "${RU}" \
#   > cache/depth0.conj.up.unk.psd
# # Right downward context
# add_conj_depth0 "${RD}" \
#   > cache/depth0.conj.down.yes.psd

# # Adding disjunction
# echo "Processing add_disj_depth0"
# # Right upward context
# add_disj_depth0 "${RU}" \
#   > cache/depth0.disj.up.yes.psd
# # Right downward context
# add_disj_depth0 "${RD}" \
#   > cache/depth0.disj.down.unk.psd


### polarity generator for Depth3 ###

# echo "Depth3-Upward"
# for n in {0..15}; do
#   num=`echo "ibase=10; obase=2; ${n}" | bc`
#   pol=`printf "%04d " $num`
#   i=`echo ${pol} | grep -o 0 | wc -l`
#     if [ $((${i} % 2)) = 0 ]; then
#       echo $pol | sed 's/0/"${LU}" /g' | sed 's/1/"${LD}" /g'
#     fi
# done

# echo "Depth3-Downward"
# for n in {0..15}; do
#   num=`echo "ibase=10; obase=2; ${n}" | bc`
#   pol=`printf "%04d " $num`
#   i=`echo ${pol} | grep -o 0 | wc -l`
#     if [ $((${i} % 2)) = 1 ]; then
#       echo $pol | sed 's/0/"${LU}" /g' | sed 's/1/"${LD}" /g'
#     fi
# done

# Depth3-Upward
# "${LU}" "${LU}" "${LU}" "${LU}"
# "${LU}" "${LU}" "${LD}" "${LD}"
# "${LU}" "${LD}" "${LU}" "${LD}"
# "${LU}" "${LD}" "${LD}" "${LU}"
# "${LD}" "${LU}" "${LU}" "${LD}"
# "${LD}" "${LU}" "${LD}" "${LU}"
# "${LD}" "${LD}" "${LU}" "${LU}"
# "${LD}" "${LD}" "${LD}" "${LD}"
# Depth3-Downward
# "${LU}" "${LU}" "${LU}" "${LD}"
# "${LU}" "${LU}" "${LD}" "${LU}"
# "${LU}" "${LD}" "${LU}" "${LU}"
# "${LU}" "${LD}" "${LD}" "${LD}"
# "${LD}" "${LU}" "${LU}" "${LU}"
# "${LD}" "${LU}" "${LD}" "${LD}"
# "${LD}" "${LD}" "${LU}" "${LD}"
# "${LD}" "${LD}" "${LD}" "${LU}"

##############################################

for psd in cache/*.psd; do \
  string $psd | sed -E 's/ [ ]*/ /g' \
  > ${psd/psd/txt}
done

function combine(){
  input=$1
  fname=${input##*/}
  depth=${fname%%.*}
  output=cache/${fname/.txt/.scheme}
  paste ${base}/${depth}.txt $input | awk -F"\t" '! ($1 == $2){print}'|awk 'NR%2==0' > $output
  wc -l $output
}

for file in cache/depth*.txt; do
  combine $file
done

# for file in ${results}/*; do
#   fname=${file##*/}
#   label=${fname##*.}
#   depth=${fname%%.*}
#   cat $file >> ${results}/${depth}.all.${label}
# done

# wc -l ${results}/depth0.all.yes
# wc -l ${results}/depth0.all.unk

# wc -l ${results}/depth1.all.yes
# wc -l ${results}/depth1.all.unk

# wc -l ${results}/depth2.all.yes
# wc -l ${results}/depth2.all.unk

# wc -l ${results}/depth3.all.yes
# wc -l ${results}/depth3.all.unk