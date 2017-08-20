function block_name = get_block_name_from_variable_using_xRoot(xRoot, node_name, var_name)
%GET_BLOCK_NAME_FROM_VARIABLE_USING_XROOT
%this function help to get the name of Simulink block from lustre
%variable name, using the generated tracability by Cocosim.

block_name = '';
nodes = xRoot.getElementsByTagName('Node');
for idx_node=0:nodes.getLength-1
    block_name_node = nodes.item(idx_node).getAttribute('node_name');
    if strcmp(block_name_node, node_name)
        inputs = nodes.item(idx_node).getElementsByTagName('Input');
        for idx_input=0:inputs.getLength-1
            input = inputs.item(idx_input);
            if strcmp(input.getAttribute('variable'), var_name)
                block = input.getElementsByTagName('block_name');
                block_name = char(block.item(0).getFirstChild.getData);
                return;
            end
        end
        outputs = nodes.item(idx_node).getElementsByTagName('Output');
        for idx_output=0:outputs.getLength-1
            output = outputs.item(idx_output);
            if strcmp(output.getAttribute('variable'), var_name)
                block = output.getElementsByTagName('block_name');
                block_name = char(block.item(0).getFirstChild.getData);
                return;
            end
        end
    end
end
end

