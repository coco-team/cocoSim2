# CoCoSim menu

![Kind Library](https://github.com/coco-team/cocoSim2/blob/master/doc/images/menu.png)

CoCoSim Menu can be accessed after [launching CoCoSim](https://github.com/coco-team/cocoSim2/blob/master/doc/installation.md#launching) through the Tools menu in Simulink models. CoCoSim menu contains many items:

+ Verify: this option starts the verification process for the current model using the current user's preferences 
+ Create Property (deprecated): This option adds an observer property to the model. Observers are subsumed by the new [CoCoSim Specification Library](https://github.com/coco-team/cocoSim2/blob/master/doc/specificationLibrary.md)
+ Verify using: this option starts the verification process for the current model using the selected back-end solver 
+ Simplifier: [to be completed]
+ Compiler Validation (experimental): [to be completed]
+ Check unsupported blocks: check whether all blocks used in the model are supported by the plugin
+ Preferences: user's preferences are updated using this menu item. 
![Kind Library](https://github.com/coco-team/cocoSim2/blob/master/doc/images/preferences.png)
The preferences include: 
   + Use IR to lustre Compiler (enabled by default): CoCoSim uses the latest [translator](https://github.com/coco-team/ir2lustre) from CoCoSim IR to Lustre (written in Java) which supports [contract specification](https://github.com/coco-team/cocoSim2/blob/master/doc/specificationLibrary.md). If this option is disabled, CoCoSim will use the old translator (written in MATLAB) which only supports the observer block. 
   + Compositional Analysis (enabled by default): CoCoSim will verify the model specification using a [compositional analysis](https://github.com/coco-team/cocoSim2/blob/master/doc/compositionalAnalysis.md). If it is disabled, CoCoSim will perform only a modular analysis.
   + Kind 2 binary: This option specifies which Kind 2 binary is used in the backend:
     + Local: The default option in Linux and macOS which tells CoCoSim to use the local binary located inside the tools folder. 
     + Docker: This option tells CoCoSim to use Kind 2 image installed in docker container platform. See [here](https://github.com/coco-team/cocoSim2/blob/master/doc/installation.md#docker) on how to install docker and Kind 2 in Windows
     + Kind2 web service: This is the default option in Windows. This option tells CoCoSim to use [Kind2 web service](https://github.com/kind2-mc/kind2-webservices/wiki) which supports verification and simulation requests. 
   + Verification timeout: the timeout argument for Kind 2 
