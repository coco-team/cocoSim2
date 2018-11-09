classdef Days < Simulink.IntEnumType
  enumeration
    Sunday(1)
    Monday(2)
    Tuesday(3) 
    Wednesday(4)
    Thursday(5)
    Friday(6)
    Saturday(7)
  end
%   methods(Static)
%       function retVal = getDefaultValue()
%           % GETDEFAULTVALUE Specifies the default enumeration member.
%           % Return a valid member of this enumeration class to specify the default.
%           % If you do not define this method, Simulink uses the first member.
%           retVal = Days.Monday;
%       end
%   end
end 