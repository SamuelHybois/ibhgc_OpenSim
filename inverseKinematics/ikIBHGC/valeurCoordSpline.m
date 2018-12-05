function real_coordinate = valeurCoordSpline(Coord,spline)
% Calcul de la coordonnée généralisée interpolée dans le cas des joints avec fonction SimmSpline

%%% [real_coordinate] : valeur de la coord. gen. (rad)

%%% Coord : valeur prise par la coord. gen. (rad)

%%% spline : structure décrivant la spline de ce DDL du modèle, écrite lors de la lecture du modèle avec Extract_KinChainData_ModelOS.m
% spline.pieces = nombre d'intervalles d'interpolation
% spline.order = ordre du polynôme d'interpolation
% spline.X = bornes des intervalles d'interp.
% spline.coefs = coefficients de la spline 

if spline.pieces ==1
    coef_spline = spline.coefs;
    real_coordinate = 0;
    for i_exp = 1:spline.order
        real_coordinate = real_coordinate + coef_spline(1,i_exp)*(Coord)^(spline.order+1-i_exp);
    end
    
else
    % Coefficient de la spline cubique sur le segment [x1,x2] auquel appartient
    % Coord.
    coef_spline = spline.coefs;
    % Début de l'intervalle
    vect_rank = spline.X - Coord;
    idx = find(vect_rank>0);
    idx = idx(1);
    deb_spline = spline.X(idx-1);
    % Calcul de l'estimation par spline cubique
    real_coordinate = 0;
    for i_exp = 1:spline.order
        real_coordinate = real_coordinate + coef_spline(1,i_exp)*(Coord-deb_spline)^(spline.order+1-i_exp);
    end
end
end