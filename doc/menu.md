# CoCoSim menu

![Kind Library](https://github.com/coco-team/cocoSim2/blob/master/doc/images/menu.png)

CoCoSm Menu can be accessed through the Tools menu in Simulink models. CoCoSim menu contains many items:

+ Verify: this option starts the verification process for the current model using the current user's preferences 
+ Create Property (deprecated): This option adds an observer property to the model. Observers are subsumed by the new [CoCoSim Specification Library](https://github.com/coco-team/cocoSim2/blob/master/doc/specificationLibrary.md)
+ Verify using: this option starts the verification process for the current model using the current user's preferences 
+ Simplifier: (to be completed)
+ Compiler Validation Experimental: (to be completed)
+ Check unsupported blocks: (to be completed)
+ Preferences: user's preferences are updated using this menu item. The preferences include: 
   + Use java to lustre Compiler: By default this option is enabled which means CoCoSim uses the latest lustre translator (written in java) which supports contracts. If this option is disabled, CoCoSim will use the old translator (written in MATLAB) which supports the observer block. 
   + Compositional Analysis: By default this option is enabled which tells CoCoSim to use [compostional analysis](https://github.com/coco-team/cocoSim2/blob/master/doc/compositionalAnalysis.md). If it is disabled, CoCoSim will use normal modular analysis.
   + Kind2 binary: This option specifies which kind2 binary is used in the backend:
     + Local: The default option in Linux and macOS which tells CoCoSim to use the local binary located inside the tools folder. 
     + Docker: This option tells CoCoSim to use kind2 image installed in docker container platform. See [here](https://github.com/coco-team/cocoSim2/blob/master/doc/installation.md#docker) on how to install docker and kind2 in Windows
     + Kind2 web service: This is the default option in Windows. This option tells CoCoSim to use [kind2 web service](https://github.com/kind2-mc/kind2-webservices/wiki) which supports verification and simulation requests. 
