## CoCoSim ToolBox

The CoCoSim toolbox contains linux and osx binariers for the backend solvers.
Download the [CoCoSim ToolBox](https://github.com/coco-team/cocoSim/releases)



## Installation

## Kind2 web service

[![Kind2 web service](https://github.com/coco-team/cocoSim2/blob/master/doc/videos/kind2WebService.PNG)](https://coco-team.github.io/cocosim/videos/kind2WebService.mp4)

## Docker (Windows)

[![Docker](https://github.com/coco-team/cocoSim2/blob/master/doc/videos/docker.PNG)](https://coco-team.github.io/cocosim/videos/docker.mp4)

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

