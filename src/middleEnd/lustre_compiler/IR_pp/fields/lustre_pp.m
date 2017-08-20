function [ new_ir ] = lustre_pp( new_ir )
% LUSTRE_PP

% Model's name
model_path = new_ir.meta.file_path;
[~, model_name, ~] = fileparts(model_path);
[ new_ir ] = lustre_pp_aux( new_ir, model_name );
end

function [ new_ir ] = lustre_pp_aux( old_ir, model_name )
% LUSTRE_PP
write_config;

new_ir = old_ir;
if nargin >= 2
    ir_struct = old_ir.(model_name);
else
    ir_struct = old_ir;
end

fields = fieldnames(ir_struct.Content);
fields(cellfun('isempty', regexprep(fields, '^Annotation.*', ''))) = [];
for i=1:numel(fields)
    sub_blk = ir_struct.Content.(fields{i});
    
    % Pre and Post
    ir_struct.Content.(fields{i}).Pre = [sub_blk.PortConnectivity.SrcBlock];
    ir_struct.Content.(fields{i}).Post = [sub_blk.PortConnectivity.DstBlock];
    % name_level
    ir_struct.Content.(fields{i}).name_level = 0;
    
    % action, trigger and enable
    indexes = find(arrayfun(@(x) strcmp(x.Type, 'ifaction'), sub_blk.PortConnectivity));
    if ~isempty(indexes)
        ir_struct.Content.(fields{i}).action = sub_blk.PortConnectivity(indexes).SrcBlock;
        ir_struct.Content.(fields{i}).actionport = sub_blk.PortConnectivity(indexes).SrcPort;
    else
        ir_struct.Content.(fields{i}).action = [];
        ir_struct.Content.(fields{i}).actionport = [];
    end
    indexes = find(arrayfun(@(x) strcmp(x.Type, 'trigger'), sub_blk.PortConnectivity));
    if ~isempty(indexes)
        ir_struct.Content.(fields{i}).trigger = sub_blk.PortConnectivity(indexes).SrcBlock;
        ir_struct.Content.(fields{i}).triggerport = sub_blk.PortConnectivity(indexes).SrcPort;
    else
        ir_struct.Content.(fields{i}).trigger = [];
        ir_struct.Content.(fields{i}).triggerport = [];
    end
    indexes = find(arrayfun(@(x) strcmp(x.Type, 'enable'), sub_blk.PortConnectivity));
    if ~isempty(indexes)
        ir_struct.Content.(fields{i}).enable = sub_blk.PortConnectivity(indexes).SrcBlock;
        ir_struct.Content.(fields{i}).enableport = sub_blk.PortConnectivity(indexes).SrcPort;
    else
        ir_struct.Content.(fields{i}).enable = [];
        ir_struct.Content.(fields{i}).enableport = [];
    end
    
    if BlockUtils.needs_zero_rounding(sub_blk.BlockType)
        ir_struct.Content.(fields{i}).RndMeth = 'Zero';
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% name_level
    if strcmp(sub_blk.BlockType, 'SubSystem') && strcmp(sub_blk.IsSubsystemVirtual, 'on')
        fields_sub = fieldnames(sub_blk.Content);
        fields_sub(cellfun('isempty', regexprep(fields_sub, '^Annotation.*', ''))) = [];
        fields_sub = fields_sub(sub_blk.Ports(1):(end-sub_blk.Ports(2)));
        for j=1:numel(fields_sub)
            if isfield(ir_struct.Content.(fields{i}).Content.(fields_sub{j}), 'name_level')
                ir_struct.Content.(fields{i}).Content.(fields_sub{j}).name_level = ir_struct.Content.(fields{i}).Content.(fields_sub{j}).name_level + 1;
            else
                ir_struct.Content.(fields{i}).Content.(fields_sub{j}).name_level = 1;
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%% Verify for what that is (cf flatten_subsystems...)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%% Verify that it is that or not
    if strcmp(sub_blk.BlockType, 'ModelReference')
        ir_struct.Content.(fields{i}).isref = true;
    else
        ir_struct.Content.(fields{i}).isref = false;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmp(sub_blk.BlockType, 'SubSystem') || strcmp(sub_blk.BlockType, 'ModelReference')
        if ~strcmp(sub_blk.MaskType, '')
            % check if the block is handled. If not, we open it like a
            % subsystem to have the blocks inside, because they could be handled
            if isKey(write_func_map, sub_blk.MaskType)
                func_name = write_func_map(type);
            else
                func_name = ['write_' blockType_format(sub_blk.MaskType)];
            end
            % Block handled, so we won't open it. Remove its Content
            if exist(func_name, 'file')
                ir_struct.Content.(fields{i}) = rmfield(ir_struct.Content.(fields{i}), 'Content');
                sub_blk = ir_struct.Content.(fields{i});
            end
        end
        if isfield(sub_blk, 'Content')
            fields_sub = fieldnames(sub_blk.Content);
            fields_sub(cellfun('isempty', regexprep(fields_sub, '^Annotation.*', ''))) = [];
            ir_struct.Content.(fields{i}).foriter = false;
            found = false;
            j = 1;
            while j <= numel(fields_sub) && ~found
                if strcmp(sub_blk.Content.(fields_sub{j}).BlockType, 'ForIterator')
                    found = true;
                    ir_struct.Content.(fields{i}).foriter = true;
                end
                j = j + 1;
            end
            
            found = false;
            j = 1;
            ir_struct.Content.(fields{i}).enable_reset = false;
            while j <= numel(fields_sub) && ~found
                block = sub_blk.Content.(fields_sub{j});
                if strcmp(block.BlockType, 'EnablePort');
                    enable_block = block;
                    found = true;
                    ir_struct.Content.(fields{i}).enable_reset = (strcmp(enable_block.StatesWhenEnabling, 'reset'));
                end
                j = j+1;
            end
            
            found = false;
            j = 1;
            ir_struct.Content.(fields{i}).action_reset = false;
            while j <= numel(fields_sub) && ~found
                block = sub_blk.Content.(fields_sub{j});
                if strcmp(block.BlockType, 'ActionPort');
                    action_block = block;
                    found = true;
                    ir_struct.Content.(fields{i}).action_reset = (strcmp(action_block.InitializeStates, 'reset'));
                end
                j = j+1;
            end
            
            found = false;
            j = 1;
            ir_struct.Content.(fields{i}).foriter_reset = false;
            while j <= numel(fields_sub) && ~found
                block = sub_blk.Content.(fields_sub{j});
                if strcmp(block.BlockType, 'ForIterator');
                    foriter_block = block;
                    found = true;
                    ir_struct.Content.(fields{i}).foriter_reset = (strcmp(foriter_block.ResetStates, 'reset'));
                end
                j = j+1;
            end
        end
    end
    if isfield(sub_blk, 'Content')
        ir_struct.Content.(fields{i}) = lustre_pp_aux(ir_struct.Content.(fields{i}));
    end
end

if nargin >= 2
    new_ir.(model_name) = ir_struct;
else
    new_ir = ir_struct;
end
end

