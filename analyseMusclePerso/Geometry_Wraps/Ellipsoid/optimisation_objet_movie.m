function A = optimisation_objet_movie(A,Nblim,ite_lim)
%
% Fonction permettant de r�duire le nombre de facette d'un objet movie, en
% conservant un maillage correct et en le lissant
%
warning('off','all')
if nargin==2
    ite_lim=500;
end
%
% 1. Boucle d'optimisation
%
Tx_init = 0.5 ;         % Taux initial de r�duction de l'objet movie
Apre = A ;              % Objet pr�c�dant
%
ite=0;
while 1 && ite<ite_lim
    %
    % 1.1 Normalisation de l'objet :
    %
    Apre = normalise_movie(Apre) ;
    %
    % 1.2 R�duction de l'objet movie
    %
    A = reducemov(Apre,Tx_init) ;
    %
    % 1.3 Etude de la sortie de la boucle d'optimisation
    %
    if A.N_Pts <= 0.90 * Nblim ;
        % ---> Il faut moins r�duire le nombre de noeuds
        Tx_init = Tx_init * 1.2 ;
    elseif A.N_Pts >= 1.1 * Nblim ;
        % ---> Il faut continuer � r�duire l'objet + lissage
        A.Noeuds = lambdanusmoothing(A.Noeuds,A.Polygones,'iterations',25) ;
        Apre = A ;
    else
        % ---> Nous avons obtenu le r�sultat souhait� qu'il faut lisser
        A = normalise_movie(A) ;
        A.Noeuds = lambdanusmoothing(A.Noeuds,A.Polygones,'iterations',25) ;
%         disp([num2str(A.N_Pts),' / ',num2str(Nblim)]) ;
        break % ---> Sortie de la boucle d'optimisation
    end
    %
    % 1.4 Affichage des nombres de noeuds
    %
%     disp([num2str(A.N_Pts),' / ',num2str(Nblim)]) ;
    ite=ite+1;
end
%
% ---> Fin de la fonction
warning('on','all')