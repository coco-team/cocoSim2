# Verification results visualization

## Property colors

When **assume**, **guarantee** or **ensure** blocks are verified, there are possible 3 answers returned by the CoCoSim solvers: *valid*, *unknown*, or *falsifiable* with a counter example. The colors of these blocks indicate the answers as follows:

+ *Green* background if the result is valid or safe
+ *Yellow* background if the result is unknown
+ *Red* background if the result is falsified or unsafe for **guarantee** or **ensure** blocks. *Orange* background for **assume** blocks if they are falsified. 

![property colors](https://github.com/coco-team/cocoSim2/blob/master/doc/images/propertyColors.png "property colors")



## Counter examples for falsified properties

Whenever  **assume**, **guarantee**, or **ensure** blocks are falsified during the verfication process, counter examples are returned by the backend solver. To display the counter example, double click on the falsified block. The following options will appear:

![property colors](https://github.com/coco-team/cocoSim2/blob/master/doc/images/counterExampleOptions.png "counter example options")

+ Display counter example as signals would show a window with inputs and outputs of the counter example displayed as signals
+ Display counter example as tables would show a window with inputs and outputs of blocks relative to the counter example displayed as tables
+ Display counter example as HTML tables would show a html page with inputs and outputs of blocks relative to the counter example displayed as tables. Unlike the previous option, this one enables the user to copy and save the result in different formats. 

+ Generate an outer model for the counter example generates a new Simulink model replacing the inports of the susbsytem connected to the contract with signal builders whose values come from the inputs of the counter example returned by the backend solver. This option enables simulating the counter example in Simulink on the level of the target subystem. 

+ Generate an inner model for the counter example generates a new Simulink model replacing the inports of the current contract with signal builders whose values come from the inputs of the counter example returned by the backend solver. This option enables simulating the counter example in Simulink on the level of the contract. 

## Subsystem colors

Contracts and subsystems are colored as follows:

+ *Green* background if all properties inside are valid or safe
+ *Yellow* background if there is at least one unknown property inside, and no falsified or unsafe property
+ *Red* background if there is at least one falsified or unsafe property inside
+ *Orange* border or foreground color if there is at least one falsified **assume** property


![property colors](https://github.com/coco-team/cocoSim2/blob/master/doc/images/subsystemColors.png "property colors")
