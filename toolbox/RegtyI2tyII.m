function A = RegtyI2tyII(B,Champ) ;

% ---> Fonction permettant de transformer une d�finition de r�gion de type I
%      en d�finition de type II


%
% 1. Gestion des entr�es
%
if nargin == 1 ;
    % ---> Champ est impos� �gale � Noeuds :
    Champ = 'Noeuds' ;
end
%
% 2. Compatibilit� du type I
% ---> Soit les tags sont d�j� num�rique, soit ils sont de la forme Point_xyz
%
if isempty(str2num(B(1).tag{1})) & ~strncmp(B(1).tag{1},'Point_',6) ;
    % ---> La d�finition de r�gions n'est pas compatible
    error('D�finition de r�gions incompatible')
end
%
% 3. Noms des r�gions
%
liste_regions = extract_field(B,'nom') ;
%
% 4. Boucle d'�criture de la nouvelle variable
%
A = struct([]) ; 
for t = 1:length(liste_regions) ;
    % ---> Cr�ation des listes de noeuds :
    Temp = struct([]) ; % ---> Initialise la structure Temp
    for u = 1:length(B(t).tag) ;
        Temp = setfield(Temp,{1,1},Champ,{u,1},...
            str2num(strrep(B(t).tag{u},'Point_',''))) ;
    end
    % ---> Ecriture du champ
    A = setfield(A,{1,1},liste_regions{t},Temp) ;
end
%
% ---> Fin de la fonction
    