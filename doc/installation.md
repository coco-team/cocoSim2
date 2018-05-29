
## CoCoSim ToolBox

The CoCoSim toolbox contains linux and osx binariers for the backend solvers.
Download the [CoCoSim ToolBox](https://github.com/coco-team/cocoSim/releases)

## Installation

CoCoSim can be installed and used as follows:

### Dependencies

* MATLAB(c) version **R2014b** or newer
* [Kind2](http://kind2-mc.github.io/kind2/)
* [Zustre](https://github.com/lememta/zustre)
* (Optional) [JKind](https://github.com/agacek/jkind)
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
