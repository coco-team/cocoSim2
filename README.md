
# CoCoSim

CoCoSim is an automated analysis and code generation framework for
Simulink and Stateflow models. Specifically, CoCoSim can be used to
verify automatically user-supplied safety requirements. Moreover,
CoCoSim can be used to generate C and/or Rust code. CoCoSim uses
Lustre as its intermediate language. CoCoSim is currently under
development. We welcome any feedback and bug report.

## Installation

Installation instructions can be found [here](https://github.com/coco-team/cocoSim2/blob/master/doc/installation.md).

## CoCoSim Features

+ [CoCoSim Specification Library](https://github.com/coco-team/cocoSim2/blob/master/doc/specificationLibrary.md)
+ [CoCoSim Menu](https://github.com/coco-team/cocoSim2/blob/master/doc/menu.md)
+ [Visualization of Verification Results](https://github.com/coco-team/cocoSim2/blob/master/doc/verificationVisualization.md)
+ [Compositional Analysis](https://github.com/coco-team/cocoSim2/blob/master/doc/compositionalAnalysis.md)

## Example

1. Launch cocosim `start_cocosim`
2. Open one of the examples ```open('contract/DoorLockCompositional.slx')```
3. To verify the model, go to Tools menu and select ```Tools/CoCoSim/Verify```

## Tutorial Videos

The first video below explains the concept of contract specification using a simple Lustre model that simulates the evolution of a bacteria population. The second video shows how CoCoSim can be used to specify a contract for a CoCoSim version of the bacteria population model. Finally, the third video explains the concept of compositional analysis using a semi-realistic model of a door lock.

1. [Contracts in Lustre](http://milner.cs.uiowa.edu/cocosim/1_contracts_kind2.mp4)
2. [Contracts in CoCoSim](http://milner.cs.uiowa.edu/cocosim/2_contracts_simulink.mp4)
3. [Compositional analysis](http://milner.cs.uiowa.edu/cocosim/3_compositional_analysis.mp4)

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
