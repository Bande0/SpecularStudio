function img_list = generate_image_sources(obj, P, max_order)
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
% - the "max_order" argument sets the recursion counter
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
%     max_order: reflection order to calculate (i.e. recursion depth)
%
% Output Arguments:
%     img_list: struct array containing a list of image sources in the same
%               format as the input source
        
    walls = obj.walls;

    % initialize returned list
    img_list = [];
    
    % if input P is a 0'th order image source (i.e: the original source),
    % append to the list as the 0'th order source   
    if isempty(P.path)
        P = P.set_order(0);
        img_list = [img_list; P];
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
            img = PointSource(P_m);
            new_path_segment = PathSegment(P.location, walls(i));
            path = [P.path; new_path_segment];     
            img = img.set_path(path);
            img = img.set_order(length(path));
            % recursively call the function for the image source and
            % decrement the order counter            
            list = obj.generate_image_sources(img, max_order-1);
            % append the image source and the list returned from the
            % recursion to the image list
            img_list = [img_list; img];
            img_list = [img_list; list];
        end
    end
    
end