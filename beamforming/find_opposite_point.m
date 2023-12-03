% looking for the opposite point by finding the point that has the fewest
% common coordinates
function opp_idx = find_opposite_point(surface, idx)
    sp = surface.points;
    P = sp(idx, :);
    
    opp_idx = 0;
    fewest = 3;
    for i = 1:4
        if sum(P == sp(i, :)) < fewest
            fewest = sum(P == sp(i, :));
            opp_idx = i;
        end
    end
end