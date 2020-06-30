#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import glob
import os.path
import argparse

parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter)
ARGS = parser.parse_args()
res_dir = "results_simple"

#if os.path.exists(res_dir):
#    print("Results directory already exists!")
#    sys.exit()
#else:
if not os.path.exists(res_dir):
    os.mkdir(res_dir)

## Lexical items ##

noun_list = ["animal","creature","mammal","beast"]
iv_list = ["moved","worked","existed"]
adj_list = ["small","large","crazy","polite","wild"]
pp_list = ["in the area","on the ground","at the park","near the shore","around the island"]
adv_list = ["slowly","quickly","seriously","suddenly","lazily"]
rc_list = ["which ate dinner","that liked flowers","which hated the sun","that stayed up late"]
conj_list = ["and laughed","and groaned","and roared","and screamed","and cried"]
disj_list = ["or laughed","or groaned","or roared","or screamed","or cried"]


def develop(item_list,finput,fout,rate):
    for item in item_list:
        res = finput.replace("TARGET-plur",item + "s") \
                    .replace("TARGET",item)
        lines = res.splitlines()
        #lines = [l.replace("emptydet","").strip() for l in lines]
        # Set the pruning rate
        pruned = lines[::rate]
        pruned_str = '\n'.join(pruned) + '\n'
        with open(fout, 'a') as f:
            f.write(pruned_str)


for file in glob.glob("./cache/*.scheme"):
    basename = os.path.basename(file)
    resname = basename.replace('scheme','txt')
    fout = res_dir + '/' + resname

    with open(file) as f:
        finput = f.read()

        if 'lex.n' in basename:
            develop(noun_list,finput,fout,3)
        if 'lex.iv' in basename:
            develop(iv_list,finput,fout,3)
        if 'adj' in basename:
            develop(adj_list,finput,fout,3)
        if 'pp' in basename:
            develop(pp_list,finput,fout,3)
        if 'adv' in basename:
            develop(adv_list,finput,fout,3)
        if 'rc' in basename:
            develop(rc_list,finput,fout,3)
        if 'conj' in basename:
            develop(conj_list,finput,fout,3)
        if 'disj' in basename:
            develop(disj_list,finput,fout,3)
