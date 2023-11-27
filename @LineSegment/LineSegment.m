classdef LineSegment
    % Implements a line segment object
    % A line segment is defined by its two endpoints

    properties
       % x/y/z coordinates of the endpoints
       start_point  
       end_point  
    end
    
    methods

        function obj = LineSegment(start_point, end_point)            
            obj.start_point = start_point;
            obj.end_point = end_point;
        end 
        
    end
    
end



