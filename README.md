[![Build Status](https://travis-ci.org/coco-team/cocoSim.svg?branch=master)](https://travis-ci.org/coco-team/cocoSim)

# CoCoSim

CoCoSim is an automated analysis and code generation framework for
Simulink and Stateflow models. Specifically, CoCoSim can be used to
verify automatically user-supplied safety requirements. Moreover,
CoCoSim can be used to generate C and/or Rust code. CoCoSim uses
Lustre as its intermediate language. CoCoSim is currently under
development. We welcome any feedback and bug report.

[![ScreenCast of CoCoSim](http://i.imgur.com/itLte0X.png)](https://youtu.be/dcs8GOeFI9c)

## [Installation](https://github.com/coco-team/cocoSim2/blob/master/doc/installation.md)

## Example

1. To test a safe property: `open test/properties/safe_1.mdl`
2. Under the `Tools` menu choose `Verify with ...` and then `Zustre` (or JKind if you are under Windows OS).
3. To test an unsafe property (which also provide a counterexample):
   `open test/properties/unsafe_1.mdl`

More information about CoCoSim can be found [here](https://github.com/coco-team/cocoSim/wiki/CoCoSim)

## Waffle
[![Stories in Ready](https://badge.waffle.io/coco-team/cocoSim.png?label=ready&title=Ready)](https://waffle.io/coco-team/cocoSim)
[![Throughput Graph](https://graphs.waffle.io/coco-team/cocoSim/throughput.svg)](https://waffle.io/coco-team/cocoSim/metrics/throughput)

## Developers

### Current

* Contributors: Hamza Bourbouh (SGT - USA), Christelle Dambreville (ENSEEIHTENSEEIHT - France)

### Until May 2017

* Lead Developer: [Temesghen Kahsai](http://www.lememta.info/)

* Contributors: Hamza Bourbouh (SGT - USA), Pierre-Loic
  Garoche (Onera - France), Claire Pagetti (Onera - France), Eric
  Noulard (Onera - France), Thomas Loquen (Onera - France), Xavier
  Thirioux (ENSEEIHT - France), Arnaud Dieumegard (IRIT - France, February - August 2015)


## Acknowledgments and Disclaimers

CoCoSim is partially funded by:

   * NASA NRA NNX14AI09G
   * NSF award 1136008

Any opinions, findings and conclusions or recommendations expressed in
this material are those of the author(s) do not necessarily
reflect the views of NASA and NSF.
