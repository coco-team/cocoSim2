1. Install Automake

```sudo apt-get install automake```

2. Install opam for ocaml:

```
wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sh -s /usr/local/bin

opam init

opam switch 4.06.1

eval `opam config env`

opam install ocamlbuild

opam install menhir

opam install num
```

3. Install z3

```
git clone https://github.com/Z3Prover/z3

cd z3

python scripts/mk_make.py

cd build

make

sudo make install

```

4. Install kind2

```
git clone https://github.com/kind2-mc/kind2

cd kind2

./autogen.sh

./build.sh

make install

```
