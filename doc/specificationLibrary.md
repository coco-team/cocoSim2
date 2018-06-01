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

### Modes

CoCoSim augments traditional assume-guarantee contracts with the notion of *mode*. A mode (requires, ensures) is a set of **requires** and a set of **ensures**. A CoCoSim contract is therefore a triplet (assumptions, guarantees, modes). If the set of modes is empty, then the semantics of contract is exactly that of an assume-guarantee contract. 

A mode represents a *situation*/*reaction* implication. A mode (requires, ensures) in the contract of a subsystem is active at time t in a simulation of that subsystem if ```AND requires``` is true at that time. A contract (assumptions, guarantees, modes) can be re-written as an assume-guarantee contract (assumptions, guarantees') where 

```guarantees' = guarantees ⋃ {requires_i → ensures_i}``` for each mode i. 

Modes are introduced in the contract language of CoCoSim to account for the fact that most requirements found in specification documents are actually implications between a situation and a behavior. In a traditional assume-guarantee contract, such requirements have to be written as situation → behavior guarantees. This is cumbersome, error-prone, but most importantly some information is lost in this encoding. Modes make writing specification more straightforward and user-friendly, and allow CoCoSim to keep the mode information around to improve feedback for counterexamples, and adopt a defensive approach to guard against typos and specification oversights to a certain extent.  If a mode is missing, or a requirement is more restrictive than it should be, then CoCoSim will detect the modes that are not exhaustive, and provide a counterexample.
