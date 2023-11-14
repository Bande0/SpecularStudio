function [P_int, contains] = intersect(obj, P1, P2)
% Calculates the coordinates of the intersection point between a line
% segment connecting P1 and P2 and the RectangularSurface object
%
% Returns:
% P_int:    x/y/z coordinates of the intersection point of the INFINITE line 
%           defined by P1 and P2 and the INFINITE plane defined by 
%           the RectangularSurface object.
%           If (and only if) the infinite line and infinite surface don't 
%           intersect (i.e. they are parallel), the returned coordinates 
%           will be Inf, -Inf or NaN.
% contains: boolean indicating whether the intersection point is contained 
%           within the line segment / RectangulatSurface object.

    % bool indicating whether or not the intersect point is inside the line
    % segment and the surface segment
    contains = 1;
    
    % surface normal vector and offset coefficient
    n = obj.normal;
    D = obj.D;

    % direction vector of line connecting P1 and P2
    d = P2 - P1;
    % Inteserct point fulfills the following equations:
    % 1) P_int = P1 + k*d (original point + some constant times the direction vector)
    % 2) n*P_int' + D = 0 (the surface equation)
    % --> substitute 1) int 2) and solve for k 
    k = -(n*P1' + D)./(n*d');
    P_int = P1 + k*d;
    
    % Now P_int is the point that is the intersection between the INFINITE
    % line defined by P1 and P2 and the INFINITE plane defined by W.
    % The code below checks whether the intersection point actually lies on
    % the plane section and the line section, or outside
    
    % if k < 0 --> intersect point is outside the line segment on the P1 side
    % if k > 1 --> intersect point is outside the line segment ont the P2 side 
    % equality means that the intersect point is the same as one of the
    % original points
    % OBS: we DON'T regard equality as an intersection
    % OBS: equality is not always exactly fulfilled due to numerical
    % precision - threshold value found empirically    
    thresh = 2*eps;
    
    if (k <= thresh) || (k >= 1-thresh)
        contains = 0;
    end
    
    % Determining whether the intersect point is inside the surface segment
    % or not is generally more complicated. This simple check only works 
    % correctly if the surface is a rectangle and is parallel to at least 
    % one coordinate axis
    % Basically we just check whether the point is within the containing
    % box of the surface segment
    if any((P_int < (min(obj.points) - thresh)) | (P_int > (max(obj.points) + thresh)))
        contains = 0;
    end    
    
end