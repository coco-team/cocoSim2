[![Build Status](https://travis-ci.org/coco-team/cocoSim.svg?branch=master)](https://travis-ci.org/coco-team/cocoSim)

# CoCoSim

CoCoSim is an automated analysis and code generation framework for
Simulink and Stateflow models. Specifically, CoCoSim can be used to
verify automatically user-supplied safety requirements. Moreover,
CoCoSim can be used to generate C and/or Rust code. CoCoSim uses
Lustre as its intermediate language. CoCoSim is currently under
development. We welcome any feedback and bug report.

[![ScreenCast of CoCoSim](http://i.imgur.com/itLte0X.png)](https://youtu.be/dcs8GOeFI9c)

## CoCoSim ToolBox

The CoCoSim toolbox contains linux and osx binariers for the backend solvers.
Download the [CoCoSim ToolBox](https://github.com/coco-team/cocoSim/releases)



## Installation

CoCoSim can be installed and used as follows:

### Dependencies

* MATLAB(c) version **R2014b** or newer
* [Zustre](https://github.com/lememta/zustre)
* (Optional) [JKind](https://github.com/agacek/jkind) -- Best for Windows OS users
* (Optional) [Kind2](http://kind2-mc.github.io/kind2/)
* Python2.7

### Configuration

* Place the different solvers (Zustre, Kind2, JKind) under ```cocosim/tools/verifiers/```.
* Set the configuration for the backend solvers in `src/config.m`:
 * `ZUSTRE`: Path to [Zustre](https://github.com/coco-team/zustre) binary.
 * `KIND2`: Path to [Kind2](https://github.com/kind2-mc/kind2) binary.
 * `LUSTREC`: Path to [LustreC](https://github.com/coco-team/lustrec) binary.
 * `Z3`: Path to Z3 binary. If you install Zustre, Z3 can be found in `ZUSTRE_PATH/build/run/bin/z3`.
 * `JKIND`: Path to [JKind](https://github.com/agacek/jkind).


### Launching

+ Launch Matlab(c)
+ Navigate to `cocosim/`
+ Just run the file ```start_cocosim```
+ Make sure to have one of the backround solvers installed (e.g. Zustre, Kind2 and or JKind)
+ You can now open your Simulink model, e.g. ```open test/properties/safe_1.mdl```

## # Example

1. To test a safe property: `open test/properties/safe_1.mdl`
2. Under the `Tools` menu choose `Verify with ...` and then `Zustre` (or JKind if you are under Windows OS).
3. To test an unsafe property (which also provide a counterexample):
   `open test/properties/unsafe_1.mdl`

More information about CoCoSim can be found [here](https://github.com/coco-team/cocoSim/wiki/CoCoSim)

## Waffle
[![Stories in Ready](https://badge.waffle.io/coco-team/cocoSim.png?label=ready&title=Ready)](https://waffle.io/coco-team/cocoSim)
[![Throughput Graph](https://graphs.waffle.io/coco-team/cocoSim/throughput.svg)](https://waffle.io/coco-team/cocoSim/metrics/throughput)

## Developers

* Lead Developer: [Temesghen Kahsai](http://www.lememta.info/)

* Current Contributors: Hamza Bourbouh (SGT - USA), Pierre-Loic
  Garoche (Onera - France), Claire Pagetti (Onera - France), Eric
  Noulard (Onera - France), Thomas Loquen (Onera - France), Xavier
  Thirioux (ENSEEIHT - France)

* Past Contributors: Arnaud Dieumegard (Fabruary - August 2015)


## Acknowledgments and Disclaimers

CoCoSim is partially funded by:

   * NASA NRA NNX14AI09G
   * NSF award 1136008

Any opinions, findings and conclusions or recommendations expressed in
this material are those of the author(s) do not necessarily
reflect the views of NASA and NSF.
