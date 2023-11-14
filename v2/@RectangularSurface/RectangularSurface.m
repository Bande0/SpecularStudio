classdef RectangularSurface
    % Implements a reflective rectangular surface object
    % A reflective surface is defined by its four cornerpoints and its
    % absorption parameters (currently, a single attenuation coefficient
    % between 0.0 and 1.0). 
    %
    % A RectangularSurface must:
    % - Have four cornerpoints that are coplanar
    % - Be a rectangle (all neighboring edges at right angles)
    % - Be parallel to at least one coordinate axis (this is required due
    % to the simplifed way of calculating an intersection point between a
    % surface segment and a line segment

    properties
       points     % list of 4 points defining the corners
       abs_coeff  % absorption coefficient 
       normal     % normal vector
       D          % D coefficient (offset)
       idx        % ID index
    end
    
    methods
        function obj = RectangularSurface(idx, Point_1, Point_2, Point_3, Point_4, abs_param)
            if nargin > 4
              obj.abs_coeff = abs_param;
            else
              obj.abs_coeff = 1.0;
            end
            
            obj.idx = idx;
            obj.points = [Point_1; Point_2; Point_3; Point_4];
            
            % initialize and verify surfaces
            obj = obj.init();
            % We run this extra check now, since in this simple simulator, intersection
            % points are only calculated correctly for surfaces that are rectangles and
            % are parallel to at least one coordinate axis
            obj = obj.verify();
        end       
      
        % initialization + verifying requirements on whether points are
        % coplanar and whether the rectangle is parallel to at least one
        % axis
        obj = init(obj);
        obj = verify(obj);
        
        % mirroring and absorption
        [P_int, contains] = intersect(obj, P1, P2);
        [P_m, P_int] = mirror_point(obj, P);
        sig_out = absorb(obj, sig_in);
        
    end
    
end