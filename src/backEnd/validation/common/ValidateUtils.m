classdef ValidateUtils
    methods (Static = true)
        
        function vector = construct_random_integers(nb_iterations, IMIN, IMAX, dt, dim)
            if numel(dim)==1
                vector = randi([IMIN, IMAX], [nb_iterations,dim],dt);
            else
                vector = randi([IMIN, IMAX], [dim,nb_iterations],dt);
            end
        end
        
        function vector = construct_random_booleans(nb_iterations, IMIN, IMAX, dim)
            vector = boolean(Utils.construct_random_integers(nb_iterations, IMIN, IMAX, 'uint8',dim));
        end
        
        function vector = construct_random_doubles(nb_iterations, IMIN, IMAX,dim)
            if numel(dim)==1
                vector = double(IMIN + (IMAX-IMIN).*rand([nb_iterations,dim]));
            else
                vector = double(IMIN + (IMAX-IMIN).*rand([dim, nb_iterations]));
            end
        end
    end
end


