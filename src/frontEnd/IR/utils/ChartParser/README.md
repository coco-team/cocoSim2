# ChartParser

To build the project use the command
```
mvn install
```

This will generate the file ```target/ChartParser.jar```. 
To deploy the jar file in CoCoSim, just replace ```CoCoSim/src/frontEnd/IR/utils/ChartParser.jar``` with the new jar file.

## State labels

The parser class for state labels is [`StateParser`](https://github.com/coco-team/cocoSim2/blob/master/src/frontEnd/IR/utils/ChartParser/src/main/java/edu/uiowa/chart/state/StateParser.java). It has a static function `StateParser.parse` which receives a string representing the state label and returns an object of [`StateAction`](https://github.com/coco-team/cocoSim2/blob/master/src/frontEnd/IR/utils/ChartParser/src/main/java/edu/uiowa/chart/state/StateAction.java). StateParser relies on the following ANTRL grammar for state labels [`StateLabel.g4`](https://github.com/coco-team/cocoSim2/blob/master/src/frontEnd/IR/utils/ChartParser/src/main/java/edu/uiowa/chart/state/antlr/StateLabel.g4). The corresponding visitor code is available in [`StateVisitor`](https://github.com/coco-team/cocoSim2/blob/master/src/frontEnd/IR/utils/ChartParser/src/main/java/edu/uiowa/chart/state/StateVisitor.java).

## Transition labels

The parser class for transition labels is [`TransitionParser`](https://github.com/coco-team/cocoSim2/blob/master/src/frontEnd/IR/utils/ChartParser/src/main/java/edu/uiowa/chart/transition/TransitionParser.java). It has a static function `TransitionParser.parse` which receives a string representing the transition label and returns an object of [`Transition`](https://github.com/coco-team/cocoSim2/blob/master/src/frontEnd/IR/utils/ChartParser/src/main/java/edu/uiowa/chart/transition/Transition.java). TransitionParser relies on the following ANTRL grammar for transition labels [`TransitionLabel.g4`](https://github.com/coco-team/cocoSim2/blob/master/src/frontEnd/IR/utils/ChartParser/src/main/java/edu/uiowa/chart/transition/antlr/TransitionLabel.g4). The corresponding visitor code is available in [`TransitionVisitor`](https://github.com/coco-team/cocoSim2/blob/master/src/frontEnd/IR/utils/ChartParser/src/main/java/edu/uiowa/chart/transition/TransitionVisitor.java).
