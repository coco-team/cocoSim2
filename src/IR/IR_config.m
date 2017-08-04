%% The map contains BlockTypes associate with parameters the user want to print
% It helps to have a more refined internal representation

%% Parameters are in 2 lists :
% -The DialogParameters which can be changed by the dialog's box of Simulink
% -Other parameters

%% Some BlockTypes have little numbers of parameters and don't need to be filtered
% You can choice to do it anyway by concatenate their list to the Map
% (See documentation for the parameters list,
% you can get the DialogParameters of a block with get_param(block_path, 'DialogParameters')).
% if you only want to add some other parameters, you can put 'all' in the
% dialog one to not have to copy all the parameters

%% Here are the list of the BlockTypes not in the map :
% ZeroPole, Saturate, DiscreteStateSpace, UnitDelay, Memory,
% DiscreteZeroPole, Logic, RelationalOperator, LookupNDDirect,
% Bitwise Operator, Saturation Dynamic, Compare To Constant,
% Compare To Zero, Abs, Reshape, DotProduct, Signum, Gain, Polyval,
% MinMax, Sum, Bias, Concatenate, Rounding, Math, Sqrt, Trigonometry,
% Assignment, DataTypeConversion, SignalSpecification,
% Demux, Merge, Switch, From, Goto, BusSelector, BusCreator, BusAssignment,
% Selector, Terminator, ToWorkspace, Step, Constant, S-Function, Fcn,
% EnablePort, If, SwitchCase

% ForIterator et ActionPort introuvables

global block_param_map;

DiscreteIntegrator_param = struct();
DiscreteIntegrator_param.DialogParameters = {'IntegratorMethod', 'gainval',...
    'ExternalReset', 'InitialConditionSource', 'InitialCondition',...
    'LimitOutput', 'LowerSaturationLimit','UpperSaturationLimit'};
DiscreteIntegrator_param.Others = {};

Delay_param = struct();
Delay_param.DialogParameters = {'InitialCondition', 'DelayLength'};
Delay_param.Others = {};

DiscreteFilter_param = struct();
DiscreteFilter_param.DialogParameters = {'Numerator', 'Denominator',...
    'a0EqualsOne', 'InitialStates'};
DiscreteFilter_param.Others = {};

Mux_param = struct();
Mux_param.DialogParameters = {'Inputs', 'DisplayOption'};
Mux_param.Others = {'UseBusObject', 'BusObject', 'NonVirtualBus'};

MultiPortSwitch_param = struct();
MultiPortSwitch_param.DialogParameters = {'DataPortOrder', 'DataPortIndices'...
    'Inputs', 'DataPortForDefault', 'AllowDiffInputSizes'};
MultiPortSwitch_param.Others = {};

Scope_param = struct();
Scope_param.DialogParameters = {};
Scope_param.Others = {'Floating'};

Outport_param = struct();
Outport_param.DialogParameters = {'Port', 'CompiledPortDimensions', 'CompiledPortDataTypes'};
Outport_param.Others = {'UseBusObject', 'BusObject'};

Inport_param = struct();
Inport_param.DialogParameters = {'Port', 'CompiledPortDimensions', 'CompiledPortDataTypes'};
Inport_param.Others = {'UseBusObject', 'BusObject'};

Subsystem_param = struct();
Subsystem_param.DialogParameters = {'ShowPortLabels', 'TemplateBlock', 'Permissions', 'PermitHierarchicalResolution', 'TreatAsAtomicUnit',...
    'MinAlgLoopOccurrences', 'PropExecContextOutsideSubsystem', 'IsSubsystemVirtual'};
Subsystem_param.Others = {'DataTypeOverride', 'MinMaxOverflowLogging', 'Virtual', 'SFBlockType'};

TriggerPort_param = struct();
TriggerPort_param.DialogParameters = {'ShowOutputPort', 'TriggerType'};
TriggerPort_param.Others = {};

ModelReference_param = struct();
ModelReference_param.DialogParameters = {'all'};
ModelReference_param.Others = {'ProtectedModel', 'Variants', 'DefaultDataLogging'};

keySet = {'DiscreteIntegrator', 'Delay', 'DiscreteFilter', 'Mux',...
    'MultiPortSwitch', 'Scope', 'Outport', 'Inport', 'SubSystem',...
    'TriggerPort', 'ModelReference'};
valueSet = {DiscreteIntegrator_param, Delay_param, DiscreteFilter_param,...
    Mux_param, MultiPortSwitch_param, Scope_param, Outport_param, Inport_param, Subsystem_param, TriggerPort_param, ModelReference_param};
block_param_map = containers.Map(keySet, valueSet);