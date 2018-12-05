% Arrr = analyse_arretes(P) ; ;
%
% Version:     2.0 (Mai 2000)
% Langage:     Matlab    Version: 7.5
% Plate-forme: PC windows 20
%___________________________________________________________________________
%
% Niveau de Validation : 2
%___________________________________________________________________________
%
% Description de la fonction :  Analyse un maillage de polygones triangles pour en 
% extraire les diff�rentes arretes 
%___________________________________________________________________________
%
% Param�tres d'entr�e  :
%
% P : Matrice polygones
% Matrice - n*3
%
%
% Param�tres de sortie :
%
% Arrr : Structure d�crivant les na aretes li�s au polygones
% Structure contenant les champs suivant :
%           - .Definition : numero des noeuds extremes de chacune des aretes
%                      Matrice  - na*2 interger
%           - .Polygones : numero des polygones d'appartenance de chacune des aretes
%                      Matrice  - na*2 interger
%___________________________________________________________________________
%
% Mots clefs : Movie, aretes, 
%___________________________________________________________________________
%
% Auteurs : 
% Date de cr�ation : 
% Cr�� dans le cadre de :
% Professeur responsable : 
%___________________________________________________________________________
%
% Modifi� par : 
% le :          
% Pour :        
% Modif N�1   : 
%___________________________________________________________________________
%
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
%%
% 
%%
%
%
function Arrr = analyse_arretes(P) ;
%
% 1. Type de maillage � traiter : triangles seuls, quadrangles seuls ou m�lange :
%
[N,Dim] = size(P) ; % Nombre de polygones et dimension des polygones
switch Dim
    case 3      % ----> Il n'y a que des triangles :
        % Mise en forme des polygones : on fait apparaitre 2 fois chaque noeuds :
        P = [P(:,1),P(:,2),P(:,2),P(:,3),P(:,3),P(:,1)] ;
        N_ar = 3 ;
    case 4      % ----> Il y a des quadrangles
        % Recherche de triangles dans les quadrangles
        ltri = find(P(:,4) == 0) ;
        if ~isempty(ltri) % ---------> Il y a des triangles ...
            P(ltri,4) = P(ltri,3) ; %  On recopie les derniers noeuds � la place des zeros
            clear ltri ;
        end
        P = [P(:,1),P(:,2),P(:,2),P(:,3),P(:,3),P(:,4),P(:,4),P(:,1)] ;
        N_ar = 4 ;
    case 8      % ----> Il n'y a que des triangles :
        % Mise en forme des polygones : on fait apparaitre 2 fois chaque noeuds :
        P = [P(:,1),P(:,2),P(:,2),P(:,3),P(:,3),P(:,4),P(:,4),P(:,1),...
            P(:,5),P(:,6),P(:,6),P(:,7),P(:,7),P(:,8),P(:,8),P(:,5),...
            P(:,1),P(:,5),P(:,2),P(:,6),P(:,3),P(:,7),P(:,4),P(:,8)] ;
        N_ar = 12 ;
end
%
% 2. Cr�ation de la matrice brute des arretes et de la liste des polygones associ�s
%
Arr = reshape(P',2,prod(size(P))/2)' ; %clear P ;    % Liste brute des arretes
P = reshape(ones(N_ar,1)*[1:N],1,N_ar*N)' ; % Liste des polygones associ�es
%
% 3. Nettoyages de la liste brute
%
% a) Arretes s'appuyant sur un seul noeud : exemple [12,12] % ---> � �liminer
%
liste = find(diff(Arr,1,2) ~= 0) ;
if ~isempty(liste) ; % ---> Mise � jour des listes :
    Arr = Arr(liste,:) ;
    P = P(liste,:) ;
end
clear liste ;
%
% b) Tri des arretes suivant les num�ros de noeuds
%
Arr = [min(Arr')',max(Arr')'] ; % Le premier noeud est toujours le plus petit tag num
[Arr,liste] = sortrows(Arr) ;   % Et nous trion ensuite par ordre croissant du premier noeud
P = P(liste,:) ;                % Il faut aussi faire suivre la liste des polygones
clear liste ;
%
% c) Recherche des arretes et des polygones associ�s
%
liste = find(diff(Arr(:,1)) ~= 0 | diff(Arr(:,2)) ~= 0) ; % Recherche les changements
%                                                         % d'arretes
% Traitement pour la r�cup�ration des polygones associ�s
liste = [0;liste;length(Arr)] ; % Liste enrichie ...
N_PAr = diff(liste) ;           % Nombre de polygones associ�s par arretes
infoM = find(diff(N_PAr)~=0) ;  % Localisation des modifications de N_Par
% Intialisation de variables
Pfinal = zeros(length(N_PAr),1) ;% Pour la variable de sortie
indice_pre = 1 ;                 % Indice pr�c�dant
P_Pre = 1 ;                      % Localisation pr�c�dante de P
for t = 1:length(infoM)+1 ;
    % Nombre actuel de polynomes par arretes
    if t > length(infoM) ;
        N_PAr_actu = N_PAr(end) ;
        P_Actu = length(P) ;
        indice_actu = length(N_PAr) ;
    else
        N_PAr_actu = N_PAr(infoM(t)) ;
        indice_actu = infoM(t) ;
        P_Actu = P_Pre - 1 + N_PAr_actu * (indice_actu - indice_pre + 1) ;
    end
    % ---> Mise en forme pour les polygones donn�s
    Pfinal([indice_pre:indice_actu],1:N_PAr_actu) = ...
        reshape(P(P_Pre:P_Actu),N_PAr_actu,indice_actu - indice_pre +1)' ;
    % ---> Pr�paration du calcul suivant :
    indice_pre = indice_actu + 1 ;
    P_Pre = P_Actu + 1 ;
end
Arrr.Definition = Arr(liste(2:end),:) ; % ---> Pour les arretes
Arrr.Polygones = Pfinal ;               % ---> Pour les polygones
%
% Fin de la fonction.