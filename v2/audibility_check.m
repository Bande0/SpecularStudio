function img_list_valid = audibility_check(img_list, walls, R)
% Takes a receiver and a list of image sources and checks whether the
% reflection path is valid
% Also it constructs a set of segments corresponding to the actual 
% reflection path travelled by the sound (for plotting)

    i_valid = 1;       
    reverseStr = '';
    for i = 1:length(img_list)  % "audibility check" for each image source
                
        msg = ['Checking image source ' num2str(i) '/' num2str(length(img_list)) '...'];
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
        
        S = img_list(i); 
        S.idx = i;
        all_segments_ok = 1;
        last_segment_ok = 1;
        
        % 0'th order (i.e. original source) does not have to be validated
        if S.order > 0 
            % Backtracking starts from the receiver and through the last
            % stage of the reflection path
            prev = R.location;  
            next = S.location;
            W = S.path(end).wall;  
            
            % Backtracking:
            % We follow the path travelled by the sound, starting from the
            % receiver and and tracing each segment one by one, reflection
            % by reflection.
            % The condition for an N'th order reflection path to be valid 
            % is:
            % - The line connecting the receiver and the N'th order image
            % source must cross the surface onto which the N-1'th source
            % was mirrored to obtain the N'th order source.
            % - The line connecting the previous intersection point and the
            % N-1'th order image source must intersect the surface that the
            % N-2'th order source was mirrored onto.
            % - Also, the same lines must not cross any other surface
            % other than the one used for the given mirroring
            % - The last segment is the line connecting the intersection
            % point of the 1st surface to the source - this segment must
            % not cross any of the surfaces.
            % 
            % source: 
            % https://reuk.github.io/wayverb/image_source.html
            for j = 1:length(S.path)                              
               % Check if the current segment crosses the next wall on 
               % the path
               [P_int, crosses_next] = W.intersect(prev, next);                            
               
               % now we also need to check that this segment doesn't cross
               % any other walls on its way
               if crosses_next                   
                   crosses_others = 0;
                   for k = 1:length(walls)
                       % Check every wall except the one it HAS to cross             
                       if k ~= W.idx 
                           [~, tmp] = walls(k).intersect(prev, P_int);
                           if tmp
                               crosses_others = 1;                
                           end
                       end
                   end
                   
                   % if it crosses the next wall on the path but not others
                   % --> the segment is valid and we should store
                   if ~crosses_others
                       new_segment = LineSegment(prev, P_int);
                       segments = [S.segments; new_segment];     
                       S = S.set_segments(segments);
                   else
                       all_segments_ok = 0;
                   end
               else
                   all_segments_ok = 0;
               end
               
               % continue with the next path segment
               prev = P_int;
               next = S.path(end-j+1).location;  
               if j < length(S.path)  % the last segment doesn't have a wall
                   W = S.path(end-j).wall;
               end
            end   
            
            % condition for the last segment:
            % line connecting last intersection point and source should not
            % intersect anyting
            for k = 1:length(walls)
                W = walls(k);  
                [~, crosses] = W.intersect(prev, next);
                if crosses
                    last_segment_ok = 0;                
                end
            end
            % if condition for the last segment is met - it is also a valid
            % segment and we should store
            if last_segment_ok
                new_segment = LineSegment(prev, next);
                segments = [S.segments; new_segment];     
                S = S.set_segments(segments);
            end            
        end 
        
        % if all segments were OK --> the whole path is OK and we should
        % store
        if all_segments_ok && last_segment_ok
            img_list_valid(i_valid, :) = S;            
            i_valid = i_valid + 1;
        end
        
    end
    fprintf('\n');
end