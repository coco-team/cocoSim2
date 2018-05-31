# Compositional analysis

![compositional analysis](https://github.com/coco-team/cocoSim2/blob/master/doc/images/compositionalAnalysis.png)

When verifying a subsystem, compositional analysis consists in abstracting the complexity of the underlying 
subsystems by their contracts. The idea is that the contract has typically a lot less state than the subsystem it specifies, which in 
addition to its own state contains that of its underlying subsystems recursively. Compositional reasoning thus improves the scalability 
of CoCosim by taking advantage of information provided by the user to abstract the complexity away. When in compositional analysis option 
is enabled, CoCosim will abstract all underlying subsystems with contracts in the top subsystem and verify the resulting, abstract system.


## Displaying compositional analysis results

The result of compositional analysis is displayed using the context menu. Two options are available:
![context menu](https://github.com/coco-team/cocoSim2/blob/master/doc/images/contextMenuVerificationResults.png)


+ Displaying the result using html page. When the verification is successfully finished, you can right click on an empty space anywhere in the model to show the context menu, then choose ```CoCoSim/Verification Results```.

The results would be displayed in Matlab web browser. The results summary can be found at the top the page. The summary shows the result of each subsystem with a contract as a table, bottom-up. Only one column **Result** is displayed in tables for subsystems which have no underlying subsytems with contracts. For other subsystems, the rows in the table show the result of each analysis performed by CoCosim. A check icon for a subsystem means that subystem is abstracted in the analysis, and a cross icon means the concrete implementation of the subsystem is used. 

More detailed results are displayed at the end of the page where the result of each property for each compositional analysis performed is displayed. Falsified properties appear as links which can be cliked to see the counter examples

The following video demonstrates this option. 

[![Installation](https://github.com/coco-team/cocoSim2/blob/master/doc/videos/htmlVerificationResults.png)](https://coco-team.github.io/cocosim/videos/htmlVerificationResults.mp4)

+ 
