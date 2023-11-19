classdef SpecularStudio
    % TODO
    
    properties
       S             % Point source list
       R             % Receiver list (i.e. mic array)
       walls         % Room geometry
       sig_params    % Source signal parameters
       fs            % sampling rate
       c             % speed of sound
       len_s         % signal length in seconds
       max_order     % maximum reflection order to simulate
       % process flags
       do_plot_IRs
       do_plot_reflection_paths
       do_export_audio
    end
    
    methods
        function obj = SpecularStudio(source_list, mic_array, walls, sig_params, params)
            
           % --------------- General signal properties --------------- %
           obj.fs = params.fs;                 % sampling rate
           obj.c = params.c;                   % speed of sound
           obj.len_s = params.len_s;           % signal length in seconds
           
           % ----------- maximum reflection order to simulate --------- %
           obj.max_order = params.max_order;   
           
           % ----------- various process flags --------- %
           obj.do_plot_IRs = params.do_plot_IRs;
           obj.do_plot_reflection_paths = params.do_plot_reflection_paths;
           obj.do_export_audio = params.do_export_audio;
           
           % ------ geometry (room, sources, receivers) ----- %
           obj.S = source_list;
           obj.R = mic_array;
           obj.walls = walls;
           
           % ------ signals assigned to point sources
           obj.sig_params = sig_params;         
        end   
        
        % main simulation
        [x, y, ir] = run_simulation(obj);
        
        sig = generate_source_signals(obj);
        cnt = count_all_image_sources(obj);
        img_list = generate_image_sources(obj, P, max_order);
        img_list_valid = audibility_check(obj, img_list, i_rcv);
        [y, ir] = map_signals_to_receiver(obj, i_rcv, img_src_list);
        
        
        
        
    end
    
end