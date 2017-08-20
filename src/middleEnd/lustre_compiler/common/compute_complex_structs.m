function [ complex_structs ] = compute_complex_structs( ir_struct, file_name )
%COMPUTE_COMPLEX_STRUCTS

fields = fieldnames(ir_struct.(file_name).Content);
fields(cellfun('isempty', regexprep(fields, '^Annotation.*', ''))) = [];
complex_data = {};

for i=1:numel(fields)
    sub_blk = ir_struct.(file_name).Content.(fields{i});
    indexes_in = find(sub_blk.CompiledPortComplexSignals.Inport);
    [inport_complex_data] = sub_blk.CompiledPortDataTypes.Inport(indexes_in);
    indexes_out = find(sub_blk.CompiledPortComplexSignals.Outport);
    [outport_complex_data] = sub_blk.CompiledPortDataTypes.Outport(indexes_out);
    complex_data = [complex_data inport_complex_data outport_complex_data];
end

complex_data = unique(complex_data);
for i=1:numel(complex_data)
    complex_data{i} = LusUtils.get_lustre_dt(complex_data{i});
end
complex_data = unique(complex_data);

complex_structs = '';
for i=1:numel(complex_data)
    complex_structs = [complex_structs BusUtils.get_complex_struct(complex_data{i})];
end

end

