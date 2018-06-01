
# CoCoSim

CoCoSim is an automated analysis and code generation framework for
Simulink and Stateflow models. Specifically, CoCoSim can be used to
verify automatically user-supplied safety requirements. Moreover,
CoCoSim can be used to generate C and/or Rust code. CoCoSim uses
Lustre as its intermediate language. CoCoSim is currently under
development. We welcome any feedback and bug report.

## Installation

Installation instructions can be found [here](https://github.com/coco-team/cocoSim2/blob/master/doc/installation.md).

## Example

1. Launch cocosim `start_cocosim`
2. Open one of the examples ```open('contract/DoorLockCompositional.slx')```
3. To verify the model, go to Tools menu and select ```Tools/CoCoSim/Verify```

## Tutorial videos

The first and the second videos below explain the concept of contracts using bacteria population example in both Lustre and CoCoSim respectively, and the third video concept of compositional analysis using the door lock example. 

1. [Contracts in Lustre](https://coco-team.github.io/cocosim/videos/1_contracts_kind2.mp4)
2. [Contracts in CoCoSim](https://coco-team.github.io/cocosim/videos/2_contracts_simulink.mp4)
3. [Composotional analysis](https://coco-team.github.io/cocosim/videos/3_compositional_analysis.mp4)


## CoCosim Features

+ [CoCoSim Specification Library](https://github.com/coco-team/cocoSim2/blob/master/doc/specificationLibrary.md)
+ [Verification results visualization](https://github.com/coco-team/cocoSim2/blob/master/doc/verificationVisualization.md)
+ [Compositional Analysis](https://github.com/coco-team/cocoSim2/blob/master/doc/compositionalAnalysis.md)

## People

* Project leaders: [Temesghen Kahsai](http://www.lememta.info/),
  [Cesare Tinelli](http://homepage.cs.uiowa.edu/~tinelli/), and
  [Corina Pasareanu](https://ti.arc.nasa.gov/profile/pcorina/)

* Developers/Contributors: Hamza Bourbouh (SGT - USA), Pierre-Loic Garoche (Onera - France),
  Mudathir Mohamed (The University of Iowa - USA), Baoluo Meng (The University of Iowa - USA),
  Daniel Larraz (The University of Iowa - USA), Christelle Dambreville (ENSEEIHTENSEEIHT - France),
  Claire Pagetti (Onera - France), Eric Noulard (Onera - France), Thomas Loquen (Onera - France),
  Xavier Thirioux (ENSEEIHT - France), and Arnaud Dieumegard (IRIT - France)


## Acknowledgments and Disclaimers

CoCoSim was partially funded by:

   * NASA NRA NNX14AI09G
   * NSF award 1136008

Any opinions, findings and conclusions or recommendations expressed in
this material are those of the author(s) do not necessarily
reflect the views of NASA and NSF.
