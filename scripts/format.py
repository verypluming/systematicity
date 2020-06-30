#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

import glob
import numpy as np
import pandas as pd
import re
from collections import defaultdict, Counter
import collections
import copy
import os
import sys
import random
import logging
import argparse


def add_label(def_gold):
    if def_gold == "yes":
        return "entailment", "neutral"
    elif def_gold == "unk":
        return "neutral", "entailment"

parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter)
parser.add_argument("--input_dir", nargs='?', type=str, help="input file")
parser.add_argument("--obj", action='store_true', help="object")
ARGS = parser.parse_args()

files = glob.glob(ARGS.input_dir+"/*")
sentences = []
for fi in files:
    print(fi)
    if re.search("all", fi):
        continue
    if not re.search("(yes|unk)", fi):
        continue
    def_gold = re.search("(yes|unk)", fi).group(1)
    def_label, rev_label = add_label(def_gold)
    pat = re.compile("."+def_gold)
    tmp = re.sub(pat, '', os.path.basename(fi))
    origenre = re.sub('.txt', '', tmp)
    with open(fi, "r") as f:
        for line in f:
            genre = origenre
            s1, s2 = line.split("\t")
            if re.search("emptydet", s1):
                s1 = re.sub("emptydet ", "several ", s1)
                s2 = re.sub("emptydet ", "several ", s2)
                genre = genre+".empty"
            s1 = s1[0].upper() + s1[1:]
            s1 = s1.strip()+"."
            s2 = s2[0].upper() + s2[1:]
            s2 = s2.strip()+"."
            sentences.append([genre, s1, s2, def_label])
            sentences.append([genre, s2, s1, rev_label])

df = pd.DataFrame(sentences, columns=['genre', 'sentence1', 'sentence2', 'gold_label'])
df8 = df
train =pd.DataFrame(index=[], columns=['index','promptID','pairID','genre','sentence1_binary_parse','sentence2_binary_parse','sentence1_parse','sentence2_parse','sentence1','sentence2','label1','gold_label'])
train['index'] = df8.index
train['promptID'] = df8.index
train['pairID'] = df8.index
train['gold_label'] = df8["gold_label"]
train['genre'] = df8["genre"]
train['sentence1'] = df8["sentence1"]
train['sentence2'] = df8["sentence2"]
final_train = train.sample(frac=1)
final_train.to_csv(ARGS.input_dir+"/all_formatted.tsv", sep="\t", index=False)

if ARGS.obj:
    pass
else:
    depth0 = final_train.query('genre.str.contains("depth0")', engine='python')
    depth0.to_csv(ARGS.input_dir+"/depth0.tsv", sep="\t", index=False)
    depth1 = final_train.query('genre.str.contains("depth1")', engine='python')
    depth1.to_csv(ARGS.input_dir+"/depth1.tsv", sep="\t", index=False)
    depth2 = final_train.query('genre.str.contains("depth2")', engine='python')
    depth2.to_csv(ARGS.input_dir+"/depth2.tsv", sep="\t", index=False)
    depth3 = final_train.query('genre.str.contains("depth3")', engine='python')
    depth3.to_csv(ARGS.input_dir+"/depth3.tsv", sep="\t", index=False)
    depth4 = final_train.query('genre.str.contains("depth4")', engine='python')
    depth4.to_csv(ARGS.input_dir+"/depth4.tsv", sep="\t", index=False)

    sample_lex1_1 = depth0.query('genre.str.contains("empty")', engine='python')
    rest_1 = depth0.query('not genre.str.contains("empty")', engine='python')
    sample_lex1_2 = depth0.query('sentence1.str.contains("No ")', engine='python')
    rest_2 = depth0.query('not sentence1.str.contains("No ")', engine='python')

    allq_lex1_1_l = rest_1.query('genre.str.contains("lex.")', engine='python')
    allq_lex1_2_l = rest_2.query('genre.str.contains("lex.")', engine='python')
    rest_1_l = rest_1.query('not genre.str.contains("lex.")', engine='python')
    rest_2_l = rest_2.query('not genre.str.contains("lex.")', engine='python')

    allq_lex1_1_p = rest_1.query('genre.str.contains("pp.")', engine='python')
    allq_lex1_2_p = rest_2.query('genre.str.contains("pp.")', engine='python')
    rest_1_p = rest_1.query('not genre.str.contains("pp.")', engine='python')
    rest_2_p = rest_2.query('not genre.str.contains("pp.")', engine='python')

    rest_types = [[rest_1_l,sample_lex1_2,allq_lex1_2_l,sample_lex1_1,allq_lex1_1_l],
                   [rest_2_l,sample_lex1_2,allq_lex1_2_l,sample_lex1_1,allq_lex1_1_l],
                   [rest_1_p,sample_lex1_2,allq_lex1_2_p,sample_lex1_1,allq_lex1_1_p],
                   [rest_2_p,sample_lex1_2,allq_lex1_2_p,sample_lex1_1,allq_lex1_1_p]]

    for i, rest_type in enumerate(rest_types):
        #sampling lex_1
        train = pd.concat([rest_type[1],rest_type[2]]).drop_duplicates().reset_index(drop=True).sample(frac=1)
        test = rest_type[0]
        train.to_csv(ARGS.input_dir+"/lex_1_"+str(i)+".tsv", sep="\t", index=False)
        test.to_csv(ARGS.input_dir+"/dev_matched_lex_1_"+str(i)+".tsv", sep="\t", index=False)

        #1.{at least three, at most three}, {less than three, more than three},{a few, few}
        #2.{a few, few}, {at least three, at most three}, {less than three, more than three}
        at = test.query('sentence1.str.contains("At ")', engine='python')
        than = test.query('sentence1.str.contains(" than ")', engine='python')
        few = test.query('sentence1.str.contains("ew ")', engine='python')
        rest = test.query('not sentence1.str.contains("At ") and not sentence1.str.contains(" than ") and not sentence1.str.contains("ew ")', engine='python')

        lex_2 = pd.concat([rest_type[3],rest_type[4], at]).drop_duplicates().reset_index(drop=True).sample(frac=1)
        test_lex_2 = pd.concat([than, few, rest]).drop_duplicates().reset_index(drop=True)
        lex_2.to_csv(ARGS.input_dir+"/lex_2_"+str(i)+"_1.tsv", sep="\t", index=False)
        test_lex_2.to_csv(ARGS.input_dir+"/dev_matched_lex_2_"+str(i)+"_1.tsv", sep="\t", index=False)
        lex_3 = pd.concat([rest_type[3],rest_type[4], at, than]).drop_duplicates().reset_index(drop=True).sample(frac=1)
        test_lex_3 = pd.concat([few, rest]).drop_duplicates().reset_index(drop=True)
        lex_3.to_csv(ARGS.input_dir+"/lex_3_"+str(i)+"_1.tsv", sep="\t", index=False)
        test_lex_3.to_csv(ARGS.input_dir+"/dev_matched_lex_3_"+str(i)+"_1.tsv", sep="\t", index=False)
        lex_4 = pd.concat([rest_type[3],rest_type[4], at, than, few]).drop_duplicates().reset_index(drop=True).sample(frac=1)
        test_lex_4 = pd.concat([rest]).drop_duplicates().reset_index(drop=True)
        lex_4.to_csv(ARGS.input_dir+"/lex_4_"+str(i)+"_1.tsv", sep="\t", index=False)
        test_lex_4.to_csv(ARGS.input_dir+"/dev_matched_lex_4_"+str(i)+"_1.tsv", sep="\t", index=False)

        lex_2 = pd.concat([rest_type[3],rest_type[4], few]).drop_duplicates().reset_index(drop=True).sample(frac=1)
        test_lex_2 = pd.concat([than, at, rest]).drop_duplicates().reset_index(drop=True)
        lex_2.to_csv(ARGS.input_dir+"/lex_2_"+str(i)+"_2.tsv", sep="\t", index=False)
        test_lex_2.to_csv(ARGS.input_dir+"/dev_matched_lex_2_"+str(i)+"_2.tsv", sep="\t", index=False)
        lex_3 = pd.concat([rest_type[3],rest_type[4], few, at]).drop_duplicates().reset_index(drop=True).sample(frac=1)
        test_lex_3 = pd.concat([than, rest]).drop_duplicates().reset_index(drop=True)
        lex_3.to_csv(ARGS.input_dir+"/lex_3_"+str(i)+"_2.tsv", sep="\t", index=False)
        test_lex_3.to_csv(ARGS.input_dir+"/dev_matched_lex_3_"+str(i)+"_2.tsv", sep="\t", index=False)
        lex_4 = pd.concat([rest_type[3],rest_type[4], few, than, at]).drop_duplicates().reset_index(drop=True).sample(frac=1)
        test_lex_4 = pd.concat([rest]).drop_duplicates().reset_index(drop=True)
        lex_4.to_csv(ARGS.input_dir+"/lex_4_"+str(i)+"_2.tsv", sep="\t", index=False)
        test_lex_4.to_csv(ARGS.input_dir+"/dev_matched_lex_4_"+str(i)+"_2.tsv", sep="\t", index=False)

    #prepositional phrases and adverbs
    basetests = glob.glob(ARGS.input_dir+"/dev_matched*.tsv")
    advs = ["Slowly, ","Quickly, ","Seriously, ","Suddenly, ","Lazily, "]
    preps = ["In the isrand, ","On the shore, ","At the shore, ","Near the island, ","Around the shore, "]
    for basetest in basetests:
        df= pd.read_csv(basetest, sep='\t')
        df2 = df.query('~genre.str.contains("adv.")', engine='python')
        df2['adv'] = pd.Series([random.choice(advs)for i in range(len(df2))], index=df2.index )
        df2['sentence1'] = df2['adv'].str.cat(df2['sentence1'].str.lower())
        df2['sentence2'] = df2['adv'].str.cat(df2['sentence2'].str.lower())
        output = re.sub("dev","adv_dev", basetest)
        df2.drop("adv", axis=1).to_csv(output, sep="\t", index=False)

        df2 = df.query('~genre.str.contains("prep.")', engine='python')
        df2['prep'] = pd.Series([random.choice(preps)for i in range(len(df2))], index=df2.index )
        df2['sentence1'] = df2['prep'].str.cat(df2['sentence1'].str.lower())
        df2['sentence2'] = df2['prep'].str.cat(df2['sentence2'].str.lower())
        output = re.sub("dev","prep_dev", basetest)
        df2.drop("prep", axis=1).to_csv(output, sep="\t", index=False)