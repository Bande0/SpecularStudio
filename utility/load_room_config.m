function [sources, walls] = load_room_config(filename)

    room_config = loadjson(filename);

    sources = [];
    % loop till the length parameter, to avoid reading in any dummies
    for i = 1:room_config.sources.length
        tmp = PointSource(room_config.sources.data(i).location);

        % empty lists are exported as length 1 cell arrays - this needs to be
        % fixed
        fields = {'idx', 'segments', 'emitted_signal', 'path', 'order'};
        for field = fields
           tmp.(field{1}) = room_config.sources.data(i).(field{1});
           if isempty(tmp.(field{1}))
              tmp.(field{1}) = [];
           end      
        end

        sources = [sources tmp];
    end

    walls = [];
    for i = 1:room_config.walls.length
        tmp = room_config.walls.data(i);
        W = RectangularSurface(tmp.idx, tmp.points(1,:), tmp.points(2,:), tmp.points(3,:), tmp.points(4,:), tmp.abs_coeff);
        walls = [walls W]; 
    end

end

