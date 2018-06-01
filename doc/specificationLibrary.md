# CoCoSim Specification Library

![Kind Library](https://github.com/coco-team/cocoSim2/blob/master/doc/images/kindLibrary.png)

CoCoSim specification library contains blocks commonly used in verification. 

+ The *arrow* block is used when we have a signal with initial value coming from a signal at the first time step, and next values from another signal at later steps. 
+ The *first* block outputs a constant signal which is the first value of the input signal. 
+ The *hasHappened* block receives a Boolean input signal and outputs whether this signal was ever true since the first time step
+ The *sofar* block receives a Boolean input signal and outputs whether this signal is true from the fist time step till the current time step
+ The blocks *assume*, *guarantee*, *require*, *ensure*, *mode* and *validator* are relevant to the *contract* block on the far right. These blocks formally capture the specifications and the behavior of a component. Contract semantics is explained below. 

## Contract semantics

Typically a contract consists of a set of assumptions and a set of guarantees. An assumption describes how a subsystem **must** be used, while guarantees specify how that subsystem behaves. More formally, a susbystem respects its contract if 
```(☐ contract assumptions) → (☐ contract guarantees)``` where ☐ is the global temporal operator. That is, if the assumptions always hold then the guarantees hold. 

In CoCoSim, contract assumptions are handled by **assume** blocks, and guarantees are handled by **guarantee** blocks. These blocks are subsystems where the outport is fixed (only a single boolean outport) and the inports and other blocks are implemented by the user. The outports of **assume** and **guarantee** blocks need to be connected to the **validator** block in order to be considered in the verification process. 

CoCoSim augments traditional assume-guarantee contracts with the notion of *mode*. A mode (require, ensure) is a set of **requires** and a set of **ensures**. A CoCoSim contract is therefore a triplet (assumptions,guarantees,modes). If the set of modes is empty, then the semantics of contract is exactly that of an assume-guarantee contract. 
