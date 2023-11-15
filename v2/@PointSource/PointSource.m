classdef PointSource
    % Implements a point source object (either a "true" physical point 
    % source or an image source generated by a specular reflection). A true
    % source is regarded as a 0'th order image source.
    % 
    % A point source is defined by the following properties:
    % - location: x/y/z coordinates of the source
    % - emitted_signal: signal emitted by the source. For 0th order sources
    % this is directly assigned and can be arbitrarily picked. For N'th
    % order image sources (N > 0) the emitted signal is calculated by
    % processing the signal of an N-1'th order source through a surface
    % reflection.
    % - path: An ordered list of source/surface pairs of length N (where N
    % is the order of the image source, i.e. how many times it has been
    % reflected since the original source) that describes the "path" 
    % through which the image source was generated. Each element in the 
    % list contains a source/surface pair -> the i'th list element describes
    % the i-1'th order source and the i'th surface it was reflected on. 
    % The location of the N'th order source is contained in its "location"
    % property.
    % - segments: a list of line segments that make up the actual reflection
    % path from the true source to the N'th order source, connecting all
    % intersection points along the way. This is for plotting and debugging
    % purposes mainly
    % - idx: Index of the image source as it is generated - for debug
    % purposes
    % - order: The order N of the image source    

    properties
       location
       emitted_signal
       path
       segments
       idx     
       order
    end
    
    methods
        % Constructor - only the location is specified, the rest are set
        % later
        function obj = PointSource(location)            
            obj.location = location;                        
            obj.emitted_signal = [];
            obj.path = [];
            obj.segments = [];
            obj.idx = [];
            obj.order = [];
        end      
        
        % setter functions
        function obj = set_emitted_signal(obj, signal)
            obj.emitted_signal = signal;
        end
        function obj = set_path(obj, path)
            obj.path = path;
        end
        function obj = set_segments(obj, segments)
            obj.segments = segments;
        end
        function obj = set_idx(obj, idx)
            obj.idx = idx;
        end
        function obj = set_order(obj, order)
            obj.order = order;
        end

    end
    
end
