classdef SpecularStudio
    % TODO
    
    properties
       S           % Point source list
       R           % Receiver list (i.e. mic array)
       room        % Room geometry
       sig_params  % general signal properties
    end
    
    methods
        function obj = SpecularStudio(source_list, mic_array, room, sig_params)
            
           % --------------- General signal properties --------------- %
           obj.sig_params.fs = sig_params.fs;       % sampling rate
           obj.sig_params.c = sig_params.c;         % speed of sound
           obj.sig_params.len_s = sig_params.len_s; % signal length in seconds
           
           obj.S = source_list;
           obj.R = mic_array;
           obj.room = room;
        end       
        
    end
    
end