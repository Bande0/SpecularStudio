% defining the line
P1 = [2, 2];
P2 = [-1, 3];

% point to mirror
P = [3, 3];

DIF = P1 - P2;

% calculate coeffs
A = DIF(2);
B = -DIF(1);
C = -A*P1(1) - B*P1(2);

% normalize coeffs
M = sqrt(A * A + B * B);
A = A/M;
B = B/M;
C = C/M;

% calculate distance from point to line
D = A*P(1) + B*P(2) + C;

% calculate mirror point
P_m(1) = P(1) - 2*A*D;
P_m(2) = P(2) - 2*B*D;

m = -A/B;
b = -C/B;
X = linspace(-5,5,100);

close all
plot(X, m*X + b);  % line
hold on
plot(P(1),P(2),'rx','MarkerSize',10,'LineWidth',2);  % point
plot(P_m(1),P_m(2),'rx','MarkerSize',10,'LineWidth',2);  % mirrored point
quiver(P2(1),P2(2),A,B,0);  % line normal vector
grid on;
xlim([-5 5]);
ylim([-5 5]);
axis square