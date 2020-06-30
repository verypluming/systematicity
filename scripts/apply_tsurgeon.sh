#!/bin/bash

# Set tregex path:
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

# results directory
results="results_simple"
base="base_simple"


if [ -d cache ]; then
   echo "Clear up cache directory"
   rm -rf cache
fi

mkdir -p cache

## Shortcut for Monotonicity Markers ##

NP="/NP-SBJ|NP-OBJ/"

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

# Adding PPs
function add_pp_n_depth0(){
  polarity=$1
  tsurgeon_cmd ${base}/depth0.psd \
    "S < ${polarity} < (NP-SBJ < (N=x !< MOD))" \
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

### Depth 1 ###

# Lexical Replacement: Noun
function replace_lex_n_depth1(){
  input=$1
  pol_1=$2
  pol_2=$3
  tmp="${input##*/}.lex.n.tmp"
  # singular
  tsurgeon_cmd $input \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (N < !/s$|TARGET/=x))))" \
    "relabel x TARGET" \
    > cache/$tmp
  # plural
  tsurgeon_cmd cache/$tmp \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (N < /s$/=x !< /TARGET-plur/))))" \
    "relabel x TARGET-plur"
}

# Adding adjectives
function add_adj_depth1(){
  input=$1
  pol_1=$2
  pol_2=$3
  tsurgeon_cmd $input \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (N=x !< MOD))))" \
    "insert (MOD TARGET) >1 x"
}

# Adding PPs
function add_pp_n_depth1(){
  input=$1
  pol_1=$2
  pol_2=$3
  tsurgeon_cmd $input \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (N=x !< MOD))))" \
    "insert (MOD TARGET) >2 x"
}

# Adding relative clauses
function add_rc_depth1(){
  input=$1
  pol_1=$2
  pol_2=$3
  tsurgeon_cmd $input \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (N=x !< MOD))))" \
    "insert (MOD TARGET) >2 x"
}


### Depth 2 ###

# Lexical Replacement: Noun
function replace_lex_n_depth2(){
  input=$1
  pol_1=$2
  pol_2=$3
  pol_3=$4
  tmp="${input##*/}.lex.n.tmp"
  # singular
  tsurgeon_cmd $input \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (SBAR < ${pol_3} < (${NP} < (N < !/s$|TARGET/=x))))))" \
    "relabel x TARGET" \
    > cache/$tmp
  # plural
  tsurgeon_cmd cache/$tmp \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (SBAR < ${pol_3} < (${NP} < (N < /s$/=x !< /TARGET-plur/))))))" \
    "relabel x TARGET-plur"
}

# Adding adjectives
function add_adj_depth2(){
  input=$1
  pol_1=$2
  pol_2=$3
  pol_3=$4
  tsurgeon_cmd $input \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (SBAR < ${pol_3} < (${NP} < (N=x !< MOD))))))" \
    "insert (MOD TARGET) >1 x"
}

# Adding PPs
function add_pp_n_depth2(){
  input=$1
  pol_1=$2
  pol_2=$3
  pol_3=$4
  tsurgeon_cmd $input \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (SBAR < ${pol_3} < (${NP} < (N=x !< MOD))))))" \
    "insert (MOD TARGET) >2 x"
}

# Adding relative clauses
function add_rc_depth2(){
  input=$1
  pol_1=$2
  pol_2=$3
  pol_3=$4
  tsurgeon_cmd $input \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (SBAR < ${pol_3} < (${NP} < (N=x !< MOD))))))" \
    "insert (MOD TARGET) >2 x"
}


### Depth 3 ###

# Lexical Replacement: Noun
function replace_lex_n_depth3(){
  input=$1
  pol_1=$2
  pol_2=$3
  pol_3=$4
  pol_4=$5
  tmp="${input##*/}.lex.n.tmp"
  # singular
  tsurgeon_cmd $input \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (SBAR < ${pol_3} < (${NP} < (SBAR < ${pol_4} < (${NP} < (N < !/s$|TARGET/=x))))))))" \
    "relabel x TARGET" \
    > cache/$tmp
  # plural
  tsurgeon_cmd cache/$tmp \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (SBAR < ${pol_3} < (${NP} < (SBAR < ${pol_4} < (${NP} < (N < /s$/=x !< /TARGET-plur/))))))))" \
    "relabel x TARGET-plur"
}

# Adding adjectives
function add_adj_depth3(){
  input=$1
  pol_1=$2
  pol_2=$3
  pol_3=$4
  pol_4=$5
  tsurgeon_cmd $input \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (SBAR < ${pol_3} < (${NP} < (SBAR < ${pol_4} < (${NP} < (N=x !< MOD))))))))" \
    "insert (MOD TARGET) >1 x"
}

# Adding PPs
function add_pp_n_depth3(){
  input=$1
  pol_1=$2
  pol_2=$3
  pol_3=$4
  pol_4=$5
  tsurgeon_cmd $input \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (SBAR < ${pol_3} < (${NP} < (SBAR < ${pol_4} < (${NP} < (N=x !< MOD))))))))" \
    "insert (MOD TARGET) >2 x"
}

# Adding relative clauses
function add_rc_depth3(){
  input=$1
  pol_1=$2
  pol_2=$3
  pol_3=$4
  pol_4=$5
  tsurgeon_cmd $input \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (SBAR < ${pol_3} < (${NP} < (SBAR < ${pol_4} < (${NP} < (N=x !< MOD))))))))" \
    "insert (MOD TARGET) >2 x"
}

### Depth 4 ###

# Lexical Replacement: Noun
function replace_lex_n_depth4(){
  input=$1
  pol_1=$2
  pol_2=$3
  pol_3=$4
  pol_4=$5
  pol_5=$6
  tmp="${input##*/}.lex.n.tmp"
  # singular
  tsurgeon_cmd $input \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (SBAR < ${pol_3} < (${NP} < (SBAR < ${pol_4} < (${NP} < (SBAR < ${pol_5} < (${NP} < (N < !/s$|TARGET/=x))))))))))" \
    "relabel x TARGET" \
    > cache/$tmp
  # plural
  tsurgeon_cmd cache/$tmp \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (SBAR < ${pol_3} < (${NP} < (SBAR < ${pol_4} < (${NP} < (SBAR < ${pol_5} < (${NP} < (N < /s$/=x !< /TARGET-plur/))))))))))" \
    "relabel x TARGET-plur"
}

# Adding adjectives
function add_adj_depth4(){
  input=$1
  pol_1=$2
  pol_2=$3
  pol_3=$4
  pol_4=$5
  pol_5=$6
  tsurgeon_cmd $input \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (SBAR < ${pol_3} < (${NP} < (SBAR < ${pol_4} < (${NP} < (SBAR < ${pol_5} < (${NP} < (N=x !< MOD))))))))))" \
    "insert (MOD TARGET) >1 x"
}

# Adding PPs
function add_pp_n_depth4(){
  input=$1
  pol_1=$2
  pol_2=$3
  pol_3=$4
  pol_4=$5
  pol_5=$6
  tsurgeon_cmd $input \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (SBAR < ${pol_3} < (${NP} < (SBAR < ${pol_4} < (${NP} < (SBAR < ${pol_5} < (${NP} < (N=x !< MOD))))))))))" \
    "insert (MOD TARGET) >2 x"
}

# Adding relative clauses
function add_rc_depth4(){
  input=$1
  pol_1=$2
  pol_2=$3
  pol_3=$4
  pol_4=$5
  pol_5=$6
  tsurgeon_cmd $input \
    "S < ${pol_1} < (NP-SBJ < (SBAR < ${pol_2} < (${NP} < (SBAR < ${pol_3} < (${NP} < (SBAR < ${pol_4} < (${NP} < (SBAR < ${pol_5} < (${NP} < (N=x !< MOD))))))))))" \
    "insert (MOD TARGET) >2 x"
}

##### Main scripts #####

### Depth 0 ###

# Lexical replacement for Noun
# ..to N_subj
echo "Processing replace_lex_n_depth0"
# Left upward context
replace_lex_n_depth0 "${LU}" \
  > cache/depth0.lex.n.up.yes.psd
# Left downward context
replace_lex_n_depth0 "${LD}" \
  > cache/depth0.lex.n.down.unk.psd

# Lexical replacement for IV
echo "Processing replace_lex_iv_depth0"
# Right upward context
replace_lex_iv_depth0 "${RU}" \
  > cache/depth0.lex.iv.up.yes.psd
# Right downward context
replace_lex_iv_depth0 "${RD}" \
  > cache/depth0.lex.iv.down.unk.psd

# Adding adjectives
# ..to N_subj
echo "Processing add_adj_depth0"
# Left upward context
add_adj_depth0 "${LU}" \
  > cache/depth0.adj.up.unk.psd
# Left downward context
add_adj_depth0 "${LD}" \
  > cache/depth0.adj.down.yes.psd

# Adding PP
# ..to N_subj
echo "Processing add_pp_n_depth0"
# Left upward context
add_pp_n_depth0 "${LU}" \
  > cache/depth0.pp.n.up.unk.psd
# Left downward context
add_pp_n_depth0 "${LD}" \
  > cache/depth0.pp.n.down.yes.psd

# ..to IV
echo "Processing add_pp_iv_depth0"
# Right upward context
add_pp_iv_depth0 "${RU}" \
  > cache/depth0.pp.iv.up.unk.psd
# Right downward context
add_pp_iv_depth0 "${RD}" \
  > cache/depth0.pp.iv.down.yes.psd

# Adding adverbs
echo "Processing add_adv_depth0"
# Right upward context
add_adv_depth0 "${RU}" \
  > cache/depth0.adv.up.unk.psd
# Right downward context
add_adv_depth0 "${RD}" \
  > cache/depth0.adv.down.yes.psd

# Adding relative clauses
# ..to N_subj
echo "Processing add_rc_depth0"
# Left upward context
add_rc_depth0 "${LU}" \
  > cache/depth0.rc.up.unk.psd
# Left downward context
add_rc_depth0 "${LD}" \
  > cache/depth0.rc.down.yes.psd

# Adding conjunction
echo "Processing add_conj_depth0"
# Right upward context
add_conj_depth0 "${RU}" \
  > cache/depth0.conj.up.unk.psd
# Right downward context
add_conj_depth0 "${RD}" \
  > cache/depth0.conj.down.yes.psd

# Adding disjunction
echo "Processing add_disj_depth0"
# Right upward context
add_disj_depth0 "${RU}" \
  > cache/depth0.disj.up.yes.psd
# Right downward context
add_disj_depth0 "${RD}" \
  > cache/depth0.disj.down.unk.psd

### Depth 1 ###

function upward_depth1_cmd(){
  fun=$1
  $fun ${base}/depth1.psd "${LU}" "${LU}" \
  > cache/depth1.tmp
  $fun cache/depth1.tmp "${LD}" "${LD}"
}

function downward_depth1_cmd(){
  fun=$1
  $fun ${base}/depth1.psd "${LU}" "${LD}" \
  > cache/depth1.tmp
  $fun cache/depth1.tmp "${LD}" "${LU}"
}

# Lexical replacement for Noun
echo "Processing replace_lex_n_depth1"
# Left upward context
upward_depth1_cmd replace_lex_n_depth1 \
  > cache/depth1.lex.n.up.yes.psd
# Left downward context
downward_depth1_cmd replace_lex_n_depth1 \
  > cache/depth1.lex.n.down.unk.psd

# Adding adjectives
echo "Processing add_adj_depth1"
# Left upward context
upward_depth1_cmd add_adj_depth1 \
  > cache/depth1.adj.up.unk.psd
# Left downward context
downward_depth1_cmd add_adj_depth1 \
  > cache/depth1.adj.down.yes.psd

# Adding PPs to nouns
echo "Processing add_pp_n_depth1"
# Left upward context
upward_depth1_cmd add_pp_n_depth1 \
  > cache/depth1.pp.n.up.unk.psd
# Left downward context
downward_depth1_cmd add_pp_n_depth1 \
  > cache/depth1.pp.n.down.yes.psd

# Adding relative clauses
echo "Processing add_rc_depth1"
# Left upward context
upward_depth1_cmd add_rc_depth1 \
  > cache/depth1.rc.n.up.unk.psd
# Left downward context
downward_depth1_cmd add_rc_depth1 \
  > cache/depth1.rc.n.down.yes.psd


### Depth 2 ###

function upward_depth2_cmd(){
  fun=$1
  $fun ${base}/depth2.psd "${LU}" "${LU}" "${LU}" \
    > cache/depth2.up1.tmp
  $fun cache/depth2.up1.tmp "${LD}" "${LD}" "${LU}" \
    > cache/depth2.up2.tmp
  $fun cache/depth2.up2.tmp "${LD}" "${LU}" "${LD}" \
    > cache/depth2.up3.tmp
  $fun cache/depth2.up3.tmp "${LU}" "${LD}" "${LD}"
}

function downward_depth2_cmd(){
  fun=$1
  $fun ${base}/depth2.psd "${LD}" "${LD}" "${LD}" \
    > cache/depth2.down1.tmp
  $fun cache/depth2.down1.tmp "${LU}" "${LU}" "${LD}" \
    > cache/depth2.down2.tmp
  $fun cache/depth2.down2.tmp "${LU}" "${LD}" "${LU}" \
    > cache/depth2.down3.tmp
  $fun cache/depth2.down3.tmp "${LD}" "${LU}" "${LU}"
}

# Lexical replacement for Noun
echo "Processing replace_lex_n_depth2"
# Left upward context
upward_depth2_cmd replace_lex_n_depth2 \
  > cache/depth2.lex.n.up.yes.psd
# Left downward context
downward_depth2_cmd replace_lex_n_depth2 \
  > cache/depth2.lex.n.down.unk.psd

# Adding adjectives
echo "Processing add_adj_depth2"
# Left upward context
upward_depth2_cmd add_adj_depth2 \
  > cache/depth2.adj.up.unk.psd
# Left downward context
downward_depth2_cmd add_adj_depth2 \
  > cache/depth2.adj.down.yes.psd

# Adding PP
echo "Processing add_pp_n_depth2"
# ..to N
# Left upward context
upward_depth2_cmd add_pp_n_depth2 \
  > cache/depth2.pp.n.up.unk.psd
# Left downward context
downward_depth2_cmd add_pp_n_depth2 \
  > cache/depth2.pp.n.down.yes.psd

# Adding relative clauses
echo "Processing add_rc_depth2"
# Left upward context
upward_depth2_cmd add_rc_depth2 \
  > cache/depth2.rc.n.up.unk.psd
# Left downward context
downward_depth2_cmd add_rc_depth2 \
  > cache/depth2.rc.n.down.yes.psd

### Depth 3 ###

function upward_depth3_cmd(){
  fun=$1
  $fun ${base}/depth3.psd "${LU}" "${LU}" "${LU}" "${LU}" \
    > cache/depth3.up1.tmp
  $fun cache/depth3.up1.tmp "${LU}" "${LU}" "${LD}" "${LD}" \
    > cache/depth3.up2.tmp
  $fun cache/depth3.up2.tmp "${LU}" "${LD}" "${LU}" "${LD}" \
    > cache/depth3.up3.tmp
  $fun cache/depth3.up3.tmp "${LU}" "${LD}" "${LD}" "${LU}" \
    > cache/depth3.up4.tmp
  $fun cache/depth3.up4.tmp "${LD}" "${LU}" "${LU}" "${LD}" \
    > cache/depth3.up5.tmp
  $fun cache/depth3.up5.tmp "${LD}" "${LU}" "${LD}" "${LU}" \
    > cache/depth3.up6.tmp
  $fun cache/depth3.up6.tmp "${LD}" "${LD}" "${LU}" "${LU}" \
    > cache/depth3.up7.tmp
  $fun cache/depth3.up7.tmp "${LD}" "${LD}" "${LD}" "${LD}"
}

function downward_depth3_cmd(){
  fun=$1
  $fun ${base}/depth3.psd "${LU}" "${LU}" "${LU}" "${LD}" \
    > cache/depth3.down1.tmp
  $fun cache/depth3.down1.tmp "${LU}" "${LU}" "${LD}" "${LU}" \
    > cache/depth3.down2.tmp
  $fun cache/depth3.down2.tmp "${LU}" "${LD}" "${LU}" "${LU}" \
    > cache/depth3.down3.tmp
  $fun cache/depth3.down3.tmp "${LU}" "${LD}" "${LD}" "${LD}" \
    > cache/depth3.down4.tmp
  $fun cache/depth3.down4.tmp "${LD}" "${LU}" "${LU}" "${LU}" \
    > cache/depth3.down5.tmp
  $fun cache/depth3.down5.tmp "${LD}" "${LU}" "${LD}" "${LD}" \
    > cache/depth3.down6.tmp
  $fun cache/depth3.down6.tmp "${LD}" "${LD}" "${LU}" "${LD}" \
    > cache/depth3.down7.tmp
  $fun cache/depth3.down7.tmp "${LD}" "${LD}" "${LD}" "${LU}"
}

# Lexical replacement for Noun
echo "Processing replace_lex_n_depth3"
# Left upward context
upward_depth3_cmd replace_lex_n_depth3 \
  > cache/depth3.lex.n.up.yes.psd
# Left downward context
downward_depth3_cmd replace_lex_n_depth3 \
  > cache/depth3.lex.n.down.unk.psd

# Adding adjectives
echo "Processing add_adj_depth3"
# Left upward context
upward_depth3_cmd add_adj_depth3 \
  > cache/depth3.adj.up.unk.psd
# Left downward context
downward_depth3_cmd add_adj_depth3 \
  > cache/depth3.adj.down.yes.psd

# Adding PP
echo "Processing add_pp_n_depth3"
# ..to N
# Left upward context
upward_depth3_cmd add_pp_n_depth3 \
  > cache/depth3.pp.n.up.unk.psd
# Left downward context
downward_depth3_cmd add_pp_n_depth3 \
  > cache/depth3.pp.n.down.yes.psd

# Adding relative clauses
echo "Processing add_rc_depth3"
# Left upward context
upward_depth3_cmd add_rc_depth3 \
  > cache/depth3.rc.n.up.unk.psd
# Left downward context
downward_depth3_cmd add_rc_depth3 \
  > cache/depth3.rc.n.down.yes.psd

## Depth 4 ###

function upward_depth4_cmd(){
  fun=$1
  $fun ${base}/depth4.psd "${LU}" "${LU}" "${LU}" "${LU}" "${LU}" > cache/depth4.up1.tmp
  $fun cache/depth4.up1.tmp "${LU}" "${LU}" "${LU}" "${LD}" "${LD}" > cache/depth4.up2.tmp
  $fun cache/depth4.up2.tmp "${LU}" "${LU}" "${LD}" "${LU}" "${LD}" > cache/depth4.up3.tmp
  $fun cache/depth4.up3.tmp "${LU}" "${LU}" "${LD}" "${LD}" "${LU}" > cache/depth4.up4.tmp
  $fun cache/depth4.up4.tmp "${LU}" "${LD}" "${LU}" "${LU}" "${LD}" > cache/depth4.up5.tmp
  $fun cache/depth4.up5.tmp "${LU}" "${LD}" "${LU}" "${LD}" "${LU}" > cache/depth4.up6.tmp
  $fun cache/depth4.up6.tmp "${LU}" "${LD}" "${LD}" "${LU}" "${LU}" > cache/depth4.up7.tmp
  $fun cache/depth4.up7.tmp "${LU}" "${LD}" "${LD}" "${LD}" "${LD}" > cache/depth4.up8.tmp
  $fun cache/depth4.up8.tmp "${LD}" "${LU}" "${LU}" "${LU}" "${LD}" > cache/depth4.up9.tmp
  $fun cache/depth4.up9.tmp "${LD}" "${LU}" "${LU}" "${LD}" "${LU}" > cache/depth4.up10.tmp
  $fun cache/depth4.up10.tmp "${LD}" "${LU}" "${LD}" "${LU}" "${LU}" > cache/depth4.up11.tmp
  $fun cache/depth4.up11.tmp "${LD}" "${LU}" "${LD}" "${LD}" "${LD}" > cache/depth4.up12.tmp
  $fun cache/depth4.up12.tmp "${LD}" "${LD}" "${LU}" "${LU}" "${LU}" > cache/depth4.up13.tmp
  $fun cache/depth4.up13.tmp "${LD}" "${LD}" "${LU}" "${LD}" "${LD}" > cache/depth4.up14.tmp
  $fun cache/depth4.up14.tmp "${LD}" "${LD}" "${LD}" "${LU}" "${LD}" > cache/depth4.up15.tmp
  $fun cache/depth4.up15.tmp "${LD}" "${LD}" "${LD}" "${LD}" "${LU}"
}

function downward_depth4_cmd(){
  fun=$1
  $fun ${base}/depth4.psd "${LU}" "${LU}" "${LU}" "${LU}" "${LD}" > cache/depth4.down1.tmp
  $fun cache/depth4.down1.tmp "${LU}" "${LU}" "${LU}" "${LD}" "${LU}" > cache/depth4.down2.tmp
  $fun cache/depth4.down2.tmp "${LU}" "${LU}" "${LD}" "${LU}" "${LU}" > cache/depth4.down3.tmp
  $fun cache/depth4.down3.tmp "${LU}" "${LU}" "${LD}" "${LD}" "${LD}" > cache/depth4.down4.tmp
  $fun cache/depth4.down4.tmp "${LU}" "${LD}" "${LU}" "${LU}" "${LU}" > cache/depth4.down5.tmp
  $fun cache/depth4.down5.tmp "${LU}" "${LD}" "${LU}" "${LD}" "${LD}" > cache/depth4.down6.tmp
  $fun cache/depth4.down6.tmp "${LU}" "${LD}" "${LD}" "${LU}" "${LD}" > cache/depth4.down7.tmp
  $fun cache/depth4.down7.tmp "${LU}" "${LD}" "${LD}" "${LD}" "${LU}" > cache/depth4.down8.tmp
  $fun cache/depth4.down8.tmp "${LD}" "${LU}" "${LU}" "${LU}" "${LU}" > cache/depth4.down9.tmp
  $fun cache/depth4.down9.tmp "${LD}" "${LU}" "${LU}" "${LD}" "${LD}" > cache/depth4.down10.tmp
  $fun cache/depth4.down10.tmp "${LD}" "${LU}" "${LD}" "${LU}" "${LD}" > cache/depth4.down11.tmp
  $fun cache/depth4.down11.tmp "${LD}" "${LU}" "${LD}" "${LD}" "${LU}" > cache/depth4.down12.tmp
  $fun cache/depth4.down12.tmp "${LD}" "${LD}" "${LU}" "${LU}" "${LD}" > cache/depth4.down13.tmp
  $fun cache/depth4.down13.tmp "${LD}" "${LD}" "${LU}" "${LD}" "${LU}" > cache/depth4.down14.tmp
  $fun cache/depth4.down14.tmp "${LD}" "${LD}" "${LD}" "${LU}" "${LU}" > cache/depth4.down15.tmp
  $fun cache/depth4.down15.tmp "${LD}" "${LD}" "${LD}" "${LD}" "${LD}"
}


# Lexical replacement for Noun
echo "Processing replace_lex_n_depth4"
# Left upward context
upward_depth4_cmd replace_lex_n_depth4 \
  > cache/depth4.lex.n.up.yes.psd
# Left downward context
downward_depth4_cmd replace_lex_n_depth4 \
  > cache/depth4.lex.n.down.unk.psd

# Adding adjectives
echo "Processing add_adj_depth4"
# Left upward context
upward_depth4_cmd add_adj_depth4 \
  > cache/depth4.adj.up.unk.psd
# Left downward context
downward_depth4_cmd add_adj_depth4 \
  > cache/depth4.adj.down.yes.psd

# Adding PP
echo "Processing add_pp_n_depth4"
# ..to N
# Left upward context
upward_depth4_cmd add_pp_n_depth4 \
  > cache/depth4.pp.n.up.unk.psd
# Left downward context
downward_depth4_cmd add_pp_n_depth4 \
  > cache/depth4.pp.n.down.yes.psd

# Adding relative clauses
echo "Processing add_rc_depth4"
# Left upward context
upward_depth4_cmd add_rc_depth4 \
  > cache/depth4.rc.n.up.unk.psd
# Left downward context
downward_depth4_cmd add_rc_depth4 \
  > cache/depth4.rc.n.down.yes.psd


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