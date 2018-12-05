function distance = squared_scaploc2ellispoid_distance(var_ellipsoid,scap_center_in_thorax)
% Cost function for the ellipsoid orientation, position and dimensions
% optimization: the objectif is to minimize the squared distance between
% scapula centre and a functional ellipsoide surface
%
% INPUT
% var_ellipsoid : 9*1 vector with ellipsoid parameters
% scap_center_in_thorax : N*3 matrix of scapula center x,y,z coordinates in 
% thorax during functional movements
%
% OUTPUT
% distance : sum of squared distances between scapula coordinates and
% ellipsoid surface
%
%                                                   D. HAERING 16.10.2018

% 1. Matrice de passage du thorax à l'éllispoide (sequence xyz)
a = var_ellipsoid(1:3); %euler angles
t = var_ellipsoid(4:6); %translation
thorax2ellipsoid = matrice_homogene(a,t);

nb_frame = size(scap_center_in_thorax,1);
d = NaN (nb_frame,1);
r = var_ellipsoid(7:9); %rayons de l'éllispoide
o = [0,0,0];
for i_frame = 1:nb_frame
    
% 2. Coordonnees du centre de la scapula dans le referentiel de l'ellipsoid
    scap_center_in_ellipsoid = thorax2ellipsoid*[scap_center_in_thorax(i_frame,:)';1];

% 3. Distance du centre de la scapula à l'ellipsoide
    %3.a. lagrangian polynomial method (samuel)
    d(i_frame) = distancePointEllipsoide(scap_center_in_ellipsoid(1:3),r,o);
    %3.bis. jacobian iterative method (diane)
    %from: http://www.scielo.br/scielo.php?script=sci_arttext&pid=S1982-21702014000400970
%     [~,d(i_frame)] = shortest_distance( scap_center_in_ellipsoid(1:3), r ); 
end

distance = sum(d.*d);

end