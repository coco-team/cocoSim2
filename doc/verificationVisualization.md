# Verification results visualization

## Property colors

When **guarantee** or **ensure** blocks are verified, there are possible 3 answers returned by the CoCoSim solvers: *valid*, *unknown*, or *falsifiable* with a counter example. The colors of these blocks indicate the answers as follows:

+ *Green* background if the result is valid or safe
+ *Yellow* background if the result is unknown
+ *Red* background if the result is falsified or unsafe

![property colors](https://github.com/coco-team/cocoSim2/blob/master/doc/images/propertyColors.png "property colors")

For **assume** properties, there are 2 possible answers: *valid* or *falsified*. The colors of **assume** blocks indicate the answers as follows:

+ *Green* background if the result is valid
+ *Orange* background if the result is falsified

## Counter examples

## Subsystem colors

Contracts and subsystems are colored as follows:

+ *Green* background if all properties inside are valid or safe
+ *Yellow* background if there is at least one unknown property inside, and no falsified or unsafe property
+ *Red* background if there is at least one falsified or unsafe property inside
+ *Orange* border or foreground color if there is at least one falsified **assume** property


![property colors](https://github.com/coco-team/cocoSim2/blob/master/doc/images/propertyColors.png "property colors")
