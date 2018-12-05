function plot_ellipsoid(parameters,n)

a = parameters(1:3); %angles
p = parameters(4:6); %position
r = parameters(7:9); %radii

[x_loc,y_loc,z_loc] = ellipsoid(0,0,0,r(1),r(2),r(3),n);

global2local = eye(4,4);

[R1,R2,R3] = Rotations2Matrix_xyz(a(1),a(2),a(3));
global2local(1:3,1:3) = R1*R2*R3;
global2local(1:3,4) = -p;

x_glo = NaN(size(x_loc));
y_glo = NaN(size(x_loc));
z_glo = NaN(size(x_loc));
for i = 1:(n+1)*(n+1)
    xyz0 = global2local\[x_loc(i);y_loc(i);z_loc(i);1];
    x_glo(i) = xyz0(1);
    y_glo(i) = xyz0(2);
    z_glo(i) =  xyz0(3);
end
surf(z_glo,x_glo,y_glo)
shading interp
axis equal
xlabel('Z'),ylabel('X'),zlabel('Y')

end %function