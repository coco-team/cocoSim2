%% The map contains BlockTypes associate with parameters the user want to add in the IR
% It helps to have a more refined internal representation
% Only the specified parameters in the map for the specified BlockType
% will be in the IR
% You can also add common parameters in the 'CommonParameters's values at the end if you
% want
% There are also an UnwantedParameters list. It is any Parameters common or not, that
% you don't want to be in the IR because they are not relevant. Be aware
% that this will take effect on the entire IR. To disable all the comments,
% simply put 'Annotation' in it.
% You can find all Specific Parameters and/or Common properties of the blocks in the official documentation. 

%% Default
% If a BlockType doesn't appear in the map, by default, all (and only) the
% dialogParameters will be in the internal representation.
% If you want to add other specific parameters of a block, or filter the
% dialog parameters represented in the IR, you can concatenate the list of
% your choosen parameters in the map
% (see the documentation for the list of specific parameters of a block,
% you can do get_param(block_path, 'DialogParameters') to get all the
% dialog parameters of a block)
% If 'CommonParameters' doesn't appear in the map, only the basics one will
% be in the IR (Name, BlockType, handle, LineHandles)

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

global block_param_map stateflow_treatment;

block_param_map = containers.Map();

%% Add new specific parameters associated to a specific block here
block_param_map('DiscreteIntegrator') = {'IntegratorMethod', 'gainval',...
    'ExternalReset', 'InitialConditionSource', 'InitialCondition',...
    'LimitOutput', 'LowerSaturationLimit','UpperSaturationLimit'};


block_param_map('DiscreteFilter') = {'Numerator', 'Denominator',...
    'a0EqualsOne', 'InitialStates'};

block_param_map('Mux') = {'Inputs', 'DisplayOption', 'UseBusObject', 'BusObject', 'NonVirtualBus'};

block_param_map('MultiPortSwitch') = {'DataPortOrder', 'DataPortIndices'...
    'Inputs', 'DataPortForDefault', 'AllowDiffInputSizes' 'RndMeth', 'SaturateOnIntegerOverflow'};

block_param_map('Scope') = {'Floating'};

block_param_map('Outport') = {'Port', 'CompiledPortDimensions', 'CompiledPortDataTypes', 'UseBusObject', 'BusObject', 'OutputWhenDisabled', 'InitialOutput'};

block_param_map('Inport') = {'Port', 'CompiledPortDimensions', 'CompiledPortDataTypes', 'UseBusObject', 'BusObject'};

block_param_map('SubSystem') = {'ShowPortLabels', 'TemplateBlock', 'Permissions', 'PermitHierarchicalResolution', 'TreatAsAtomicUnit',...
    'MinAlgLoopOccurrences', 'PropExecContextOutsideSubsystem', 'IsSubsystemVirtual', 'DataTypeOverride', 'MinMaxOverflowLogging', 'Virtual', 'SFBlockType'};

block_param_map('TriggerPort') = {'ShowOutputPort', 'TriggerType'};

block_param_map('ModelReference') = {'ModelNameDialog', 'ModelFile', 'ModelName', 'ParameterArgumentNames', 'ParameterArgumentValues',...
    'SimulationMode', 'CodeInterface', 'Variant', 'VariantControl', 'OverrideUsingVariant', 'ActiveVariant',...
    'GeneratePreprocessorConditionals', 'ProtectedModel', 'Variants', 'DefaultDataLogging'};

%% Add not wanted parameters here
block_param_map('UnwantedParameters') = {'IconShape'};

%% Add common parameters here
block_param_map('CommonParameters') = {'CompiledSampleTime', 'CompiledPortDataTypes', 'CompiledPortDimensions', 'CompiledPortWidths', 'CompiledPortComplexSignals', 'PortConnectivity', 'Ports', 'Position', 'AttributesFormatString'};

%% Stateflow Treatment
stateflow_treatment = {'chart_struct'};
