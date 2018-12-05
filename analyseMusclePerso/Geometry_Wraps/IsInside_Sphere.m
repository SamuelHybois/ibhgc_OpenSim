function bool=IsInside_Sphere(Wrap,pt)
%Puchaud Pierre 24/05/2017
% En entree:
%           *Un wrap (structure)
%           *1 points dans Rw (vecteur colonne)
% En sortie :
%           *booleen "le point est dedans"
% reference : Obstacle set method, Garnder and Pandy for muscle path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1- Compute locations of obstacle via points
R = Wrap.Geometry.Rayon;
% tol=0.001/2; %m (1/2 millimetre de tolérance) pour les points juste en dessous la surface
if (pt(1)/R)^2+(pt(2)/R)^2+(pt(3)/R)^2<1 %le point est dedans
% if abs(pt(1))<R && abs(pt(2))<R && abs(pt(3))<R %le point est dedans
    bool =1;
else
    bool=0;
end

% if abs(pt(1))>=R-tol && abs(pt(2))>=R-tol && abs(pt(3))>=R-tol && bool==1 %le point est dedans
%     bool =0;
% end

end