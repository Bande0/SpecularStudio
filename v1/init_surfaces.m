function walls = init_surfaces(walls)
% Initializes a list of surfaces
% calculates surface equation coefficients from the first 3 points and
% verifies that the 4th point is coplanar with the plane defined by the
% first three points
                                        
    for i = 1:length(walls)
        wp = walls(i).points;
        % define surface unit normal vector from its first 3 points
        v1 = wp(2,:) - wp(1,:);
        v2 = wp(3,:) - wp(1,:);
        n = cross(v1, v2);
        n = n/norm(n); % normalize to unit length (not necessary)      

        % calculate last surface coefficient (offset)
        D = -n*wp(1,:)';   

        % check if 4th point is coplanar:
        % -n*wp(4,:)' must equal D
        if abs(n*wp(4,:)' + D) > eps
           error('Error! Surface nr. %d is invalid: Point [%.3f %.3f %.3f] is not coplanar',...
                walls(i).idx, wp(4,1), wp(4,2), wp(4,3)); 
        end

        % store normal vector and offset in struct
        walls(i).D = D;
        walls(i).normal = n;
    end

end

