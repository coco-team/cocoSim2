# Kind Library

Kind library contains blocks commonly used in verification. 

+ The *arrow* block is used when we have a signal with initial value coming from a signal at the first time step, and next values from another signal at later steps. 
+ The *first* block outputs a constant signal which is the first value of the input signal. 
+ The *hasHappened* block receives a Boolean input signal and outputs whether this signal was ever true since the first time step
+ The *sofar* block receives a Boolean input signal and outputs whether this signal is true from the fist time step till the current time step
+ The blocks *assume*, *guarantee*, *require*, *ensure*, *mode* and *validator* are relevant to the *contract* block on the far right. These blocks formally capture the specifications and the behavior of a component
