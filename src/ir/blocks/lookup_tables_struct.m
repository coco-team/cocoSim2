function [ S ] = lookup_tables_struct( file_name, block_type )
%Non supporté : 'Lookup_n-D', 'Interpolation_n-D',
%    'PreLookup'

S = struct();

if strcmp(block_type, 'LookupNDDirect')
    S.NumberOfTableDimensions = get_param(file_name, 'NumberOfTableDimensions');
    S.InputsSelectThisObjectFromTable = get_param(file_name, 'InputsSelectThisObjectFromTable');
    S.TableIsInput = get_param(file_name, 'TableIsInput');
    S.Table = get_param(file_name, 'Table');
end
end

