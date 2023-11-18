function cnt = count_all_image_sources(no_walls, max_order)
% counts the theoretical number of all possible (valid and invalid) image
% sources for a given number of walls and maximum reflection order
        
    % 0'th order source (true source) == 1
    % 1st order sources == no_walls
    cnt = 1 + no_walls;      
    % N+1'th order sources: N'th order sources * (no_walls - 1)
    prev_refs = no_walls;
    for i = 2:max_order
        refs = prev_refs * (no_walls - 1);
        prev_refs = refs;
        cnt = cnt + refs;
    end

end