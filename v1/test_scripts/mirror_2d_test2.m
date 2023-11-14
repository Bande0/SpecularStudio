% defining the line
P1 = [2, 2];
P2 = [1, 5];

% point to mirror
P = [-2,-3];

% calculate line coeffs
DIF = P1 - P2;
A = DIF(2);
B = -DIF(1);
C = -A*P1(1) - B*P1(2);

% find coeffs for perpendicular line
D = B;
E = -A;
F = -D*P(1) - E*P(2);

% mx + b form
m1 = -A/B;
b1 = -C/B;
m2 = -D/E;
b2 = -F/E;

% intersection point coordinates
P_int(1) = (b2 - b1)/(m1 - m2);
P_int(2) = m1 *  P_int(1) + b1;

% mirrored point coordinates
P_m(1) = P_int(1) + (P_int(1) - P(1));
P_m(2) = P_int(2) + (P_int(2) - P(2));


X = linspace(-10,10,100);

close all
plot(X, m1*X + b1);  % original line
hold on
plot(X, m2*X + b2, '--');  % perpendicular line
plot(P(1),P(2),'rx','MarkerSize',10,'LineWidth',2);  % point
plot(P_int(1),P_int(2),'gx','MarkerSize',10,'LineWidth',2);  % Intersect point
plot(P_m(1),P_m(2),'rx','MarkerSize',10,'LineWidth',2);  % mirrored point
% quiver(P2(1),P2(2),A,B,0);  % line normal vector
grid on;
xlim([-10 10]);
ylim([-10 10]);
axis square