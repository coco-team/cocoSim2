%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2018  The university of Iowa
% Author: Mudathir Mahgoub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef Kind2Utils   
    
    methods(Static)
        function [kind2Output] = simulate(lustreFile, inputsFile)
             [CoCoSimPreferences, KIND2, Z3] = Kind2Utils.checkAvailability();      

            [file_path,file_name,extension] = fileparts(lustreFile);   
            [~,inputsName,inputsExtension] = fileparts(inputsFile);   
            inputsFileName = [inputsName inputsExtension];

            % local binary
            if strcmp(CoCoSimPreferences.kind2Binary, 'Local')               
                
                command = sprintf('%s --z3_bin %s -xml  "%s"  --enable interpreter --interpreter_input_file "%s"',...
                    KIND2, Z3,  lustreFile, inputsFile);

                display_msg(['KIND2_COMMAND ' command], Constants.DEBUG, 'write_code', '');
                [~, kind2Output] = system(command);
                display_msg(kind2Output, Constants.DEBUG, 'write_code', '');                
            end          


            % docker binary
            if strcmp(CoCoSimPreferences.kind2Binary, 'Docker')
                
               command = sprintf('docker run -v %s:/lus kind2/kind2:dev /lus/%s --enable interpreter --interpreter_input_file /lus/%s -xml',...
                        file_path, [file_name extension], inputsFileName);               

                display_msg(['KIND2_COMMAND ' command], Constants.DEBUG, 'write_code', '');
                [~, kind2Output] = system(command);
                display_msg(kind2Output, Constants.DEBUG, 'write_code', '');                
            end        

            % call kind2  web server
            if strcmp(CoCoSimPreferences.kind2Binary, 'Kind2 web service')            
                postUrl = 'http://kind.cs.uiowa.edu:8080/kindservices/verify';
                data = {};
                % read the lustre code from the file
                data.code = fileread(lustreFile);                
                data.arguments.smt_solver = 'Z3';
                data.arguments.timeout = str2num(timeout);
                data.arguments.modular = 'true';

                if CoCoSimPreferences.compositionalAnalysis
                    data.arguments.compositional = 'true';
                end

                options = weboptions('MediaType','application/json');
                postResponse = webwrite(postUrl,data,options);

                % pause for one second
                pause(1);
                getUrl = strcat('http://kind.cs.uiowa.edu:8080/kindservices/getRawResults/',postResponse.jobId);
                getResponse = webread(getUrl);
                while getResponse.jobFinished == 0
                    % pause for one second
                    pause(1);
                    getResponse = webread(getUrl);
                end
                kind2Output = getResponse.data;
                display_msg(kind2Output, Constants.DEBUG, 'write_code', '');      
            end                
        end % simulate
        
        function [kind2Output] = verify(lustreFile, arguments)
            
            [CoCoSimPreferences, KIND2, Z3] = Kind2Utils.checkAvailability();      
            
            timeout = num2str(CoCoSimPreferences.verificationTimeout);
            
            [file_path,file_name,extension] = fileparts(lustreFile);      

            % local binary
            if strcmp(CoCoSimPreferences.kind2Binary, 'Local')
                % check whether to use compositional analysis
                if CoCoSimPreferences.compositionalAnalysis
                    command = sprintf('%s --z3_bin %s -xml --timeout %s %s "%s" --modular true --compositional true',...
                        KIND2, Z3, timeout, arguments, lustreFile);
                else
                    command = sprintf('%s --z3_bin %s -xml --timeout %s %s "%s" --modular true',...
                        KIND2, Z3, timeout, arguments, lustreFile);
                end

                display_msg(['KIND2_COMMAND ' command], Constants.DEBUG, 'write_code', '');
                [~, kind2Output] = system(command);
                display_msg(kind2Output, Constants.DEBUG, 'write_code', '');                
            end          


            % docker binary
            if strcmp(CoCoSimPreferences.kind2Binary, 'Docker')
                % check whether to use compositional analysis
                if CoCoSimPreferences.compositionalAnalysis
                    command = sprintf('docker run -v %s:/lus kind2/kind2:dev /lus/%s -xml --timeout %s --modular true --compositional true',...
                        file_path, [file_name extension], timeout);
                else
                     command = sprintf('docker run -v %s:/lus kind2/kind2:dev /lus/%s -xml --timeout %s --modular true',...
                        file_path, [file_name extension], timeout);
                end

                display_msg(['KIND2_COMMAND ' command], Constants.DEBUG, 'write_code', '');
                [~, kind2Output] = system(command);
                display_msg(kind2Output, Constants.DEBUG, 'write_code', '');                
            end        

            % call kind2  web server
            if strcmp(CoCoSimPreferences.kind2Binary, 'Kind2 web service')            
                postUrl = 'http://kind.cs.uiowa.edu:8080/kindservices/verify';
                data = {};
                % read the lustre code from the file
                data.code = fileread(lustreFile);                
                data.arguments.smt_solver = 'Z3';
                data.arguments.timeout = timeout;
                data.arguments.modular = 'true';

                if CoCoSimPreferences.compositionalAnalysis
                    data.arguments.compositional = 'true';
                end

                options = weboptions('MediaType','application/json');
                postResponse = webwrite(postUrl,data,options);

                % pause for one second
                pause(1);
                getUrl = strcat('http://kind.cs.uiowa.edu:8080/kindservices/getRawResults/',postResponse.jobId);
                getResponse = webread(getUrl);
                while getResponse.jobFinished == 0
                    % pause for one second
                    pause(1);
                    getResponse = webread(getUrl);
                end
                kind2Output = getResponse.data;
                display_msg(kind2Output, Constants.DEBUG, 'write_code', '');      
            end                
        end % verify
        
        
        function [CoCoSimPreferences,KIND2, Z3] = checkAvailability()
            
            [KIND2, Z3] =  Kind2Utils.loadConfig(); 
            % load preferences
            CoCoSimPreferences = loadCoCoSimPreferences();

            if (exist(KIND2,'file') && exist(Z3,'file')) || ...
                    strcmp(CoCoSimPreferences.kind2Binary, 'Kind2 web service') || ...
                    strcmp(CoCoSimPreferences.kind2Binary, 'Docker') 

            else
                msg = 'Kind2: Impossible to find Kind2';
                error(msg);    
            end 
        end % checkAvailability
        
        function [KIND2, Z3]= loadConfig()
            [file_path, ~, ~] = fileparts(mfilename('fullpath'));
                
                cocosim_path = fileparts(file_path);
                cocosim_path = fileparts(cocosim_path);
                cocosim_path = fileparts(cocosim_path);
            if ismac
                solvers_path = fullfile(cocosim_path, 'tools/verifiers/osx/bin/');               
            elseif isunix
                solvers_path = fullfile(cocosim_path, 'tools/verifiers/linux/bin/');               
             elseif ispc       
                 solvers_path = fullfile(cocosim_path, 'tools\verifiers\');                
            else
                error('CoCoSim backend configuration: OS not supported yet');
            end
            
            Z3 = fullfile(solvers_path,'z3');
            KIND2 = fullfile(solvers_path,'kind2');
        end %loadConfig
        
                
        function [simulationStruct] = parseSimulation(kind2XmlOutput)
            xmlDocument = xmlread(kind2XmlOutput);
            xmlExecutionElement = xmlDocument.getElementsByTagName('Execution').item(0);    
            simulationStruct = {};    
            nodeElement = xmlExecutionElement.getElementsByTagName('Node').item(0); 
            simulationStruct.node = Kind2Utils.parseSimulationNode(nodeElement);        
        end % 

        function [nodeStruct] = parseSimulationNode(nodeElement)
            nodeStruct = {};
            nodeStruct.name = char(nodeElement.getAttribute('name'));  
            children = nodeElement.getChildNodes;        
            streamIndex = 0;
            nodeIndex = 0;

            for childIndex = 0 : (children.getLength - 1)

                xmlElement = children.item(childIndex);

                if strcmp(xmlElement.getNodeName,'Stream')                                              
                    streamStruct = {};    
                    streamStruct.class = char(xmlElement.getAttribute('class')); 
                    % for simulation, we only need the output
                    if ~strcmp(streamStruct.class, 'output')
                        continue;
                    end
                    streamStruct.name = char(xmlElement.getAttribute('name'));
                    streamStruct.type = char(xmlElement.getAttribute('type'));                              
                    valueElements = xmlElement.getElementsByTagName('Value');
                    streamStruct.values = [];
                    nodeStruct.timeSteps = valueElements.getLength;
                    for valueIndex=0:(valueElements.getLength-1)
                        value = char(valueElements.item(valueIndex).getTextContent);
                        if strcmp(value, 'false')
                            streamStruct.values(valueIndex + 1) = false;
                        elseif strcmp(value, 'true')
                            streamStruct.values(valueIndex + 1) = true;
                        else
                            streamStruct.values(valueIndex + 1) = str2num(value);
                        end
                    end
                    streamIndex = streamIndex + 1;
                    nodeStruct.streams{streamIndex} = streamStruct;    
                elseif strcmp(xmlElement.getNodeName,'Node')   
                    % for parsing nested nodes and their streams inside
                    % the counter example            
                    nestedNodeStruct = Kind2Utils.parseSimulationNode(xmlElement);
                    nodeIndex = nodeIndex + 1;
                    nodeStruct.nodes{nodeIndex} = nestedNodeStruct;   
                end            
            end        
        end  %        
    end
end

