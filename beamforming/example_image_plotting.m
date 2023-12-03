[xSphere,ySphere,zSphere] = sphere(16);          % Points on a sphere
scatter3(xSphere(:),ySphere(:),zSphere(:),'.');  % Plot the points
axis equal;   % Make the axes scales match
hold on;      % Add to the plot
xlabel('x');
ylabel('y');
zlabel('z');
img = imread('peppers.png');     % Load a sample image
xImage = [-0.5 0.5; -0.5 0.5];   % The x data for the image corners
yImage = [0 0; 0 0];             % The y data for the image corners
zImage = [0.5 0.5; -0.5 -0.5];   % The z data for the image corners
surf(xImage,yImage,zImage,...    % Plot the surface
     'CData',img,...
     'FaceColor','texturemap');