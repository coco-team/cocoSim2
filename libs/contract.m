function contract(block)
    setup(block);
end

%% Function: setup 
%% Abstract:
%%   Set up the basic characteristics of the S-function block such as:
%%   - Input ports
%%   - Output ports
%%   - Dialog parameters
%%   - Options
%%
function setup(block)

    % Register number of ports
    values = get_param(block.BlockHandle,'MaskValues');
    
    % disable the library link 
    contractBlock = get_param(block.BlockHandle, 'Parent');    
    set_param(contractBlock, 'LinkStatus', 'inactive');

    % get the size of input ports
    assumePorts = str2num(char(values(1)));
    guaranteePorts = str2num(char(values(2)));
    modePorts = str2num(char(values(3)));
    block.NumInputPorts  = assumePorts + guaranteePorts + modePorts;
    % only a single output port for the validator
    block.NumOutputPorts = 1;

    % all ports are boolean
    for i = 1 : block.NumInputPorts
        block.InputPort(i).DatatypeID = 8; %'boolean';
    end    
    
    block.OutputPort(1).DatatypeID = 8; %'boolean';
    
    
    % Setup port properties to be inherited or dynamic
    block.SetPreCompInpPortInfoToDynamic;
    block.SetPreCompOutPortInfoToDynamic;

    % Register parameters
    block.NumDialogPrms     = 0;

    % Register sample times
    %  [0 offset]            : Continuous sample time
    %  [positive_num offset] : Discrete sample time
    %
    %  [-1, 0]               : Inherited sample time
    %  [-2, 0]               : Variable sample time
    block.SampleTimes = [0 0];


    %% The MATLAB S-function uses an internal registry for all
    %% block methods. You should register all relevant methods
    %% (optional and required) as illustrated below. You may choose
    %% any suitable name for the methods and implement these methods
    %% as local functions within the same file. See comments
    %% provided for each function for more information.
    %% -----------------------------------------------------------------

    block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
    block.RegBlockMethod('Start', @Start);
    block.RegBlockMethod('Update', @Update);
    block.RegBlockMethod('Outputs', @Outputs);     % Required
    block.RegBlockMethod('SetInputPortSamplingMode',@SetInputPortSamplingMode);
    block.RegBlockMethod('Terminate', @Terminate); % Required
        
end

%%
%% PostPropagationSetup:
%%   Functionality    : Setup work areas and state variables. Can
%%                      also register run-time methods here
%%   Required         : No
%%   C-Mex counterpart: mdlSetWorkWidths
%%
function DoPostPropSetup(block)
    block.NumDworks = 1;  
    block.Dwork(1).Name            = 'sofar';
    block.Dwork(1).Dimensions      = 1;
    block.Dwork(1).DatatypeID      = 8;      % boolean  
    block.Dwork(1).Complexity      = 'Real';
    block.Dwork(1).UsedAsDiscState = true;
end
%%
%% Start:
%%   Functionality    : Called once at start of model execution. If you
%%                      have states that should be initialized once, this 
%%                      is the place to do it.
%%   Required         : No
%%   C-MEX counterpart: mdlStart
%%
function Start(block) 
    block.Dwork(1).Data = true;
end

%%
%% Update:
%%   Functionality    : Called to update discrete states
%%                      during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlUpdate
%%
function Update(block)
    assume = getAssumeResult(block);
    block.Dwork(1).Data = block.Dwork(1).Data & assume;
end
%end Update

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
function Outputs(block)

    values = get_param(block.BlockHandle,'MaskValues');
    assumePorts = str2num(char(values(1)));
    guaranteePorts = str2num(char(values(2)));
    modePorts = str2num(char(values(3)));

    assume = getAssumeResult(block);
    
    index = assumePorts;
    % aggregate the logical AND of all guarantee ports
    guarantee = 1;
    for i = 1 : guaranteePorts
        index = index + 1;
        guarantee = guarantee & block.InputPort(index).Data;
    end

    % aggregate the logical AND of all mode ports
    mode = 1;
    for i = 1 : mode
        index = index + 1;
        mode = mode & block.InputPort(index).Data;
    end

    % output = assumption so far => (guarantees and modes)    
    output = (~(block.Dwork(1).Data & assume))|(guarantee & mode);   
    block.OutputPort(1).Data = output;
end


%% Set the sampling of the input ports
function SetInputPortSamplingMode(block, idx, fd)
    block.InputPort(idx).SamplingMode = fd;

    for i = 1 : block.NumOutputPorts
        block.OutputPort(i).SamplingMode = fd;
    end
end

%%
%% Terminate:
%% Called at the end of simulation for cleanup
function Terminate(block)

end

function assume = getAssumeResult(block)
    values = get_param(block.BlockHandle,'MaskValues');
    assumePorts = str2num(char(values(1)));

    index = 0;
    % aggregate the logical AND of all assume ports
    assume = 1;
    for i = 1 : assumePorts
        index = index + 1;
        assume = assume & block.InputPort(index).Data;
    end
end

