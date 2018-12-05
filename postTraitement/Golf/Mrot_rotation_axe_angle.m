function Mrot = Mrot_rotation_axe_angle(coord_axe,angle,radian)
ux = coord_axe(1);
uy = coord_axe(2);
uz = coord_axe(3);
theta = angle; % en degrés
P = [ux,uy,uz]' * [ux,uy,uz];
I = eye(3,3);
Q = [ 0 ,-uz , uy;...
    uz,  0  ,-ux;...
    -uy,  ux , 0];

if nargin==2
    Mrot = P + cosd(theta)*(I-P) + sind(theta)*Q;
elseif strcmp(radian,'radians')
    theta = angle; %radians
    
    Mrot = P + cos(theta)*(I-P) + sin(theta)*Q;
elseif strcmp(radian,'degrees')
    
    Mrot = P + cosd(theta)*(I-P) + sind(theta)*Q;
end

end