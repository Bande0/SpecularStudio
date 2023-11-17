function save_room_config(walls, sources, filename)

    % assemble walls and source info into a struct for export
    room_config = struct();
    room_config.walls.data = walls;
    room_config.walls.length = length(walls);
    room_config.sources.data = sources;
    room_config.sources.length = length(sources);

    % jsonsave will produce non-human readable outputs for lists of length 1,
    % so in that case we will extend the list by a dummy element, but we will
    % keep the length parameter intact
    if room_config.sources.length == 1
        room_config.sources.data = [room_config.sources.data,...
                               PointSource([NaN, NaN, NaN])];
    end
    if room_config.walls.length == 1
        room_config.walls.data = [room_config.walls.data,...
                             RectangularSurface(NaN, NaN, NaN, NaN, NaN, NaN)];
    end

    % remove wall normal vector and D coefficient info from exported JSON file
    % - it will be recalculated upon loading and just creates clutter
    for i = 1:room_config.walls.length
        room_config.walls.data(i).normal = [];
        room_config.walls.data(i).D = [];
    end

    savejson('', room_config, filename);

end

