clear;
data = GetDataSDF('00011.sdf');

%n = data.Derived.Number_Density.Electron.data;
%Ey = data.Electric_Field.Ey.data;
%Ex = data.Electric_Field.Ex.data;
Bz = data.Magnetic_Field.Bz.data;
x = data.Grid.Grid.x;
y = data.Grid.Grid.y;
x(length(x)) = [];
y(length(y)) = [];
figure(1);

imagesc(x,y,Bz);
title('Ey');
xlabel('y - Position[um]'); %epoch swaps axes for some reason
ylabel('x - Position[um]')
zlabel('Ey - Electric Field[V/m]');

%figure(2);
%mesh(x,y,Ex);
%title('Ex');
%xlabel('x - Position[um]');
%ylabel('y - Position[um]')
%zlabel('Ey - Electric Field[V/m]');

%figure(3);

%imagesc(x,y,n);
%title('Electron Density');
%xlabel('x - Position[um]');
%ylabel('y - Position[um]')
%zlabel('n - Electron Density');

fclose('all'); 