% function [N2,P2,Arr] = nettoie_movie_arr(N,P,Arr) ;
%
% Fonction permettant de modifier localement un maillage si certaine arretes ne sont pas correctes
%
function [N,P,Arr] = nettoie_movie_arr(N,P,Arr) ;
%
% 1. Gestion des donn�es d'entr�e
%
if nargin < 3 ; 
    % Nous devons r�aliser l'analyse des arretes maintenant
    Arr = analyse_arretes(P) ;
end
%
% 2. Boucle de recherche et de correction :
%
warning off
while 1 ;
    % ao) analyse des arretes et correction
    Arr = analyse_arretes(P) ;
    if size(Arr.Polygones,2) == 2 ;
        % ---> Pas de modification � r�aliser ...
        break
    end
    liste = find(Arr.Polygones(:,3) ~= 0) ; 
    disp(['Nombre d''arretes � corriger : ',num2str(length(liste))]) ;
    % a) recherche des polygones ayant au moins 1 noeuds appartenant � l'arrete incrimin�e :
    Narr = Arr.Definition(liste(1),:) ;     % Noeuds d�finissant l'arrete
    [D1,J] = find(P == Narr(1)) ;           % Polygones contenant le premier noeud
    [D2,J] = find(P == Narr(2)) ;           % Polygones contenant le second noeud
    D = unique([D1;D2]) ;                   % Liste compl�te des polygones
    % InfoN = Calcul_normale_noeuds(N,P(D,:));% Calculs des normales aux noeuds
    % b) recherche des arretes limites de la surface ainsi cr�e
    DefP = P(D,:) ;                         % D�finition des polygones concern�s
    Ar2 = analyse_arretes(DefP) ;           % Nouvelle analyse
    Marr = find(Ar2.Polygones(:,3) ~= 0) ;  % O� se situe l'arrete analys�e
    Carr = find(Ar2.Polygones(:,2) == 0) ;  % Arretes limites de la surface
    DirN = mean(cross(N(DefP(:,2),:) - N(DefP(:,1),:),...
        N(DefP(:,3),:) - N(DefP(:,1),:))) ; % Orientation pr�c�dante des normales
    % c) Cr�ation du barycentre des noeuds de l'arretes incrimin�e
    N = [N;barycentre([N(Ar2.Definition(Marr,1),:);N(Ar2.Definition(Marr,1),:)])] ;
    Nnoeud = length(N) ;                    % Num�ro du nouveau noeud
    % d) supression des polygones D
    J = setdiff([1:length(P)],D) ;          % liste des polygones � conserver
    P = P(J,:) ; clear J ;                  % nouvelle d�finition de la surface
    % e) cr�ation des nouveaux triangles
    Pn = [Ar2.Definition(Carr,:),ones(length(Carr),1)*Nnoeud] ;
    % f) r�orientation des normale pour les nouveaux polygones
    for t = 1:length(Carr) ;
        Dira = cross(N(Pn(t,2),:) - N(Pn(t,1),:),...
            N(Pn(t,3),:) - N(Pn(t,1),:)) ;         % orientation actuelle du polygone
        if dot(Dira,DirN) < 0 ;            
            Pn(t,:) = [Pn(t,1),Pn(t,3),Pn(t,2)] ;  % modification si n�cessaire
        end
    end
    % g) mise � jour propre du maillage
    P = [P;Pn] ;
    [N,P,Info] = nettoie_maillage_NP(N,P) ;
end
warning on
%
% fin de la fonction