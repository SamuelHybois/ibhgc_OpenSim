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
% Description de la fonction : cette fonction cr�er la matrice des distances
% entre tous les points d'une meme liste si seulement B est est entr�e ou ceux
% de deux listes diff�rentes (cas B et C). La taille de la matrice est �gale au 
% nombre de points entr�s. La dimension de l'espace pour ces points n'est pas
% impos�e.
%___________________________________________________________________________
%
% Param�tres d'entr�e  : 
%
% B : liste de points dont on veut conna�tre les distances relatives respectives
%     matrice de r�el - real array (m*n) en g�n�ral n = 1, 2 ou 3
%
% C : liste de points dont on veut conna�tre les distances relatives respectives
%     matrice de r�el - real array (p*n) en g�n�ral n = 1, 2 ou 3
%
% Param�tres de sortie : 
%
% A : matrice des distances relatives entre les points
%     matrice de r�el - real array (m*m) (A(i,j) = d(Pi,Pj))
%___________________________________________________________________________
%
% Mots clefs : Calcul, G�om�trie
%___________________________________________________________________________
%
% Auteurs : S.LAPORTE
% Date de cr�ation : 06/04/2000
% Cr�� dans le cadre de : Th�se
% Professeur responsable : W.Skalli & D.Mitton
%___________________________________________________________________________
%
% Laboratoire de Biom�canique LBM
% ENSAM C.E.R. de PARIS                          email: lbm@paris.ensam.fr
% 151, bld de l'H�pital                          tel:   01.44.24.63.63
% 75013 PARIS                                    fax:   01.44.24.63.66
%___________________________________________________________________________
%
% Toutes copies ou diffusions de cette fonction ne peut �tre r�alis�e sans
% l'accord du LBM
%___________________________________________________________________________
%
function [A,sg] = distance_points(B,C) ;
%
% Taille limite pour une matrice acceptable
%
limite = 1e6 ; % (C'est le nombre maximal d'�l�ments dans la matrice)
%pack ;         % R�organisation de la m�moire
%
% ~~~~ > 2 cas : 1 seule matrice // 2 matrices < ~~~~
%
if nargin == 1 ;
    % ---> C est la meme matrice que B
    C = B ;
end
%
% r�cup�ration de la dimension de l'espace de travail ainsin que le nombre de points
%
[Nb,Dim] = size(B) ; 
[Nc,Dim2] = size(C) ;
%
% il faut v�rifier que les deux matrices sont dans des espace de meme dimension
%
if Dim2 ~= Dim ;
    A = [] ;
    error('B et C ne sont pas compatibles en terme de dimension d''espace') ;
    return
end
%
% Cr�ation de la matrice de distance entre chacun des points
% Initialisation de la variable A pour le calcul
%
% ---> Gestion de la m�moire : morcellement du calcul si n�cessaire
%
if Nb * Nc <= limite ;
    % ---> Le calcul peut etre direct
    A = zeros([Nb,Nc]) ; 
    sg = ones([Nb,Nc]) ; 
    % Calcul des distances au carr�
    for t = 1:Dim ;
        k = B(:,t)*ones(1,Nc)-ones(Nb,1)*C(:,t)' ; % pour la direction t
        A = A + k.^2 ;                             % pour la partie t du calcul de la distance
        sg1 = sign(k);
        sg = sg .* sg1;
    end
    % maintenant la racine carr�
    A = sqrt(A) ;
    %
else
    % ---> Il faut d�composer le calcul
    % Initialisation de la variable de sortie
    A = [] ; 
    save('TempDP.mat','A') ;
    % ---> Calcul du pas pour la cr�ation par bloc
    Pas = floor(limite/Nb) - 1 ; 
    Npas = ceil(Nc/Pas) ;        % Nombre de Pas
    %disp(['Nombre de pas : ',num2str(Npas)]) ;
    % ---> Boucle de calcul :
    for t = 1:Npas ;
        %disp(['Pas n�',num2str(t),' / ',num2str(Npas)]) ;
        %pack ;         % R�organisation de la m�moire
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
    % ---> R�cup�ration de la variable de sortie
    % load('TempDP.mat') ;
    % delete('TempDP.mat') ;
end
%
% fin de la fonction