function A = RegtyII2tyI(B,option) ;

% ---> Fonction permettant de transformer une d�finition de r�gion de type II
%      en d�finition de type I

% 
% a) Quel est la sous-structure � utiliser ?
% ---> Liste des r�gions :
liste_regions = fields(B) ;
% ---> Liste des sous structures � disposition
liste = fields(getfield(B,liste_regions{1})) ; 
if nargin == 1 ;
    % ---> Par d�faut si elle n'est pas pr�cis�e l'option est la premiere sous structure
    option = liste{1} ;
end
if isempty(find(strcmp(liste,option))) ;
    % ---> L'option choisie n'existe pas : par d�faut nous prendrons la premi�re sous structure
    warning('Option choisie inconnue : S�lection par d�faut') ;
end
% ---> Affichage de l'option
disp(['Option retenue : ',option]) ;
%
% b) Mise en forme Type I
%
for t = 1:length(liste_regions) ;
    % ---> Nom de la r�gion :
    Temp(t).nom = liste_regions{t} ;
    % ---> Tag de la r�gion :
    U = getfield(B,liste_regions{t}) ; 
    U = getfield(U,option) ; % ---> liste num�rique
    for k = 1:length(U) ;
        Temp(t).tag{k,1} = num2str(U(k)) ;
    end
end
A = Temp ;
%
% ---> Fin de la fonction