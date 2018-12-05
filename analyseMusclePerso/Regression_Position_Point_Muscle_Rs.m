function [new_coord] = Regression_Position_Point_Muscle_Rs( Regression_tree , coord_ik)
% En entrée :
%               *Location initiale
%               *Arbre de regression dans le muscle du forceset du OSIM
%               *coordonnées de l'angle au cours de l'essai vertical array
% Sortie :
%               *Liste de la coordonnée (x,y ou z) dans le Repere
%               segmentaire Rs du point du muscle au cours de l'essai

% !! pas tout tester !!
res = fieldnames(Regression_tree);
if strcmp(res{1},'LinearXfunction')==1
    Coef =  Regression_tree.LinearXfunction.coefficients;
    
    if ~isempty(find(strcmp(List_Coordinates,coordinate_name)==1, 1))
        new_coord =  Coef(1) * coord_ik + Coef(2);
        
    else
        new_coord =  zeros(size(Generalized_coordinates.(List_Coordinates{1}),1),1);
    end
    
    
elseif strcmp(res{1},'Constant')==1
    Constante=  Regression_tree.Constant.value;
    
    new_coord =  Constante * ones(size(Generalized_coordinates.(List_Coordinates{1}),1),1);
    
elseif strcmp(res{1},'SimmSpline')==1
    X =  Regression_tree.SimmSpline.x;
    Y =  Regression_tree.SimmSpline.y;
    
    Coord = coord_ik * pi/180;
    
    new_coord =  interp1(X,Y,Coord,'spline');
    
elseif strcmp(res{1},'MultiplierXfunction')==1
    xfunction = Regression_tree.MultiplierXfunction.xfunction;
    scale = Regression_tree.MultiplierXfunction.scale;
    res2 = fieldnames(xfunction);
    if strcmp(res2{1},'LinearXfunction')==1
        Coef =  xfunction.LinearXfunction.coefficients;
        
        if ~isempty(find(strcmp(List_Coordinates,coordinate_name)==1, 1))
            new_coord =  (Coef(1) * coord_ik + Coef(2)) * scale;
            
        else
            new_coord =  zeros(size(Generalized_coordinates.(List_Coordinates{1}),1),1);
        end
    elseif strcmp(res2{1},'PiecewiseLinearXFunction') % Fonctionne seulement si il y a 2 valeurs dans PiecewiseLinearfunction
        % n'est pas affine..
                    X=xfunction.x;
                    Y=xfunction.y;
                    coeff=(Y(2)-Y(1))/(X(2)-X(1));
                    new_coord = coord_ik*coeff;    
                    
     elseif strcmp(res2{1},'PiecewiseLinearXfunction') % Fonctionne seulement si il y a 2 et 3 valeurs dans PiecewiseLinearfunction
         X=xfunction.PiecewiseLinearXfunction.x;
         Y=xfunction.PiecewiseLinearXfunction.y*scale;
         
         if length(xfunction.PiecewiseLinearXfunction.x)== 2
                    
                    coeff=(Y(2)-Y(1))/(X(2)-X(1));
                    new_coord = coeff*coord_ik*pi/180+Y(1);
                    
         elseif length(xfunction.PiecewiseLinearXfunction.x)== 3
             
             coeff{1}=(Y(2)-Y(1))/(X(2)-X(1));
             coeff{2}=(Y(3)-Y(2))/(X(3)-X(2));
             
             new_coord = zeros(length(coord_ik),1);
             
             for i_crd = 1:length(coord_ik)
                 if coord_ik(i_crd)*pi/180 >= X(1) && coord_ik(i_crd)*pi/180 < X(2)
                     new_coord(i_crd,1) = coeff{1}*coord_ik(i_crd,1)*pi/180+Y(1);
                 elseif coord_ik(i_crd)*pi/180 >= X(2) && coord_ik(i_crd)*pi/180 < X(3)
                     new_coord(i_crd,1) = coeff{2}*coord_ik(i_crd,1)*pi/180+Y(2);
                 end
             end
             
             
         end
                
    elseif strcmp(res2{1},'Constant')==1
        Constante=  xfunction.Constant.value;
        
        new_coord = (Constante * ones(size(Generalized_coordinates.(List_Coordinates{1}),1),1)) * scale;
        
    elseif strcmp(res2{1},'SimmSpline')==1
        X =  xfunction.SimmSpline.x;
        Y =  (xfunction.SimmSpline.y) * scale;
        
        Coord = coord_ik * pi/180; 
        
        new_coord =  (interp1(X,Y,Coord,'spline'));
    end
    
end


end