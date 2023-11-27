function obj = verify(obj)
% Verifies the following requirements for a RectangularSurface object:
% - The provided surface is a rectangle (all neighboring edges are at right
% angles)
% - The surface is parallel to at least one coordinate axis
% If any of the above is false, the function throws an error

    wp = obj.points;

    v1 = wp(2,:) - wp(1,:);
    v2 = wp(3,:) - wp(2,:);
    v3 = wp(4,:) - wp(3,:);
    v4 = wp(1,:) - wp(4,:);

    % check if neighboring edges are at right angle
    % dot products should give zero 
    if (v1*v2' ~= 0) || (v2*v3' ~= 0) || (v3*v4' ~= 0) || (v4*v1' ~= 0)
       error('ERROR: Surface nr. %d is not a rectangle.', obj.idx); 
    end

    % check if any edge is parallel to at least one coordinate axis
    % --> Angle between a vector v and the three unit axis vectors:
    % arccos(v*eye(3) / norm(v)) ==> v / norm(v);   
    try
        V = [v1' v2' v3' v4'];
        V = V ./ vecnorm(V);
    catch
        % vecnorm() doesn't work in Matlab R2016A
        V = [(v1 / norm(v1))'  (v2 / norm(v2))' (v3 / norm(v3))' (v4 / norm(v4))'];
    end
    % ---> at least one cosine should be +/- 1
    if (isempty(find(abs(V) == 1)))
        error('ERROR: Surface nr. %d is not parallel to any coordinate axis', obj.idx); 
    end

end
