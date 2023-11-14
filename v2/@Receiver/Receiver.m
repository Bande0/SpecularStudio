classdef Receiver
    % Implements a receiver (i.e. microphone) object 
    % 
    % Currently only contains location information

    properties
       location
    end
    
    methods

        function obj = Receiver(location)            
            obj.location = location;
        end 
        
    end
    
end

