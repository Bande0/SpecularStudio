function img_list = assign_signals_to_image_sources(img_list, x)
% For each point source (whether true physical source or image source),
% the function loops through the "path" variable and applies the absorption
% from each surface encountered along the way 

    for i_img = 1:length(img_list)
        y = x;
        S = img_list(i_img);
        for i = 1:length(S.path)
            y = S.path(i).wall.absorb(y);
        end     
        img_list(i_img).emitted_signal = y;
    end

end

