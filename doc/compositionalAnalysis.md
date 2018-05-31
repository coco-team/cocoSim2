# Compositional analysis

When verifying a subsystem, compositional analysis consists in abstracting the complexity of the underlying 
subsystems by their contracts. The idea is that the contract has typically a lot less state than the subsystem it specifies, which in 
addition to its own state contains that of its underlying subsystems recursively. Compositional reasoning thus improves the scalability 
of CoCosim by taking advantage of information provided by the user to abstract the complexity away. When in compositional analysis option 
is enabled, CoCosim will abstract all underlying subsystems with contracts in the top subsystem and verify the resulting, abstract system.
