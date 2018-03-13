function link_process( new_model_base )
%LINK_PROCESS disable all links

lib_ss=libinfo (new_model_base);
if not(isempty(lib_ss))
    display_msg('Processing links', MsgType.INFO, 'PP', '');
    for i=1:length(lib_ss)
        %disp(lib_ss(i))
        try
            set_param(lib_ss(i).Block,'LinkStatus','none')
        catch
        end
    end
    display_msg('Done\n\n', MsgType.INFO, 'PP', '');
end


end

