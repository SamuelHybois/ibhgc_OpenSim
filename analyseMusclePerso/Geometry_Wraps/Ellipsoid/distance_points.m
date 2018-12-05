% Fonction :    A = distance_points(B,C) ;
%
% Version:      1.0
% Langage:      MatLab    Version: 5.3 
% Plate-forme:  PC Win98
%___________________________________________________________________________
%
% Niveau de Validation : 1
%___________________________________________________________________________
%
% Description de la fonction : cette fonction créer la matrice des distances
% entre tous les points d'une meme liste si seulement B est est entrée ou ceux
% de deux listes différentes (cas B et C). La taille de la matrice est égale au 
% nombre de points entrés. La dimension de l'espace pour ces points n'est pas
% imposée.
%___________________________________________________________________________
%
% Paramètres d'entrée  : 
%
% B : liste de points dont on veut connaître les distances relatives respectives
%     matrice de réel - real array (m*n) en général n = 1, 2 ou 3
%
% C : liste de points dont on veut connaître les distances relatives respectives
%     matrice de réel - real array (p*n) en général n = 1, 2 ou 3
%
% Paramètres de sortie : 
%
% A : matrice des distances relatives entre les points
%     matrice de réel - real array (m*m) (A(i,j) = d(Pi,Pj))
%___________________________________________________________________________
%
% Mots clefs : Calcul, Géométrie
%___________________________________________________________________________
%
% Auteurs : S.LAPORTE
% Date de création : 06/04/2000
% Créé dans le cadre de : Thèse
% Professeur responsable : W.Skalli & D.Mitton
%___________________________________________________________________________
%
% Laboratoire de Biomécanique LBM
% ENSAM C.E.R. de PARIS                          email: lbm@paris.ensam.fr
% 151, bld de l'Hôpital                          tel:   01.44.24.63.63
% 75013 PARIS                                    fax:   01.44.24.63.66
%___________________________________________________________________________
%
% Toutes copies ou diffusions de cette fonction ne peut être réalisée sans
% l'accord du LBM
%___________________________________________________________________________
%
function [A,sg] = distance_points(B,C) ;
%
% Taille limite pour une matrice acceptable
%
limite = 1e6 ; % (C'est le nombre maximal d'éléments dans la matrice)
%pack ;         % Réorganisation de la mémoire
%
% ~~~~ > 2 cas : 1 seule matrice // 2 matrices < ~~~~
%
if nargin == 1 ;
    % ---> C est la meme matrice que B
    C = B ;
end
%
% récupération de la dimension de l'espace de travail ainsin que le nombre de points
%
[Nb,Dim] = size(B) ; 
[Nc,Dim2] = size(C) ;
%
% il faut vérifier que les deux matrices sont dans des espace de meme dimension
%
if Dim2 ~= Dim ;
    A = [] ;
    error('B et C ne sont pas compatibles en terme de dimension d''espace') ;
    return
end
%
% Création de la matrice de distance entre chacun des points
% Initialisation de la variable A pour le calcul
%
% ---> Gestion de la mémoire : morcellement du calcul si nécessaire
%
if Nb * Nc <= limite ;
    % ---> Le calcul peut etre direct
    A = zeros([Nb,Nc]) ; 
    sg = ones([Nb,Nc]) ; 
    % Calcul des distances au carré
    for t = 1:Dim ;
        k = B(:,t)*ones(1,Nc)-ones(Nb,1)*C(:,t)' ; % pour la direction t
        A = A + k.^2 ;                             % pour la partie t du calcul de la distance
        sg1 = sign(k);
        sg = sg .* sg1;
    end
    % maintenant la racine carré
    A = sqrt(A) ;
    %
else
    % ---> Il faut décomposer le calcul
    % Initialisation de la variable de sortie
    A = [] ; 
    save('TempDP.mat','A') ;
    % ---> Calcul du pas pour la création par bloc
    Pas = floor(limite/Nb) - 1 ; 
    Npas = ceil(Nc/Pas) ;        % Nombre de Pas
    %disp(['Nombre de pas : ',num2str(Npas)]) ;
    % ---> Boucle de calcul :
    for t = 1:Npas ;
        %disp(['Pas n°',num2str(t),' / ',num2str(Npas)]) ;
        %pack ;         % Réorganisation de la mémoire
        % ---> Sous partie de C
        if t == Npas ;
            TempC = C([(t-1)*Pas+1:end],:) ;
        else
            TempC = C([(t-1)*Pas+1:t*Pas],:) ;
        end
        % ---> Calcul des distances dans ce cas 
        TempC = distance_points(B,TempC) ;
        % load('TempDP.mat') ;
        A = [A,TempC] ;
        % save('TempDP.mat') ;
        % clear A
    end
    % ---> Récupération de la variable de sortie
    % load('TempDP.mat') ;
    % delete('TempDP.mat') ;
end
%
% fin de la fonction