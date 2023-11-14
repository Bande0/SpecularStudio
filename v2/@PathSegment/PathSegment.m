classdef PathSegment
    % Implements a path segment object
    % A list of PathSegment objects constitute a reflection path -
    % containing the locations of each image source and each surface they
    % have been reflected on along the way

    properties
       location   % x/y/z coordinates of the mirrored source
       wall       % RectangularSurface object that the source described in "location" was mirrored across
    end
    
    methods

        function obj = PathSegment(location, wall)            
            obj.location = location;
            obj.wall = wall;
        end 
        
    end
    
end

