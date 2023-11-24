function R = swap_mic_coordinates(R, swap_from, swap_to)
% Applies a simple transformation between the XY and XZ planes by simply
% swapping the Y and Z coordinates

    if strcmp(swap_from, 'y')
        from_idx = 2;
    elseif strcmp(swap_from, 'z')
        from_idx = 3;
    else
        error('Unsupported coordinate axis swap for "%s"', swap_from);
    end

    if strcmp(swap_to, 'y')
        to_idx = 2;
    elseif strcmp(swap_to, 'z')
        to_idx = 3;
    else
        error('Unsupported coordinate axis swap for "%s"', swap_to);
    end

    for i = 1:length(R)
        tmp = R(i).location(to_idx);
        R(i).location(to_idx) = R(i).location(from_idx);
        R(i).location(from_idx) = tmp;
    end

end

