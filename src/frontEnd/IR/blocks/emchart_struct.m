function [StateflowContentStruct] = emchart_struct(emchartPath)
    StateflowContentStruct = {};
    blockObject = find(slroot, '-isa', 'Stateflow.EMChart', 'Path', emchartPath);
    StateflowContentStruct.Script = blockObject.Script;
    for index = 1 : length(blockObject.Inputs)       
        StateflowContentStruct.Inputs{index} = ...
            buildDataStruct(blockObject.Inputs(index));
    end
    for index = 1 : length(blockObject.Outputs)       
        StateflowContentStruct.Outputs{index} = ...
            buildDataStruct(blockObject.Outputs(index));
    end
end

function dataStruct = buildDataStruct(data)
    dataStruct.Id = data.id;
    dataStruct.Name = data.name;
    dataStruct.Datatype = data.DataType;
    dataStruct.CompiledType = data.CompiledType;
    dataStruct.Port = data.Port;
    dataStruct.Scope = data.scope;
    dataStruct.ArraySize = data.Props.Array.Size;
    dataStruct.CompiledSize = data.CompiledSize;
end
