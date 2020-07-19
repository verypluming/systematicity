# Do Neural Models Learn Systematicity of Monotonicity Inference in Natural Language?

## Usage

- `cfg_simple.pl` -- CFG prolog scripts to generate sentences with relative clauses
- `cfg_complex.pl` -- CFG prolog scripts to generate sentences with relative clauses, negation and conditionals.
- `generate_trees.sh` -- script to run `cfg_simple.pl` and `cfg_complex.pl` up to depth 3 with selectors
- `apply_tsurgeon.sh` -- tsurgeon scripts for lexical replacement/phrasal addition: target item is marked as a schematic entry "TARGET"
- `develop.py` -- python script to develop TARGET in tsurgeon outputs.

## Install tools
```
$ sudo apt-get -y install swi-prolog
$ ./install_tools.sh
```

## Generate monotonicity inference datasets
```
$ cd scripts
$ ./create_data.sh simple
```

1. Generate sentences 

with `cfg_simple.pl`:

```
$ ./generate_trees.sh simple
```
Outputs are stored in `sample/base_simple` directory.


with `cfg_complex.pl`:

```
$ ./generate_trees.sh complex
```
Outputs are stored in `sample/base_complex` directory.

2. Replacing words (e.g. from *Every cat ran* to *Every animal ran*) and adding phrases (e.g. from *Every cat ran* to *Every small cat ran*) according to polarities:

```
$ ./apply_tsurgeon.sh
```

3. Outputs with entailment lables are to be stored in `cache` directory.

These outputs have schematic variable TARGET, which is to be developed by:

```
python develop.py
```

The results are stored in `results_simple` directory.

4. Create a training set and a test set (MultiNLI tsv format)

```
python format.py
```

The final results are stored in `results_simple` directory.

5. Check gold labels by first-order logic prover Vampire

```
$ for f in results_simple/depth0*.txt; do ./prove.sh $f 0; done
$ for f in results_simple/depth1*.txt; do ./prove.sh $f 1; done
$ for f in results_simple/depth2*.txt; do ./prove.sh $f 2; done
$ for f in results_simple/depth3*.txt; do ./prove.sh $f 3; done
$ for f in results_simple/depth4*.txt; do ./prove.sh $f 4; done
```

## Citation
If you use this code in any published research, please cite the following:
* Hitomi Yanaka, Koji Mineshima, Daisuke Bekki, and Kentaro Inui. [Do Neural Models Learn Systematicity of Monotonicity Inference in Natural Language?](https://www.aclweb.org/anthology/2020.acl-main.543.pdf) [arXiv](https://arxiv.org/pdf/2004.14839.pdf) Proceedings of the 58th Annual Meeting of the Association for Computational Linguistics (ACL2020), Seattle, USA, 2020.

```
@InProceedings{yanaka-EtAl:2020:acl,
  author    = {Yanaka, Hitomi and Mineshima, Koji  and  Bekki, Daisuke and Inui, Kentaro},
  title     = {Do Neural Models Learn Systematicity of Monotonicity Inference in Natural Language?},
  booktitle = {Proceedings of the 58th Annual Meeting of the Association for Computational Linguistics (ACL2020)},
  year      = {2020},
  pages     = {6105–-6117}
}
```

## Contact
For questions and usage issues, please contact hitomi.yanaka@riken.jp .

## License
Apache License
