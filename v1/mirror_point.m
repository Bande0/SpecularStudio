function [P_m, P_int] = mirror_point(P, W)
% mirrors the point P wrt. the infinite plane defined by the surface W
%
% returns the coordinates of the mirrored point P_m and also the 
% intersection point P_int (the point where the P_m - P line and the
% infinite plane defined by W intersect
%
% source: https://www.geeksforgeeks.org/mirror-of-a-point-through-a-3-d-plane/

    n = W.normal;
    D = W.D;
    % intersect point:
    % Vector pointing from P to P_int has the direction of the normal vector
    % plus a length k --> P_int - P = k*n --> P_int = k*n + P
    % also, the intersect point lies in the plane so it satisfies n*P_int + D = 0
    % (where n contains is the A/B/C coefficients of the surface equation and D is the
    % offset coefficient). 
    % 1) P_int = k*n + P
    % 2) n*P_int + D = 0
    % substitute 1) in 2: 
    % 3) n*(k*n + P) + D = 0
    % solve for k
    % 4) k = -(n*P + D) / |n|^2
    k = -(n*P' + D) / norm(n)^2; % denominator can be omitted if normal vector is normalized to unit length
    P_int = k*n + P;
    P_m = 2*P_int - P;

end