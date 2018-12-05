%
% Fonction normant ligne par ligne les vecteurs d'une matrice
% de N vecteurs A = [N,:] ?
%
function A = norme_vecteur(A)
warning off
%
% Calcul de la norme de chacun des vecteurs
%
try
NA = Norm2(A) ;
catch
    NA=norm2(A);
end
%
% boucle sur la dimension de A
%
for t = 1:size(A,2) ;
    A(:,t) = A(:,t) ./ NA ;
end
%
% _ Fin de la fonction _