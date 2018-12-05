function Ellipse = ellipse_moindres_carres_2D(M) ;
%
% Fonction de calcul de l'ellipse au moindre carr� pour un nuage de points
% ---> Les points sont entr�s en ligne
%
[NPts,Dim] = size(M) ; % Dimension du nuage de points et dimension
%
% 1. Gestion des erreurs
%
if Dim ~= 2 ;
    % ---> On n'est pas dans le plan ...
    error('Les points ne sont pas dimension 2') ;
end
if NPts < 6 ;
    % ---> Il n'y a pas assez de points pour le calcul
    error('Il faut au moins 6 points pour faire le calcul') ;
end
%
% 2. Recherche de la forme brute : A.X� + B.Y� + C.X.Y + D.X + E.Y - 1 = 0
%
% ---> Cr�ation des matrices des moindres carr�s :
% 
Mat = [M(:,1).^2,M(:,2).^2,M(:,1).*M(:,2),M(:,1),M(:,2)] ;
Cible = ones(length(M),1) ;
%
% ---> R�solution du syst�me : calcul de A, B, C, D et E :
%
Soluce = inv(Mat'*Mat) * (Mat'*Cible) ;
%
% ---> Sauvegarde de la forme brute : vecteur soluce :
%
Ellipse.Equation = Soluce' ;
%
% 3. Analyse de l'ellipse et �quation r�duite
%
% 3.1. Orientation des axes : il faut trouver le changement de variables
%      annulant les termes crois�s c'est � dire en X.Y ...
%
if Soluce(1) ~= Soluce(2) ;
    Ellipse.Angle = .5 * atan(Soluce(3)/(Soluce(2)-Soluce(1))) ;
    Phi = Ellipse.Angle ;
    Ellipse.R = [cos(Phi),sin(Phi);-sin(Phi),cos(Phi)] ;
else
    error('Vous avez affaire � un cercle') ;
end
%
% 3.2. Calcul des nouveaux coefficients :
%
Alpha = Soluce(1)*cos(Phi)^2 + Soluce(2)*sin(Phi)^2 - Soluce(3)*cos(Phi)*sin(Phi) ;
Beta = Soluce(1)*sin(Phi)^2 + Soluce(2)*cos(Phi)^2 + Soluce(3)*cos(Phi)*sin(Phi) ;
Gamma = Soluce(4)*cos(Phi) - Soluce(5)*sin(Phi) ;
Delta = Soluce(4)*sin(Phi) + Soluce(5)*cos(Phi) ;
%
% 3.3. Calcul des param�tres g�om�triques
%
xo = - 0.5 * Gamma / Alpha ;
yo = - 0.5 * Delta / Beta ; % ---> Coordonn�es du centroide r�duit
Ellipse.a = sqrt( xo^2 + yo^2 * Beta / Alpha + 1 / Alpha) ;
Ellipse.b = Ellipse.a * sqrt(Alpha/Beta) ;
Ellipse.Centroide = (Ellipse.R*[xo;yo])' ; % ---> Passage dans le rep�re de d�part
%
% Fin de la fonction ;
