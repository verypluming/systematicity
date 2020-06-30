#!/bin/sh

exp_name=$1
#./generate_trees.sh simple
if [ $exp_name == "obj" ];
then
  ./generate_trees.sh simple_obj
  ./apply_tsurgeon_obj.sh
  python develop_obj.py
  python format.py --input_dir results_simple --obj
else
  ./generate_trees.sh simple
  ./apply_tsurgeon.sh
  python develop.py
  python format.py --input_dir results_simple
fi