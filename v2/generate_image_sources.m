function img_list = generate_image_sources(P, walls, max_order)
% Recursively generates image sources of a source P for the room geometry 
% defined by the list of RectangularSurface objects in the "walls" argument. 
%
% The function recursively mirrors sources onto all planes in the geometry
% by doing the following:
% - Generates 1st order image sources by mirroring the original source onto
% all surfaces in the geometry
% - Generates N+1'th order images by recursively mirroring N'th order image
% sources (where N > 0) again onto all surfaces EXCEPT for the one onto
% which they have been mirrored onto most recently (because that would give
% back an N-1'th image)
% - the "order" argument sets the recursion depth
% 
% OBS: this function generates ALL image sources for order 0:N - also
% "invalid" ones --> Validation of reflection paths must be done
% separately.
%
% Input Arguments:
%     P: struct defining a source (either a physical or image source)
%         .location - x/y/z coordinates of the source
%         .path - struct array describing the reflection path through which
%               the source has been obtained (empty struct for original source)
%     walls: list of RectangularSurface objects defining the room geometry
%     order: maximum reflection order to calculate (i.e. recursion depth)
%
% Output Arguments:
%     img_list: struct array containing a list of image sources in the same
%               format as the input source
        
    % if the source in the argument has no path (i.e. orignal source),
    % initialize it
    if ~isfield(P, 'path')
       P.path = []; 
    end

    % initialize returned list
    img_list = struct('location', [], 'path', []);
    
    % if input P is a 0'th order image source (i.e: the original source),
    % append to the list    
    if isempty(P.path)
        img_list = concat_structs(img_list, P);
    end       
    
    % stop at max recursion depth
    if (max_order == 0)
        return
    end
    
    % Loop through all the surfaces in the geometry and calculate image
    % sources
    for i = 1:length(walls)
        % We don't reflect image sources back through the surface on which
        % they have just been mirrored onto (i.e. the last "wall" in its path)
        % The only exception is the original source, which needs to be
        % mirrored onto all surfaces
        if isempty(P.path) || (P.path(end).wall.idx ~= i)
            % calculate the location of the image source wrt. the i'th
            % surface
            [P_m, ~] = walls(i).mirror_point(P.location);
            img.location = P_m;      
            img.path = concat_structs(P.path, struct('location', P.location, 'wall', walls(i)));                        
            % recursively call the function for the image source and
            % decrement the max_order counter            
            list = generate_image_sources(img, walls, max_order-1);
            % append the image source and the list returned from the
            % recursion to the image list
            img_list = concat_structs(img_list, img);
            img_list = concat_structs(img_list, list);               
        end
    end
    
end

% helper function for concatenating structs into a struct array
% discards empty structs
function C = concat_structs(A, B)
    if (length(A) == 1) && all(structfun(@isempty, A))
        C = B; 
    elseif (length(B) == 1) && all(structfun(@isempty, B))
        C = A;
    else
        C = [A; B];
    end 
end