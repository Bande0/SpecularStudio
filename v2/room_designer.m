close all
clc
clear all
addpath(fullfile(pwd, 'utility'));
addpath(fullfile(pwd, 'jsonlab'));
addpath(fullfile(pwd, 'plotting'));

% ----- JSON filename for saving room config  ----- %
filename = 'room.json';

% --------------- Reflective surfaces --------------- %
i_wall = 1;
walls(i_wall) = RectangularSurface(i_wall,...
                                   [0,0,0],...
                                   [6,0,0],...
                                   [6,0,4],...
                                   [0,0,4],...
                                   1.0);
i_wall = i_wall + 1;

walls(i_wall) = RectangularSurface(i_wall,...
                                   [0,0,0],...
                                   [-1,8,0],...
                                   [-1,8,4],...
                                   [0,0,4],...
                                   1.0);
i_wall = i_wall + 1; 

walls(i_wall) = RectangularSurface(i_wall,...
                                   [6,0,0],...
                                   [7,8,0],...
                                   [7,8,4],...
                                   [6,0,4],...
                                   1.0);
i_wall = i_wall + 1; 

walls(i_wall) = RectangularSurface(i_wall,...
                                   [7,8,4],...
                                   [7,8,0],...
                                   [-1,8,0],...
                                   [-1,8,4],...
                                   1.0);
i_wall = i_wall + 1; 

%floor
walls(i_wall) = RectangularSurface(i_wall,...
                                   [7,8,0],...
                                   [-1,8,0],...
                                   [-1,0,0],...
                                   [7,0,0],...
                                   1.0);
i_wall = i_wall + 1; 

%ceiling
walls(i_wall) = RectangularSurface(i_wall,...
                                   [7,8,4],...
                                   [-1,8,4],...
                                   [-1,0,4],...
                                   [7,0,4],...
                                   1.0);
i_wall = i_wall + 1; 
                                
                    
% Define true pointsource(s)      
S = [PointSource([3, 5, 2]),...
    ];

%%  plotting
plot_room(walls, S);

%%
% save room configuration
save_room_config(walls, S, fullfile(pwd, 'geometry', 'room', filename));
