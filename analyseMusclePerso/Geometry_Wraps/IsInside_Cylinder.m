function bool=IsInside_Cylinder(Wrap,pt)
%Puchaud Pierre 24/05/2017
% En entree:
%           *Un wrap (structure)
%           *1 points dans Rw (vecteur colonne)
% En sortie :
%           *booleen "le point est dedans"
% reference : Obstacle set method, Garnder and Pandy for muscle path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1- Compute locations of obstacle via points
R = Wrap.Geometry.Rayon  ;
h = Wrap.Geometry.Longueur  ;

% tol=0.98; %m (1/2 millimetre de tolérance) pour les points juste en dessous la surface
if (pt(1)/R)^2+(pt(2)/R)^2<1 && -h/2<pt(3) && pt(3)<h/2 %le point est dedans
    bool =1;
else
    bool=0;
end

% if pt(1)>R*0.98 && pt(2)>R*0.98 && -h/2<pt(3) && pt(3)<h/2 && bool==1 %le point est dedans
%     bool =0;
% end

end